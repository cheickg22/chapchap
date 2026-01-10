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
        Schema::table('requests', function (Blueprint $table) {
            // Champs Moov Money
            $table->decimal('moov_money_amount', 10, 2)->nullable()->after('is_moov_money');
            $table->decimal('moov_money_fees', 10, 2)->nullable()->after('moov_money_amount');
            $table->decimal('moov_money_total_amount', 10, 2)->nullable()->after('moov_money_fees');
            $table->string('moov_money_currency', 10)->default('XOF')->after('moov_money_total_amount');
            $table->string('moov_money_phone', 20)->nullable()->after('moov_money_currency');
            $table->string('moov_money_security_code', 10)->nullable()->after('moov_money_phone');
            $table->string('moov_money_voucher_code', 50)->nullable()->after('moov_money_security_code');
            $table->string('moov_money_validation_code', 10)->nullable()->after('moov_money_voucher_code');
            $table->string('moov_money_status', 50)->nullable()->after('moov_money_validation_code');
            $table->timestamp('moov_money_processed_at')->nullable()->after('moov_money_status');
            $table->uuid('moov_money_transaction_id')->nullable()->after('moov_money_processed_at');
            
            // Index pour les recherches
            $table->index('moov_money_status');
            $table->index('moov_money_transaction_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('requests', function (Blueprint $table) {
            $table->dropColumn([
                'moov_money_amount',
                'moov_money_fees',
                'moov_money_total_amount',
                'moov_money_currency',
                'moov_money_phone',
                'moov_money_security_code',
                'moov_money_voucher_code',
                'moov_money_validation_code',
                'moov_money_status',
                'moov_money_processed_at',
                'moov_money_transaction_id',
            ]);
        });
    }
};
