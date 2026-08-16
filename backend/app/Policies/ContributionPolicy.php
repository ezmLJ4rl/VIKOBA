<?php

namespace App\Policies;

use App\Models\Contribution;
use App\Models\Group;
use App\Models\User;

class ContributionPolicy
{
    public function viewAny(User $user, Group $group): bool
    {
        return $user->group_id === $group->id;
    }

    /** Any member of the group can record a (their own) contribution. */
    public function create(User $user, Group $group): bool
    {
        return $user->group_id === $group->id;
    }

    public function view(User $user, Contribution $contribution): bool
    {
        return $user->group_id === $contribution->group_id;
    }
}
