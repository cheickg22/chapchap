<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasTable('moov_money_transactions')) {
            Schema::create('moov_money_transactions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id');
                $table->string('transaction_id')->unique();
                $table->string('moov_transaction_id')->nullable();
                $table->enum('type', ['deposit', 'withdrawal', 'transfer']);
                $table->decimal('amount', 10, 2);
                $table->decimal('fee', 10, 2)->default(0);
                $table->decimal('commission', 10, 2)->default(0);
                $table->enum('status', ['pending', 'processing', 'completed', 'failed', 'cancelled'])
                      ->default('pending');
                $table->string('phone_number')->nullable();
                $table->text('description')->nullable();
                $table->text('moov_response')->nullable();
                $table->json('metadata')->nullable();
                $table->timestamps();
                
                $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
                $table->index(['user_id', 'status']);
                $table->index(['created_at']);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('moov_money_transactions');
    }
};
