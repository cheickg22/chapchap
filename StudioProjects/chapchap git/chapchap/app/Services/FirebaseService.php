<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FirebaseService
{
    protected $messaging;

    public function __construct()
    {
        try {
            $firebase = app('firebase');
            $this->messaging = $firebase->createMessaging();
        } catch (\Exception $e) {
            Log::error('Firebase initialization error: ' . $e->getMessage());
        }
    }

    /**
     * Envoyer une notification push
     */
    public function sendNotification($token, $title, $body, $data = [])
    {
        try {
            if (!$this->messaging) {
                Log::warning('Firebase messaging not initialized');
                return false;
            }

            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification($notification)
                ->withData($data);

            $this->messaging->send($message);
            
            Log::info('Firebase notification sent', [
                'token' => substr($token, 0, 20) . '...',
                'title' => $title
            ]);
            
            return true;
            
        } catch (\Exception $e) {
            Log::error('Firebase notification error', [
                'error' => $e->getMessage(),
                'token' => substr($token, 0, 20) . '...'
            ]);
            return false;
        }
    }

    /**
     * Envoyer une notification à plusieurs tokens
     */
    public function sendMulticast($tokens, $title, $body, $data = [])
    {
        try {
            if (!$this->messaging) {
                Log::warning('Firebase messaging not initialized');
                return false;
            }

            $notification = Notification::create($title, $body);
            
            $message = CloudMessage::new()
                ->withNotification($notification)
                ->withData($data);

            $sendReport = $this->messaging->sendMulticast($message, $tokens);
            
            Log::info('Firebase multicast sent', [
                'success_count' => $sendReport->successes()->count(),
                'failure_count' => $sendReport->failures()->count()
            ]);
            
            return true;
            
        } catch (\Exception $e) {
            Log::error('Firebase multicast error', [
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}
