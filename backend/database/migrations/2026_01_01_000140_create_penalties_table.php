<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Loan late-payment penalties. Each charge is one row so the treasurer
     * can see, waive or justify every single penalty that hit a loan.
     * (Meeting/absentee fines live in `fines`, a separate ledger.)
     */
    public function up(): void
    {
        Schema::create('penalties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('loan_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->string('type', 10)->default('flat')->comment('flat | percent');
            $table->unsignedBigInteger('amount');
            $table->date('applied_for_date')->comment('The late period this charge covers.');
            $table->string('reason', 255)->nullable();
            $table->string('status', 10)->default('pending')
                ->comment('pending | paid | waived');
            $table->foreignId('waived_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('waived_at')->nullable();
            $table->timestamps();

            $table->index(['loan_id', 'status']);
            $table->index(['member_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penalties');
    }
};
