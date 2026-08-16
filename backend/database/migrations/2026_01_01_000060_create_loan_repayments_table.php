<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Every repayment is its own row: a full audit trail of what was paid,
     * when, and by whom. `loans.amount_repaid` is a denormalized running total
     * kept in sync inside the same transaction.
     */
    public function up(): void
    {
        Schema::create('loan_repayments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('loan_id')->constrained()->cascadeOnDelete();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedBigInteger('amount');
            $table->timestamp('recorded_at');
            $table->string('idempotency_key', 64)->nullable()->index();
            $table->timestamps();

            $table->index(['loan_id', 'recorded_at']);
            $table->index(['group_id', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loan_repayments');
    }
};
