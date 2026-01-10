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
            if (!Schema::hasColumn('requests', 'moov_money_transaction_id')) {
                $table->string('moov_money_transaction_id')
                    ->nullable()
                    ->after('moov_money_voucher_code')
                    ->comment('Trans-ID retourné par Moov Money après envoi USSD');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('requests', function (Blueprint $table) {
            if (Schema::hasColumn('requests', 'moov_money_transaction_id')) {
                $table->dropColumn('moov_money_transaction_id');
            }
        });
    }
};
