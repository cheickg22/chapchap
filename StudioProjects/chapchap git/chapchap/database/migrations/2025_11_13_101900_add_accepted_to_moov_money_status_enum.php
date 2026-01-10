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
        // Modifier l'ENUM pour ajouter 'accepted' et 'en_route'
        DB::statement("ALTER TABLE requests MODIFY COLUMN moov_money_status ENUM('pending', 'accepted', 'en_route', 'arrived', 'processing', 'completed', 'failed', 'waiting_payment') NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Retirer les nouveaux statuts de l'ENUM
        DB::statement("ALTER TABLE requests MODIFY COLUMN moov_money_status ENUM('pending', 'processing', 'completed', 'failed', 'waiting_payment') NULL");
    }
};
