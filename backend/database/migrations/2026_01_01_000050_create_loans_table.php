<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Loans. Interest/total-payable are computed server-side at creation time
     * and stored (never trusted from the client), so reports don't recompute
     * anything. Amounts are whole shillings (integers).
     */
    public function up(): void
    {
        Schema::create('loans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->foreignId('requested_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('decided_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedBigInteger('principal');
            $table->decimal('interest_rate', 5, 2)
                ->comment('Percent charged per cycle (group setting at issue time).');
            $table->unsignedBigInteger('interest_amount');
            $table->unsignedBigInteger('total_payable');
            $table->unsignedBigInteger('amount_repaid')->default(0);
            $table->string('status', 20)->default('pending')
                ->comment('pending | approved | active | repaid | rejected');
            $table->dateTime('issued_at')->nullable();
            $table->date('due_date')->nullable();
            $table->string('idempotency_key', 64)->nullable()->index();
            $table->string('note')->nullable();
            $table->timestamps();

            $table->index(['group_id', 'status', 'due_date']);
            $table->index(['member_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
