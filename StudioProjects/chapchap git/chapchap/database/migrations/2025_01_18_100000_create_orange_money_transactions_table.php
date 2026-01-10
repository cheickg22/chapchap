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
        Schema::create('orange_money_transactions', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            
            // Informations utilisateur - IMPORTANT: utiliser unsignedInteger comme dans les autres tables
            $table->unsignedInteger('user_id');
            $table->string('user_type')->default('user'); // user, driver, owner
            
            // Informations de transaction Orange Money
            $table->string('order_id')->unique();
            $table->string('pay_token')->nullable();
            $table->string('notif_token')->nullable();
            $table->string('payment_url')->nullable();
            
            // Détails du paiement
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('XOF'); // XOF ou OUV
            $table->string('reference')->nullable();
            
            // Type de paiement
            $table->string('payment_for')->default('wallet'); // wallet, subscription, trip
            $table->string('request_id')->nullable(); // ID de la course si applicable
            $table->string('plan_id')->nullable(); // ID du plan si subscription
            
            // Statut de la transaction
            $table->enum('status', [
                'pending',      // En attente de paiement
                'initiated',    // Paiement initié
                'processing',   // En cours de traitement
                'success',      // Paiement réussi
                'failed',       // Paiement échoué
                'cancelled',    // Paiement annulé
                'refunded'      // Remboursé
            ])->default('pending');
            
            // Réponse Orange Money
            $table->text('om_response')->nullable(); // Réponse complète d'Orange Money
            $table->string('om_transaction_id')->nullable(); // ID transaction Orange Money
            $table->string('om_status')->nullable(); // Statut Orange Money
            $table->text('om_error_message')->nullable();
            
            // Métadonnées
            $table->string('ip_address', 45)->nullable();
            $table->string('user_agent')->nullable();
            $table->json('metadata')->nullable(); // Données supplémentaires
            
            // Timestamps
            $table->timestamp('initiated_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('failed_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Index
            $table->index('user_id');
            $table->index('order_id');
            $table->index('status');
            $table->index('payment_for');
            $table->index('created_at');
            
            // Foreign key
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orange_money_transactions');
    }
};
