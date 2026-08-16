<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Group constitution fines — separate from loan penalties. Real vikoba
     * groups fine members for missing meetings, arriving late, etc. This is
     * the ledger that records every such charge.
     */
    public function up(): void
    {
        Schema::create('fines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->foreignId('meeting_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('recorded_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('type', 20)->default('other')
                ->comment('meeting_absence | late_meeting | other');
            $table->unsignedBigInteger('amount');
            $table->string('reason', 255)->nullable();
            $table->string('status', 10)->default('pending')
                ->comment('pending | paid | waived');
            $table->dateTime('recorded_at');
            $table->timestamps();

            $table->index(['group_id', 'status']);
            $table->index(['member_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fines');
    }
};
