<?php

namespace Tests\Feature;

use App\Models\Contribution;
use App\Models\Group;
use App\Models\Loan;
use App\Models\Member;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VikobaApiTest extends TestCase
{
    use RefreshDatabase;

    private Group $group;

    private User $treasurer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->group = Group::create([
            'name' => 'Test Group',
            'share_value' => 10000,
            'default_interest_rate' => 10,
            'max_loan_multiple' => 4,
        ]);

        $this->treasurer = User::create([
            'name' => 'Elisha Mgeni',
            'email' => 'treasurer@test.test',
            'phone' => '0765432109',
            'password' => bcrypt('password'),
            'role' => User::ROLE_TREASURER,
            'group_id' => $this->group->id,
        ]);
    }

    private function memberUser(): User
    {
        return User::create([
            'name' => 'Yusuf Hamisi',
            'email' => 'member@test.test',
            'phone' => '0754332211',
            'password' => bcrypt('password'),
            'role' => User::ROLE_MEMBER,
            'group_id' => $this->group->id,
        ]);
    }

    private function authHeaders(User $user): array
    {
        $token = $user->createToken('test')->plainTextToken;

        return ['Authorization' => "Bearer {$token}", 'Accept' => 'application/json'];
    }

    public function test_unauthenticated_requests_are_rejected(): void
    {
        $this->getJson('/api/v1/members')->assertStatus(401);
    }

    public function test_login_returns_a_token(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'treasurer@test.test',
            'password' => 'password',
        ]);

        $response->assertStatus(201)->assertJsonStructure(['token', 'user']);
    }

    public function test_treasurer_can_create_a_member(): void
    {
        $response = $this->postJson('/api/v1/members', [
            'full_name' => 'Neema Paulo',
            'phone' => '0722223333',
            'role' => 'member',
        ], $this->authHeaders($this->treasurer));

        $response->assertStatus(201);
        $this->assertDatabaseHas('members', ['full_name' => 'Neema Paulo']);
    }

    public function test_member_role_cannot_create_a_member(): void
    {
        $memberUser = $this->memberUser();

        $response = $this->postJson('/api/v1/members', [
            'full_name' => 'Sneaky Member',
            'phone' => '0722224444',
            'role' => 'member',
        ], $this->authHeaders($memberUser));

        $response->assertStatus(403);
        $this->assertDatabaseMissing('members', ['full_name' => 'Sneaky Member']);
    }

    public function test_member_can_request_a_loan_but_not_approve_it(): void
    {
        $memberUser = $this->memberUser();
        $member = $this->group->members()->create([
            'full_name' => 'Yusuf Hamisi',
            'phone' => '0754332211',
            'role' => 'member',
            'joined_date' => now()->subDays(90),
            'total_shares' => 12,
            'share_value' => 10000,
        ]);
        Contribution::create([
            'group_id' => $this->group->id,
            'member_id' => $member->id,
            'recorded_by' => $this->treasurer->id,
            'shares' => 12,
            'share_value' => 10000,
            'amount_total' => 120000,
            'recorded_at' => now(),
        ]);

        $headers = $this->authHeaders($memberUser);
        $request = $this->postJson('/api/v1/loans', [
            'member_id' => $member->id,
            'principal' => 60000,
            'repayment_days' => 60,
        ], $headers);

        $request->assertStatus(201);
        $loanId = $request->json('loan.id');
        $this->assertEquals(Loan::STATUS_PENDING, Loan::find($loanId)->status);

        $this->postJson("/api/v1/loans/{$loanId}/approve", [], $headers)
            ->assertStatus(403);
    }

    public function test_treasurer_approves_disburses_and_repays_a_loan(): void
    {
        $member = $this->group->members()->create([
            'full_name' => 'Amina Juma',
            'phone' => '0712345678',
            'role' => 'chairperson',
            'joined_date' => now()->subDays(90),
            'total_shares' => 24,
            'share_value' => 10000,
        ]);
        Contribution::create([
            'group_id' => $this->group->id,
            'member_id' => $member->id,
            'recorded_by' => $this->treasurer->id,
            'shares' => 24,
            'share_value' => 10000,
            'amount_total' => 240000,
            'recorded_at' => now(),
        ]);
        $loan = $this->group->loans()->create([
            'member_id' => $member->id,
            'requested_by' => $this->treasurer->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_amount' => 10000,
            'total_payable' => 110000,
            'amount_repaid' => 0,
            'status' => Loan::STATUS_PENDING,
            'due_date' => now()->addDays(60)->toDateString(),
        ]);

        $headers = $this->authHeaders($this->treasurer);

        $this->postJson("/api/v1/loans/{$loan->id}/approve", [], $headers)
            ->assertStatus(200)
            ->assertJsonPath('loan.status', Loan::STATUS_APPROVED);

        $this->postJson("/api/v1/loans/{$loan->id}/disburse", [], $headers)
            ->assertStatus(200)
            ->assertJsonPath('loan.status', Loan::STATUS_ACTIVE);

        $this->postJson("/api/v1/loans/{$loan->id}/repayments", ['amount' => 110000], $headers)
            ->assertStatus(201)
            ->assertJsonPath('loan.status', Loan::STATUS_REPAID);
    }

    public function test_loan_request_beyond_eligibility_is_rejected(): void
    {
        $member = $this->group->members()->create([
            'full_name' => 'Amina Juma',
            'phone' => '0712345678',
            'role' => 'chairperson',
            'joined_date' => now()->subDays(90),
            'total_shares' => 4,
            'share_value' => 10000,
        ]);
        Contribution::create([
            'group_id' => $this->group->id,
            'member_id' => $member->id,
            'recorded_by' => $this->treasurer->id,
            'shares' => 4,
            'share_value' => 10000,
            'amount_total' => 40000,
            'recorded_at' => now(),
        ]);

        $this->postJson('/api/v1/loans', [
            'member_id' => $member->id,
            'principal' => 900000, // far beyond max multiple
            'repayment_days' => 60,
        ], $this->authHeaders($this->treasurer))
            ->assertStatus(422);
    }

    public function test_sync_accepts_offline_payloads_with_demo_phone_references(): void
    {
        $member = $this->group->members()->create([
            'full_name' => 'Amina Juma',
            'phone' => '0712345678',
            'role' => 'chairperson',
            'joined_date' => now()->subDays(90),
            'total_shares' => 24,
            'share_value' => 10000,
        ]);

        $headers = $this->authHeaders($this->treasurer);

        // Flutter demo payload: local id "MEM1" (not a server id) — the
        // server must resolve the member via phoneNumber.
        $response = $this->postJson('/api/v1/sync', [
            'operations' => [
                [
                    'idempotency_key' => 'flt-1',
                    'type' => 'contribution.create',
                    'payload' => [
                        'memberId' => 'MEM1',
                        'phoneNumber' => '0712345678',
                        'sharesBought' => 3,
                    ],
                ],
            ],
        ], $headers);

        $response->assertStatus(200);
        $result = $response->json('results.0.result');
        $this->assertEquals('ok', $result['status']);
        $this->assertDatabaseHas('contributions', ['member_id' => $member->id, 'shares' => 3]);
        $this->assertEquals(27, $member->fresh()->total_shares);

        // Playing the same idempotency key again must NOT double-record.
        $this->postJson('/api/v1/sync', [
            'operations' => [
                [
                    'idempotency_key' => 'flt-1',
                    'type' => 'contribution.create',
                    'payload' => [
                        'memberId' => 'MEM1',
                        'phoneNumber' => '0712345678',
                        'sharesBought' => 3,
                    ],
                ],
            ],
        ], $headers)
            ->assertStatus(200)
            ->assertJsonPath('results.0.result.status', 'duplicated');
        $this->assertEquals(1, Contribution::where('member_id', $member->id)->count());
    }

    public function test_sync_loan_lifecycle_resolves_loans_by_phone_and_principal(): void
    {
        $member = $this->group->members()->create([
            'full_name' => 'Yusuf Hamisi',
            'phone' => '0754332211',
            'role' => 'member',
            'joined_date' => now()->subDays(90),
            'total_shares' => 12,
            'share_value' => 10000,
        ]);
        Contribution::create([
            'group_id' => $this->group->id,
            'member_id' => $member->id,
            'recorded_by' => $this->treasurer->id,
            'shares' => 12,
            'share_value' => 10000,
            'amount_total' => 120000,
            'recorded_at' => now(),
        ]);

        $headers = $this->authHeaders($this->treasurer);
        $payload = fn (string $key, array $extra) => [
            'operations' => [[
                'idempotency_key' => $key,
                'type' => 'loan.request',
                'payload' => array_merge([
                    'memberId' => 'MEM4',
                    'phoneNumber' => '0754332211',
                    'principal' => 60000,
                    'repaymentDays' => 60,
                ], $extra),
            ]],
        ];

        $request = $this->postJson('/api/v1/sync', $payload('fl-loan-1', []), $headers);
        $request->assertStatus(200)->assertJsonPath('results.0.result.status', 'ok');
        $loan = $this->group->loans()->where('principal', 60000)->firstOrFail();
        $this->assertEquals(Loan::STATUS_PENDING, $loan->status);

        // Approve via an id-less payload referencing the SAME member+amount.
        $this->postJson('/api/v1/sync', [
            'operations' => [[
                'idempotency_key' => 'fl-loan-2',
                'type' => 'loan.approve',
                'payload' => [
                    'phoneNumber' => '0754332211',
                    'principal' => 60000,
                ],
            ]],
        ], $headers)
            ->assertStatus(200)
            ->assertJsonPath('results.0.result.status', 'ok');
        $this->assertEquals(Loan::STATUS_APPROVED, $loan->fresh()->status);
    }
}
