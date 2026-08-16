<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Repayments record their waterfall split (penalty -> interest ->
     * principal) so the loan statement shows exactly where each shilling went.
     * `amount` stays the full cash taken; the splits sum to it.
     */
    public function up(): void
    {
        Schema::table('loan_repayments', function (Blueprint $table) {
            $table->unsignedBigInteger('principal_paid')->default(0)->after('amount');
            $table->unsignedBigInteger('interest_paid')->default(0)->after('principal_paid');
            $table->unsignedBigInteger('penalty_paid')->default(0)->after('interest_paid');
        });
    }

    public function down(): void
    {
        Schema::table('loan_repayments', function (Blueprint $table) {
            $table->dropColumn(['principal_paid', 'interest_paid', 'penalty_paid']);
        });
    }
};
