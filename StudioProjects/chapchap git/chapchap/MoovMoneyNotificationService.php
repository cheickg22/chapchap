<?php

namespace App\Services\MoovMoney;

use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Kreait\Firebase\Factory;

class MoovMoneyNotificationService
{
    /**
     * Envoyer une notification de succès
     */
    public function sendSuccessNotification(User $user, $amount, $transactionId)
    {
        $title = '✅ Transaction réussie !';
        $body = sprintf(
            'Vous avez reçu %s FCFA via Moov Money',
            number_format($amount, 0, ',', ' ')
        );
        
        $data = [
            'type' => 'moov_money_success',
            'amount' => (string) $amount,
            'transaction_id' => $transactionId,
            'timestamp' => now()->toIso8601String(),
        ];
        
        return $this->sendNotification($user, $title, $body, $data);
    }
    
    /**
     * Envoyer une notification d'échec
     */
    public function sendFailureNotification(User $user, $errorMessage, $requestId)
    {
        $title = '❌ Transaction échouée';
        $body = $this->getReadableErrorMessage($errorMessage);
        
        $data = [
            'type' => 'moov_money_failed',
            'error' => $errorMessage,
            'request_id' => $requestId,
            'timestamp' => now()->toIso8601String(),
        ];
        
        return $this->sendNotification($user, $title, $body, $data);
    }
    
    /**
     * Envoyer une notification de traitement en cours
     */
    public function sendProcessingNotification(User $user, $amount, $requestId)
    {
        $title = '⏳ Transaction en cours';
        $body = sprintf(
            'Votre transaction de %s FCFA est en cours de traitement',
            number_format($amount, 0, ',', ' ')
        );
        
        $data = [
            'type' => 'moov_money_processing',
            'amount' => (string) $amount,
            'request_id' => $requestId,
            'timestamp' => now()->toIso8601String(),
        ];
        
        return $this->sendNotification($user, $title, $body, $data);
    }
    
    /**
     * Envoyer une notification de retry
     */
    public function sendRetryNotification(User $user, $attempt, $maxAttempts, $requestId)
    {
        $title = '🔄 Nouvelle tentative';
        $body = sprintf(
            'Tentative %d/%d en cours...',
            $attempt,
            $maxAttempts
        );
        
        $data = [
            'type' => 'moov_money_retry',
            'attempt' => (string) $attempt,
            'max_attempts' => (string) $maxAttempts,
            'request_id' => $requestId,
            'timestamp' => now()->toIso8601String(),
        ];
        
        return $this->sendNotification($user, $title, $body, $data);
    }
    
    /**
     * Envoyer une notification de mode test
     */
    public function sendTestModeNotification(User $user, $amount, $requestId)
    {
        $title = '🧪 Mode Test';
        $body = sprintf(
            'Transaction de %s FCFA simulée avec succès',
            number_format($amount, 0, ',', ' ')
        );
        
        $data = [
            'type' => 'moov_money_test',
            'amount' => (string) $amount,
            'request_id' => $requestId,
            'test_mode' => 'true',
            'timestamp' => now()->toIso8601String(),
        ];
        
        return $this->sendNotification($user, $title, $body, $data);
    }
    
    /**
     * Convertir les messages d'erreur techniques en messages lisibles
     */
    private function getReadableErrorMessage($errorMessage)
    {
        $errorMap = [
            'command ID is mandatory' => 'Problème de connexion avec Moov Money. Veuillez réessayer.',
            'timeout' => 'La transaction a pris trop de temps. Veuillez réessayer.',
            'insufficient balance' => 'Solde insuffisant sur le compte.',
            'invalid phone' => 'Numéro de téléphone invalide.',
            'network error' => 'Problème de connexion réseau.',
            'api error' => 'Erreur temporaire du service Moov Money.',
        ];
        
        foreach ($errorMap as $key => $message) {
            if (stripos($errorMessage, $key) !== false) {
                return $message;
            }
        }
        
        return 'Une erreur s\'est produite. Veuillez réessayer ou contacter le support.';
    }
    
    /**
     * Envoyer une notification Firebase
     */
    private function sendNotification(User $user, $title, $body, array $data = [])
    {
        try {
            // Vérifier si l'utilisateur a un token FCM
            if (empty($user->fcm_token)) {
                Log::channel('moov_money')->warning('Utilisateur sans FCM token', [
                    'user_id' => $user->id,
                ]);
                return false;
            }
            
            $factory = (new Factory)->withServiceAccount(config('firebase.credentials'));
            $messaging = $factory->createMessaging();
            
            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::withTarget('token', $user->fcm_token)
                ->withNotification($notification)
                ->withData($data);
            
            $messaging->send($message);
            
            Log::channel('moov_money')->info('Notification envoyée', [
                'user_id' => $user->id,
                'type' => $data['type'] ?? 'unknown',
                'title' => $title,
            ]);
            
            return true;
            
        } catch (\Exception $e) {
            Log::channel('moov_money')->error('Erreur envoi notification', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
            
            return false;
        }
    }
}
