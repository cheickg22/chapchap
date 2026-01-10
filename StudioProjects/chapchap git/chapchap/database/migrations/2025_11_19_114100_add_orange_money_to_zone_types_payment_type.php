<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Mettre à jour tous les zone_types actifs pour inclure orange_money
        
        // Pour les zone_types qui n'ont pas encore orange_money
        DB::statement("
            UPDATE zone_types 
            SET payment_type = CONCAT(payment_type, ',orange_money')
            WHERE payment_type NOT LIKE '%orange_money%'
              AND payment_type != 'all'
              AND payment_type IS NOT NULL
              AND payment_type != ''
              AND active = 1
        ");
        
        // Log des modifications
        \Log::info('Migration: Orange Money ajouté aux payment_types des zone_types actifs');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Retirer orange_money des payment_types
        DB::statement("
            UPDATE zone_types 
            SET payment_type = REPLACE(payment_type, ',orange_money', '')
            WHERE payment_type LIKE '%,orange_money%'
        ");
        
        DB::statement("
            UPDATE zone_types 
            SET payment_type = REPLACE(payment_type, 'orange_money,', '')
            WHERE payment_type LIKE '%orange_money,%'
        ");
        
        DB::statement("
            UPDATE zone_types 
            SET payment_type = REPLACE(payment_type, 'orange_money', '')
            WHERE payment_type = 'orange_money'
        ");
        
        \Log::info('Migration rollback: Orange Money retiré des payment_types');
    }
};
