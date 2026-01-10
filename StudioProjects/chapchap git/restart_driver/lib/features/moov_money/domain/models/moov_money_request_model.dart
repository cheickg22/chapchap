import 'package:equatable/equatable.dart';

/// Modèle pour une requête Moov Money
class MoovMoneyRequest extends Equatable {
  final String id;
  final String requestNumber;
  final String userId;
  final String userName;
  final String userPhone;
  final String driverId;
  final String type; // 'deposit' ou 'withdrawal'
  final int amount;
  final String phone;
  final String status; // 'pending', 'accepted', 'processing', 'completed', 'cancelled'
  final String? securityCode;
  final int? commission;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? cancelReason;
  final double? userLatitude;
  final double? userLongitude;
  final String? userAddress;

  const MoovMoneyRequest({
    required this.id,
    required this.requestNumber,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.driverId,
    required this.type,
    required this.amount,
    required this.phone,
    required this.status,
    this.securityCode,
    this.commission,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelReason,
    this.userLatitude,
    this.userLongitude,
    this.userAddress,
  });

  factory MoovMoneyRequest.fromJson(Map<String, dynamic> json) {
    return MoovMoneyRequest(
      id: _parseString(json['id']),
      requestNumber: _parseString(json['request_number']),
      userId: _parseString(json['user_id']),
      userName: _parseString(json['user_name']),
      userPhone: _parseString(json['user_phone']),
      driverId: _parseString(json['driver_id']),
      type: _parseString(json['moov_money_type'], 'deposit'),
      amount: _parseAmount(json['moov_money_amount']),
      phone: _parseString(json['moov_money_phone']),
      status: _parseString(json['moov_money_status'], 'pending'),
      securityCode: json['moov_money_security_code'] != null 
          ? _parseString(json['moov_money_security_code']) 
          : null,
      commission: json['commission'] != null 
          ? _parseAmount(json['commission']) 
          : null,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      acceptedAt: _parseDate(json['accepted_at']),
      completedAt: _parseDate(json['completed_at']),
      cancelReason: json['cancel_reason'] != null 
          ? _parseString(json['cancel_reason']) 
          : null,
      userLatitude: _parseDouble(json['pick_lat']),
      userLongitude: _parseDouble(json['pick_lng']),
      userAddress: json['pick_address'] != null 
          ? _parseString(json['pick_address']) 
          : null,
    );
  }

  factory MoovMoneyRequest.fromFirebase(Map<dynamic, dynamic> data) {
    // Convertir tous les types dynamiques en String/int appropriés
    final map = <String, dynamic>{};
    data.forEach((key, value) {
      map[key.toString()] = value;
    });
    return MoovMoneyRequest.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_number': requestNumber,
      'user_id': userId,
      'user_name': userName,
      'user_phone': userPhone,
      'driver_id': driverId,
      'moov_money_type': type,
      'moov_money_amount': amount,
      'moov_money_phone': phone,
      'moov_money_status': status,
      'moov_money_security_code': securityCode,
      'commission': commission,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancel_reason': cancelReason,
      'pick_lat': userLatitude,
      'pick_lng': userLongitude,
      'pick_address': userAddress,
    };
  }

  static String _parseString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is int) {
        // Timestamp Unix (millisecondes)
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get typeLabel => isDeposit ? 'Dépôt' : 'Retrait';
  
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'processing':
        return 'En cours';
      case 'completed':
        return 'Complétée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  MoovMoneyRequest copyWith({
    String? id,
    String? requestNumber,
    String? userId,
    String? userName,
    String? userPhone,
    String? driverId,
    String? type,
    int? amount,
    String? phone,
    String? status,
    String? securityCode,
    int? commission,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? cancelReason,
    double? userLatitude,
    double? userLongitude,
    String? userAddress,
  }) {
    return MoovMoneyRequest(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      securityCode: securityCode ?? this.securityCode,
      commission: commission ?? this.commission,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelReason: cancelReason ?? this.cancelReason,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      userAddress: userAddress ?? this.userAddress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestNumber,
        userId,
        userName,
        userPhone,
        driverId,
        type,
        amount,
        phone,
        status,
        securityCode,
        commission,
        createdAt,
        acceptedAt,
        completedAt,
        cancelReason,
        userLatitude,
        userLongitude,
        userAddress,
      ];
}
