<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Append-only audit trail for every financial mutation. This is the trust
     * mechanism of a group finance system: who changed what, when, from what
     * to what. Never update or delete rows here.
     */
    public function up(): void
    {
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->nullable()->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('entity_type', 60)->index();
            $table->unsignedBigInteger('entity_id')->index();
            $table->string('action', 40);
            $table->json('old')->nullable();
            $table->json('new')->nullable();
            $table->string('ip', 45)->nullable();
            $table->timestamps();

            $table->index(['group_id', 'entity_type', 'entity_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
    }
};
