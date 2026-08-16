<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Vikoba groups run in cycles that end in a full share-out. A cycle is
     * open while contributions happen; closing it freezes the interest earned
     * and produces one `share_outs` row per member.
     */
    public function up(): void
    {
        Schema::create('cycles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->date('starts_on');
            $table->date('ends_on')->nullable();
            $table->string('status', 10)->default('active')
                ->comment('active | closed');
            $table->unsignedBigInteger('interest_earned')->default(0);
            $table->unsignedBigInteger('total_share_out')->default(0);
            $table->foreignId('closed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('closed_at')->nullable();
            $table->timestamps();

            $table->index(['group_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cycles');
    }
};
