part of 'cash_service_bloc.dart';

/// États pour le service cash
abstract class CashServiceState extends Equatable {
  const CashServiceState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CashServiceInitial extends CashServiceState {
  const CashServiceInitial();
}

/// État de chargement
class CashServiceLoading extends CashServiceState {
  final String? message;

  const CashServiceLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// État avec les demandes chargées
class CashServiceLoaded extends CashServiceState {
  final List<CashRequestModel> availableRequests;
  final List<CashRequestModel> myRequests;
  final List<CashRequestModel> filteredRequests;
  final CashRequestModel? selectedRequest;
  final String? filterType;
  final CashRequestSortCriteria sortCriteria;
  final double? driverLatitude;
  final double? driverLongitude;
  final bool isRefreshing;

  const CashServiceLoaded({
    required this.availableRequests,
    required this.myRequests,
    required this.filteredRequests,
    this.selectedRequest,
    this.filterType,
    required this.sortCriteria,
    this.driverLatitude,
    this.driverLongitude,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
        availableRequests,
        myRequests,
        filteredRequests,
        selectedRequest,
        filterType,
        sortCriteria,
        driverLatitude,
        driverLongitude,
        isRefreshing,
      ];

  /// Copie l'état avec de nouvelles valeurs
  CashServiceLoaded copyWith({
    List<CashRequestModel>? availableRequests,
    List<CashRequestModel>? myRequests,
    List<CashRequestModel>? filteredRequests,
    CashRequestModel? selectedRequest,
    String? filterType,
    CashRequestSortCriteria? sortCriteria,
    double? driverLatitude,
    double? driverLongitude,
    bool? isRefreshing,
    bool clearSelectedRequest = false,
  }) {
    return CashServiceLoaded(
      availableRequests: availableRequests ?? this.availableRequests,
      myRequests: myRequests ?? this.myRequests,
      filteredRequests: filteredRequests ?? this.filteredRequests,
      selectedRequest: clearSelectedRequest ? null : (selectedRequest ?? this.selectedRequest),
      filterType: filterType ?? this.filterType,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Obtient le nombre total de demandes disponibles
  int get totalAvailableRequests => availableRequests.length;

  /// Obtient le nombre de demandes assignées
  int get totalMyRequests => myRequests.length;

  /// Obtient le nombre de demandes filtrées
  int get totalFilteredRequests => filteredRequests.length;

  /// Vérifie s'il y a des demandes disponibles
  bool get hasAvailableRequests => availableRequests.isNotEmpty;

  /// Vérifie s'il y a des demandes assignées
  bool get hasMyRequests => myRequests.isNotEmpty;

  /// Obtient les demandes par type
  List<CashRequestModel> getRequestsByType(String type) {
    return availableRequests.where((request) => request.type == type).toList();
  }

  /// Obtient les demandes de retrait
  List<CashRequestModel> get withdrawalRequests => getRequestsByType('withdrawal');

  /// Obtient les demandes de dépôt
  List<CashRequestModel> get depositRequests => getRequestsByType('deposit');

  /// Calcule le total des commissions potentielles
  double get totalPotentialCommissions {
    return availableRequests.fold(0.0, (sum, request) => sum + request.commission);
  }

  /// Obtient les demandes dans un rayon donné (en km)
  List<CashRequestModel> getRequestsInRadius(double radiusKm) {
    if (driverLatitude == null || driverLongitude == null) return [];
    
    return availableRequests.where((request) {
      if (request.distance == null) return false;
      return request.distance! <= radiusKm;
    }).toList();
  }
}

/// État d'opération en cours
class CashServiceOperating extends CashServiceState {
  final String operationType; // 'accepting', 'cash_out', 'cash_in', 'validating', 'uploading'
  final String requestId;
  final String message;

  const CashServiceOperating({
    required this.operationType,
    required this.requestId,
    required this.message,
  });

  @override
  List<Object?> get props => [operationType, requestId, message];
}

/// État de succès d'opération
class CashServiceOperationSuccess extends CashServiceState {
  final String operationType;
  final String requestId;
  final String message;
  final Map<String, dynamic>? data;

  const CashServiceOperationSuccess({
    required this.operationType,
    required this.requestId,
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [operationType, requestId, message, data];
}

/// État d'erreur
class CashServiceError extends CashServiceState {
  final String message;
  final String? operationType;
  final String? requestId;
  final bool canRetry;

  const CashServiceError({
    required this.message,
    this.operationType,
    this.requestId,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, operationType, requestId, canRetry];
}

/// État de navigation active
class CashServiceNavigating extends CashServiceState {
  final CashRequestModel request;
  final bool hasArrived;

  const CashServiceNavigating({
    required this.request,
    this.hasArrived = false,
  });

  @override
  List<Object?> get props => [request, hasArrived];

  CashServiceNavigating copyWith({
    CashRequestModel? request,
    bool? hasArrived,
  }) {
    return CashServiceNavigating(
      request: request ?? this.request,
      hasArrived: hasArrived ?? this.hasArrived,
    );
  }
}

/// État de validation de code de sécurité
class CashServiceValidatingCode extends CashServiceState {
  final CashRequestModel request;
  final int attemptsRemaining;

  const CashServiceValidatingCode({
    required this.request,
    this.attemptsRemaining = 3,
  });

  @override
  List<Object?> get props => [request, attemptsRemaining];

  CashServiceValidatingCode copyWith({
    CashRequestModel? request,
    int? attemptsRemaining,
  }) {
    return CashServiceValidatingCode(
      request: request ?? this.request,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    );
  }
}

/// État de transaction Moov Money en cours
class CashServiceMoovTransactionPending extends CashServiceState {
  final CashRequestModel request;
  final String transactionId;
  final String operationType; // 'cash_in' ou 'cash_out'

  const CashServiceMoovTransactionPending({
    required this.request,
    required this.transactionId,
    required this.operationType,
  });

  @override
  List<Object?> get props => [request, transactionId, operationType];
}

/// État de transaction Moov Money complétée
class CashServiceMoovTransactionCompleted extends CashServiceState {
  final CashRequestModel request;
  final String transactionId;
  final String operationType;

  const CashServiceMoovTransactionCompleted({
    required this.request,
    required this.transactionId,
    required this.operationType,
  });

  @override
  List<Object?> get props => [request, transactionId, operationType];
}

/// État de demande complétée avec succès
class CashServiceRequestCompleted extends CashServiceState {
  final CashRequestModel request;
  final double earnedCommission;

  const CashServiceRequestCompleted({
    required this.request,
    required this.earnedCommission,
  });

  @override
  List<Object?> get props => [request, earnedCommission];
}
