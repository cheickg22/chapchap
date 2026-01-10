<?php

namespace App\Http\Controllers\Api\V1\Request;

use App\Http\Controllers\ApiController;
use App\Models\Request\Request;
use App\Models\MoovMoney\MoovMoneyTransaction;
use App\Services\MoovMoney\MoovMoneyService;
use App\Services\MoovMoney\MoovMoneyStatusService;
use App\Services\FirebaseService;
use App\Transformers\Requests\TripRequestTransformer;
use Illuminate\Http\Request as HttpRequest;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Jobs\CheckMoovMoneyStatus;
use Carbon\Carbon;
use Kreait\Firebase\Contract\Database;
use App\Helpers\Rides\FetchDriversFromFirebaseHelpers;
use App\Helpers\Rides\RidePriceCalculationHelpers;

class MoovMoneyRequestController extends ApiController
{
    use FetchDriversFromFirebaseHelpers, RidePriceCalculationHelpers;
    
    protected $moovMoneyService;
    protected $database;

    public function __construct(MoovMoneyService $moovMoneyService, Database $database)
    {
        $this->moovMoneyService = $moovMoneyService;
        $this->database = $database;
    }

    /**
     * Create a Moov Money deposit request
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function createDepositRequest(HttpRequest $request)
    {
        $validator = Validator::make($request->all(), [
            'pick_lat' => 'required|numeric',
            'pick_lng' => 'required|numeric',
            'pick_address' => 'required|string',
            'amount' => 'required|numeric|min:100',
            'phone_number' => 'required|string|max:20',
            'service_location_id' => 'nullable|uuid',
            'zone_type_id' => 'nullable|uuid',
            'payment_opt' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $user = auth()->user();
        
        // Utiliser des valeurs par défaut si non fournies
        $serviceLocationId = $request->service_location_id ?? \DB::table('service_locations')->first()->id ?? null;
        $zoneTypeId = $request->zone_type_id ?? \DB::table('zone_types')->first()->id ?? null;
        $paymentOpt = $request->payment_opt ?? '1';

        DB::beginTransaction();
        try {
            // 1. Créer la transaction Moov Money
            $moovTransaction = MoovMoneyTransaction::create([
                'user_id' => $user->id,
                'transaction_type' => 'deposit',
                'status' => 'pending',
                'amount' => $request->amount,
                'currency' => 'XOF',
                'phone_number' => $request->phone_number,
            ]);

            // 2. Générer un numéro de requête unique
            $requestNumber = 'MM-DEP-' . time() . '-' . rand(1000, 9999);
            
            // 2.1 Générer un code de sécurité à 6 chiffres
            $securityCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // 3. Créer la requête (Request)
            $moovRequest = Request::create([
                'request_number' => $requestNumber,
                'user_id' => $user->id,
                'service_location_id' => $serviceLocationId,
                'zone_type_id' => $zoneTypeId,
                'transport_type' => 'delivery',
                'payment_opt' => $paymentOpt,
                'is_moov_money' => 1,
                'moov_money_type' => 'deposit',
                'moov_money_amount' => $request->amount,
                'moov_money_phone' => $request->phone_number,
                'moov_money_security_code' => $securityCode,
                'moov_money_transaction_id' => $moovTransaction->id,
                'moov_money_status' => 'pending',
                'is_later' => 0,
                'is_completed' => 0,
                'is_cancelled' => 0,
                'is_paid' => 0,
                'on_search' => 1, // Pour rotation automatique
                'assign_method' => 0, // Méthode d'assignation automatique
                'is_bid_ride' => 0,
                'timezone' => $request->timezone ?? 'UTC',
                'requested_currency_code' => 'XOF',
                'requested_currency_symbol' => 'FCFA',
                'unit' => 1, // kilometers
            ]);

            // 4. Créer l'adresse de pickup (où le driver doit aller)
            $moovRequest->requestPlace()->create([
                'pick_lat' => $request->pick_lat,
                'pick_lng' => $request->pick_lng,
                'pick_address' => $request->pick_address,
                'drop_lat' => $request->pick_lat, // Même position pour Moov Money
                'drop_lng' => $request->pick_lng,
                'drop_address' => $request->pick_address,
            ]);

            // 5. Calculer la commission Moov Money
            $commissionRate = get_settings('moov_money_deposit_commission_rate') ?? 2;
            $moovCommission = ($request->amount * $commissionRate) / 100;
            
            // 5.1 Calculer la commission driver
            $driverCommissionRate = get_settings('moov_money_driver_commission_rate') ?? 1;
            $driverCommission = ($request->amount * $driverCommissionRate) / 100;
            
            // 6. Créer la facture (RequestBill)
            // Note: distance_price sera mis à jour quand le driver accepte
            $moovRequest->requestBill()->create([
                'total_amount' => $moovCommission + $driverCommission,
                'base_price' => $moovCommission,
                'distance_price' => 0, // Sera calculé à l'acceptation
                'time_price' => 0,
                'tax_amount' => 0,
                'admin_commision' => $moovCommission,
                'driver_commision' => $driverCommission,
            ]);

            DB::commit();

            Log::info('Moov Money Deposit Request created', [
                'request_id' => $moovRequest->id,
                'transaction_id' => $moovTransaction->id,
                'user_id' => $user->id,
                'amount' => $request->amount,
            ]);

            // Créer l'entrée Firebase pour la requête
            $this->createFirebaseRequest($moovRequest);
            
            // Charger les relations nécessaires pour fetchDriversFromFirebase
            $moovRequest->load(['requestPlace', 'userDetail', 'zoneType.vehicleType']);
            
            // Assigner la requête aux drivers disponibles (Moov Money accepte tous les types de véhicules)
            $nearest_drivers = $this->fetchDriversForMoovMoney($moovRequest, $this->database);
            
            if ($nearest_drivers == null) {
                Log::warning('No drivers available for Moov Money request', [
                    'request_id' => $moovRequest->id,
                ]);
            }

            // Retourner la requête créée
            $result = fractal($moovRequest, new TripRequestTransformer);
            return $this->respondSuccess($result, 'Demande de dépôt Moov Money créée avec succès');

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Moov Money Deposit Request creation failed', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return $this->respondInternalError('Erreur lors de la création de la demande');
        }
    }

    /**
     * Create a Moov Money withdrawal request
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function createWithdrawalRequest(HttpRequest $request)
    {
        $validator = Validator::make($request->all(), [
            'pick_lat' => 'required|numeric',
            'pick_lng' => 'required|numeric',
            'pick_address' => 'required|string',
            'amount' => 'required|numeric|min:100',
            'phone_number' => 'required|string|max:20',
            'service_location_id' => 'nullable|uuid',
            'zone_type_id' => 'nullable|uuid',
            'payment_opt' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $user = auth()->user();
        
        // Utiliser des valeurs par défaut si non fournies
        $serviceLocationId = $request->service_location_id ?? \DB::table('service_locations')->first()->id ?? null;
        $zoneTypeId = $request->zone_type_id ?? \DB::table('zone_types')->first()->id ?? null;
        $paymentOpt = $request->payment_opt ?? '1';

        DB::beginTransaction();
        try {
            // NOUVEAU WORKFLOW: Ne PAS envoyer le USSD immédiatement
            // Le USSD sera envoyé uniquement quand le driver arrive
            
            Log::info('Moov Money: Creating withdrawal request WITHOUT sending USSD', [
                'user_id' => $user->id,
                'amount' => $request->amount,
                'phone' => $request->phone_number,
                'workflow' => 'deferred_ussd'
            ]);
            
            // Créer une réponse de type "pending" sans envoyer le USSD
            $apiResponse = [
                'success' => true,
                'transaction_id' => 'DEFERRED_' . strtoupper(uniqid()),
                'voucher_code' => 'PENDING_DRIVER_' . time(),
                'message' => 'Demande créée - En attente du driver',
                'warning' => 'USSD sera envoyé quand le driver arrive'
            ];

            // 2. Créer la transaction Moov Money
            $voucherCode = $apiResponse['transaction_id'] ?? MoovMoneyTransaction::generateVoucherCode();
            
            // Extraire seulement les chiffres du numéro de téléphone pour le code de validation
            $phoneDigitsOnly = preg_replace('/[^0-9]/', '', $request->phone_number);
            $validationValue = substr($phoneDigitsOnly, -4);

            $moovTransaction = MoovMoneyTransaction::create([
                'user_id' => $user->id,
                'transaction_type' => 'withdrawal',
                'status' => 'pending',
                'amount' => $request->amount,
                'currency' => 'XOF',
                'phone_number' => $request->phone_number,
                'voucher_code' => $voucherCode,
                'voucher_validation_value' => $validationValue,
                'voucher_expires_at' => Carbon::now()->addHours(24),
                'conversation_id' => $requestId ?? ($apiResponse['conversation_id'] ?? null),
                'transaction_id' => $apiResponse['transaction_id'] ?? null,
                'api_response' => json_encode($apiResponse),
            ]);

            // 3. Générer un numéro de requête unique
            $requestNumber = 'MM-RET-' . time() . '-' . rand(1000, 9999);
            
            // 3.1 Générer un code de sécurité à 6 chiffres
            $securityCode = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            // 4. Créer la requête (Request)
            $moovRequest = Request::create([
                'request_number' => $requestNumber,
                'user_id' => $user->id,
                'service_location_id' => $serviceLocationId,
                'zone_type_id' => $zoneTypeId,
                'transport_type' => 'delivery',
                'payment_opt' => $paymentOpt,
                'is_moov_money' => 1,
                'moov_money_type' => 'withdrawal',
                'moov_money_amount' => $request->amount,
                'moov_money_phone' => $request->phone_number,
                'moov_money_voucher_code' => $voucherCode,
                'moov_money_validation_code' => $validationValue,
                'moov_money_security_code' => $securityCode,
                'moov_money_transaction_id' => $moovTransaction->id,
                'moov_money_status' => 'pending',
                'is_later' => 0,
                'is_completed' => 0,
                'is_cancelled' => 0,
                'is_paid' => 0,
                'on_search' => 1, // Pour rotation automatique
                'assign_method' => 0, // Méthode d'assignation automatique
                'is_bid_ride' => 0,
                'timezone' => $request->timezone ?? 'UTC',
                'requested_currency_code' => 'XOF',
                'requested_currency_symbol' => 'FCFA',
                'unit' => 1,
            ]);

            // 5. Créer l'adresse de pickup
            $moovRequest->requestPlace()->create([
                'pick_lat' => $request->pick_lat,
                'pick_lng' => $request->pick_lng,
                'pick_address' => $request->pick_address,
                'drop_lat' => $request->pick_lat,
                'drop_lng' => $request->pick_lng,
                'drop_address' => $request->pick_address,
            ]);

            // 6. Calculer la commission Moov Money pour retrait
            $commissionRate = get_settings('moov_money_withdrawal_commission_rate') ?? 2.5;
            $moovCommission = ($request->amount * $commissionRate) / 100;
            
            // 6.1 Calculer la commission driver
            $driverCommissionRate = get_settings('moov_money_driver_commission_rate') ?? 1;
            $driverCommission = ($request->amount * $driverCommissionRate) / 100;
            
            // 7. Créer la facture
            // Note: distance_price sera mis à jour quand le driver accepte
            $moovRequest->requestBill()->create([
                'total_amount' => $moovCommission + $driverCommission,
                'base_price' => $moovCommission,
                'distance_price' => 0, // Sera calculé à l'acceptation
                'time_price' => 0,
                'tax_amount' => 0,
                'admin_commision' => $moovCommission,
                'driver_commision' => $driverCommission,
            ]);

            DB::commit();

            Log::info('Moov Money Withdrawal Request created', [
                'request_id' => $moovRequest->id,
                'transaction_id' => $moovTransaction->id,
                'voucher_code' => $voucherCode,
                'user_id' => $user->id,
                'amount' => $request->amount,
            ]);

            // Créer l'entrée Firebase pour la requête
            $this->createFirebaseRequest($moovRequest);
            
            // Charger les relations nécessaires pour fetchDriversFromFirebase
            $moovRequest->load(['requestPlace', 'userDetail', 'zoneType.vehicleType']);
            
            // Assigner la requête aux drivers disponibles (Moov Money accepte tous les types de véhicules)
            $nearest_drivers = $this->fetchDriversForMoovMoney($moovRequest, $this->database);
            
            if ($nearest_drivers == null) {
                Log::warning('No drivers available for Moov Money request', [
                    'request_id' => $moovRequest->id,
                ]);
            }

            // Lancer le job pour vérifier le statut après 30 secondes
            CheckMoovMoneyStatus::dispatch($moovRequest->id)->delay(now()->addSeconds(30));
            
            Log::info('Moov Money status check job dispatched', [
                'request_id' => $moovRequest->id
            ]);
            
            // Retourner la requête créée avec le voucher
            $result = fractal($moovRequest->load('moovMoneyTransaction'), new TripRequestTransformer);
            return $this->respondSuccess($result, 'Demande de retrait Moov Money créée avec succès');

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Moov Money Withdrawal Request creation failed', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return $this->respondInternalError('Erreur lors de la création de la demande: ' . $e->getMessage());
        }
    }

    /**
     * Fetch drivers for Moov Money requests (accepts all vehicle types)
     * 
     * @param Request $request_detail
     * @param Database $database
     * @return mixed
     */
    protected function fetchDriversForMoovMoney($request_detail, $database)
    {
        if ($request_detail->requestMeta()->exists()) {
            return null;
        }

        $pick_lat = $request_detail->pick_lat;
        $pick_lng = $request_detail->pick_lng;
        $driver_search_radius = get_settings('driver_search_radius') ?: 30;
        
        $radius = kilometer_to_miles($driver_search_radius);
        $calculatable_radius = ($radius / 2);

        $calulatable_lat = 0.0144927536231884 * $calculatable_radius;
        $calulatable_long = 0.0181818181818182 * $calculatable_radius;

        $lower_lat = ($pick_lat - $calulatable_lat);
        $lower_long = ($pick_lng - $calulatable_long);
        $higher_lat = ($pick_lat + $calulatable_lat);
        $higher_long = ($pick_lng + $calulatable_long);

        $g = new \Sk\Geohash\Geohash();
        $lower_hash = $g->encode($lower_lat, $lower_long, 12);
        $higher_hash = $g->encode($higher_lat, $higher_long, 12);

        // Augmenté de 7 à 30 minutes pour permettre aux drivers de recevoir les requêtes
        $conditional_timestamp = Carbon::now()->subMinutes(30)->timestamp;

        $fire_drivers = $database->getReference('drivers')
            ->orderByChild('g')
            ->startAt($lower_hash)
            ->endAt($higher_hash)
            ->getValue();
        
        $firebase_drivers = [];

        if ($fire_drivers) {
            foreach ($fire_drivers as $key => $fire_driver) {
                $driver_updated_at = Carbon::createFromTimestamp($fire_driver['updated_at'] / 1000)->timestamp;

                // Pour Moov Money, on accepte tous les types de véhicules
                // On vérifie seulement que le driver est actif, disponible et à jour
                if (
                    $fire_driver['is_active'] == 1 && 
                    $fire_driver['is_available'] == 1 && 
                    $conditional_timestamp < $driver_updated_at
                ) {
                    $distance = distance_between_two_coordinates(
                        $pick_lat,
                        $pick_lng,
                        $fire_driver['l'][0],
                        $fire_driver['l'][1],
                        'K'
                    );

                    if ($distance <= $driver_search_radius) {
                        $firebase_drivers[$fire_driver['id']]['distance'] = $distance;
                    }
                }
            }
        }
        
        asort($firebase_drivers);
        $current_date = Carbon::now();

        if (!empty($firebase_drivers)) {
            Log::info('Drivers found for Moov Money request', [
                'request_id' => $request_detail->id,
                'drivers_count' => count($firebase_drivers),
            ]);

            foreach ($firebase_drivers as $key => $firebase_driver) {
                $database->getReference('requests/' . $request_detail->id)->update([
                    'updated_at' => $current_date->timestamp,
                ]);

                $driver_detail = \App\Models\Admin\Driver::where('id', $key)->first();

                if ($driver_detail) {
                    $request_detail->requestMeta()->create([
                        'request_id' => $request_detail->id,
                        'driver_id' => $driver_detail->id,
                        'active' => 1,
                    ]);
                    
                    // ✅ Créer aussi dans Firebase request-meta avec IDs en String
                    $database->getReference('request-meta/' . $request_detail->id)->set([
                        'driver_id' => (string)$driver_detail->id,
                        'request_id' => (string)$request_detail->id,
                        'user_id' => (string)$request_detail->user_id,
                        'active' => 1,
                        'updated_at' => ['sv' => 'timestamp'],
                    ]);

                    // ✅ FIX: Récupérer l'objet User du driver
                    $notifiable_driver = $driver_detail->user;
                    
                    // Notification spécifique pour Moov Money
                    $title = 'Nouvelle demande Moov Money';
                    $body = 'Demande de ' . $request_detail->moov_money_type . ' - ' . $request_detail->moov_money_amount . ' FCFA';
                    
                    // Données additionnelles pour l'app driver
                    $notification_data = [
                        'request_id' => $request_detail->id,
                        'is_moov_money' => 1,
                        'moov_money_type' => $request_detail->moov_money_type,
                        'moov_money_amount' => $request_detail->moov_money_amount,
                        'moov_money_phone' => $request_detail->moov_money_phone,
                        'moov_money_security_code' => $request_detail->moov_money_security_code,
                        'type' => 'new_moov_money_request',
                    ];

                    dispatch(new \App\Jobs\Notifications\SendPushNotification(
                        $notifiable_driver, 
                        $title, 
                        $body,
                        $notification_data
                    ));
                }
            }
        }

        return $firebase_drivers;
    }

    /**
     * Calculate commission for Moov Money transaction
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function calculateCommission(HttpRequest $request)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:100',
            'type' => 'required|in:deposit,withdrawal',
        ]);

        if ($validator->fails()) {
            return $this->respondBadRequest('Validation failed', $validator->errors());
        }

        $amount = $request->amount;
        $type = $request->type;

        // Récupérer les taux de commission depuis les settings
        // Par défaut: 2% pour dépôt, 2.5% pour retrait
        $depositRate = get_settings('moov_money_deposit_commission_rate') ?: 0.02;
        $withdrawalRate = get_settings('moov_money_withdrawal_commission_rate') ?: 0.025;

        $commissionRate = $type === 'deposit' ? $depositRate : $withdrawalRate;
        $commission = round($amount * $commissionRate, 2);
        $total = $amount + $commission;

        return $this->respondSuccess([
            'commission' => $commission,
            'total' => $total,
            'commission_rate' => $commissionRate * 100, // En pourcentage
        ], 'Commission calculée avec succès');
    }

    /**
     * Get user's Moov Money request history
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function myRequests(HttpRequest $request)
    {
        $user = auth()->user();
        
        $query = Request::where('user_id', $user->id)
            ->where('is_moov_money', 1);
        
        // Filtrer par type (deposit ou withdrawal)
        if ($request->has('type') && in_array($request->type, ['deposit', 'withdrawal'])) {
            $query->where('moov_money_type', $request->type);
        }
        
        // Filtrer par statut
        if ($request->has('status')) {
            $statusMap = [
                'pending' => ['pending', 'assigned'],
                'in_progress' => ['in_progress'],
                'completed' => ['completed'],
                'cancelled' => ['cancelled'],
            ];
            
            if (isset($statusMap[$request->status])) {
                $query->whereIn('is_completed', $statusMap[$request->status] === ['completed'] ? [1] : [0])
                      ->whereIn('is_cancelled', $statusMap[$request->status] === ['cancelled'] ? [1] : [0]);
            }
        }
        
        $requests = $query->with(['requestPlace', 'driverDetail.user', 'moovMoneyTransaction'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);
        
        $result = fractal($requests, new TripRequestTransformer);
        return $this->respondSuccess($result, 'Historique récupéré avec succès');
    }

    /**
     * Get details of a specific Moov Money request
     * 
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $user = auth()->user();
        
        $request = Request::where('id', $id)
            ->where('user_id', $user->id)
            ->where('is_moov_money', 1)
            ->with(['requestPlace', 'driverDetail.user', 'moovMoneyTransaction', 'requestBill'])
            ->first();
        
        if (!$request) {
            return $this->respondNotFound('Demande non trouvée');
        }
        
        $result = fractal($request, new TripRequestTransformer);
        
        // Ajouter des informations supplémentaires pour les transactions terminées
        $data = $result->toArray();
        $data['is_completed_transaction'] = $request->is_completed == 1;
        $data['is_cancelled_transaction'] = $request->is_cancelled == 1;
        $data['can_track'] = $request->is_completed == 0 && $request->is_cancelled == 0;
        $data['show_history_view'] = $request->is_completed == 1 || $request->is_cancelled == 1;
        
        return $this->respondSuccess($data, 'Détails récupérés avec succès');
    }

    /**
     * Cancel a Moov Money request
     * 
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancel($id)
    {
        $user = auth()->user();
        
        $request = Request::where('id', $id)
            ->where('user_id', $user->id)
            ->where('is_moov_money', 1)
            ->where('is_completed', 0)
            ->where('is_cancelled', 0)
            ->first();
        
        if (!$request) {
            return $this->respondNotFound('Demande non trouvée ou déjà terminée');
        }

        // Vérifier que la demande n'est pas déjà en cours de traitement
        if ($request->moov_money_status === 'processing') {
            return $this->respondBadRequest('Impossible d\'annuler une demande en cours de traitement');
        }

        DB::beginTransaction();
        try {
            // Mettre à jour le statut de la requête
            $request->update([
                'is_cancelled' => 1,
                'cancel_reason' => 'Annulée par l\'utilisateur',
                'cancelled_at' => Carbon::now(),
                'moov_money_status' => 'failed',
            ]);

            // Mettre à jour la transaction Moov Money
            if ($request->moovMoneyTransaction) {
                $request->moovMoneyTransaction->update([
                    'status' => 'cancelled',
                    'cancelled_at' => Carbon::now(),
                ]);
            }

            // Supprimer de Firebase si elle est en recherche
            if ($request->on_search) {
                $this->database->getReference('requests/' . $request->id)->remove();
            }

            // Supprimer les requestMeta (drivers notifiés)
            $request->requestMeta()->delete();

            DB::commit();

            Log::info('Moov Money Request cancelled', [
                'request_id' => $request->id,
                'user_id' => $user->id,
            ]);

            $result = fractal($request, new TripRequestTransformer);
            return $this->respondSuccess($result, 'Demande annulée avec succès');

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Moov Money Request cancellation failed', [
                'error' => $e->getMessage(),
                'request_id' => $id,
                'user_id' => $user->id,
            ]);

            return $this->respondInternalError('Erreur lors de l\'annulation de la demande');
        }
    }
    
    /**
     * Créer l'entrée Firebase pour une requête Moov Money
     * 
     * @param Request $request
     * @return void
     */
    private function createFirebaseRequest($request)
    {
        try {
            $requestPlace = $request->requestPlace;
            
            // Déterminer le statut pour Firebase
            $firebaseStatus = 'pending'; // Par défaut
            
            if ($request->is_completed) {
                $firebaseStatus = 'completed';
            } elseif ($request->is_cancelled) {
                $firebaseStatus = 'cancelled';
            } elseif ($request->driver_id) {
                $firebaseStatus = 'accepted';
            }
            
            $requestData = [
                // ✅ Convertir tous les IDs en String pour éviter les erreurs de type dans Flutter
                'id' => (string)$request->id,
                'request_id' => (string)$request->id,
                'request_number' => (string)$request->request_number,
                'user_id' => (string)$request->user_id,
                'driver_id' => $request->driver_id ? (string)$request->driver_id : null,
                'service_location_id' => (string)$request->service_location_id,
                'zone_type_id' => (string)$request->zone_type_id,
                
                // ✅ CHAMP STATUS (IMPORTANT!)
                'status' => (string)$firebaseStatus,
                
                // Informations Moov Money
                'is_moov_money' => true,
                'moov_money_type' => (string)$request->moov_money_type,
                'moov_money_amount' => (string)$request->moov_money_amount,
                'moov_money_phone' => (string)$request->moov_money_phone,
                'moov_money_status' => (string)$request->moov_money_status,
                'moov_money_security_code' => (string)$request->moov_money_security_code,
                
                // Type de transport
                'transport_type' => 'delivery',
                
                // États
                'is_completed' => $request->is_completed,
                'is_cancelled' => $request->is_cancelled,
                'on_search' => $request->on_search,
                
                // Localisation
                'pick_lat' => (float)$requestPlace->pick_lat,
                'pick_lng' => (float)$requestPlace->pick_lng,
                'pick_address' => (string)$requestPlace->pick_address,
                
                // Timestamps
                'created_at' => now()->timestamp,
                'updated_at' => now()->timestamp,
                'active' => 1,
                'date' => (string)now()->timestamp,
            ];
            
            // Ajouter les codes pour les retraits
            if ($request->moov_money_type === 'withdrawal') {
                $requestData['moov_money_voucher_code'] = $request->moov_money_voucher_code;
                $requestData['moov_money_validation_code'] = $request->moov_money_validation_code;
            }
            
            // Ajouter les infos du driver si assigné
            if ($request->driver_id && $request->driverDetail) {
                $requestData['driver_name'] = $request->driverDetail->user->name ?? '';
            }
            
            // Créer dans les deux emplacements Firebase
            $this->database->getReference('requests/' . $request->id)->set($requestData);
            $this->database->getReference('requests/new-request/' . $request->id)->set($requestData);
            
            Log::info('✅ Firebase request created for Moov Money', [
                'request_id' => $request->id,
                'type' => $request->moov_money_type,
                'status' => $firebaseStatus,
                'data_keys' => array_keys($requestData),
            ]);
            
        } catch (\Exception $e) {
            Log::error('❌ Failed to create Firebase request for Moov Money', [
                'error' => $e->getMessage(),
                'request_id' => $request->id,
                'trace' => $e->getTraceAsString(),
            ]);
        }
    }
    
    /**
     * Mettre à jour le statut Firebase d'une requête Moov Money
     * 
     * @param Request $request
     * @param string $status
     * @return void
     */
    private function updateFirebaseRequestStatus($request, $status)
    {
        try {
            $updateData = [
                'status' => $status,
                'moov_money_status' => $status,
                'updated_at' => now()->timestamp,
            ];
            
            // Ajouter des champs spécifiques selon le statut
            switch ($status) {
                case 'accepted':
                case 'assigned':
                    if ($request->driver_id) {
                        $updateData['driver_id'] = $request->driver_id;
                        if ($request->driverDetail) {
                            $updateData['driver_name'] = $request->driverDetail->user->name ?? '';
                        }
                    }
                    break;
                    
                case 'processing':
                    $updateData['is_driver_started'] = 1;
                    break;
                    
                case 'completed':
                    $updateData['is_completed'] = 1;
                    $updateData['completed_at'] = now()->timestamp;
                    break;
                    
                case 'cancelled':
                    $updateData['is_cancelled'] = 1;
                    $updateData['cancelled_at'] = now()->timestamp;
                    $updateData['cancel_reason'] = $request->cancel_reason ?? 'Annulée';
                    break;
            }
            
            $this->database->getReference('requests/' . $request->id)->update($updateData);
            
            Log::info('✅ Firebase status updated for Moov Money', [
                'request_id' => $request->id,
                'status' => $status,
                'update_keys' => array_keys($updateData),
            ]);
            
        } catch (\Exception $e) {
            Log::error('❌ Failed to update Firebase status for Moov Money', [
                'error' => $e->getMessage(),
                'request_id' => $request->id,
                'status' => $status,
            ]);
        }
    }
    
    /**
     * Obtenir les statistiques des transactions Moov Money de l'utilisateur
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getStatistics(HttpRequest $request)
    {
        $user = auth()->user();
        
        $query = Request::where('user_id', $user->id)
            ->where('is_moov_money', 1);
        
        // Filtrer par période
        if ($request->has('period')) {
            switch ($request->period) {
                case 'today':
                    $query->whereDate('created_at', Carbon::today());
                    break;
                case 'week':
                    $query->whereBetween('created_at', [
                        Carbon::now()->startOfWeek(),
                        Carbon::now()->endOfWeek()
                    ]);
                    break;
                case 'month':
                    $query->whereMonth('created_at', Carbon::now()->month)
                          ->whereYear('created_at', Carbon::now()->year);
                    break;
                case 'year':
                    $query->whereYear('created_at', Carbon::now()->year);
                    break;
            }
        }
        
        $stats = [
            // Totaux par type
            'total_deposits' => (clone $query)->where('moov_money_type', 'deposit')->count(),
            'total_withdrawals' => (clone $query)->where('moov_money_type', 'withdrawal')->count(),
            
            // Totaux par statut
            'total_completed' => (clone $query)->where('is_completed', 1)->count(),
            'total_cancelled' => (clone $query)->where('is_cancelled', 1)->count(),
            'total_pending' => (clone $query)->where('moov_money_status', 'pending')->count(),
            'total_processing' => (clone $query)->where('moov_money_status', 'processing')->count(),
            
            // Montants
            'amount_deposits' => (clone $query)
                ->where('moov_money_type', 'deposit')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'amount_withdrawals' => (clone $query)
                ->where('moov_money_type', 'withdrawal')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'total_amount' => (clone $query)
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            
            // Total général
            'total_transactions' => $query->count(),
        ];
        
        return $this->respondSuccess($stats, 'Statistiques récupérées avec succès');
    }
    
    /**
     * Obtenir le résumé des transactions par période
     * 
     * @param HttpRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function getSummary(HttpRequest $request)
    {
        $user = auth()->user();
        
        // Résumé par période
        $summary = [
            'today' => $this->getSummaryByPeriod($user->id, 'today'),
            'week' => $this->getSummaryByPeriod($user->id, 'week'),
            'month' => $this->getSummaryByPeriod($user->id, 'month'),
            'year' => $this->getSummaryByPeriod($user->id, 'year'),
            'all_time' => $this->getSummaryByPeriod($user->id, 'all'),
        ];
        
        // Graphique des 7 derniers jours
        $last7Days = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::today()->subDays($i);
            $dayData = [
                'date' => $date->format('Y-m-d'),
                'day' => $date->format('D'),
                'deposits' => Request::where('user_id', $user->id)
                    ->where('is_moov_money', 1)
                    ->where('moov_money_type', 'deposit')
                    ->whereDate('created_at', $date)
                    ->count(),
                'withdrawals' => Request::where('user_id', $user->id)
                    ->where('is_moov_money', 1)
                    ->where('moov_money_type', 'withdrawal')
                    ->whereDate('created_at', $date)
                    ->count(),
                'amount' => Request::where('user_id', $user->id)
                    ->where('is_moov_money', 1)
                    ->where('is_completed', 1)
                    ->whereDate('completed_at', $date)
                    ->sum('moov_money_amount'),
            ];
            $last7Days[] = $dayData;
        }
        
        return $this->respondSuccess([
            'summary' => $summary,
            'chart' => $last7Days,
        ], 'Résumé récupéré avec succès');
    }
    
    /**
     * Obtenir le résumé par période
     * 
     * @param int $userId
     * @param string $period
     * @return array
     */
    private function getSummaryByPeriod($userId, $period)
    {
        $query = Request::where('user_id', $userId)
            ->where('is_moov_money', 1);
        
        switch ($period) {
            case 'today':
                $query->whereDate('created_at', Carbon::today());
                break;
            case 'week':
                $query->whereBetween('created_at', [
                    Carbon::now()->startOfWeek(),
                    Carbon::now()->endOfWeek()
                ]);
                break;
            case 'month':
                $query->whereMonth('created_at', Carbon::now()->month)
                      ->whereYear('created_at', Carbon::now()->year);
                break;
            case 'year':
                $query->whereYear('created_at', Carbon::now()->year);
                break;
            case 'all':
                // Pas de filtre
                break;
        }
        
        return [
            'total_transactions' => $query->count(),
            'total_completed' => (clone $query)->where('is_completed', 1)->count(),
            'total_amount' => (clone $query)->where('is_completed', 1)->sum('moov_money_amount'),
            'deposits' => (clone $query)->where('moov_money_type', 'deposit')->count(),
            'withdrawals' => (clone $query)->where('moov_money_type', 'withdrawal')->count(),
            'amount_deposits' => (clone $query)
                ->where('moov_money_type', 'deposit')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
            'amount_withdrawals' => (clone $query)
                ->where('moov_money_type', 'withdrawal')
                ->where('is_completed', 1)
                ->sum('moov_money_amount'),
        ];
    }

    /**
     * Annuler une demande MoovMoney
     * 
     * @param HttpRequest $request
     * @param string $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancelRequest(HttpRequest $request, $id)
    {
        try {
            $user = $request->user();
            
            Log::info('Tentative annulation MoovMoney', [
                'request_id' => $id,
                'user_id' => $user->id,
                'reason' => $request->input('reason'),
            ]);
            
            // Récupérer la demande
            $moovRequest = Request::where('id', $id)
                ->where('user_id', $user->id)
                ->whereNotNull('moov_money_type')
                ->first();
            
            if (!$moovRequest) {
                Log::warning('Demande MoovMoney introuvable', [
                    'request_id' => $id,
                    'user_id' => $user->id,
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Demande non trouvée'
                ], 404);
            }
            
            // Vérifier que la demande peut être annulée
            $cancelableStatuses = ['pending', 'searching', 'accepted'];
            if (!in_array($moovRequest->moov_money_status, $cancelableStatuses)) {
                Log::warning('Demande MoovMoney non annulable', [
                    'request_id' => $id,
                    'status' => $moovRequest->moov_money_status,
                ]);
                
                return response()->json([
                    'success' => false,
                    'message' => 'Cette demande ne peut plus être annulée (statut: ' . $moovRequest->moov_money_status . ')'
                ], 400);
            }
            
            // Annuler la demande ET la course
            $moovRequest->update([
                'moov_money_status' => 'cancelled',
                'is_cancelled' => 1,  // Annuler la course
                'cancel_method' => 'user',
                'cancelled_at' => now(),
                'cancel_reason' => $request->input('reason', 'Annulé par l\'utilisateur'),
            ]);
            
            // Libérer le driver s'il y en a un assigné
            if ($moovRequest->driver_id) {
                $driver = \App\Models\Admin\Driver::find($moovRequest->driver_id);
                if ($driver) {
                    $driver->update([
                        'available' => true,
                        'is_available' => true,
                    ]);
                    Log::info('Driver libéré après annulation', [
                        'driver_id' => $driver->id,
                        'request_id' => $id,
                    ]);
                }
            }
            
            // Mettre à jour Firebase
            try {
                $reference = $this->database->getReference('moov_money_requests/' . $id);
                $reference->update([
                    'status' => 'cancelled',
                    'moov_money_status' => 'cancelled',
                    'is_cancelled' => true,
                    'cancelled_at' => now()->toIso8601String(),
                    'cancel_reason' => $request->input('reason', 'Annulé par l\'utilisateur'),
                    '_firebase_status' => 'cancelled',
                    '_firebase_updated_at' => now()->toIso8601String(),
                ]);
            } catch (\Exception $e) {
                Log::error('Erreur mise à jour Firebase', [
                    'request_id' => $id,
                    'error' => $e->getMessage(),
                ]);
            }
            
            Log::info('Demande MoovMoney annulée avec succès', [
                'request_id' => $id,
                'user_id' => $user->id,
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Demande annulée avec succès',
                'data' => [
                    'id' => $moovRequest->id,
                    'request_number' => $moovRequest->request_number,
                    'status' => $moovRequest->status,
                    'moov_money_status' => $moovRequest->moov_money_status,
                    'cancelled_at' => $moovRequest->cancelled_at,
                    'cancelled_reason' => $moovRequest->cancelled_reason,
                ],
            ]);
            
        } catch (\Exception $e) {
            Log::error('Erreur annulation MoovMoney', [
                'request_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur serveur: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * User confirms payment after driver completes transaction
     * 
     * @param string $id Request ID
     * @return \Illuminate\Http\JsonResponse
     */
    public function confirmPayment($id)
    {
        $user = auth()->user();
        
        try {
            $moovRequest = Request::where('id', $id)
                ->where('user_id', $user->id)
                ->where('is_moov_money', 1)
                ->where('moov_money_status', 'waiting_payment')
                ->firstOrFail();
            
            DB::beginTransaction();
            
            // Marquer comme payé et complété
            $moovRequest->update([
                'is_paid' => 1,
                'is_completed' => 1,
                'completed_at' => now(),
                'moov_money_status' => 'completed',
            ]);
            
            DB::commit();
            
            // Mettre à jour Firebase avec statut completed
            $this->updateMoovMoneyFirebaseStatus($moovRequest, 'completed', 'Transaction complétée avec succès');
            
            Log::info('User confirmed Moov Money payment', [
                'request_id' => $id,
                'user_id' => $user->id,
                'type' => $moovRequest->moov_money_type,
                'amount' => $moovRequest->moov_money_amount,
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Paiement confirmé avec succès',
                'data' => [
                    'request' => $moovRequest,
                ],
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            Log::error('Error confirming Moov Money payment', [
                'request_id' => $id,
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la confirmation: ' . $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Update Moov Money request status in Firebase
     */
    private function updateMoovMoneyFirebaseStatus($request, $status, $message)
    {
        try {
            // Mettre à jour la référence principale que l'app user lit
            $reference = $this->database->getReference('requests/' . $request->id);
            $reference->update([
                'moov_money_status' => $status,
                'status' => $status, // Pour compatibilité
                'is_completed' => $status === 'completed' ? 1 : 0,
                'is_cancelled' => $status === 'cancelled' ? 1 : 0,
                'status_message' => $message,
                'updated_at' => now()->timestamp,
            ]);
            
            Log::info('Firebase status updated successfully', [
                'request_id' => $request->id,
                'status' => $status,
                'message' => $message,
            ]);
        } catch (\Exception $e) {
            Log::error('Error updating Firebase status', [
                'request_id' => $request->id,
                'status' => $status,
                'error' => $e->getMessage(),
            ]);
        }
    }
    
    /**
     * Remove request from Firebase
     */
    private function removeRequestFromFirebase($request)
    {
        try {
            $reference = $this->database->getReference('moov_money_requests/' . $request->id);
            $reference->remove();
            
            Log::info('Removed Moov Money request from Firebase', [
                'request_id' => $request->id,
            ]);
        } catch (\Exception $e) {
            Log::error('Error removing request from Firebase', [
                'request_id' => $request->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
    
    /**
     * Get simplified transaction history for user
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function transactionHistory()
    {
        $user = auth()->user();
        
        $transactions = Request::where('user_id', $user->id)
            ->where('is_moov_money', 1)
            ->with(['moovMoneyTransaction', 'requestBill'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($request) {
                return [
                    'id' => $request->id,
                    'request_number' => $request->request_number,
                    'type' => $request->moov_money_type, // 'deposit' or 'withdrawal'
                    'status' => $request->moov_money_status,
                    'amount' => $request->moov_money_amount,
                    'phone' => $request->moov_money_phone,
                    'commission' => $request->requestBill ? $request->requestBill->admin_commision : 0,
                    'total' => $request->requestBill ? $request->requestBill->total_amount : 0,
                    'date' => $request->created_at->toIso8601String(),
                    'completed_at' => $request->completed_at ? $request->completed_at->toIso8601String() : null,
                    'is_completed' => $request->is_completed == 1,
                    'is_cancelled' => $request->is_cancelled == 1,
                ];
            });
        
        return response()->json([
            'success' => true,
            'message' => 'Historique récupéré avec succès',
            'data' => $transactions,
        ]);
    }

    /**
     * Vérifier le statut d'une transaction directement auprès de Moov Money
     * Utilise la même authentification que Cash In qui fonctionne
     */
    public function verifyTransactionStatus($requestId)
    {
        try {
            $request = Request::where('id', $requestId)
                ->where('is_moov_money', 1)
                ->first();

            if (!$request) {
                return response()->json([
                    'success' => false,
                    'message' => 'Demande non trouvée'
                ], 404);
            }

            // Utiliser le service de vérification de statut
            $statusService = new MoovMoneyStatusService();
            
            // Vérifier via un Cash In de montant minimal (méthode qui fonctionne)
            $verification = $statusService->verifyTransactionViaMinimalAmount(
                $request->moov_money_phone,
                $request->moov_money_voucher_code
            );

            Log::info('Manual status verification', [
                'request_id' => $requestId,
                'result' => $verification
            ]);

            // Si la vérification réussit et le compte est actif
            if ($verification['success'] && $verification['account_active']) {
                // Marquer comme complété
                $request->moov_money_status = 'completed';
                $request->save();

                // Envoyer une notification
                $this->notifyTransactionCompleted($request);

                return response()->json([
                    'success' => true,
                    'message' => 'Transaction vérifiée et confirmée',
                    'data' => [
                        'status' => 'completed',
                        'verified_at' => now()->toIso8601String(),
                        'verification_result' => $verification
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Impossible de vérifier la transaction',
                'data' => $verification
            ]);

        } catch (\Exception $e) {
            Log::error('Transaction verification error', [
                'error' => $e->getMessage(),
                'request_id' => $requestId
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la vérification',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Vérifier le solde Moov Money de l'utilisateur
     */
    public function checkBalance(HttpRequest $request)
    {
        try {
            $user = auth()->user();
            
            // Récupérer le numéro de téléphone
            $phoneNumber = $request->input('phone_number') ?? $user->mobile;
            
            if (!$phoneNumber) {
                return response()->json([
                    'success' => false,
                    'message' => 'Numéro de téléphone non trouvé'
                ], 400);
            }
            
            Log::info('User checking Moov Money balance', [
                'user_id' => $user->id,
                'phone' => $phoneNumber
            ]);
            
            $result = $this->moovMoneyService->checkBalance($phoneNumber);
            
            return response()->json([
                'success' => true,
                'data' => [
                    'balance' => $result['balance'] ?? 0,
                    'bonus' => $result['bonus'] ?? 0,
                    'message' => $result['message'] ?? '',
                    'phone' => $phoneNumber
                ]
            ]);
            
        } catch (\Exception $e) {
            Log::error('Error checking Moov Money balance', [
                'error' => $e->getMessage()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la vérification du solde: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Notifier que la transaction est complétée
     */
    private function notifyTransactionCompleted($request)
    {
        try {
            $user = \App\Models\User::find($request->user_id);
            if (!$user || !$user->device_token) {
                return;
            }

            $firebaseService = new FirebaseService();
            $message = "Votre retrait de " . number_format($request->moov_money_amount, 0, ',', ' ') . 
                      " FCFA a été confirmé. Code: " . $request->moov_money_voucher_code;

            $firebaseService->sendNotification(
                $user->device_token,
                'Transaction confirmée',
                $message,
                [
                    'type' => 'moov_money_completed',
                    'request_id' => $request->id,
                    'voucher_code' => $request->moov_money_voucher_code
                ]
            );

        } catch (\Exception $e) {
            Log::error('Failed to send completion notification', [
                'error' => $e->getMessage()
            ]);
        }
    }
}
