part of 'cash_service_bloc.dart';

/// Événements pour le service cash
abstract class CashServiceEvent extends Equatable {
  const CashServiceEvent();

  @override
  List<Object?> get props => [];
}

/// Charge les demandes cash disponibles
class LoadAvailableCashRequests extends CashServiceEvent {
  const LoadAvailableCashRequests();
}

/// Rafraîchit les demandes cash disponibles
class RefreshAvailableCashRequests extends CashServiceEvent {
  const RefreshAvailableCashRequests();
}

/// Charge les demandes assignées au driver
class LoadMyCashRequests extends CashServiceEvent {
  const LoadMyCashRequests();
}

/// Accepte une demande cash
class AcceptCashRequest extends CashServiceEvent {
  final String requestId;
  final String requestType;

  const AcceptCashRequest({
    required this.requestId,
    required this.requestType,
  });

  @override
  List<Object?> get props => [requestId, requestType];
}

/// Effectue une opération Cash Out (retrait)
class PerformCashOut extends CashServiceEvent {
  final String requestId;
  final String clientPhoneNumber;

  const PerformCashOut({
    required this.requestId,
    required this.clientPhoneNumber,
  });

  @override
  List<Object?> get props => [requestId, clientPhoneNumber];
}

/// Effectue une opération Cash In (dépôt)
class PerformCashIn extends CashServiceEvent {
  final String requestId;

  const PerformCashIn({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}

/// Valide le code de sécurité
class ValidateSecurityCode extends CashServiceEvent {
  final String requestId;
  final String requestType;
  final String securityCode;

  const ValidateSecurityCode({
    required this.requestId,
    required this.requestType,
    required this.securityCode,
  });

  @override
  List<Object?> get props => [requestId, requestType, securityCode];
}

/// Upload une photo de preuve
class UploadProofPhoto extends CashServiceEvent {
  final String requestId;
  final String requestType;
  final String photoPath;

  const UploadProofPhoto({
    required this.requestId,
    required this.requestType,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [requestId, requestType, photoPath];
}

/// Met à jour la position du driver pour calculer les distances
class UpdateDriverLocation extends CashServiceEvent {
  final double latitude;
  final double longitude;

  const UpdateDriverLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Filtre les demandes par type
class FilterCashRequestsByType extends CashServiceEvent {
  final String? filterType; // null = tous, 'withdrawal', 'deposit'

  const FilterCashRequestsByType({
    this.filterType,
  });

  @override
  List<Object?> get props => [filterType];
}

/// Trie les demandes par critère
class SortCashRequests extends CashServiceEvent {
  final CashRequestSortCriteria sortCriteria;

  const SortCashRequests({
    required this.sortCriteria,
  });

  @override
  List<Object?> get props => [sortCriteria];
}

/// Sélectionne une demande pour voir les détails
class SelectCashRequest extends CashServiceEvent {
  final CashRequestModel? request;

  const SelectCashRequest({
    this.request,
  });

  @override
  List<Object?> get props => [request];
}

/// Démarre la navigation vers une demande
class StartNavigationToCashRequest extends CashServiceEvent {
  final CashRequestModel request;

  const StartNavigationToCashRequest({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

/// Marque l'arrivée chez le client
class MarkArrivedAtClient extends CashServiceEvent {
  final String requestId;
  final String requestType;

  const MarkArrivedAtClient({
    required this.requestId,
    required this.requestType,
  });

  @override
  List<Object?> get props => [requestId, requestType];
}

/// Met à jour le statut d'une demande
class UpdateRequestStatus extends CashServiceEvent {
  final String requestId;
  final String requestType;
  final String status;

  const UpdateRequestStatus({
    required this.requestId,
    required this.requestType,
    required this.status,
  });

  @override
  List<Object?> get props => [requestId, requestType, status];
}

/// Remet à zéro les états d'erreur
class ClearCashServiceError extends CashServiceEvent {
  const ClearCashServiceError();
}

/// Énumération pour les critères de tri
enum CashRequestSortCriteria {
  distance,
  amount,
  commission,
  requestedAt,
}
