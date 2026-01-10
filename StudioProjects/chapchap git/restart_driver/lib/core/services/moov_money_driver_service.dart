import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/endpoints.dart';
import '../../common/local_data.dart';
import '../../features/moov_money/domain/models/moov_money_request_model.dart';

class MoovMoneyDriverService {
  final Dio dio;

  MoovMoneyDriverService(this.dio);

  Future<Map<String, String>> _getHeaders() async {
    final token = await AppSharedPreference.getToken();
    return {
      'Authorization': token,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Get request details
  Future<MoovMoneyRequest> getRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        '${ApiEndpoints.getMoovMoneyRequest}$requestId',
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return MoovMoneyRequest.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get request');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Accept a Moov Money request
  Future<void> acceptRequest(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        '${ApiEndpoints.getMoovMoneyRequest}$requestId/accept',
        options: Options(headers: headers),
      );
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to accept request');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Reject a Moov Money request
  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        '${ApiEndpoints.getMoovMoneyRequest}$requestId/reject',
        data: {'reason': reason},
        options: Options(headers: headers),
      );
      
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to reject request');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Process deposit - validates security code
  Future<Map<String, dynamic>> processDeposit({
    required String requestId,
    required String securityCode,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        ApiEndpoints.processMoovMoneyDeposit,
        data: {
          'request_id': requestId,
          'security_code': securityCode,
        },
        options: Options(headers: headers),
      );

      debugPrint('🔍 processDeposit response type: ${response.data.runtimeType}');
      debugPrint('🔍 processDeposit response: ${response.data}');
      
      // Vérifier si la réponse est du HTML (erreur serveur)
      if (response.data is String && response.data.toString().contains('<!DOCTYPE')) {
        debugPrint('❌ Serveur retourne HTML au lieu de JSON - route non trouvée ou erreur serveur');
        throw Exception('Erreur serveur: La route API n\'existe pas. Contactez l\'administrateur.');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Vérifier si la réponse est un succès
        bool isSuccess = false;
        if (responseData is Map<String, dynamic>) {
          isSuccess = responseData['success'] == true;
        }
        
        if (isSuccess) {
          final data = responseData['data'];
          debugPrint('🔍 data type: ${data.runtimeType}');
          
          // Gérer différents formats de réponse
          if (data is Map<String, dynamic>) {
            return _sanitizeResponseData(data);
          } else if (data is List && data.isNotEmpty) {
            // Si c'est une liste, prendre le premier élément
            if (data[0] is Map) {
              return _sanitizeResponseData(Map<String, dynamic>.from(data[0]));
            }
          }
          return <String, dynamic>{};
        } else {
          throw Exception(responseData['message'] ?? 'Failed to process deposit');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process deposit');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }
  
  /// Sanitize response data to ensure correct types
  Map<String, dynamic> _sanitizeResponseData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value is Map) {
        // Récursivement sanitizer les objets imbriqués
        result[key] = _sanitizeResponseData(Map<String, dynamic>.from(value));
      } else if (value is List) {
        // Sanitizer les listes
        result[key] = value.map((item) {
          if (item is Map) {
            return _sanitizeResponseData(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        // Convertir les valeurs numériques string en int/double si nécessaire
        result[key] = value;
      }
    });
    
    return result;
  }

  /// Process withdrawal - This sends the USSD to the client
  Future<void> processWithdrawal({
    required String requestId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Nouveau workflow : envoyer le USSD via le nouvel endpoint
      // Le code de sécurité est vérifié côté client, pas besoin de l'envoyer ici
      final response = await dio.post(
        '/api/v1/moov-money/driver/process/$requestId',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to send USSD');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Signal arrival at customer location
  Future<void> signalArrival(String requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        '/api/v1/moov-money/driver/arrived/$requestId',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to signal arrival');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Cancel a Moov Money transaction
  Future<void> cancelRequest({
    required String requestId,
    required String reason,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        ApiEndpoints.cancelMoovMoneyRequest,
        data: {
          'request_id': requestId,
          'reason': reason,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel request');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Get Moov Money transaction history
  Future<Map<String, dynamic>> getHistory(Map<String, String> params) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        ApiEndpoints.moovMoneyHistory,
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get history');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Get Moov Money earnings summary
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        ApiEndpoints.moovMoneyEarnings,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get earnings');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Complete a Moov Money transaction (finalizes the trip and triggers payment)
  Future<Map<String, dynamic>> completeTransaction(String requestId) async {
    try {
      final headers = await _getHeaders();
      // Ajouter X-Requested-With pour indiquer une requête AJAX/API
      headers['X-Requested-With'] = 'XMLHttpRequest';
      
      final response = await dio.post(
        '/api/v1/moov-money/driver/complete/$requestId',
        data: {}, // Envoyer un body vide pour éviter les problèmes de parsing
        options: Options(headers: headers),
      );

      // Debug: afficher la réponse brute
      print('=== completeTransaction response ===');
      print('Status: ${response.statusCode}');
      print('Data type: ${response.data.runtimeType}');
      print('Data: ${response.data}');

      // Vérifier que la réponse est bien un Map
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response: ${response.data}');
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final resultData = data['data'];
        if (resultData is Map<String, dynamic>) {
          return resultData;
        }
        return {};
      } else {
        final message = data['message'];
        throw Exception(message is String ? message : 'Failed to complete transaction');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          final message = errorData['message'];
          throw Exception(message is String ? message : 'Network error');
        }
      }
      throw Exception('Failed to connect to server');
    }
  }

  /// Check Moov Money balance
  Future<Map<String, dynamic>> checkBalance({String? phoneNumber}) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        '/api/v1/moov-money/driver/check-balance',
        queryParameters: phoneNumber != null ? {'phone_number': phoneNumber} : null,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to check balance');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Network error');
      }
      throw Exception('Failed to connect to server');
    }
  }
}
