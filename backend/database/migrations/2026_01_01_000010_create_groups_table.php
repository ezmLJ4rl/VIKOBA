<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('groups', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->unsignedBigInteger('share_value')->default(10000)
                ->comment('Price of one share in whole shillings.');
            $table->decimal('default_interest_rate', 5, 2)->default(10)
                ->comment('Percent charged per loan cycle.');
            $table->unsignedBigInteger('max_loan_multiple')->default(4)
                ->comment('Max loan = member savings x this factor.');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('groups');
    }
};
