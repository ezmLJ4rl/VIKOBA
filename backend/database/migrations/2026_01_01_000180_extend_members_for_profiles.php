<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Richer member profiles: NIDA/ID number and an optional photo for the
     * member detail screen. `joined_date` already exists and drives the
     * minimum-membership-duration eligibility rule.
     */
    public function up(): void
    {
        Schema::table('members', function (Blueprint $table) {
            $table->string('nida_number', 40)->nullable()->after('phone');
            $table->string('photo_path')->nullable()->after('nida_number');
        });
    }

    public function down(): void
    {
        Schema::table('members', function (Blueprint $table) {
            $table->dropColumn(['nida_number', 'photo_path']);
        });
    }
};
