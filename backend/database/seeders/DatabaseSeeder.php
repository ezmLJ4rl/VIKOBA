<?php

namespace Database\Seeders;

use App\Models\Contribution;
use App\Models\Group;
use App\Models\Loan;
use App\Models\LoanRepayment;
use App\Models\Meeting;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * Demo data for development, kept in sync with the Flutter seed
 * (lib/core/data/seed_data.dart) so screenshots/numbers match across stacks.
 */
class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $group = Group::create([
            'name' => 'Vikoba Demo Group',
            'share_value' => 10000,
            'default_interest_rate' => 10,
            'max_loan_multiple' => 4,
        ]);

        $treasurer = User::create([
            'name' => 'Elisha Mgeni',
            'email' => 'treasurer@vikoba.test',
            'phone' => '0765432109',
            'password' => bcrypt('password'),
            'role' => User::ROLE_TREASURER,
            'group_id' => $group->id,
        ]);

        $members = collect([
            ['MEM1', 'Amina Juma', '0712345678', 'chairperson', 24],
            ['MEM2', 'Elisha Mgeni', '0765432109', 'treasurer', 30],
            ['MEM3', 'Fatuma Rashidi', '0788112233', 'secretary', 18],
            ['MEM4', 'Yusuf Hamisi', '0754332211', 'member', 12],
        ])->map(function (array $row) use ($group, $treasurer) {
            $member = $group->members()->create([
                'full_name' => $row[1],
                'phone' => $row[2],
                'role' => $row[3],
                'joined_date' => now()->subDays(90),
                'total_shares' => $row[4],
                'share_value' => $group->share_value,
                'is_active' => true,
            ]);

            Contribution::create([
                'group_id' => $group->id,
                'member_id' => $member->id,
                'recorded_by' => $treasurer->id,
                'shares' => $row[4],
                'share_value' => $group->share_value,
                'amount_total' => $row[4] * $group->share_value,
                'recorded_at' => now()->subDays(7),
            ]);

            return $member;
        });

        // Loan: Fatuma (active, partially repaid).
        $active = $group->loans()->create([
            'member_id' => $members[2]->id,
            'requested_by' => $treasurer->id,
            'decided_by' => $treasurer->id,
            'principal' => 150000,
            'interest_rate' => 10,
            'interest_amount' => 15000,
            'total_payable' => 165000,
            'amount_repaid' => 80000,
            'status' => Loan::STATUS_ACTIVE,
            'issued_at' => now()->subDays(30),
            'due_date' => now()->addDays(30)->toDateString(),
        ]);
        LoanRepayment::create([
            'group_id' => $group->id,
            'loan_id' => $active->id,
            'recorded_by' => $treasurer->id,
            'amount' => 80000,
            'recorded_at' => now()->subDays(2),
        ]);

        // Loan: Yusuf (repaid, earned 10k interest for the group).
        $repaid = $group->loans()->create([
            'member_id' => $members[3]->id,
            'requested_by' => $treasurer->id,
            'decided_by' => $treasurer->id,
            'principal' => 100000,
            'interest_rate' => 10,
            'interest_amount' => 10000,
            'total_payable' => 110000,
            'amount_repaid' => 110000,
            'status' => Loan::STATUS_REPAID,
            'issued_at' => now()->subDays(60),
            'due_date' => now()->subDays(5)->toDateString(),
        ]);
        LoanRepayment::create([
            'group_id' => $group->id,
            'loan_id' => $repaid->id,
            'recorded_by' => $treasurer->id,
            'amount' => 110000,
            'recorded_at' => now()->subDays(10),
        ]);

        // Loan: Amina (pending approval).
        $group->loans()->create([
            'member_id' => $members[0]->id,
            'requested_by' => $treasurer->id,
            'principal' => 200000,
            'interest_rate' => 10,
            'interest_amount' => 20000,
            'total_payable' => 220000,
            'status' => Loan::STATUS_PENDING,
            'due_date' => now()->addDays(45)->toDateString(),
        ]);

        $meeting = Meeting::create([
            'group_id' => $group->id,
            'created_by' => $treasurer->id,
            'held_at' => now()->subDays(7),
            'agenda' => 'Weekly contribution & loan review',
        ]);
        foreach ($members->take(3) as $member) {
            $meeting->attendance()->create(['member_id' => $member->id, 'present' => true]);
        }
    }
}
