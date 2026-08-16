<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Past share-out records, one row per member per closed cycle. This makes
     * "Gawanya" auditable history instead of a one-shot action.
     */
    public function up(): void
    {
        Schema::create('share_outs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('cycle_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->unsignedBigInteger('savings_paid');
            $table->unsignedBigInteger('interest_share');
            $table->unsignedBigInteger('total_paid');
            $table->dateTime('paid_at')->nullable();
            $table->string('status', 10)->default('pending')
                ->comment('pending | paid');
            $table->timestamps();

            $table->unique(['cycle_id', 'member_id']);
            $table->index(['group_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('share_outs');
    }
};
