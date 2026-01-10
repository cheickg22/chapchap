import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../common/common.dart';
import '../../../../core/network/network.dart';
import '../models/moov_money_agent_model.dart';
import '../models/moov_money_transaction_model.dart';

class MoovMoneyApi {
  /// Get nearby Moov Money agents
  Future<List<MoovMoneyAgentModel>> getNearbyAgents({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final url = 'api/v1/moov-money/agents/nearby?latitude=$latitude&longitude=$longitude&radius=$radius';
      print('🔍 Moov Money API - Calling: $url');
      
      Response response = await DioProviderImpl().get(url);
      
      print('📡 Moov Money API - Status Code: ${response.statusCode}');
      print('📦 Moov Money API - Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List agentsList = data['data'] as List;
          print('✅ Moov Money API - Found ${agentsList.length} agents');
          return agentsList
              .map((json) => MoovMoneyAgentModel.fromJson(json))
              .toList();
        }
      }
      print('❌ Moov Money API - Failed to load agents');
      throw Exception('Failed to load agents');
    } catch (e) {
      print('💥 Moov Money API - Error: $e');
      throw Exception('Error getting nearby agents: $e');
    }
  }

  /// Initiate a deposit (Cash In)
  Future<MoovMoneyTransactionModel> initiateDeposit({
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
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().post(
        'api/v1/moov-money/deposit/create',
        headers: {'Authorization': token},
        body: FormData.fromMap({
          'amount': amount,
          'phone_number': phoneNumber,
          'pick_lat': pickLat,
          'pick_lng': pickLng,
          'pick_address': pickAddress,
          if (agentId != null) 'agent_id': agentId,
          if (agentLocation != null) 'agent_location': agentLocation,
          if (agentLat != null) 'agent_lat': agentLat,
          if (agentLng != null) 'agent_lng': agentLng,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MoovMoneyTransactionModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to initiate deposit');
    } catch (e) {
      throw Exception('Error initiating deposit: $e');
    }
  }

  /// Generate a withdrawal voucher (Cash Out)
  Future<MoovMoneyTransactionModel> generateWithdrawalVoucher({
    required double amount,
    required String phoneNumber,
    required double pickLat,
    required double pickLng,
    required String pickAddress,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().post(
        'api/v1/moov-money/withdrawal/create',
        headers: {'Authorization': token},
        body: FormData.fromMap({
          'amount': amount,
          'phone_number': phoneNumber,
          'pick_lat': pickLat,
          'pick_lng': pickLng,
          'pick_address': pickAddress,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MoovMoneyTransactionModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to generate withdrawal voucher');
    } catch (e) {
      throw Exception('Error generating withdrawal voucher: $e');
    }
  }

  /// Get transaction history
  Future<List<MoovMoneyTransactionModel>> getTransactionHistory({
    String? type, // 'deposit' or 'withdrawal'
    String? status, // 'pending', 'completed', 'failed', 'cancelled'
    int page = 1,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();

      String url = 'api/v1/moov-money/transactions?page=$page';
      if (type != null) url += '&type=$type';
      if (status != null) url += '&status=$status';
      
      Response response = await DioProviderImpl().get(
        url,
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List transactionsList = data['data'] as List;
          return transactionsList
              .map((json) => MoovMoneyTransactionModel.fromJson(json))
              .toList();
        }
      }
      throw Exception('Failed to load transaction history');
    } catch (e) {
      throw Exception('Error getting transaction history: $e');
    }
  }

  /// Get transaction details
  Future<MoovMoneyTransactionModel> getTransactionDetails({
    required String transactionId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().get(
        'api/v1/moov-money/transactions/$transactionId',
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MoovMoneyTransactionModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load transaction details');
    } catch (e) {
      throw Exception('Error getting transaction details: $e');
    }
  }

  /// Cancel a pending transaction
  Future<MoovMoneyTransactionModel> cancelTransaction({
    required String transactionId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().post(
        'api/v1/moov-money/transactions/$transactionId/cancel',
        headers: {'Authorization': token},
        body: FormData.fromMap({}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return MoovMoneyTransactionModel.fromJson(data['data']);
        }
      }
      throw Exception('Failed to cancel transaction');
    } catch (e) {
      throw Exception('Error cancelling transaction: $e');
    }
  }
}
