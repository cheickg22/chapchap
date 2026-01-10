import 'package:dartz/dartz.dart';
import '../../../../core/network/network.dart';
import '../../data/models/moov_money_agent_model.dart';
import '../../data/models/moov_money_transaction_model.dart';
import '../../domain/repositories/moov_money_repo.dart';

class MoovMoneyUsecase {
  final MoovMoneyRepository _moovMoneyRepository;

  MoovMoneyUsecase(this._moovMoneyRepository);

  /// Get nearby Moov Money agents
  Future<Either<Failure, List<MoovMoneyAgentModel>>> getNearbyAgents({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) {
    return _moovMoneyRepository.getNearbyAgents(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

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
  }) {
    return _moovMoneyRepository.initiateDeposit(
      amount: amount,
      phoneNumber: phoneNumber,
      pickLat: pickLat,
      pickLng: pickLng,
      pickAddress: pickAddress,
      agentId: agentId,
      agentLocation: agentLocation,
      agentLat: agentLat,
      agentLng: agentLng,
    );
  }

  /// Generate a withdrawal voucher (Cash Out)
  Future<Either<Failure, MoovMoneyTransactionModel>> generateWithdrawalVoucher({
    required double amount,
    required String phoneNumber,
    required double pickLat,
    required double pickLng,
    required String pickAddress,
  }) {
    return _moovMoneyRepository.generateWithdrawalVoucher(
      amount: amount,
      phoneNumber: phoneNumber,
      pickLat: pickLat,
      pickLng: pickLng,
      pickAddress: pickAddress,
    );
  }

  /// Get transaction history
  Future<Either<Failure, List<MoovMoneyTransactionModel>>> getTransactionHistory({
    String? type,
    String? status,
    int page = 1,
  }) {
    return _moovMoneyRepository.getTransactionHistory(
      type: type,
      status: status,
      page: page,
    );
  }

  /// Get transaction details
  Future<Either<Failure, MoovMoneyTransactionModel>> getTransactionDetails({
    required String transactionId,
  }) {
    return _moovMoneyRepository.getTransactionDetails(
      transactionId: transactionId,
    );
  }

  /// Cancel a pending transaction
  Future<Either<Failure, MoovMoneyTransactionModel>> cancelTransaction({
    required String transactionId,
  }) {
    return _moovMoneyRepository.cancelTransaction(
      transactionId: transactionId,
    );
  }
}
