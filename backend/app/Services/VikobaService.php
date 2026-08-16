<?php

namespace App\Services;

use App\Models\Group;
use App\Models\Loan;
use App\Models\LoanProduct;
use App\Models\LoanRepayment;
use App\Models\LoanSchedule;
use App\Models\Member;
use App\Models\Penalty;
use DateTimeInterface;
use Illuminate\Support\Facades\DB;

/**
 * Server-side money rules.
 *
 * THIS is the authoritative implementation. The Flutter app carries a mirror
 * (lib/core/domain/vizoba_calc.dart) purely for fast UI feedback; every
 * calculation involving money is re-done here and the numbers stored in the
 * database are the ones produced by this service — never client input.
 *
 * Conventions:
 *  - All amounts are WHOLE SHILLINGS stored as PHP integers (TZS has no
 *    fractional unit; floats would drift on audit trails).
 *  - A loan has a product (rate, method, term cap, penalty rules). Interest
 *    is charged per installment period (default monthly):
 *      flat    -> total interest = principal x (rate/100) x term, split evenly
 *      reducing-> declining-balance EMI, interest on the running balance
 *  - Late-payment penalties accrue into `penalty_accrued` and are paid in
 *    the waterfall BEFORE interest and principal.
 */
final class VikobaService
{
    public const MIN_LOAN = 20000;

    // ---------------------------------------------------------------------------
    // Interest / amortization
    // ---------------------------------------------------------------------------

    /**
     * Legacy single-cycle interest: principal * rate / 100.
     */
    public static function interestAmount(int $principal, float $ratePercent): int
    {
        return (int) round($principal * ($ratePercent / 100));
    }

    public static function totalPayable(int $principal, float $ratePercent): int
    {
        return $principal + self::interestAmount($principal, $ratePercent);
    }

    /**
     * Installment-by-installment amortization for a whole term.
     *
     * @return list<array{no: int, principal: int, interest: int, total: int, balance_after: int}>
     *                                                                                             The rows always sum to exactly `$principal` in principal, so the
     *                                                                                             stored schedule can never drift from the cash ledger.
     */
    public static function amortize(
        int $principal,
        float $ratePercent,
        int $termMonths,
        string $method = LoanProduct::METHOD_FLAT,
    ): array {
        $termMonths = max(1, $termMonths);
        $rows = [];
        $balance = $principal;

        if ($method === LoanProduct::METHOD_REDUCING) {
            $r = $ratePercent / 100;
            $emi = $r > 0
                ? (int) round($principal * $r * ((1 + $r) ** $termMonths) / (((1 + $r) ** $termMonths) - 1))
                : (int) round($principal / $termMonths);

            for ($i = 1; $i <= $termMonths; $i++) {
                $interest = $r > 0 ? (int) round($balance * $r) : 0;
                if ($i === $termMonths) {
                    $principalPart = $balance; // last installment absorbs rounding drift
                } else {
                    $remaining = $termMonths - $i + 1;
                    $floor = (int) floor($balance / $remaining); // never stall on high rates
                    $principalPart = max(min($emi - $interest, $balance), $floor, 0);
                }
                $rows[] = [
                    'no' => $i,
                    'principal' => $principalPart,
                    'interest' => $interest,
                    'total' => $principalPart + $interest,
                    'balance_after' => $balance - $principalPart,
                ];
                $balance -= $principalPart;
            }

            return $rows;
        }

        // Flat rate: interest is principal x rate% x term, split evenly across
        // installments with the remainder (of both principal and interest)
        // distributed one shilling at a time to the earliest rows.
        $totalInterest = (int) round($principal * ($ratePercent / 100) * $termMonths);
        $basePrincipal = (int) floor($principal / $termMonths);
        $baseInterest = (int) floor($totalInterest / $termMonths);
        $principalRemainder = $principal - $basePrincipal * $termMonths;
        $interestRemainder = $totalInterest - $baseInterest * $termMonths;
        $runningPrincipal = 0;
        $runningInterest = 0;

        for ($i = 1; $i <= $termMonths; $i++) {
            $p = $basePrincipal + ($i <= $principalRemainder ? 1 : 0);
            $int = $baseInterest + ($i <= $interestRemainder ? 1 : 0);
            if ($i === $termMonths) {
                $p = $principal - $runningPrincipal;
                $int = $totalInterest - $runningInterest;
            }
            $runningPrincipal += $p;
            $runningInterest += $int;
            $rows[] = [
                'no' => $i,
                'principal' => $p,
                'interest' => $int,
                'total' => $p + $int,
                'balance_after' => $balance - $p,
            ];
            $balance -= $p;
        }

        return $rows;
    }

    /**
     * A full loan quote: the amortization schedule plus the derived totals a
     * request form shows live before submission. Centralised here so the
     * client can never supply its own numbers.
     *
     * @return array{schedule: array, total_interest: int, total_payable: int, monthly_installment: int, interest_method: string}
     */
    public static function quote(LoanProduct $product, int $principal, int $termMonths): array
    {
        $rows = self::amortize($principal, (float) $product->interest_rate, $termMonths, $product->interest_method);
        $totalInterest = array_sum(array_column($rows, 'interest'));

        return [
            'schedule' => $rows,
            'total_interest' => $totalInterest,
            'total_payable' => $principal + $totalInterest,
            'monthly_installment' => $rows[0]['total'] ?? 0,
            'interest_method' => $product->interest_method,
        ];
    }

    /**
     * Persist the amortization schedule rows for a loan, dating from $start
     * (disbursement). Clears any previously-generated rows first so re-issue
     * is safe.
     */
    public static function generateSchedule(Loan $loan, DateTimeInterface $start): void
    {
        $rows = self::amortize(
            $loan->principal,
            (float) $loan->interest_rate,
            $loan->term_months,
            $loan->interest_method,
        );
        $interval = max(1, $loan->installment_interval_days);

        $loan->schedules()->delete();
        foreach ($rows as $row) {
            $loan->schedules()->create([
                'installment_no' => $row['no'],
                'due_date' => $start->modify("+{$row['no']} {$interval} days"),
                'principal_due' => $row['principal'],
                'interest_due' => $row['interest'],
                'total_due' => $row['total'],
                'status' => LoanSchedule::STATUS_PENDING,
            ]);
        }
    }

    // ---------------------------------------------------------------------------
    // Penalties
    // ---------------------------------------------------------------------------

    /**
     * Penalties that SHOULD have accrued as of $asOf, per the loan product's
     * penalty rules (flat TZS or % of outstanding, per completed period after
     * the grace period). Purely a computation — does not write.
     */
    public static function accruedPenalty(Loan $loan, ?DateTimeInterface $asOf = null): int
    {
        if ($loan->status !== Loan::STATUS_ACTIVE || $loan->due_date === null) {
            return 0;
        }
        $asOf = $asOf ?? now();
        if ($asOf <= $loan->due_date) {
            return 0;
        }

        $product = $loan->product;
        $grace = $product?->penalty_grace_days ?? 0;
        $period = max(1, $product?->penalty_period_days ?? 7);
        $type = $product?->penalty_type ?? Penalty::TYPE_FLAT;
        $value = (int) ($product?->penalty_value ?? 0);
        if ($value <= 0) {
            return 0;
        }

        $daysLate = (int) floor($loan->due_date->diffInDays($asOf));
        if ($daysLate <= 0) {
            return 0;
        }

        $daysAfterGrace = $daysLate - $grace;
        if ($daysAfterGrace <= 0) {
            return 0;
        }

        $charges = (int) ceil($daysAfterGrace / $period);
        $perCharge = $type === Penalty::TYPE_PERCENT
            ? (int) round($loan->outstanding * ($value / 100))
            : $value;

        return $charges * $perCharge;
    }

    /**
     * Bring `penalty_accrued` up to date with what the rules now demand and
     * write one `penalties` ledger row per newly-covered period. Returns the
     * amount added (0 when nothing new). Idempotent — safe to call daily.
     */
    public static function syncPenalties(Loan $loan, ?DateTimeInterface $asOf = null): int
    {
        if ($loan->status !== Loan::STATUS_ACTIVE || $loan->due_date === null) {
            return 0;
        }
        $asOf = $asOf ?? now();
        $product = $loan->product;
        $grace = $product?->penalty_grace_days ?? 0;
        $period = max(1, $product?->penalty_period_days ?? 7);
        $type = $product?->penalty_type ?? Penalty::TYPE_FLAT;
        $value = (int) ($product?->penalty_value ?? 0);
        if ($value <= 0) {
            return 0;
        }

        $daysLate = (int) floor($loan->due_date->diffInDays($asOf));
        if ($daysLate <= 0) {
            return 0;
        }
        $daysAfterGrace = $daysLate - $grace;
        if ($daysAfterGrace <= 0) {
            return 0;
        }
        $chargesDue = (int) ceil($daysAfterGrace / $period);
        $covered = $loan->penalties()->where('status', Penalty::STATUS_PENDING)->count();
        if ($chargesDue <= $covered) {
            return 0;
        }

        $newly = 0;
        DB::transaction(function () use ($loan, $type, $value, $chargesDue, $covered, $grace, $period, &$newly) {
            for ($c = $covered; $c < $chargesDue; $c++) {
                $charge = $type === Penalty::TYPE_PERCENT
                    ? (int) round($loan->outstanding * ($value / 100))
                    : $value;
                $loan->penalties()->create([
                    'group_id' => $loan->group_id,
                    'member_id' => $loan->member_id,
                    'type' => $type,
                    'amount' => $charge,
                    'applied_for_date' => $loan->due_date->copy()->addDays($grace + $c * $period),
                    'reason' => 'Late payment — penalty period '.($c + 1),
                    'status' => Penalty::STATUS_PENDING,
                ]);
                $newly += $charge;
            }
            $loan->increment('penalty_accrued', $newly);
        });

        if ($newly > 0) {
            AuditService::log('loan', $loan->id, 'penalty.accrue',
                new: ['added' => $newly, 'total' => $loan->fresh()->penalty_accrued]);
        }

        return $newly;
    }

    // ---------------------------------------------------------------------------
    // Repayment waterfall
    // ---------------------------------------------------------------------------

    /**
     * Apply a cash payment to a loan in the constitution order: accrued
     * penalties first, then interest, then principal — walking the amortized
     * schedule installment by installment. Overpayment is returned, never
     * silently credited.
     *
     * @return array{repayment: LoanRepayment, overpayment: int}
     */
    public static function repay(Loan $loan, int $amount, int $recordedBy, ?string $recordedAt = null): array
    {
        self::syncPenalties($loan);
        $loan->refresh();

        $applied = min($amount, max(0, $loan->balance));
        $overpayment = $amount - $applied;
        $penaltyPaid = min($applied, (int) $loan->penalty_accrued);
        $remaining = $applied - $penaltyPaid;
        $interestPaid = 0;
        $principalPaid = 0;

        $repayment = DB::transaction(function () use (
            $loan, $applied, $penaltyPaid, $remaining, $recordedBy, $recordedAt, &$interestPaid, &$principalPaid
        ) {
            $schedules = $loan->schedules()->orderBy('installment_no')->get();

            if ($schedules->isEmpty()) {
                // Legacy pre-schedule loan: treat as a single installment.
                $interestPaid = min($remaining, max(0, (int) $loan->interest_amount));
                $principalPaid = $remaining - $interestPaid;
            } else {
                foreach ($schedules as $schedule) {
                    if ($remaining <= 0) {
                        break;
                    }
                    $interestLeft = (int) $schedule->interest_due - (int) $schedule->paid_interest;
                    if ($interestLeft > 0) {
                        $pay = min($remaining, $interestLeft);
                        $schedule->increment('paid_interest', $pay);
                        $interestPaid += $pay;
                        $remaining -= $pay;
                    }
                    $principalLeft = (int) $schedule->principal_due - (int) $schedule->paid_principal;
                    if ($principalLeft > 0) {
                        $pay = min($remaining, $principalLeft);
                        $schedule->increment('paid_principal', $pay);
                        $principalPaid += $pay;
                        $remaining -= $pay;
                    }
                    if ($schedule->paid_interest >= $schedule->interest_due
                        && $schedule->paid_principal >= $schedule->principal_due) {
                        $schedule->update(['status' => LoanSchedule::STATUS_PAID]);
                    }
                }
            }

            $repayment = $loan->repayments()->create([
                'group_id' => $loan->group_id,
                'recorded_by' => $recordedBy,
                'amount' => $applied,
                'principal_paid' => $principalPaid,
                'interest_paid' => $interestPaid,
                'penalty_paid' => $penaltyPaid,
                'recorded_at' => $recordedAt ?? now(),
            ]);

            $loan->increment('amount_repaid', $principalPaid + $interestPaid);
            $loan->decrement('penalty_accrued', $penaltyPaid);
            $loan->update(['status' => $loan->isFullyRepaid() ? Loan::STATUS_REPAID : Loan::STATUS_ACTIVE]);

            return $repayment;
        });

        return ['repayment' => $repayment, 'overpayment' => $overpayment];
    }

    // ---------------------------------------------------------------------------
    // Eligibility
    // ---------------------------------------------------------------------------

    /**
     * Loan eligibility, mirroring the group constitution:
     *  - member is active and has belonged at least `min_membership_days`
     *  - at least the product/group minimum
     *  - at most (member savings x multiplier) — product multiplier wins
     *  - term within the product's max
     *  - no other approved/active loan already open for this member
     *
     * @return array{ok: bool, reason: string, max_allowed: int, rules: array}
     */
    public static function loanEligibility(
        Member $member,
        Group $group,
        int $requested,
        iterable $allLoans,
        ?LoanProduct $product = null,
        int $termMonths = 1,
    ): array {
        $multiplier = (int) ($product?->max_multiplier ?? $group->max_loan_multiple ?? 4);
        $minAmount = (int) ($product?->min_amount ?? self::MIN_LOAN);
        $maxTerm = (int) ($product?->max_term_months ?? 12);
        $minMembershipDays = (int) ($group->min_membership_days ?? 30);
        $maxAllowed = $member->total_shares * $member->share_value * $multiplier;

        // Strict `=== false`: the column is NOT NULL default true, so an
        // in-memory null simply means "not refreshed", never "inactive".
        if ($member->is_active === false) {
            return ['ok' => false, 'reason' => 'member_inactive', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
        }

        $membershipDays = $member->joined_date->diffInDays(now());
        if ($membershipDays < $minMembershipDays) {
            return ['ok' => false, 'reason' => 'membership_too_short', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
        }

        if ($requested < $minAmount) {
            return ['ok' => false, 'reason' => 'below_minimum', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
        }

        if ($requested > $maxAllowed) {
            return ['ok' => false, 'reason' => 'exceeds_savings_multiple', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
        }

        if ($termMonths > $maxTerm) {
            return ['ok' => false, 'reason' => 'term_exceeds_max', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
        }

        foreach ($allLoans as $loan) {
            if ($loan->member_id === $member->id
                && in_array($loan->status, [Loan::STATUS_APPROVED, Loan::STATUS_ACTIVE], true)) {
                return ['ok' => false, 'reason' => 'already_owing', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
            }
        }

        return ['ok' => true, 'reason' => 'ok', 'max_allowed' => $maxAllowed, 'rules' => ['min_amount' => $minAmount, 'max_term' => $maxTerm, 'multiplier' => $multiplier]];
    }

    // ---------------------------------------------------------------------------
    // Portfolio-level helpers
    // ---------------------------------------------------------------------------

    /**
     * Interest actually earned by the group: only counted once repaid.
     */
    public static function totalInterestEarned(iterable $loans): int
    {
        $total = 0;
        foreach ($loans as $loan) {
            if ($loan instanceof Loan
                && ($loan->status === Loan::STATUS_REPAID || $loan->amount_repaid > 0)
                && $loan->amount_repaid > $loan->principal) {
                $total += $loan->amount_repaid - $loan->principal;
            }
        }

        return $total;
    }

    public static function totalSavings(iterable $members): int
    {
        $total = 0;
        foreach ($members as $member) {
            $total += $member->total_shares * $member->share_value;
        }

        return $total;
    }

    /**
     * Cycle-end share-out: each member gets their own savings back plus a
     * proportional slice of earned interest weighted by share count.
     *
     * @return array<int, array{member: Member, savings: int, interest_share: int, total_payout: int, share_proportion: float}>
     */
    public static function shareOut(Group $group, iterable $members, int $interestEarned): array
    {
        $totalShares = 0;
        $memberList = iterator_to_array($members, false);
        foreach ($memberList as $m) {
            $totalShares += $m->total_shares;
        }

        if ($totalShares === 0) {
            return [];
        }

        $rows = [];
        foreach ($memberList as $m) {
            $proportion = $m->total_shares / $totalShares;
            $interestShare = (int) round($interestEarned * $proportion);
            $rows[] = [
                'member' => $m,
                'savings' => $m->total_shares * $m->share_value,
                'interest_share' => $interestShare,
                'total_payout' => $m->total_shares * $m->share_value + $interestShare,
                'share_proportion' => round($proportion, 6),
            ];
        }

        usort($rows, fn ($a, $b) => $b['total_payout'] <=> $a['total_payout']);

        return $rows;
    }
}
