<?php

namespace App\Policies;

use App\Models\Group;
use App\Models\Member;
use App\Models\User;

class MemberPolicy
{
    public function viewAny(User $user, Group $group): bool
    {
        return $user->group_id === $group->id;
    }

    public function create(User $user, Group $group): bool
    {
        return $user->group_id === $group->id
            && in_array($user->role, [
                User::ROLE_ADMIN,
                User::ROLE_CHAIRPERSON,
                User::ROLE_TREASURER,
                User::ROLE_SECRETARY,
            ], true);
    }

    public function update(User $user, Member $member): bool
    {
        return $user->group_id === $member->group_id
            && in_array($user->role, [
                User::ROLE_ADMIN,
                User::ROLE_CHAIRPERSON,
                User::ROLE_TREASURER,
                User::ROLE_SECRETARY,
            ], true);
    }
}
