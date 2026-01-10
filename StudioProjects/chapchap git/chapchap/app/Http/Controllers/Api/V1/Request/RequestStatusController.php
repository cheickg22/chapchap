<?php

namespace App\Http\Controllers\Api\V1\Request;

use App\Http\Controllers\ApiController;
use App\Models\Request\Request;
use Illuminate\Http\Request as HttpRequest;

/**
 * Contrôleur pour le polling des statuts de requêtes
 * Utilisé par le service hybride (Firebase + Polling API)
 * Supporte tous les types: taxi, delivery, moov_money, dispatcher
 */
class RequestStatusController extends ApiController
{
    /**
     * Récupérer le statut d'une requête (pour polling)
     * Endpoint générique pour tous les types de requêtes
     * 
     * @param string $requestId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getStatus($requestId)
    {
        $user = auth()->user();

        // Vérifier que la requête appartient à l'utilisateur
        $request = Request::where('id', $requestId)
            ->where('user_id', $user->id)
            ->first();

        if (!$request) {
            return $this->respondNotFound('Requête non trouvée');
        }

        // Déterminer le statut selon le type de requête
        $status = $this->determineStatus($request);

        return $this->respondSuccess([
            'id' => $request->id,
            'status' => $status,
            'transport_type' => $request->transport_type,
            'is_moov_money' => $request->is_moov_money,
            'moov_money_status' => $request->moov_money_status,
            'moov_money_type' => $request->moov_money_type,
            'is_completed' => $request->is_completed,
            'is_cancelled' => $request->is_cancelled,
            'is_driver_started' => $request->is_driver_started,
            'is_trip_start' => $request->is_trip_start,
            'driver_id' => $request->driver_id,
        ]);
    }

    /**
     * Déterminer le statut d'une requête selon son type
     * 
     * @param Request $request
     * @return string
     */
    private function determineStatus($request)
    {
        // Si c'est une requête MoovMoney
        if ($request->is_moov_money) {
            return $request->moov_money_status ?? 'pending';
        }

        // Pour les autres types (taxi, delivery, dispatcher)
        if ($request->is_completed) {
            return 'completed';
        }

        if ($request->is_cancelled) {
            return 'cancelled';
        }

        if ($request->is_trip_start) {
            return 'trip_started';
        }

        if ($request->is_driver_started) {
            return 'driver_started';
        }

        if ($request->is_driver_arrived) {
            return 'driver_arrived';
        }

        if ($request->driver_id) {
            return 'accepted';
        }

        return 'pending';
    }

    /**
     * Récupérer le statut d'une requête côté driver (pour polling)
     * 
     * @param string $requestId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getStatusDriver($requestId)
    {
        $driver = auth()->user()->driver;

        // Vérifier que la requête est assignée au driver
        $request = Request::where('id', $requestId)
            ->where('driver_id', $driver->id)
            ->first();

        if (!$request) {
            return $this->respondNotFound('Requête non trouvée ou non assignée à ce driver');
        }

        // Déterminer le statut selon le type de requête
        $status = $this->determineStatus($request);

        return $this->respondSuccess([
            'id' => $request->id,
            'status' => $status,
            'transport_type' => $request->transport_type,
            'is_moov_money' => $request->is_moov_money,
            'moov_money_status' => $request->moov_money_status,
            'moov_money_type' => $request->moov_money_type,
            'is_completed' => $request->is_completed,
            'is_cancelled' => $request->is_cancelled,
            'is_driver_started' => $request->is_driver_started,
            'is_trip_start' => $request->is_trip_start,
            'user_id' => $request->user_id,
        ]);
    }
}
