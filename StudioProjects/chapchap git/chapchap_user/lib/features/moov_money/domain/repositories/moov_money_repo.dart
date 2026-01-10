import 'package:dartz/dartz.dart';
import '../../../../core/network/network.dart';
import '../../data/models/moov_money_agent_model.dart';
import '../../data/models/moov_money_transaction_model.dart';

abstract class MoovMoneyRepository {
  /// Get nearby Moov Money agents
  Future<Either<Failure, List<MoovMoneyAgentModel>>> getNearbyAgents({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  });

  /// Initiate a deposit (Cash In)
  Future<Either<Failure, MoovMoneyTransactionModel>> initiateDeposit({
    required double amount,
    required String phoneNumber,
    required double pickLat,
    required double pickLng,
    required String pickAddress,
    int? agentId,
    String? agentLocation,
    double? agentLat,
    double? agentLng,
  });

  /// Generate a withdrawal voucher (Cash Out)
  Future<Either<Failure, MoovMoneyTransactionModel>> generateWithdrawalVoucher({
    required double amount,
    required String phoneNumber,
    required double pickLat,
    required double pickLng,
    required String pickAddress,
  });

  /// Get transaction history
  Future<Either<Failure, List<MoovMoneyTransactionModel>>> getTransactionHistory({
    String? type,
    String? status,
    int page = 1,
  });

  /// Get transaction details
  Future<Either<Failure, MoovMoneyTransactionModel>> getTransactionDetails({
    required String transactionId,
  });

  /// Cancel a pending transaction
  Future<Either<Failure, MoovMoneyTransactionModel>> cancelTransaction({
    required String transactionId,
  });
}
