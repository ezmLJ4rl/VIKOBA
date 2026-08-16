<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Group-defined loan products ("Emergency Loan", "Business Loan", ...).
     * Each product carries its own interest configuration, term cap and
     * penalty rules so the group constitution is expressed per product rather
     * than as a single group-wide default.
     *
     * interest_method: flat   -> interest = principal x rate% x term_months
     *                 reducing-> declining-balance amortization (standard EMI)
     * rate is expressed PER INSTALLMENT PERIOD (default monthly).
     */
    public function up(): void
    {
        Schema::create('loan_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('description')->nullable();
            $table->decimal('interest_rate', 5, 2)->default(10);
            $table->string('interest_method', 10)->default('flat')
                ->comment('flat | reducing');
            $table->unsignedInteger('max_term_months')->default(6);
            $table->unsignedInteger('max_multiplier')->default(4)
                ->comment('Max loan = member savings x this factor.');
            $table->unsignedBigInteger('min_amount')->default(20000);
            $table->string('penalty_type', 10)->default('flat')
                ->comment('flat | percent');
            $table->unsignedBigInteger('penalty_value')->default(0)
                ->comment('TZS per period when flat, percent per period when percent.');
            $table->unsignedInteger('penalty_grace_days')->default(0);
            $table->unsignedInteger('penalty_period_days')->default(7);
            $table->unsignedInteger('installment_interval_days')->default(30);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['group_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loan_products');
    }
};
