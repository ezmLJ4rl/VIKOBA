<?php

namespace App\Policies;

use App\Models\Group;
use App\Models\Loan;
use App\Models\User;

class LoanPolicy
{
    public function viewAny(User $user, Group $group): bool
    {
        return $user->group_id === $group->id;
    }

    /**
     * Any member may submit a request (approval is a separate permissioned
     * step).
     */
    public function request(User $user, Group $group): bool
    {
        return $user->group_id === $group->id;
    }

    /** Only financial authority may approve / reject / disburse. */
    public function decide(User $user, Loan $loan): bool
    {
        return $user->group_id === $loan->group_id
            && $user->canAuthorizeFinance();
    }

    /** Repayments may be recorded by any group member (audited). */
    public function repay(User $user, Loan $loan): bool
    {
        return $user->group_id === $loan->group_id;
    }
}
