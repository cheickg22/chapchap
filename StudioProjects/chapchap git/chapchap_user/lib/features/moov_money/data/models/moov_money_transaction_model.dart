import 'package:equatable/equatable.dart';

class MoovMoneyTransactionModel extends Equatable {
  final String id;
  final String transactionType;
  final String transactionTypeText;
  final String status;
  final String statusText;
  final double amount;
  final String currency;
  final String formattedAmount;
  final String phoneNumber;
  final String? voucherCode;
  final String? voucherValidationValue;
  final String? voucherExpiresAt;
  final bool? voucherExpired;
  final String? agentLocation;
  final double? agentLat;
  final double? agentLng;
  final String? agentName;
  final String? agentPhone;
  final String? conversationId;
  final String? transactionId;
  final String? errorMessage;
  final String createdAt;
  final String updatedAt;
  final String createdAtFormatted;

  const MoovMoneyTransactionModel({
    required this.id,
    required this.transactionType,
    required this.transactionTypeText,
    required this.status,
    required this.statusText,
    required this.amount,
    required this.currency,
    required this.formattedAmount,
    required this.phoneNumber,
    this.voucherCode,
    this.voucherValidationValue,
    this.voucherExpiresAt,
    this.voucherExpired,
    this.agentLocation,
    this.agentLat,
    this.agentLng,
    this.agentName,
    this.agentPhone,
    this.conversationId,
    this.transactionId,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.createdAtFormatted,
  });

  factory MoovMoneyTransactionModel.fromJson(Map<String, dynamic> json) {
    return MoovMoneyTransactionModel(
      id: json['id'] as String,
      transactionType: json['transaction_type'] as String,
      transactionTypeText: json['transaction_type_text'] as String,
      status: json['status'] as String,
      statusText: json['status_text'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      formattedAmount: json['formatted_amount'] as String,
      phoneNumber: json['phone_number'] as String,
      voucherCode: json['voucher_code'] as String?,
      voucherValidationValue: json['voucher_validation_value'] as String?,
      voucherExpiresAt: json['voucher_expires_at'] as String?,
      voucherExpired: json['voucher_expired'] as bool?,
      agentLocation: json['agent_location'] as String?,
      agentLat: json['agent_lat'] != null ? (json['agent_lat'] as num).toDouble() : null,
      agentLng: json['agent_lng'] != null ? (json['agent_lng'] as num).toDouble() : null,
      agentName: json['agent_name'] as String?,
      agentPhone: json['agent_phone'] as String?,
      conversationId: json['conversation_id'] as String?,
      transactionId: json['transaction_id'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      createdAtFormatted: json['created_at_formatted'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_type': transactionType,
      'transaction_type_text': transactionTypeText,
      'status': status,
      'status_text': statusText,
      'amount': amount,
      'currency': currency,
      'formatted_amount': formattedAmount,
      'phone_number': phoneNumber,
      'voucher_code': voucherCode,
      'voucher_validation_value': voucherValidationValue,
      'voucher_expires_at': voucherExpiresAt,
      'voucher_expired': voucherExpired,
      'agent_location': agentLocation,
      'agent_lat': agentLat,
      'agent_lng': agentLng,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'conversation_id': conversationId,
      'transaction_id': transactionId,
      'error_message': errorMessage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_at_formatted': createdAtFormatted,
    };
  }

  bool get isDeposit => transactionType == 'deposit';
  bool get isWithdrawal => transactionType == 'withdrawal';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [
        id,
        transactionType,
        status,
        amount,
        phoneNumber,
        voucherCode,
        createdAt,
      ];
}
