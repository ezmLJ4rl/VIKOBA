<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SyncRequest;
use App\Models\Loan;
use App\Models\LoanProduct;
use App\Models\Member;
use App\Services\AuditService;
use App\Services\IdempotencyGuard;
use App\Services\VikobaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Throwable;

/**
 * Offline-sync ingest. The mobile app posts its queued operations in one
 * batch; each is applied idempotently (the SAME key the app used when the
 * action was created offline). Operations that already landed are reported
 * as `duplicated` instead of being applied twice — that is what makes a
 * flaky-network retry safe.
 */
class SyncController extends Controller
{
    public function synchronize(SyncRequest $request): JsonResponse
    {
        $user = auth()->user();
        $group = $user->group;
        $results = [];

        foreach ($request->input('operations', []) as $op) {
            $key = $op['idempotency_key'];
            $results[] = [
                'idempotency_key' => $key,
                'type' => $op['type'],
                'result' => $this->apply($group, $user, $op),
            ];
        }

        return response()->json(['results' => $results]);
    }

    private function apply($group, $user, array $op): array
    {
        $key = $op['idempotency_key'];
        $claim = IdempotencyGuard::claim($key, $group->id, $user->id);
        if ($claim['duplicate']) {
            return ['status' => 'duplicated', 'entity_type' => $claim['entity_type'], 'entity_id' => $claim['entity_id']];
        }

        try {
            return match ($op['type']) {
                'member.create' => $this->applyMemberCreate($group, $user, $op['payload']),
                'contribution.create' => $this->applyContribution($group, $user, $op['payload']),
                'loan.request' => $this->applyLoanRequest($group, $user, $op['payload']),
                'loan.approve' => $this->applyLoanStatus($op['payload'], Loan::STATUS_APPROVED, $group),
                'loan.reject' => $this->applyLoanStatus($op['payload'], Loan::STATUS_REJECTED, $group),
                'loan.disburse' => $this->applyLoanDisburse($op['payload'], $group),
                'repayment.create' => $this->applyRepayment($group, $user, $op['payload']),
                'meeting.create' => $this->applyMeetingCreate($group, $user, $op['payload']),
                default => ['status' => 'unsupported'],
            };
        } catch (Throwable $e) {
            return ['status' => 'failed', 'error' => $e->getMessage()];
        }
    }

    private function applyMemberCreate($group, $user, array $payload): array
    {
        $member = $group->members()->create([
            'full_name' => $payload['fullName'] ?? $payload['full_name'],
            'phone' => $payload['phoneNumber'] ?? $payload['phone'],
            'role' => $payload['role'] ?? 'member',
            'joined_date' => $payload['joinedDate'] ?? now()->toDateString(),
            'total_shares' => $payload['totalShares'] ?? 0,
            'share_value' => $group->share_value,
        ]);
        AuditService::log('member', $member->id, 'member.create', new: $member->toArray());

        return ['status' => 'ok', 'entity_type' => 'member', 'entity_id' => $member->id];
    }

    private function applyContribution($group, $user, array $payload): array
    {
        $member = $this->resolveMember($group, $payload);
        $shares = (int) ($payload['sharesBought'] ?? $payload['shares']);

        $contribution = DB::transaction(function () use ($group, $member, $shares, $user) {
            $c = $group->contributions()->create([
                'member_id' => $member->id,
                'recorded_by' => $user->id,
                'shares' => $shares,
                'share_value' => $group->share_value,
                'amount_total' => $shares * $group->share_value,
                'recorded_at' => now(),
            ]);
            $member->increment('total_shares', $shares);

            return $c;
        });

        AuditService::log('contribution', $contribution->id, 'contribution.create', new: $contribution->toArray());

        return ['status' => 'ok', 'entity_type' => 'contribution', 'entity_id' => $contribution->id];
    }

    private function applyLoanRequest($group, $user, array $payload): array
    {
        $member = $this->resolveMember($group, $payload);
        $principal = (int) ($payload['principal'] ?? 0);

        $product = isset($payload['loanProductId'])
            ? $group->loanProducts()->find((int) $payload['loanProductId'])
            : null;
        $termMonths = max(1, (int) ($payload['termMonths'] ?? 1));
        $rate = (float) ($product?->interest_rate ?? $group->default_interest_rate);
        $method = $product?->interest_method ?? $group->interest_method ?? LoanProduct::METHOD_FLAT;
        $intervalDays = $product?->installment_interval_days ?? 30;

        $eligibility = VikobaService::loanEligibility($member, $group, $principal, $group->loans()->get(), $product, $termMonths);
        if (! $eligibility['ok']) {
            return ['status' => 'rejected_by_rules', 'reason' => $eligibility['reason']];
        }

        $scheduleRows = VikobaService::amortize($principal, $rate, $termMonths, $method);
        $interestAmount = array_sum(array_column($scheduleRows, 'interest'));

        $loan = $group->loans()->create([
            'member_id' => $member->id,
            'loan_product_id' => $product?->id,
            'requested_by' => $user->id,
            'principal' => $principal,
            'interest_rate' => $rate,
            'interest_method' => $method,
            'term_months' => $termMonths,
            'installment_interval_days' => $intervalDays,
            'interest_amount' => $interestAmount,
            'total_payable' => $principal + $interestAmount,
            'amount_repaid' => 0,
            'penalty_accrued' => 0,
            'status' => Loan::STATUS_PENDING,
            'due_date' => now()->addDays($intervalDays * $termMonths)->toDateString(),
        ]);
        VikobaService::generateSchedule($loan, now());

        foreach (array_slice($payload['guarantorMemberIds'] ?? [], 0, 2) as $guarantorId) {
            if (ctype_digit((string) $guarantorId)) {
                $loan->guarantors()->firstOrCreate(['member_id' => (int) $guarantorId]);
            }
        }

        return ['status' => 'ok', 'entity_type' => 'loan', 'entity_id' => $loan->id];
    }

    private function applyLoanStatus(array $payload, string $status, $group): array
    {
        if (! in_array($status, [Loan::STATUS_APPROVED, Loan::STATUS_REJECTED], true)
            || $this->resolveLoan($group, $payload)->status !== Loan::STATUS_PENDING) {
            return ['status' => 'skipped', 'entity_type' => 'loan'];
        }

        $loan = $this->resolveLoan($group, $payload);
        $loan->update(['status' => $status, 'decided_by' => auth()->id()]);

        return ['status' => 'ok', 'entity_type' => 'loan', 'entity_id' => $loan->id];
    }

    private function applyLoanDisburse(array $payload, $group): array
    {
        $loan = $this->resolveLoan($group, $payload);
        if ($loan->status === Loan::STATUS_APPROVED) {
            $method = $payload['method'] ?? null;
            if ($method !== null && ! in_array($method, ['cash', 'mpesa', 'bank'], true)) {
                $method = null;
            }
            $disbursedAt = now();
            VikobaService::generateSchedule($loan, $disbursedAt);
            $loan->update([
                'status' => Loan::STATUS_ACTIVE,
                'issued_at' => $disbursedAt,
                'disbursed_at' => $disbursedAt,
                'disbursement_method' => $method,
                'due_date' => $loan->schedules()->max('due_date'),
            ]);
        }

        return ['status' => 'ok', 'entity_type' => 'loan', 'entity_id' => $loan->id];
    }

    private function applyRepayment($group, $user, array $payload): array
    {
        $loan = $this->resolveLoan($group, $payload);
        $amount = (int) ($payload['amountRepaid'] ?? $payload['amount']);

        $result = VikobaService::repay($loan, $amount, $user->id);

        AuditService::log('loan', $loan->id, 'repayment.create', new: $result['repayment']->fresh()->toArray());

        return ['status' => 'ok', 'entity_type' => 'repayment', 'entity_id' => $result['repayment']->id];
    }

    private function applyMeetingCreate($group, $user, array $payload): array
    {
        $meeting = $group->meetings()->create([
            'created_by' => $user->id,
            'held_at' => $payload['date'] ?? now(),
            'agenda' => $payload['agenda'] ?? 'Meeting',
            'minutes' => $payload['minutes'] ?? null,
        ]);
        foreach (($payload['presentMemberIds'] ?? []) as $memberId) {
            $meeting->attendance()->create(['member_id' => $memberId, 'present' => true]);
        }

        return ['status' => 'ok', 'entity_type' => 'meeting', 'entity_id' => $meeting->id];
    }

    /**
     * Members referenced by an offline payload may arrive with a numeric
     * server id OR with the Flutter demo id (e.g. "MEM1") — in the latter
     * case we resolve by phone number, which is unique and identical across
     * both seed datasets.
     */
    private function resolveMember($group, array $payload): Member
    {
        $byId = $payload['memberId'] ?? $payload['member_id'] ?? null;
        if ($byId !== null && ctype_digit((string) $byId)) {
            return $group->members()->findOrFail((int) $byId);
        }

        $phone = $payload['phoneNumber'] ?? $payload['phone'] ?? null;
        if ($phone !== null) {
            return $group->members()->where('phone', $phone)->firstOrFail();
        }

        throw new \InvalidArgumentException('Payload carries no member identity.');
    }

    /**
     * Loans referenced by lifecycle ops (approve/disburse/repay). Numeric ids
     * win; otherwise match by member + principal, newest first.
     */
    private function resolveLoan($group, array $payload): Loan
    {
        $byId = $payload['id'] ?? $payload['loanId'] ?? null;
        if ($byId !== null && ctype_digit((string) $byId)) {
            return $group->loans()->findOrFail((int) $byId);
        }

        $member = $this->resolveMember($group, $payload);

        return $group->loans()
            ->where('member_id', $member->id)
            ->where('principal', (int) ($payload['principal'] ?? 0))
            ->latest('id')
            ->firstOrFail();
    }
}
