<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Modifier l'ENUM pour ajouter 'waiting_payment'
        DB::statement("ALTER TABLE requests MODIFY COLUMN moov_money_status ENUM('pending', 'processing', 'completed', 'failed', 'waiting_payment') NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Retirer 'waiting_payment' de l'ENUM
        DB::statement("ALTER TABLE requests MODIFY COLUMN moov_money_status ENUM('pending', 'processing', 'completed', 'failed') NULL");
    }
};
