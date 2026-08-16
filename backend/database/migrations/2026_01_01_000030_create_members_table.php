<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * A roster entry for a group. Tracks the running share-count directly for
     * cheap reads; the authoritative "shares bought" ledger lives in
     * `contributions` (this is a denormalized cache that must be kept in sync
     * inside a transaction).
     */
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('full_name');
            $table->string('phone', 20);
            $table->string('role', 20)->default('member')
                ->comment('chairperson | treasurer | secretary | member');
            $table->date('joined_date');
            $table->unsignedInteger('total_shares')->default(0);
            $table->unsignedBigInteger('share_value')->default(10000);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['group_id', 'phone']);
            $table->index(['group_id', 'is_active']);
            $table->index(['group_id', 'full_name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
