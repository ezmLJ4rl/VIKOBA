<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateGroupRequest;
use App\Models\Loan;
use App\Services\AuditService;
use App\Services\VikobaService;
use Illuminate\Http\JsonResponse;

class GroupController extends Controller
{
    private function group()
    {
        return auth()->user()->group;
    }

    public function show(): JsonResponse
    {
        return response()->json(['group' => $this->group()]);
    }

    public function update(UpdateGroupRequest $request): JsonResponse
    {
        $group = $this->group();
        $group->fill($request->only([
            'share_value',
            'default_interest_rate',
            'interest_method',
            'max_loan_multiple',
            'contribution_cycle',
            'min_membership_days',
        ]));
        if ($request->filled('group_name')) {
            $group->name = $request->input('group_name');
        }
        $group->save();

        AuditService::log('group', $group->id, 'settings.update', new: $group->fresh()->toArray());

        return response()->json(['group' => $group->fresh()]);
    }

    /** Read-heavy dashboard aggregate. Cached easily later. */
    public function summary(): JsonResponse
    {
        $group = $this->group();
        $members = $group->members()->get();
        $loans = $group->loans()->get();

        $activeLoanBalance = $loans
            ->where('status', Loan::STATUS_ACTIVE)
            ->sum(fn (Loan $loan) => $loan->balance);

        return response()->json([
            'group' => $group,
            'summary' => [
                'total_savings' => VikobaService::totalSavings($members),
                'active_loans_balance' => $activeLoanBalance,
                'interest_earned' => VikobaService::totalInterestEarned($loans),
                'active_members' => $members->where('is_active', true)->count(),
                'invite_code' => $group->invite_code,
                'contribution_cycle' => $group->contribution_cycle,
            ],
        ]);
    }
}
