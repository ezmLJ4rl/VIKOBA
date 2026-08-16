<?php

namespace Tests\Feature;

use App\Models\Contribution;
use App\Models\Group;
use App\Models\Loan;
use App\Models\LoanProduct;
use App\Models\Member;
use App\Models\User;
use App\Services\VikobaService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LoanApiTest extends TestCase
{
    use RefreshDatabase;

    private Group $group;

    private User $treasurer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->group = Group::create([
            'name' => 'API Group',
            'share_value' => 10000,
            'default_interest_rate' => 10,
            'max_loan_multiple' => 4,
        ]);
        $this->treasurer = User::create([
            'name' => 'Mweka Hazina',
            'email' => 'treasurer@api.test',
            'phone' => '0765432109',
            'password' => bcrypt('password'),
            'role' => User::ROLE_TREASURER,
            'group_id' => $this->group->id,
        ]);
    }

    private function headers(): array
    {
        return ['Authorization' => 'Bearer '.$this->treasurer->createToken('t')->plainTextToken, 'Accept' => 'application/json'];
    }

    private function memberWithSavings(int $shares = 40): Member
    {
        $member = $this->group->members()->create([
            'full_name' => 'Amina Juma',
            'phone' => '0712345678',
            'role' => 'member',
            'joined_date' => now()->subDays(120)->toDateString(),
            'total_shares' => $shares,
            'share_value' => 10000,
        ]);
        Contribution::create([
            'group_id' => $this->group->id,
            'member_id' => $member->id,
            'recorded_by' => $this->treasurer->id,
            'shares' => $shares,
            'share_value' => 10000,
            'amount_total' => $shares * 10000,
            'recorded_at' => now(),
        ]);

        return $member;
    }

    private function product(string $method = 'flat'): LoanProduct
    {
        return $this->group->loanProducts()->create([
            'name' => 'Emergency Loan',
            'interest_rate' => 10,
            'interest_method' => $method,
            'max_term_months' => 6,
            'max_multiplier' => 4,
            'min_amount' => 20000,
            'penalty_type' => 'flat',
            'penalty_value' => 5000,
            'penalty_period_days' => 7,
        ]);
    }

    public function test_quote_returns_schedule_and_eligibility(): void
    {
        $member = $this->memberWithSavings();
        $product = $this->product('reducing');

        $response = $this->postJson('/api/v1/loans/quote', [
            'loan_product_id' => $product->id,
            'member_id' => $member->id,
            'principal' => 100000,
            'term_months' => 3,
        ], $this->headers());

        $response->assertStatus(200);
        $quote = $response->json('quote');
        $this->assertCount(3, $quote['schedule']);
        $this->assertEquals('reducing', $quote['interest_method']);
        $this->assertLessThan(30000, $quote['total_interest']); // reducing < flat
        $this->assertEquals(100000 + $quote['total_interest'], $quote['total_payable']);
        $this->assertTrue($response->json('eligibility.ok'));
    }

    public function test_quote_reports_ineligible_member(): void
    {
        $member = $this->memberWithSavings(shares: 2); // 20k savings -> 80k max
        $product = $this->product();

        $response = $this->postJson('/api/v1/loans/quote', [
            'loan_product_id' => $product->id,
            'member_id' => $member->id,
            'principal' => 900000,
            'term_months' => 3,
        ], $this->headers());

        $response->assertStatus(200);
        $this->assertFalse($response->json('eligibility.ok'));
        $this->assertEquals('exceeds_savings_multiple', $response->json('eligibility.reason'));
    }

    public function test_member_role_cannot_create_loan_product(): void
    {
        $memberUser = User::create([
            'name' => 'Mwanachama',
            'email' => 'member@api.test',
            'phone' => '0754332211',
            'password' => bcrypt('password'),
            'role' => User::ROLE_MEMBER,
            'group_id' => $this->group->id,
        ]);

        $this->postJson('/api/v1/loan-products', [
            'name' => 'Sneaky Loan',
            'interest_rate' => 5,
            'interest_method' => 'flat',
            'max_term_months' => 6,
            'max_multiplier' => 4,
        ], ['Authorization' => 'Bearer '.$memberUser->createToken('t')->plainTextToken, 'Accept' => 'application/json'])
            ->assertStatus(403);
    }

    public function test_loan_request_with_product_creates_schedule_and_guarantors(): void
    {
        $member = $this->memberWithSavings();
        $guarantor = $this->group->members()->create([
            'full_name' => 'Yusuf Hamisi',
            'phone' => '0754332211',
            'role' => 'member',
            'joined_date' => now()->subDays(120)->toDateString(),
            'total_shares' => 30,
            'share_value' => 10000,
        ]);
        $product = $this->product('flat');

        $response = $this->postJson('/api/v1/loans', [
            'member_id' => $member->id,
            'loan_product_id' => $product->id,
            'principal' => 100000,
            'term_months' => 3,
            'guarantor_member_ids' => [$guarantor->id],
        ], $this->headers());

        $response->assertStatus(201);
        $loan = $response->json('loan');
        $this->assertCount(3, $loan['schedules']);
        $this->assertEquals(30000, $loan['interest_amount']);
        $this->assertCount(1, $loan['guarantors']);
        $this->assertDatabaseHas('loan_schedules', ['loan_id' => $loan['id']]);
        $this->assertDatabaseHas('loan_guarantors', ['loan_id' => $loan['id'], 'member_id' => $guarantor->id]);
    }

    public function test_disburse_records_method_and_reissues_dated_schedule(): void
    {
        $member = $this->memberWithSavings();
        $product = $this->product('flat');
        $loan = $this->group->loans()->create([
            'member_id' => $member->id,
            'loan_product_id' => $product->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 2,
            'installment_interval_days' => 30,
            'interest_amount' => 20000,
            'total_payable' => 120000,
            'status' => Loan::STATUS_APPROVED,
        ]);
        VikobaService::generateSchedule($loan, now());

        $response = $this->postJson("/api/v1/loans/{$loan->id}/disburse", ['method' => 'mpesa'], $this->headers());

        $response->assertStatus(200);
        $this->assertEquals(Loan::STATUS_ACTIVE, $response->json('loan.status'));
        $this->assertEquals('mpesa', $response->json('loan.disbursement_method'));
        $this->assertNotNull($response->json('loan.disbursed_at'));
        $this->assertEquals(2, count($response->json('loan.schedules')));
    }

    public function test_penalty_accrual_endpoint_and_waterfall_repayment(): void
    {
        $member = $this->memberWithSavings();
        $product = $this->product('flat');
        $loan = $this->group->loans()->create([
            'member_id' => $member->id,
            'loan_product_id' => $product->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_method' => 'flat',
            'term_months' => 2,
            'installment_interval_days' => 30,
            'interest_amount' => 20000,
            'total_payable' => 120000,
            'status' => Loan::STATUS_ACTIVE,
            'due_date' => now()->subDays(15)->toDateString(),
        ]);
        VikobaService::generateSchedule($loan, now()->subDays(60));

        $accrue = $this->postJson("/api/v1/loans/{$loan->id}/penalties/accrue", [], $this->headers());
        $accrue->assertStatus(200);
        $this->assertEquals(15000, $accrue->json('penalties_added'));

        $repay = $this->postJson("/api/v1/loans/{$loan->id}/repayments", ['amount' => 50000], $this->headers());
        $repay->assertStatus(201);
        $this->assertEquals(15000, $repay->json('repayment.penalty_paid'));
        $this->assertEquals(10000, $repay->json('repayment.interest_paid'));
        $this->assertEquals(25000, $repay->json('repayment.principal_paid'));
        $this->assertEquals(85000, $repay->json('loan.balance'));
    }

    public function test_audit_logs_feed_is_readable(): void
    {
        $member = $this->memberWithSavings();
        $this->postJson('/api/v1/loans', [
            'member_id' => $member->id,
            'loan_product_id' => $this->product()->id,
            'principal' => 60000,
            'term_months' => 1,
        ], $this->headers())->assertStatus(201);

        $this->getJson('/api/v1/audit-logs?entity_type=loan', $this->headers())
            ->assertStatus(200)
            ->assertJsonPath('audit_logs.data.0.action', 'loan.request');
    }
}
