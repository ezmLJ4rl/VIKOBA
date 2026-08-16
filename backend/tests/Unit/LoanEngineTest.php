<?php

namespace Tests\Unit;

use App\Models\Group;
use App\Models\Loan;
use App\Models\LoanProduct;
use App\Models\Member;
use App\Models\User;
use App\Services\VikobaService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoanEngineTest extends TestCase
{
    use RefreshDatabase;

    private Group $group;

    protected function setUp(): void
    {
        parent::setUp();

        $this->group = Group::create([
            'name' => 'Engine Group',
            'share_value' => 10000,
            'default_interest_rate' => 10,
            'max_loan_multiple' => 4,
        ]);
    }

    private function product(string $method = 'flat', float $rate = 10.0): LoanProduct
    {
        return $this->group->loanProducts()->create([
            'name' => 'Test Loan',
            'interest_rate' => $rate,
            'interest_method' => $method,
            'max_term_months' => 6,
            'max_multiplier' => 4,
            'min_amount' => 20000,
            'penalty_type' => 'flat',
            'penalty_value' => 5000,
            'penalty_grace_days' => 0,
            'penalty_period_days' => 7,
        ]);
    }

    private function member(int $shares = 40, int $daysJoined = 120): Member
    {
        return $this->group->members()->create([
            'full_name' => 'Amina Juma',
            'phone' => '0712345678',
            'role' => 'member',
            'joined_date' => now()->subDays($daysJoined)->toDateString(),
            'total_shares' => $shares,
            'share_value' => 10000,
        ]);
    }

    public function test_flat_amortization_sums_exactly(): void
    {
        $rows = VikobaService::amortize(100000, 10.0, 3, 'flat');

        $this->assertCount(3, $rows);
        $this->assertEquals(100000, array_sum(array_column($rows, 'principal')));
        $this->assertEquals(30000, array_sum(array_column($rows, 'interest'))); // 10% x 3 months
        $this->assertEquals(130000, array_sum(array_column($rows, 'total')));
        $this->assertEquals(0, end($rows)['balance_after']);
        // Evenly split with the +1 shilling drift pushed to the earliest rows.
        $this->assertEquals(33334, $rows[0]['principal']);
        $this->assertEquals(33333, $rows[1]['principal']);
        $this->assertEquals(33333, $rows[2]['principal']);
    }

    public function test_single_installment_flat_matches_legacy(): void
    {
        $rows = VikobaService::amortize(100000, 10.0, 1, 'flat');

        $this->assertEquals(10000, $rows[0]['interest']);
        $this->assertEquals(110000, $rows[0]['total']);
    }

    public function test_reducing_amortization_declines_interest_over_principal(): void
    {
        $rows = VikobaService::amortize(100000, 10.0, 3, 'reducing');

        $this->assertCount(3, $rows);
        $this->assertEquals(100000, array_sum(array_column($rows, 'principal')));
        $this->assertEquals(0, end($rows)['balance_after']);
        // Interest declines period over period (10% of a shrinking balance).
        $this->assertGreaterThan($rows[1]['interest'], $rows[0]['interest']);
        $this->assertGreaterThan($rows[2]['interest'], $rows[1]['interest']);
        // Reducing-balance always costs less than flat on the same rate.
        $flatInterest = array_sum(array_column(VikobaService::amortize(100000, 10.0, 3, 'flat'), 'interest'));
        $reducingInterest = array_sum(array_column($rows, 'interest'));
        $this->assertLessThan($flatInterest, $reducingInterest);
    }

    public function test_reducing_zero_rate_is_an_even_principal_split(): void
    {
        $rows = VikobaService::amortize(120000, 0.0, 3, 'reducing');

        $this->assertEquals(40000, $rows[0]['principal']);
        $this->assertEquals(0, $rows[0]['interest']);
        $this->assertEquals(0, end($rows)['balance_after']);
    }

    public function test_quote_matches_amortization_and_exposes_totals(): void
    {
        $quote = VikobaService::quote($this->product('flat', 10), 100000, 3);

        $this->assertEquals(30000, $quote['total_interest']);
        $this->assertEquals(130000, $quote['total_payable']);
        $this->assertCount(3, $quote['schedule']);
        $this->assertEquals('flat', $quote['interest_method']);
    }

    public function test_penalty_accrual_flat_and_percent(): void
    {
        $loan = $this->group->loans()->create([
            'member_id' => $this->member()->id,
            'loan_product_id' => $this->product('flat', 10)->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 1,
            'interest_amount' => 10000,
            'total_payable' => 110000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->subDays(15)->toDateString(),
        ]);

        // 15 days late, grace 0, period 7 -> ceil(15/7) = 3 charges x 5000.
        $this->assertEquals(15000, VikobaService::accruedPenalty($loan));

        $added = VikobaService::syncPenalties($loan);
        $this->assertEquals(15000, $added);
        $this->assertEquals(15000, $loan->fresh()->penalty_accrued);
        $this->assertCount(3, $loan->fresh()->penalties);
        $this->assertEquals(125000, $loan->fresh()->balance);

        // Running again adds nothing.
        $this->assertEquals(0, VikobaService::syncPenalties($loan));
    }

    public function test_penalty_respects_grace_period(): void
    {
        $loan = $this->group->loans()->create([
            'member_id' => $this->member()->id,
            'loan_product_id' => $this->product()->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 1,
            'interest_amount' => 10000,
            'total_payable' => 110000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->subDays(5)->toDateString(),
        ]);
        $loan->product->update(['penalty_grace_days' => 10]);

        $this->assertEquals(0, VikobaService::accruedPenalty($loan));
    }

    public function test_repayment_waterfall_pays_penalties_then_interest_then_principal(): void
    {
        $loan = $this->group->loans()->create([
            'member_id' => $this->member()->id,
            'loan_product_id' => $this->product()->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 2,
            'interest_amount' => 20000,
            'total_payable' => 120000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->subDays(15)->toDateString(),
        ]);
        VikobaService::generateSchedule($loan, $loan->due_date->copy()->subDays(60));
        VikobaService::syncPenalties($loan); // 15000 accrued

        $result = VikobaService::repay($loan, 50000, $this->treasurer()->id);

        $repayment = $result['repayment'];
        $this->assertEquals(0, $result['overpayment']);
        $this->assertEquals(15000, $repayment->penalty_paid);
        // Waterfall walks the schedule in order: first installment's 10k
        // interest, then as much principal as remains (25k into the 50k due).
        $this->assertEquals(10000, $repayment->interest_paid);
        $this->assertEquals(25000, $repayment->principal_paid);

        $fresh = $loan->fresh();
        $this->assertEquals(0, $fresh->penalty_accrued);
        $this->assertEquals(35000, $fresh->amount_repaid);
        $this->assertEquals(85000, $fresh->balance);

        // First schedule has its interest settled and is half-principal paid;
        // the second is untouched.
        $first = $fresh->schedules->first();
        $this->assertEquals(10000, $first->paid_interest);
        $this->assertEquals(25000, $first->paid_principal);
        $this->assertEquals(0, $fresh->schedules->last()->paid_principal);
    }

    public function test_repayment_overpayment_is_returned_not_credited(): void
    {
        $loan = $this->group->loans()->create([
            'member_id' => $this->member()->id,
            'loan_product_id' => $this->product()->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 1,
            'interest_amount' => 10000,
            'total_payable' => 110000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->addDays(30)->toDateString(),
        ]);
        VikobaService::generateSchedule($loan, now()->subDays(1));

        $result = VikobaService::repay($loan, 150000, $this->treasurer()->id);

        $this->assertEquals(40000, $result['overpayment']);
        $this->assertEquals(110000, $result['repayment']->amount);
        $this->assertEquals(Loan::STATUS_REPAID, $loan->fresh()->status);
    }

    public function test_eligibility_uses_product_rules_and_membership(): void
    {
        $product = $this->product('flat', 10);
        $member = $this->member(shares: 10, daysJoined: 5); // too new, low savings

        // Membership too short.
        $check = VikobaService::loanEligibility($member, $this->group, 100000, [], $product, 3);
        $this->assertFalse($check['ok']);
        $this->assertEquals('membership_too_short', $check['reason']);

        // Old enough now, but over the product multiplier (10 shares x 10k x 4 = 400k).
        $member->update(['joined_date' => now()->subDays(120)->toDateString()]);
        $check = VikobaService::loanEligibility($member, $this->group, 500000, [], $product, 3);
        $this->assertFalse($check['ok']);
        $this->assertEquals('exceeds_savings_multiple', $check['reason']);

        // Term exceeds product max.
        $check = VikobaService::loanEligibility($member, $this->group, 100000, [], $product, 12);
        $this->assertFalse($check['ok']);
        $this->assertEquals('term_exceeds_max', $check['reason']);

        // All good.
        $check = VikobaService::loanEligibility($member, $this->group, 100000, [], $product, 3);
        $this->assertTrue($check['ok']);
    }

    public function test_eligibility_blocks_when_already_owing(): void
    {
        $member = $this->member();
        $this->group->loans()->create([
            'member_id' => $member->id,
            'principal' => 50000,
            'interest_rate' => 10,
            'interest_amount' => 5000,
            'total_payable' => 55000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->addDays(30)->toDateString(),
        ]);

        $check = VikobaService::loanEligibility($member, $this->group, 50000, $this->group->loans()->get(), $this->product(), 3);
        $this->assertFalse($check['ok']);
        $this->assertEquals('already_owing', $check['reason']);
    }

    private function treasurer(): User
    {
        return User::create([
            'name' => 'Mweka Hazina',
            'email' => 'treasurer@engine.test',
            'phone' => '0765432109',
            'password' => bcrypt('password'),
            'role' => User::ROLE_TREASURER,
            'group_id' => $this->group->id,
        ]);
    }
}
