import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/moov_balance_model.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/local_data.dart';

/// Service pour gérer le solde Moov Money
class MoovBalanceService {
  final Dio _dio;
  
  MoovBalanceService({Dio? dio}) : _dio = dio ?? DioProviderImpl.dioClient;

  /// Récupérer le solde actuel de l'utilisateur
  Future<MoovBalanceModel?> getBalance() async {
    try {
      debugPrint('🔍 Fetching Moov Money balance from API...');
      
      // Récupérer le token d'authentification
      final token = await AppSharedPreference.getToken();
      if (token.isEmpty) {
        debugPrint('❌ No authentication token available');
        return null;
      }
      debugPrint('🔐 Token available: ${token.substring(0, 20)}...');
      
      // Nettoyer l'URL pour éviter les doubles barres obliques
      String baseUrl = AppConstants.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      final response = await _dio.get(
        '$baseUrl/api/v1/moov-money/balance',
        options: Options(
          headers: {
            'Authorization': token,
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Vérifier si la réponse contient success = true
        if (responseData is Map && responseData['success'] == true) {
          // Extraire les données du champ 'data'
          final balanceData = responseData['data'] as Map<String, dynamic>;
          debugPrint('✅ Balance data extracted: $balanceData');
          
          return MoovBalanceModel.fromJson(balanceData);
        } else {
          // Si pas de succès, log l'erreur
          debugPrint('❌ API returned success=false or invalid format');
          debugPrint('Response: $responseData');
          return null;
        }
      } else {
        debugPrint('❌ API returned status code: ${response.statusCode}');
        return null;
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching balance: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      // En cas d'erreur réseau ou autre, retourner null
      // L'UI affichera un message d'erreur approprié
      return null;
    }
  }

  /// Rafraîchir le solde depuis l'API Moov Money
  Future<MoovBalanceModel?> refreshBalance() async {
    try {
      debugPrint('🔄 Refreshing Moov Money balance from API...');
      
      // Récupérer le token d'authentification
      final token = await AppSharedPreference.getToken();
      if (token.isEmpty) {
        debugPrint('❌ No authentication token for refresh');
        return null;
      }
      
      // Nettoyer l'URL pour éviter les doubles barres obliques
      String baseUrl = AppConstants.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      final response = await _dio.post(
        '$baseUrl/api/v1/moov-money/balance/refresh',
        options: Options(
          headers: {
            'Authorization': token,
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('📡 Refresh response status: ${response.statusCode}');
      debugPrint('📡 Refresh response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map && responseData['success'] == true) {
          final balanceData = responseData['data'] as Map<String, dynamic>;
          debugPrint('✅ Balance refreshed successfully');
          return MoovBalanceModel.fromJson(balanceData);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error refreshing balance: $e');
      // En cas d'erreur, essayer avec la méthode GET normale
      return getBalance();
    }
  }

  /// Vérifier si le solde est suffisant pour une transaction
  Future<bool> checkSufficientBalance(double amount) async {
    try {
      final balance = await getBalance();
      if (balance == null) return false;
      
      return balance.availableBalance >= amount;
    } catch (e) {
      debugPrint('❌ Error checking balance: $e');
      return false;
    }
  }

  /// Obtenir l'historique des transactions
  Future<List<TransactionSummary>> getTransactionHistory({
    int limit = 10,
    String? type,
  }) async {
    try {
      debugPrint('📜 Fetching transaction history...');
      
      final queryParams = {
        'limit': limit.toString(),
        if (type != null) 'type': type,
      };
      
      final response = await _dio.get(
        '${AppConstants.baseUrl}/api/v1/moov-money/transactions',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => TransactionSummary.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      return [];
    }
  }

  /// Mettre à jour le solde après une transaction
  Future<MoovBalanceModel?> updateBalanceAfterTransaction({
    required String transactionId,
    required String type,
    required double amount,
  }) async {
    try {
      debugPrint('💰 Updating balance after transaction...');
      
      final response = await _dio.post(
        '${AppConstants.baseUrl}/api/v1/moov-money/balance/update',
        data: {
          'transaction_id': transactionId,
          'type': type,
          'amount': amount,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('✅ Balance updated after transaction');
        return MoovBalanceModel.fromJson(data['data'] ?? data);
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error updating balance: $e');
      return null;
    }
  }

  /// Obtenir les frais de transaction estimés
  Future<Map<String, double>> getTransactionFees({
    required double amount,
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/api/v1/moov-money/fees/calculate',
        data: {
          'amount': amount,
          'type': type,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return {
          'fee': (data['fee'] ?? 0.0).toDouble(),
          'total': (data['total'] ?? amount).toDouble(),
          'commission': (data['commission'] ?? 0.0).toDouble(),
        };
      }
      
      return {'fee': 0.0, 'total': amount, 'commission': 0.0};
    } catch (e) {
      debugPrint('❌ Error calculating fees: $e');
      return {'fee': 0.0, 'total': amount, 'commission': 0.0};
    }
  }

  /// Vérifier le solde Moov Money via l'API IntegratingCheckBalance
  Future<Map<String, dynamic>?> checkMoovBalance({String? phoneNumber}) async {
    try {
      debugPrint('🔍 Checking Moov Money balance via API...');
      
      final token = await AppSharedPreference.getToken();
      if (token.isEmpty) {
        debugPrint('❌ No authentication token available');
        return null;
      }
      
      String baseUrl = AppConstants.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      final response = await _dio.get(
        '$baseUrl/api/v1/moov-money/check-balance',
        queryParameters: phoneNumber != null ? {'phone_number': phoneNumber} : null,
        options: Options(
          headers: {
            'Authorization': token,
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('📡 Check Balance Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'balance': (data['balance'] ?? 0).toDouble(),
          'bonus': (data['bonus'] ?? 0).toDouble(),
          'message': data['message'] ?? '',
          'phone': data['phone'] ?? '',
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error checking Moov balance: $e');
      return null;
    }
  }

  /// Sauvegarder le solde en cache local
  Future<void> cacheBalance(MoovBalanceModel balance) async {
    try {
      // Utiliser SharedPreferences ou une autre solution de cache
      // Pour l'instant, on peut utiliser une simple variable statique
      _cachedBalance = balance;
      _lastCacheTime = DateTime.now();
    } catch (e) {
      debugPrint('❌ Error caching balance: $e');
    }
  }

  /// Récupérer le solde depuis le cache
  MoovBalanceModel? getCachedBalance() {
    // Vérifier si le cache est encore valide (moins de 5 minutes)
    if (_cachedBalance != null && _lastCacheTime != null) {
      final difference = DateTime.now().difference(_lastCacheTime!);
      if (difference.inMinutes < 5) {
        return _cachedBalance;
      }
    }
    return null;
  }

  // Cache local simple
  static MoovBalanceModel? _cachedBalance;
  static DateTime? _lastCacheTime;
}
