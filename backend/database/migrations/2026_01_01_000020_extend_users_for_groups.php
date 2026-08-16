<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Extends the default users table with Vikoba identity: the group the user
     * belongs to, their group-wide role, and a Tanzanian phone number.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('group_id')->nullable()
                ->constrained('groups')->cascadeOnDelete();
            $table->string('phone', 32)->nullable()->index();
            $table->string('role', 20)->default('member')
                ->comment('admin | chairperson | treasurer | secretary | member');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('group_id');
            $table->dropColumn(['role', 'phone']);
        });
    }
};
