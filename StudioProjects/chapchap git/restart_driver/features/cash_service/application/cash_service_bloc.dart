import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/repositories/cash_service_repository.dart';
import '../domain/models/cash_request_model.dart';

part 'cash_service_events.dart';
part 'cash_service_states.dart';

class CashServiceBloc extends Bloc<CashServiceEvent, CashServiceState> {
  final CashServiceRepository _repository;
  Timer? _refreshTimer;
  StreamSubscription<Position>? _positionSubscription;

  CashServiceBloc({
    required CashServiceRepository repository,
  })  : _repository = repository,
        super(const CashServiceInitial()) {
    
    // Enregistrement des handlers d'événements
    on<LoadAvailableCashRequests>(_onLoadAvailableCashRequests);
    on<RefreshAvailableCashRequests>(_onRefreshAvailableCashRequests);
    on<LoadMyCashRequests>(_onLoadMyCashRequests);
    on<AcceptCashRequest>(_onAcceptCashRequest);
    on<PerformCashOut>(_onPerformCashOut);
    on<PerformCashIn>(_onPerformCashIn);
    on<ValidateSecurityCode>(_onValidateSecurityCode);
    on<UploadProofPhoto>(_onUploadProofPhoto);
    on<UpdateDriverLocation>(_onUpdateDriverLocation);
    on<FilterCashRequestsByType>(_onFilterCashRequestsByType);
    on<SortCashRequests>(_onSortCashRequests);
    on<SelectCashRequest>(_onSelectCashRequest);
    on<StartNavigationToCashRequest>(_onStartNavigationToCashRequest);
    on<MarkArrivedAtClient>(_onMarkArrivedAtClient);
    on<UpdateRequestStatus>(_onUpdateRequestStatus);
    on<ClearCashServiceError>(_onClearCashServiceError);

    // Démarrer le rafraîchissement automatique
    _startAutoRefresh();
    
    // Démarrer le suivi de position
    _startLocationTracking();
  }

  /// Charge les demandes cash disponibles
  Future<void> _onLoadAvailableCashRequests(
    LoadAvailableCashRequests event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(const CashServiceLoading(message: 'Chargement des demandes...'));

    try {
      final availableResponse = await _repository.getAvailableRequests();
      final myResponse = await _repository.getMyRequests();

      if (availableResponse.success && myResponse.success) {
        final availableRequests = availableResponse.data;
        final myRequests = myResponse.data;

        // Calculer les distances si on a la position du driver
        final updatedAvailableRequests = await _updateRequestsWithDistances(availableRequests);

        emit(CashServiceLoaded(
          availableRequests: updatedAvailableRequests,
          myRequests: myRequests,
          filteredRequests: updatedAvailableRequests,
          sortCriteria: CashRequestSortCriteria.distance,
        ));
      } else {
        emit(const CashServiceError(
          message: 'Erreur lors du chargement des demandes',
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
      ));
    }
  }

  /// Rafraîchit les demandes cash disponibles
  Future<void> _onRefreshAvailableCashRequests(
    RefreshAvailableCashRequests event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      try {
        final availableResponse = await _repository.getAvailableRequests();
        final myResponse = await _repository.getMyRequests();

        if (availableResponse.success && myResponse.success) {
          final availableRequests = availableResponse.data;
          final myRequests = myResponse.data;

          final updatedAvailableRequests = await _updateRequestsWithDistances(availableRequests);
          final filteredRequests = _applyFiltersAndSort(
            updatedAvailableRequests,
            currentState.filterType,
            currentState.sortCriteria,
          );

          emit(currentState.copyWith(
            availableRequests: updatedAvailableRequests,
            myRequests: myRequests,
            filteredRequests: filteredRequests,
            isRefreshing: false,
          ));
        } else {
          emit(currentState.copyWith(isRefreshing: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
      }
    } else {
      add(const LoadAvailableCashRequests());
    }
  }

  /// Charge les demandes assignées au driver
  Future<void> _onLoadMyCashRequests(
    LoadMyCashRequests event,
    Emitter<CashServiceState> emit,
  ) async {
    try {
      final response = await _repository.getMyRequests();
      
      if (response.success && state is CashServiceLoaded) {
        final currentState = state as CashServiceLoaded;
        emit(currentState.copyWith(myRequests: response.data));
      }
    } catch (e) {
      // Ignore les erreurs pour ne pas perturber l'état principal
    }
  }

  /// Accepte une demande cash
  Future<void> _onAcceptCashRequest(
    AcceptCashRequest event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'accepting',
      requestId: event.requestId,
      message: 'Acceptation de la demande...',
    ));

    try {
      final response = await _repository.acceptRequest(
        requestId: event.requestId,
        requestType: event.requestType,
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'accepting',
          requestId: event.requestId,
          message: response.message,
          data: response.data,
        ));

        // Recharger les demandes
        add(const RefreshAvailableCashRequests());
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.message,
          operationType: 'accepting',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'accepting',
        requestId: event.requestId,
      ));
    }
  }

  /// Effectue une opération Cash Out
  Future<void> _onPerformCashOut(
    PerformCashOut event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'cash_out',
      requestId: event.requestId,
      message: 'Opération Cash Out en cours...',
    ));

    try {
      final response = await _repository.performCashOut(
        requestId: event.requestId,
        clientPhoneNumber: event.clientPhoneNumber,
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'cash_out',
          requestId: event.requestId,
          message: response.message ?? 'Cash out effectué avec succès',
          data: {
            'transaction_id': response.transactionId,
            'originator_conversation_id': response.originatorConversationId,
          },
        ));

        // Recharger les demandes pour voir le nouveau statut
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.error ?? response.message,
          operationType: 'cash_out',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'cash_out',
        requestId: event.requestId,
      ));
    }
  }

  /// Effectue une opération Cash In
  Future<void> _onPerformCashIn(
    PerformCashIn event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'cash_in',
      requestId: event.requestId,
      message: 'Opération Cash In en cours...',
    ));

    try {
      final response = await _repository.performCashIn(
        requestId: event.requestId,
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'cash_in',
          requestId: event.requestId,
          message: response.message ?? 'Cash in effectué avec succès. Le wallet du client a été crédité.',
          data: {
            'transaction_id': response.transactionId,
            'originator_conversation_id': response.originatorConversationId,
          },
        ));

        // Recharger les demandes pour voir le nouveau statut
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.error ?? response.message,
          operationType: 'cash_in',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'cash_in',
        requestId: event.requestId,
      ));
    }
  }

  /// Valide le code de sécurité
  Future<void> _onValidateSecurityCode(
    ValidateSecurityCode event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'validating',
      requestId: event.requestId,
      message: 'Validation du code...',
    ));

    try {
      final response = await _repository.validateSecurityCode(
        requestId: event.requestId,
        requestType: event.requestType,
        securityCode: event.securityCode,
      );

      if (response.success) {
        // NE PAS déclencher automatiquement le Cash In/Out
        // Le driver devra le faire manuellement pour voir les résultats SOAP
        
        emit(CashServiceOperationSuccess(
          operationType: 'validating',
          requestId: event.requestId,
          message: 'Code validé avec succès. Vous pouvez maintenant effectuer le dépôt/retrait.',
        ));

        // Recharger les demandes pour voir le nouveau statut 'verified'
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.message,
          operationType: 'validating',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'validating',
        requestId: event.requestId,
      ));
    }
  }

  /// Upload une photo de preuve
  Future<void> _onUploadProofPhoto(
    UploadProofPhoto event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'uploading',
      requestId: event.requestId,
      message: 'Upload de la photo...',
    ));

    try {
      final response = await _repository.uploadProofPhoto(
        requestId: event.requestId,
        requestType: event.requestType,
        photoPath: event.photoPath,
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'uploading',
          requestId: event.requestId,
          message: response.message,
          data: response.data,
        ));
      } else {
        emit(CashServiceError(
          message: response.message,
          operationType: 'uploading',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'uploading',
        requestId: event.requestId,
      ));
    }
  }

  /// Met à jour la position du driver
  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocation event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      
      // Recalculer les distances
      final updatedRequests = await _updateRequestsWithDistances(
        currentState.availableRequests,
        driverLat: event.latitude,
        driverLng: event.longitude,
      );

      final filteredRequests = _applyFiltersAndSort(
        updatedRequests,
        currentState.filterType,
        currentState.sortCriteria,
      );

      emit(currentState.copyWith(
        availableRequests: updatedRequests,
        filteredRequests: filteredRequests,
        driverLatitude: event.latitude,
        driverLongitude: event.longitude,
      ));
    }
  }

  /// Filtre les demandes par type
  Future<void> _onFilterCashRequestsByType(
    FilterCashRequestsByType event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      
      final filteredRequests = _applyFiltersAndSort(
        currentState.availableRequests,
        event.filterType,
        currentState.sortCriteria,
      );

      emit(currentState.copyWith(
        filterType: event.filterType,
        filteredRequests: filteredRequests,
      ));
    }
  }

  /// Trie les demandes
  Future<void> _onSortCashRequests(
    SortCashRequests event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      
      final filteredRequests = _applyFiltersAndSort(
        currentState.availableRequests,
        currentState.filterType,
        event.sortCriteria,
      );

      emit(currentState.copyWith(
        sortCriteria: event.sortCriteria,
        filteredRequests: filteredRequests,
      ));
    }
  }

  /// Sélectionne une demande
  Future<void> _onSelectCashRequest(
    SelectCashRequest event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      emit(currentState.copyWith(
        selectedRequest: event.request,
        clearSelectedRequest: event.request == null,
      ));
    }
  }

  /// Démarre la navigation vers une demande
  Future<void> _onStartNavigationToCashRequest(
    StartNavigationToCashRequest event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceNavigating(request: event.request));
  }

  /// Marque l'arrivée chez le client
  Future<void> _onMarkArrivedAtClient(
    MarkArrivedAtClient event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'marking_arrived',
      requestId: event.requestId,
      message: 'Marquage de l\'arrivée...',
    ));

    try {
      if (kDebugMode) {
        debugPrint('🚗 Marquage arrivée - Request ID: ${event.requestId}, Type: ${event.requestType}');
      }

      final response = await _repository.updateRequestStatus(
        requestId: event.requestId,
        requestType: event.requestType,
        status: 'arrived',
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'marking_arrived',
          requestId: event.requestId,
          message: response.message,
          data: response.data,
        ));

        // Recharger les demandes pour voir le nouveau statut
        add(const RefreshAvailableCashRequests());
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.message,
          operationType: 'marking_arrived',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'marking_arrived',
        requestId: event.requestId,
      ));
    }
  }

  /// Efface les erreurs
  Future<void> _onClearCashServiceError(
    ClearCashServiceError event,
    Emitter<CashServiceState> emit,
  ) async {
    if (state is CashServiceError) {
      add(const LoadAvailableCashRequests());
    }
  }

  /// Met à jour les demandes avec les distances calculées
  Future<List<CashRequestModel>> _updateRequestsWithDistances(
    List<CashRequestModel> requests, {
    double? driverLat,
    double? driverLng,
  }) async {
    double? currentLat = driverLat;
    double? currentLng = driverLng;

    // Utiliser la position actuelle si pas fournie
    if (currentLat == null || currentLng == null) {
      if (state is CashServiceLoaded) {
        final currentState = state as CashServiceLoaded;
        currentLat = currentState.driverLatitude;
        currentLng = currentState.driverLongitude;
      }
    }

    if (currentLat == null || currentLng == null) {
      return requests;
    }

    return requests.map((request) {
      final distance = _repository.calculateDistance(
        currentLat!,
        currentLng!,
        request.pickupLatitude,
        request.pickupLongitude,
      );

      return request.copyWith(distance: distance);
    }).toList();
  }

  /// Applique les filtres et le tri
  List<CashRequestModel> _applyFiltersAndSort(
    List<CashRequestModel> requests,
    String? filterType,
    CashRequestSortCriteria sortCriteria,
  ) {
    var filtered = requests;

    // Appliquer le filtre par type
    if (filterType != null) {
      filtered = filtered.where((request) => request.type == filterType).toList();
    }

    // Appliquer le tri
    switch (sortCriteria) {
      case CashRequestSortCriteria.distance:
        filtered.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
        break;
      case CashRequestSortCriteria.amount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case CashRequestSortCriteria.commission:
        filtered.sort((a, b) => b.commission.compareTo(a.commission));
        break;
      case CashRequestSortCriteria.requestedAt:
        filtered.sort((a, b) => DateTime.parse(b.requestedAt).compareTo(DateTime.parse(a.requestedAt)));
        break;
    }

    return filtered;
  }

  /// Trouve une demande par ID
  CashRequestModel? _findRequestById(String requestId) {
    if (kDebugMode) {
      debugPrint('🔍 Recherche de la demande ID: $requestId');
      debugPrint('🔍 État actuel: ${state.runtimeType}');
    }
    
    if (state is CashServiceLoaded) {
      final currentState = state as CashServiceLoaded;
      
      if (kDebugMode) {
        debugPrint('🔍 Demandes disponibles: ${currentState.availableRequests.length}');
        debugPrint('🔍 Mes demandes: ${currentState.myRequests.length}');
      }
      
      // Chercher dans les demandes disponibles
      for (final request in currentState.availableRequests) {
        if (kDebugMode) {
          debugPrint('🔍 Vérification demande disponible: ${request.id}');
        }
        if (request.id == requestId) {
          if (kDebugMode) {
            debugPrint('✅ Demande trouvée dans availableRequests: ${request.id}');
          }
          return request;
        }
      }
      
      // Chercher dans mes demandes
      for (final request in currentState.myRequests) {
        if (kDebugMode) {
          debugPrint('🔍 Vérification ma demande: ${request.id}');
        }
        if (request.id == requestId) {
          if (kDebugMode) {
            debugPrint('✅ Demande trouvée dans myRequests: ${request.id}');
          }
          return request;
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('❌ Demande non trouvée: $requestId');
    }
    return null;
  }

  /// Met à jour le statut d'une demande
  Future<void> _onUpdateRequestStatus(
    UpdateRequestStatus event,
    Emitter<CashServiceState> emit,
  ) async {
    emit(CashServiceOperating(
      operationType: 'updating_status',
      requestId: event.requestId,
      message: 'Mise à jour du statut...',
    ));

    try {
      final response = await _repository.updateRequestStatus(
        requestId: event.requestId,
        requestType: event.requestType,
        status: event.status,
      );

      if (response.success) {
        emit(CashServiceOperationSuccess(
          operationType: 'updating_status',
          requestId: event.requestId,
          message: response.message,
          data: response.data,
        ));

        // Recharger les demandes
        add(const RefreshAvailableCashRequests());
        add(const LoadMyCashRequests());
      } else {
        emit(CashServiceError(
          message: response.message,
          operationType: 'updating_status',
          requestId: event.requestId,
        ));
      }
    } catch (e) {
      emit(CashServiceError(
        message: e.toString(),
        operationType: 'updating_status',
        requestId: event.requestId,
      ));
    }
  }

  /// Démarre le rafraîchissement automatique
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (state is CashServiceLoaded) {
        add(const RefreshAvailableCashRequests());
      }
    });
  }

  /// Démarre le suivi de position
  void _startLocationTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Mise à jour tous les 100m
      ),
    ).listen((position) {
      add(UpdateDriverLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _positionSubscription?.cancel();
    return super.close();
  }
}
