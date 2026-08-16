<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Fellow members backing a loan request (1-2 per loan, per the vikoba
     * constitution). `exposure` of each guarantor is the sum of outstanding
     * balances of the loans they guarantee — surfaced on member profiles.
     */
    public function up(): void
    {
        Schema::create('loan_guarantors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('loan_id')->constrained()->cascadeOnDelete();
            $table->foreignId('member_id')->constrained()->cascadeOnDelete();
            $table->boolean('confirmed')->default(false);
            $table->timestamps();

            $table->unique(['loan_id', 'member_id']);
            $table->index(['member_id', 'confirmed']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loan_guarantors');
    }
};
