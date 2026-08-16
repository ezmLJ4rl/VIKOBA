<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Loans move to a product-driven model. `total_payable` remains the
     * principal + interest snapshot computed at creation (never client input);
     * accrued late-payment penalties are tracked separately in
     * `penalty_accrued` so they can be itemised in statements.
     *
     * Disbursement is its own step: `status` moves approved -> active only
     * when `disbursed_at` is set, with the cash/M-Pesa method recorded.
     */
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->foreignId('loan_product_id')->nullable()->after('group_id')
                ->constrained()->nullOnDelete();
            $table->unsignedInteger('term_months')->default(1)->after('interest_rate');
            $table->unsignedInteger('installment_interval_days')->default(30)->after('term_months');
            $table->string('interest_method', 10)->default('flat')->after('installment_interval_days')
                ->comment('flat | reducing — snapshot of the product at issue time.');
            $table->dateTime('disbursed_at')->nullable()->after('issued_at');
            $table->string('disbursement_method', 10)->nullable()->after('disbursed_at')
                ->comment('cash | mpesa | bank');
            $table->unsignedBigInteger('penalty_accrued')->default(0)->after('amount_repaid')
                ->comment('Cumulative late-payment penalties added to the debt.');
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropConstrainedForeignId('loan_product_id');
            $table->dropColumn([
                'term_months',
                'installment_interval_days',
                'interest_method',
                'disbursed_at',
                'disbursement_method',
                'penalty_accrued',
            ]);
        });
    }
};
