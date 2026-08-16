<?php

namespace App\Providers;

use App\Models\Group;
use App\Models\Member;
use App\Models\User;
use App\Policies\MemberPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Committee roles (chairperson/treasurer/secretary/admin) share full
        // access; plain members are view-only. Policies live in
        // App\Policies\* and double as the portable documentation of the rules.
        Gate::define('member.create', fn (User $user, Group $group) => (new MemberPolicy)->create($user, $group));
        Gate::define('member.update', fn (User $user, Member $member) => (new MemberPolicy)->update($user, $member));
        Gate::define('loan.decide', fn (User $user) => $user->canAuthorizeFinance());
    }
}
