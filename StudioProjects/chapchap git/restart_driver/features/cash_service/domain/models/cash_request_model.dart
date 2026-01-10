/// Modèle pour les demandes de cash (retrait/dépôt) côté driver
class CashRequestModel {
  final String id;
  final String type; // 'withdrawal' ou 'deposit'
  final String typeLabel; // 'Retrait' ou 'Dépôt'
  final double amount;
  final double commission;
  final double totalAmount;
  final String status;
  final String statusLabel;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String? notes;
  final String? securityCode;
  final String? userName;
  final String? userMobile;
  final String? customerName; // Pour les dépôts
  final String? phoneNumber; // Pour les dépôts
  final String requestedAt;
  final String? assignedAt;
  final String? completedAt;
  final double? distance; // Distance du driver à la demande
  final MoovTransactionModel? moovTransaction;

  CashRequestModel({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.amount,
    required this.commission,
    required this.totalAmount,
    required this.status,
    required this.statusLabel,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.notes,
    this.securityCode,
    this.userName,
    this.userMobile,
    this.customerName,
    this.phoneNumber,
    required this.requestedAt,
    this.assignedAt,
    this.completedAt,
    this.distance,
    this.moovTransaction,
  });

  factory CashRequestModel.fromJson(Map<String, dynamic> json) {
    return CashRequestModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      typeLabel: _getTypeLabel(json['type'] ?? ''),
      amount: (json['amount'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalAmount: (json['amount'] ?? 0).toDouble() + (json['commission'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      statusLabel: _getStatusLabel(json['status'] ?? ''),
      pickupAddress: json['pickup_address'] ?? '',
      pickupLatitude: (json['pickup_latitude'] ?? 0).toDouble(),
      pickupLongitude: (json['pickup_longitude'] ?? 0).toDouble(),
      notes: json['notes'],
      securityCode: json['security_code'],
      userName: json['client_name'], // Backend utilise 'client_name'
      userMobile: json['client_phone_number'], // Backend utilise 'client_phone_number'
      customerName: json['client_name'],
      phoneNumber: json['client_phone_number'],
      requestedAt: json['requested_at'] ?? '',
      assignedAt: json['assigned_at'],
      completedAt: json['completed_at'],
      distance: json['distance']?.toDouble(),
      moovTransaction: json['moov_transaction'] != null
          ? MoovTransactionModel.fromJson(json['moov_transaction'])
          : null,
    );
  }

  // Méthodes utilitaires pour les labels
  static String _getTypeLabel(String type) {
    switch (type) {
      case 'withdrawal':
        return 'Retrait';
      case 'deposit':
        return 'Dépôt';
      default:
        return type;
    }
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'assigned':
        return 'Assigné';
      case 'in_progress':
        return 'En cours';
      case 'moov_processing':
        return 'Transaction en cours';
      case 'moov_completed':
        return 'Transaction terminée';
      case 'completed':
        return 'Terminé';
      default:
        return status;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_label': typeLabel,
      'amount': amount,
      'commission': commission,
      'total_amount': totalAmount,
      'status': status,
      'status_label': statusLabel,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'notes': notes,
      'security_code': securityCode,
      'user_name': userName,
      'user_mobile': userMobile,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'requested_at': requestedAt,
      'assigned_at': assignedAt,
      'completed_at': completedAt,
      'distance': distance,
      'moov_transaction': moovTransaction?.toJson(),
    };
  }

  /// Vérifie si c'est une demande de retrait
  bool get isWithdrawal => type == 'withdrawal';

  /// Vérifie si c'est une demande de dépôt
  bool get isDeposit => type == 'deposit';

  /// Vérifie si la demande est en attente
  bool get isPending => status == 'pending';

  /// Vérifie si la demande est assignée au driver
  bool get isAssigned => status == 'assigned';

  /// Vérifie si la demande est en cours de traitement Moov Money
  bool get isMoovProcessing => status == 'moov_processing';

  /// Vérifie si la transaction Moov Money est complétée
  bool get isMoovCompleted => status == 'moov_completed';

  /// Vérifie si la demande est terminée
  bool get isCompleted => status == 'completed';

  /// Obtient le numéro de téléphone du client
  String? get clientPhoneNumber {
    if (isWithdrawal) return userMobile;
    if (isDeposit) return phoneNumber;
    return null;
  }

  /// Obtient le nom du client
  String? get clientName {
    if (isWithdrawal) return userName;
    if (isDeposit) return customerName;
    return null;
  }

  /// Vérifie si la transaction Moov Money est nécessaire
  bool get needsMoovTransaction {
    return isAssigned && moovTransaction == null;
  }

  /// Vérifie si le code de sécurité peut être validé
  bool get canValidateSecurityCode {
    return isMoovCompleted && securityCode != null;
  }

  /// Vérifie si c'est une requête Moov Money
  bool get isMoovMoney => moovTransaction != null;

  CashRequestModel copyWith({
    String? id,
    String? type,
    String? typeLabel,
    double? amount,
    double? commission,
    double? totalAmount,
    String? status,
    String? statusLabel,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? notes,
    String? securityCode,
    String? userName,
    String? userMobile,
    String? customerName,
    String? phoneNumber,
    String? requestedAt,
    String? assignedAt,
    String? completedAt,
    double? distance,
    MoovTransactionModel? moovTransaction,
  }) {
    return CashRequestModel(
      id: id ?? this.id,
      type: type ?? this.type,
      typeLabel: typeLabel ?? this.typeLabel,
      amount: amount ?? this.amount,
      commission: commission ?? this.commission,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      notes: notes ?? this.notes,
      securityCode: securityCode ?? this.securityCode,
      userName: userName ?? this.userName,
      userMobile: userMobile ?? this.userMobile,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      requestedAt: requestedAt ?? this.requestedAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      distance: distance ?? this.distance,
      moovTransaction: moovTransaction ?? this.moovTransaction,
    );
  }
}

/// Modèle pour les transactions Moov Money
class MoovTransactionModel {
  final String id;
  final String status;
  final String statusLabel;
  final String? originatorConversationId;
  final String? transactionId;

  MoovTransactionModel({
    required this.id,
    required this.status,
    required this.statusLabel,
    this.originatorConversationId,
    this.transactionId,
  });

  factory MoovTransactionModel.fromJson(Map<String, dynamic> json) {
    return MoovTransactionModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      originatorConversationId: json['originator_conversation_id'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'status_label': statusLabel,
      'originator_conversation_id': originatorConversationId,
      'transaction_id': transactionId,
    };
  }

  /// Vérifie si la transaction est en attente
  bool get isPending => status == 'pending';

  /// Vérifie si la transaction est complétée
  bool get isCompleted => status == 'completed';

  /// Vérifie si la transaction a échoué
  bool get isFailed => status == 'failed';
}

/// Modèle pour la réponse des demandes disponibles
class AvailableCashRequestsResponse {
  final bool success;
  final String message;
  final List<CashRequestModel> requests;
  final int totalRequests;
  final double totalCommission;
  final int withdrawalCount;
  final int depositCount;

  AvailableCashRequestsResponse({
    required this.success,
    required this.message,
    required this.requests,
    required this.totalRequests,
    required this.totalCommission,
    required this.withdrawalCount,
    required this.depositCount,
  });

  factory AvailableCashRequestsResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    
    return AvailableCashRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      requests: (dataMap['requests'] as List<dynamic>?)
              ?.map((item) => CashRequestModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalRequests: dataMap['total_requests'] ?? 0,
      totalCommission: (dataMap['total_commission'] ?? 0.0).toDouble(),
      withdrawalCount: dataMap['withdrawal_count'] ?? 0,
      depositCount: dataMap['deposit_count'] ?? 0,
    );
  }

  // Getter pour compatibilité avec le code existant
  List<CashRequestModel> get data => requests;
}

/// Modèle pour la réponse d'acceptation de demande
class AcceptCashRequestResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AcceptCashRequestResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AcceptCashRequestResponse.fromJson(Map<String, dynamic> json) {
    return AcceptCashRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

/// Modèle pour la réponse d'opération Moov Money
class MoovOperationResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String? originatorConversationId;
  final String? error;

  MoovOperationResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.originatorConversationId,
    this.error,
  });

  factory MoovOperationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return MoovOperationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactionId: data?['transaction_id'],
      originatorConversationId: data?['originator_conversation_id'],
      error: json['error'],
    );
  }
}
