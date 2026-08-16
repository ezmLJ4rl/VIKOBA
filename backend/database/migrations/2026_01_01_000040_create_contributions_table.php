<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Contribution ledger. Every share purchase is a row here — the running
     * per-member total on `members` is derived from summing this when needed.
     *
     * Money is stored as whole shillings (integers) because TZS has no
     * fractional unit and floats drift; MySQL/Postgres keep exact integers.
     */
    public function up(): void
    {
        Schema::create('contributions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedInteger('shares')->default(1);
            $table->unsignedBigInteger('share_value')->default(10000);
            $table->unsignedBigInteger('amount_total')->comment('shares x share_value');
            $table->string('note')->nullable();
            $table->timestamp('recorded_at');
            $table->string('idempotency_key', 64)->nullable()->index();
            $table->timestamps();

            $table->index(['group_id', 'member_id', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('contributions');
    }
};
