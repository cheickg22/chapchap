import 'package:equatable/equatable.dart';

/// Modèle pour une transaction Moov Money
class MoovMoneyTransaction extends Equatable {
  final String id;
  final String requestNumber;
  final String type; // 'deposit' ou 'withdrawal'
  final int amount;
  final String phone;
  final String status; // 'completed', 'cancelled', 'pending', 'processing'
  final int? commission;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? cancelReason;

  const MoovMoneyTransaction({
    required this.id,
    required this.requestNumber,
    required this.type,
    required this.amount,
    required this.phone,
    required this.status,
    this.commission,
    required this.createdAt,
    this.completedAt,
    this.cancelReason,
  });

  factory MoovMoneyTransaction.fromJson(Map<String, dynamic> json) {
    return MoovMoneyTransaction(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? '',
      type: json['moov_money_type']?.toString() ?? 'deposit',
      amount: _parseAmount(json['moov_money_amount']),
      phone: json['moov_money_phone']?.toString() ?? '',
      status: json['moov_money_status']?.toString() ?? 'pending',
      commission: _parseAmount(json['commission']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      completedAt: _parseDate(json['completed_at']),
      cancelReason: json['cancel_reason']?.toString(),
    );
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  bool get isDeposit => type == 'deposit';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';

  String get typeLabel => isDeposit ? 'Dépôt' : 'Retrait';
  
  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Complété';
      case 'cancelled':
        return 'Annulé';
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En cours';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        requestNumber,
        type,
        amount,
        phone,
        status,
        commission,
        createdAt,
        completedAt,
        cancelReason,
      ];
}
