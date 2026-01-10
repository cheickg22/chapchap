import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/network.dart';
import '../../../../common/common.dart';
import '../../domain/models/cash_request_model.dart';

class CashServiceRepository {
  CashServiceRepository();

  /// Récupère les demandes cash disponibles pour le driver
  Future<AvailableCashRequestsResponse> getAvailableRequests() async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().get(
        'api/v1/driver/cash-requests/available',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Available Cash Requests Response: $response');
      }

      return AvailableCashRequestsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des demandes: $e');
    }
  }

  /// Accepte une demande cash
  Future<AcceptCashRequestResponse> acceptRequest({
    required String requestId,
    required String requestType, // 'withdrawal' ou 'deposit'
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().post(
        'api/v1/driver/cash-requests/accept',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: {
          'request_id': requestId,
          'request_type': requestType,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Accept Cash Request Response: $response');
      }

      return AcceptCashRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation de la demande: $e');
    }
  }

  /// Met à jour le statut d'une demande cash
  Future<AcceptCashRequestResponse> updateRequestStatus({
    required String requestId,
    required String requestType, // 'withdrawal' ou 'deposit'
    required String status, // 'arrived', 'in_progress', 'completed'
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      
      // Si le statut est 'arrived', utiliser l'endpoint spécifique
      final endpoint = status == 'arrived' 
          ? 'api/v1/driver/cash-requests/arrived'
          : 'api/v1/driver/cash-requests/update-status';
      
      final response = await DioProviderImpl().post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: {
          'request_id': requestId,
          'request_type': requestType,
          if (status != 'arrived') 'status': status,
        },
      );
      
      if (kDebugMode) {
        debugPrint('✅ Update Request Status Response ($status): $response');
      }

      return AcceptCashRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Récupère les demandes assignées au driver
  Future<AvailableCashRequestsResponse> getMyRequests() async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().get(
        'api/v1/driver/cash-requests/my-requests',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      
      if (kDebugMode) {
        debugPrint('My Cash Requests Response: $response');
      }

      return AvailableCashRequestsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de mes demandes: $e');
    }
  }

  /// Effectue une opération Cash Out (retrait) - débite le wallet du client
  Future<MoovOperationResponse> performCashOut({
    required String requestId,
    required String clientPhoneNumber,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().post(
        'api/v1/driver/cash-requests/cash-out',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: {
          'request_id': requestId,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Cash Out Response: $response');
      }

      return MoovOperationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'opération Cash Out: $e');
    }
  }

  /// Effectue une opération Cash In (dépôt) - crédite le wallet du client
  Future<MoovOperationResponse> performCashIn({
    required String requestId,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().post(
        'api/v1/driver/cash-requests/cash-in',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: {
          'request_id': requestId,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Cash In Response: $response');
      }

      return MoovOperationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'opération Cash In: $e');
    }
  }

  /// Valide le code de sécurité pour une demande
  Future<AcceptCashRequestResponse> validateSecurityCode({
    required String requestId,
    required String requestType,
    required String securityCode,
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().post(
        'api/v1/driver/cash-requests/validate-code',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: {
          'request_id': requestId,
          'request_type': requestType,
          'security_code': securityCode,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Validate Security Code Response: $response');
      }

      return AcceptCashRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de la validation du code: $e');
    }
  }

  /// Upload une photo de preuve pour une demande
  Future<AcceptCashRequestResponse> uploadProofPhoto({
    required String requestId,
    required String requestType,
    required String photoPath,
  }) async {
    try {
      // Note: Upload de fichiers nécessite une implémentation spécifique
      // Pour l'instant, on retourne une réponse simulée
      await Future.delayed(const Duration(seconds: 1));
      
      if (kDebugMode) {
        debugPrint('Upload Proof Photo: $requestId, $requestType, $photoPath');
      }
      
      // Simulation d'une réponse réussie
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'success': true,
          'message': 'Photo uploadée avec succès',
          'data': {
            'request': {
              'id': requestId,
              'status': 'proof_uploaded',
            }
          }
        },
      );

      return AcceptCashRequestResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de la photo: $e');
    }
  }

  /// Calcule la commission pour un montant donné
  Future<Map<String, dynamic>> calculateCommission({
    required double amount,
    required String type, // 'withdrawal' ou 'deposit'
  }) async {
    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().get(
        'api/v1/cash-requests/calculate-commission',
        queryParams: {
          'amount': amount,
          'type': type,
        },
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );
      
      if (kDebugMode) {
        debugPrint('Calculate Commission Response: $response');
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Erreur lors du calcul de la commission: $e');
    }
  }

  /// Gère les erreurs Dio et retourne des messages d'erreur appropriés
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout de connexion. Vérifiez votre connexion internet.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Erreur du serveur';
        
        switch (statusCode) {
          case 400:
            return Exception('Requête invalide: $message');
          case 401:
            return Exception('Non autorisé. Veuillez vous reconnecter.');
          case 403:
            return Exception('Accès interdit: $message');
          case 404:
            return Exception('Ressource non trouvée: $message');
          case 422:
            final errors = e.response?.data?['errors'];
            if (errors != null) {
              final errorMessages = <String>[];
              if (errors is Map) {
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.cast<String>());
                  } else {
                    errorMessages.add(value.toString());
                  }
                });
              }
              return Exception('Erreurs de validation: ${errorMessages.join(', ')}');
            }
            return Exception('Erreur de validation: $message');
          case 500:
            return Exception('Erreur interne du serveur. Veuillez réessayer plus tard.');
          default:
            return Exception('Erreur HTTP $statusCode: $message');
        }
      
      case DioExceptionType.cancel:
        return Exception('Requête annulée');
      
      case DioExceptionType.connectionError:
        return Exception('Erreur de connexion. Vérifiez votre connexion internet.');
      
      default:
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}

/// Extension pour ajouter des méthodes utilitaires
extension CashServiceRepositoryExtension on CashServiceRepository {
  /// Vérifie si une demande peut être acceptée
  bool canAcceptRequest(CashRequestModel request) {
    return request.isPending && request.distance != null && request.distance! <= 10.0; // Max 10km
  }

  /// Formate un numéro de téléphone pour Moov Money
  String formatPhoneForMoov(String phoneNumber) {
    // Supprime tous les caractères non numériques
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si le numéro commence par +223, on le supprime
    if (cleaned.startsWith('223')) {
      cleaned = cleaned.substring(3);
    }
    
    // Assure-toi que le numéro fait 8 chiffres
    if (cleaned.length == 8) {
      return cleaned;
    }
    
    throw Exception('Numéro de téléphone invalide: $phoneNumber');
  }

  /// Calcule la distance entre deux points géographiques
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
