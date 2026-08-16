<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoanQuoteRequest;
use App\Http\Requests\RecordRepaymentRequest;
use App\Http\Requests\StoreLoanRequest;
use App\Models\Loan;
use App\Models\LoanProduct;
use App\Models\LoanRepayment;
use App\Services\AuditService;
use App\Services\IdempotencyGuard;
use App\Services\VikobaService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LoanController extends Controller
{
    private const DISBURSEMENT_METHODS = ['cash', 'mpesa', 'bank'];

    private const WITH_RELATIONS = [
        'member:id,id,full_name,phone',
        'product:id,id,name',
        'schedules',
        'guarantors.member:id,id,full_name,phone',
        'repayments.recorder:id,id,name',
    ];

    public function index(Request $request): JsonResponse
    {
        $query = auth()->user()->group
            ->loans()
            ->with('member:id,id,full_name', 'product:id,id,name')
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->input('status')))
            ->when($request->filled('member_id'), fn ($q) => $q->where('member_id', $request->integer('member_id')));

        return response()->json([
            'loans' => $query->orderByDesc('created_at')->paginate($request->integer('per_page', 25)),
        ]);
    }

    public function show(Loan $loan): JsonResponse
    {
        abort_unless($loan->group_id === auth()->user()->group_id, 403, 'Not your group.');

        VikobaService::syncPenalties($loan);

        return response()->json(['loan' => $loan->fresh()->load(self::WITH_RELATIONS)]);
    }

    /**
     * Server-side loan quote: principal + rate + term -> full amortization
     * schedule with totals, plus the eligibility verdict for that member.
     * The request form renders this verbatim.
     */
    public function quote(LoanQuoteRequest $request): JsonResponse
    {
        $group = auth()->user()->group;
        $product = $group->loanProducts()->findOrFail($request->integer('loan_product_id'));
        $member = $group->members()->findOrFail($request->integer('member_id'));
        $principal = $request->integer('principal');
        $termMonths = $request->integer('term_months');

        $eligibility = VikobaService::loanEligibility(
            $member,
            $group,
            $principal,
            $group->loans()->get(),
            $product,
            $termMonths,
        );

        return response()->json([
            'quote' => VikobaService::quote($product, $principal, $termMonths),
            'eligibility' => $eligibility,
        ]);
    }

    /**
     * Core money rule: eligibility + interest are computed here and the
     * produced numbers are stored. The client's preview is ignored for
     * amounts — we always recompute via the loan product's rules.
     */
    public function store(StoreLoanRequest $request): JsonResponse
    {
        $user = auth()->user();
        $group = $user->group;
        $member = $group->members()->findOrFail($request->integer('member_id'));
        $principal = $request->integer('principal');

        $idempotencyKey = $request->input('idempotency_key');
        if ($idempotencyKey) {
            $claim = IdempotencyGuard::claim($idempotencyKey, $group->id, $user->id);
            if ($claim['duplicate']) {
                return response()->json(['duplicated' => true, 'loan' => Loan::find($claim['entity_id'])], 200);
            }
        }

        $product = $request->filled('loan_product_id')
            ? $group->loanProducts()->findOrFail($request->integer('loan_product_id'))
            : null;
        $termMonths = max(1, $request->integer('term_months', 1));
        $rate = (float) ($product?->interest_rate ?? $group->default_interest_rate);
        $method = $product?->interest_method ?? $group->interest_method ?? LoanProduct::METHOD_FLAT;
        $intervalDays = $product?->installment_interval_days ?? 30;

        $eligibility = VikobaService::loanEligibility(
            $member,
            $group,
            $principal,
            $group->loans()->get(),
            $product,
            $termMonths,
        );

        if (! $eligibility['ok']) {
            return response()->json([
                'message' => 'Loan request rejected by group rules.',
                'reason' => $eligibility['reason'],
                'max_allowed' => $eligibility['max_allowed'],
            ], 422);
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
            'idempotency_key' => $idempotencyKey,
            'note' => $request->input('note'),
        ]);

        // Preview schedule (dates shift to the real disbursement on disburse()).
        VikobaService::generateSchedule($loan, now());

        $guarantors = array_slice($request->input('guarantor_member_ids', []), 0, 2);
        foreach ($guarantors as $guarantorId) {
            $guarantor = $group->members()->whereKey($guarantorId)->where('id', '!=', $member->id)->first();
            if ($guarantor !== null) {
                $loan->guarantors()->create(['member_id' => $guarantor->id, 'confirmed' => false]);
            }
        }

        if ($idempotencyKey) {
            IdempotencyGuard::mark($idempotencyKey, $group->id, 'loan', $loan->id);
        }

        AuditService::log('loan', $loan->id, 'loan.request', new: $loan->toArray());

        return response()->json(['loan' => $loan->load('guarantors', 'schedules')], 201);
    }

    public function approve(Loan $loan): JsonResponse
    {
        $this->authorizeDecision($loan);
        $loan->update(['status' => Loan::STATUS_APPROVED, 'decided_by' => auth()->id()]);
        $loan->guarantors()->update(['confirmed' => true]);
        AuditService::log('loan', $loan->id, 'loan.approve', new: $loan->fresh()->toArray());

        return response()->json(['loan' => $loan->fresh()->load(self::WITH_RELATIONS)]);
    }

    public function reject(Loan $loan): JsonResponse
    {
        $this->authorizeDecision($loan);
        $loan->update(['status' => Loan::STATUS_REJECTED, 'decided_by' => auth()->id()]);
        AuditService::log('loan', $loan->id, 'loan.reject', new: $loan->fresh()->toArray());

        return response()->json(['loan' => $loan->fresh()->load(self::WITH_RELATIONS)]);
    }

    /**
     * Approved -> active. Regenerates the amortization schedule dated from the
     * actual disbursement so due dates are real, records the cash/M-Pesa
     * method, and arms the penalty clock from the last installment date.
     */
    public function disburse(Loan $loan, Request $request): JsonResponse
    {
        $this->authorizeDecision($loan);
        if ($loan->status !== Loan::STATUS_APPROVED) {
            return response()->json(['message' => 'Loan is not approved yet.'], 422);
        }

        $method = $request->input('method');
        if ($method !== null && ! in_array($method, self::DISBURSEMENT_METHODS, true)) {
            return response()->json(['message' => 'method must be one of cash, mpesa, bank.'], 422);
        }
        $disbursedAt = $request->input('disbursed_at')
            ? Carbon::parse($request->input('disbursed_at'))
            : now();

        VikobaService::generateSchedule($loan, $disbursedAt);

        $loan->update([
            'status' => Loan::STATUS_ACTIVE,
            'issued_at' => $disbursedAt,
            'disbursed_at' => $disbursedAt,
            'disbursement_method' => $method,
            'due_date' => $loan->schedules()->max('due_date'),
        ]);

        AuditService::log('loan', $loan->id, 'loan.disburse', new: $loan->fresh()->toArray());

        return response()->json(['loan' => $loan->fresh()->load(self::WITH_RELATIONS)]);
    }

    /**
     * Records a repayment. The waterfall split (penalty -> interest ->
     * principal, per the amortized schedule) is computed by the engine, never
     * guessed by the client.
     */
    public function repay(Loan $loan, RecordRepaymentRequest $request): JsonResponse
    {
        abort_unless($loan->group_id === auth()->user()->group_id, 403, 'Not your group.');

        $user = auth()->user();
        $idempotencyKey = $request->input('idempotency_key');
        if ($idempotencyKey) {
            $claim = IdempotencyGuard::claim($idempotencyKey, $loan->group_id, $user->id);
            if ($claim['duplicate']) {
                return response()->json(['duplicated' => true, 'repayment' => LoanRepayment::find($claim['entity_id'])], 200);
            }
        }

        $result = VikobaService::repay(
            $loan,
            $request->integer('amount'),
            $user->id,
            $request->input('recorded_at'),
        );

        if ($idempotencyKey) {
            IdempotencyGuard::mark($idempotencyKey, $loan->group_id, 'repayment', $result['repayment']->id);
        }

        AuditService::log('loan', $loan->id, 'repayment.create', new: $result['repayment']->toArray());

        return response()->json([
            'repayment' => $result['repayment'],
            'overpayment' => $result['overpayment'],
            'loan' => $loan->fresh()->load(self::WITH_RELATIONS),
        ], 201);
    }

    /** Brings a loan's late-payment penalties up to date with today's date. */
    public function accruePenalties(Loan $loan): JsonResponse
    {
        $this->authorizeDecision($loan);
        $added = VikobaService::syncPenalties($loan);

        return response()->json([
            'penalties_added' => $added,
            'loan' => $loan->fresh()->load(self::WITH_RELATIONS),
        ]);
    }

    /** A loan's penalty ledger (each charge, its status and waiver info). */
    public function penalties(Loan $loan): JsonResponse
    {
        abort_unless($loan->group_id === auth()->user()->group_id, 403, 'Not your group.');

        VikobaService::syncPenalties($loan);

        return response()->json(['penalties' => $loan->fresh()->penalties()->orderByDesc('applied_for_date')->get()]);
    }

    private function authorizeDecision(Loan $loan): void
    {
        abort_unless($loan->group_id === auth()->user()->group_id, 403, 'Not your group.');
        abort_unless(auth()->user()->canAuthorizeFinance(), 403, 'Only the treasurer, chairperson or admin may decide loans.');
    }
}
