import 'package:dartz/dartz.dart';
import '../../../../core/network/network.dart';
import '../../domain/repositories/moov_money_repo.dart';
import '../models/moov_money_agent_model.dart';
import '../models/moov_money_transaction_model.dart';
import '../repository/moov_money_api.dart';

class MoovMoneyRepositoryImpl implements MoovMoneyRepository {
  final MoovMoneyApi _moovMoneyApi = MoovMoneyApi();

  @override
  Future<Either<Failure, List<MoovMoneyAgentModel>>> getNearbyAgents({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final agents = await _moovMoneyApi.getNearbyAgents(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(agents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final transaction = await _moovMoneyApi.initiateDeposit(
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
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MoovMoneyTransactionModel>> generateWithdrawalVoucher({
    required double amount,
    required String phoneNumber,
    required double pickLat,
    required double pickLng,
    required String pickAddress,
  }) async {
    try {
      final transaction = await _moovMoneyApi.generateWithdrawalVoucher(
        amount: amount,
        phoneNumber: phoneNumber,
        pickLat: pickLat,
        pickLng: pickLng,
        pickAddress: pickAddress,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MoovMoneyTransactionModel>>> getTransactionHistory({
    String? type,
    String? status,
    int page = 1,
  }) async {
    try {
      final transactions = await _moovMoneyApi.getTransactionHistory(
        type: type,
        status: status,
        page: page,
      );
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MoovMoneyTransactionModel>> getTransactionDetails({
    required String transactionId,
  }) async {
    try {
      final transaction = await _moovMoneyApi.getTransactionDetails(
        transactionId: transactionId,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MoovMoneyTransactionModel>> cancelTransaction({
    required String transactionId,
  }) async {
    try {
      final transaction = await _moovMoneyApi.cancelTransaction(
        transactionId: transactionId,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
