import 'package:equatable/equatable.dart';

abstract class MoovMoneyEvent extends Equatable {
  const MoovMoneyEvent();

  @override
  List<Object?> get props => [];
}

/// Get nearby agents
class GetNearbyAgentsEvent extends MoovMoneyEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const GetNearbyAgentsEvent({
    required this.latitude,
    required this.longitude,
    this.radius = 5.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

/// Initiate deposit
class InitiateDepositEvent extends MoovMoneyEvent {
  final double amount;
  final String phoneNumber;
  final int? agentId;
  final String? agentLocation;
  final double? agentLat;
  final double? agentLng;

  const InitiateDepositEvent({
    required this.amount,
    required this.phoneNumber,
    this.agentId,
    this.agentLocation,
    this.agentLat,
    this.agentLng,
  });

  @override
  List<Object?> get props => [amount, phoneNumber, agentId];
}

/// Generate withdrawal voucher
class GenerateWithdrawalVoucherEvent extends MoovMoneyEvent {
  final double amount;
  final String phoneNumber;

  const GenerateWithdrawalVoucherEvent({
    required this.amount,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [amount, phoneNumber];
}

/// Get transaction history
class GetTransactionHistoryEvent extends MoovMoneyEvent {
  final String? type;
  final String? status;
  final int page;

  const GetTransactionHistoryEvent({
    this.type,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [type, status, page];
}

/// Get transaction details
class GetTransactionDetailsEvent extends MoovMoneyEvent {
  final String transactionId;

  const GetTransactionDetailsEvent({
    required this.transactionId,
  });

  @override
  List<Object?> get props => [transactionId];
}

/// Cancel transaction
class CancelTransactionEvent extends MoovMoneyEvent {
  final String transactionId;

  const CancelTransactionEvent({
    required this.transactionId,
  });

  @override
  List<Object?> get props => [transactionId];
}
