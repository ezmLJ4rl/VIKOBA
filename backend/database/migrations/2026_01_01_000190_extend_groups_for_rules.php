<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Group-wide rules beyond the loan products: the default interest method,
     * contribution cycle (weekly/monthly), how long a member must belong
     * before borrowing, and an invite code so members can join an existing
     * group instead of creating a new one.
     */
    public function up(): void
    {
        Schema::table('groups', function (Blueprint $table) {
            $table->string('interest_method', 10)->default('flat')->after('default_interest_rate')
                ->comment('flat | reducing');
            $table->string('contribution_cycle', 10)->default('weekly')->after('max_loan_multiple')
                ->comment('weekly | monthly');
            $table->unsignedInteger('min_membership_days')->default(30)->after('contribution_cycle');
            $table->string('invite_code', 20)->nullable()->unique()->after('slug');
        });
    }

    public function down(): void
    {
        Schema::table('groups', function (Blueprint $table) {
            $table->dropUnique(['invite_code']);
            $table->dropColumn([
                'interest_method',
                'contribution_cycle',
                'min_membership_days',
                'invite_code',
            ]);
        });
    }
};
