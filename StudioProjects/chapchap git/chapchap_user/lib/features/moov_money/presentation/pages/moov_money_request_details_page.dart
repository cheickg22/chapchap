import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/local_data.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../data/services/moov_money_stats_storage.dart';
import '../../data/services/moov_money_realtime_service.dart';
import '../../../../core/services/hybrid_status_service.dart';
import '../widgets/moov_money_status_widget.dart';
import 'moov_money_payment_confirmation_page.dart';
import 'moov_money_transaction_completed_page.dart';
import 'moov_money_transaction_cancelled_page.dart';
import 'moov_money_transaction_failed_page.dart';
import 'dart:async';
import 'dart:math';

class MoovMoneyRequestDetailsPage extends StatefulWidget {
  static const String routeName = '/moovMoneyRequestDetails';
  final String requestId;
  final Map<String, dynamic>? requestData; // Données optionnelles

  const MoovMoneyRequestDetailsPage({
    Key? key,
    required this.requestId,
    this.requestData, // Paramètre optionnel
  }) : super(key: key);

  @override
  State<MoovMoneyRequestDetailsPage> createState() => _MoovMoneyRequestDetailsPageState();
}

class _MoovMoneyRequestDetailsPageState extends State<MoovMoneyRequestDetailsPage> {
  Map<String, dynamic>? _request;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSecurityCodeVisible = false;
  final MoovMoneyRealtimeService _realtimeService = MoovMoneyRealtimeService();
  final HybridStatusService _hybridService = HybridStatusService();
  StreamSubscription<Map<String, dynamic>>? _realtimeSubscription;
  Timer? _pollingTimer; // Timer pour le polling automatique
  String? _lastStatus; // Dernier statut pour détecter les changements

  @override
  void initState() {
    super.initState();
    // Si les données sont déjà fournies, les utiliser directement
    if (widget.requestData != null) {
      print('✅ Utilisation des données fournies directement');
      setState(() {
        _request = widget.requestData;
        _isLoading = false;
      });
    } else {
      print('🔍 Chargement des données depuis l\'API');
      _loadRequestDetails();
    }
    // Écouter les mises à jour en temps réel
    _listenToRealtimeUpdates();
    // Démarrer le polling automatique pour les demandes actives
    _startAutoPolling();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _pollingTimer?.cancel();
    _realtimeService.dispose();
    _hybridService.dispose();
    super.dispose();
  }

  /// Écoute les mises à jour en temps réel depuis Firebase (avec service hybride)
  void _listenToRealtimeUpdates() {
    print('🔄 Démarrage service hybride pour requestId: ${widget.requestId}');
    print('   📍 Chemin Firebase: requests/${widget.requestId}/moov_money_status');
    print('   📡 Endpoint API: api/v1/moov-money/requests/${widget.requestId}');
    
    // Utiliser le service hybride (Firebase + Polling API)
    _hybridService.startListening(
      requestId: widget.requestId,
      onStatusChanged: (status) {
        print('📱 User: Statut changé: $status');
        print('   🕐 Timestamp: ${DateTime.now().toIso8601String()}');
        
        // Vérifier si le statut a changé
        final statusChanged = _lastStatus != null && _lastStatus != status;
        if (statusChanged) {
          print('🔄 Changement de statut détecté: $_lastStatus → $status');
        } else {
          print('ℹ️ Statut identique, pas de changement');
        }
        
        setState(() {
          if (_request != null) {
            // Mettre à jour le statut
            _request!['status'] = status;
            _request!['moov_money_status'] = status;
            _request!['_hybrid_updated_at'] = DateTime.now().millisecondsSinceEpoch;
            
            print('✅ Statut mis à jour dans _request: ${_request!['status']}');
          } else {
            print('⚠️ _request est null, impossible de mettre à jour');
          }
          
          // Mettre à jour le dernier statut
          _lastStatus = status;
        });
        
        // Afficher une notification locale si le statut a changé
        if (statusChanged && status != 'null' && status != 'pending') {
          _showStatusChangeNotification(status);
        }
        
        // Recharger les détails complets depuis l'API
        if (statusChanged) {
          print('🔄 Rechargement des détails depuis l\'API...');
          _loadRequestDetails();
        }
      },
      apiEndpoint: 'api/v1/moov-money/requests/{id}',
    );
    
    print('🔄 Service hybride démarré (Firebase + Polling)');
    print('   - Firebase: Temps réel si connexion OK');
    print('   - Polling API: Backup toutes les 10s si Firebase lent');
    print('   - Cache: 2 minutes de validité');
    
    // Garder aussi l'ancien listener Firebase pour les données complètes
    _realtimeSubscription = _realtimeService
        .listenToRequest(widget.requestId)
        .listen(
      (data) {
        if (data.isNotEmpty && mounted) {
          setState(() {
            if (_request != null) {
              // Fusionner les données Firebase avec les données existantes
              _request = {..._request!, ...data};
              
              // Mettre à jour les infos du driver si présentes
              if (data.containsKey('driver_id')) {
                _request!['driver_id'] = data['driver_id'];
              }
              if (data.containsKey('driver_name')) {
                _request!['driver_name'] = data['driver_name'];
              }
            }
          });
        } else {
          print('⚠️ Données Firebase vides');
        }
      },
      onError: (error) {
        print('❌ Erreur Firebase: $error');
      },
    );
  }

  /// Affiche une notification locale lors du changement de statut
  void _showStatusChangeNotification(String status) {
    String message = '';
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'assigned':
        message = 'Agent trouvé ! Il se dirige vers vous';
        break;
      case 'arrived':
        message = 'L\'agent est arrivé ! Montrez votre code';
        break;
      case 'processing':
      case 'in_progress':
        message = 'Transaction en cours...';
        break;
      case 'completed':
        message = '✅ Transaction réussie !';
        break;
      case 'cancelled':
        message = 'Transaction annulée';
        break;
      case 'failed':
        message = 'Transaction échouée';
        break;
    }
    
    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: status.toLowerCase() == 'completed' 
              ? Colors.green 
              : status.toLowerCase() == 'failed' || status.toLowerCase() == 'cancelled'
                  ? Colors.red
                  : Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Démarre le polling automatique pour les demandes actives
  void _startAutoPolling() {
    // Vérifier toutes les 10 secondes si la demande est toujours active
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Rafraîchir seulement si la demande est en attente ou assignée
      final status = _request?['status']?.toString().toLowerCase();
      if (status == 'pending' || status == 'assigned' || status == 'accepted' || 
          status == 'arrived' || status == 'processing' || status == 'in_progress') {
        print('🔄 Polling automatique - Rafraîchissement des données...');
        _loadRequestDetails(silent: true);
      } else {
        // Arrêter le polling si la demande est terminée
        print('⏹️ Arrêt du polling - Demande terminée (status: $status)');
        timer.cancel();
      }
    });
  }

  Future<void> _loadRequestDetails({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      print('🔍 Chargement des détails pour requestId: ${widget.requestId}');
      print('🔍 Request ID length: ${widget.requestId.length}');
      print('🔍 Request ID type: ${widget.requestId.runtimeType}');
      
      final token = await AppSharedPreference.getToken();
      print('🔐 Token: ${token.substring(0, min(20, token.length))}...');
      
      final response = await DioProviderImpl().get(
        'api/v1/moov-money/requests/${widget.requestId}',
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Réponse reçue - Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final newRequest = data['data'] ?? data;
        
        // Logs détaillés pour debugging
        print('📊 API Response Details:');
        print('   - status: ${newRequest['status']}');
        print('   - moov_money_status: ${newRequest['moov_money_status']}');
        print('   - amount: ${newRequest['amount']}');
        print('   - moov_money_amount: ${newRequest['moov_money_amount']}');
        print('   - total_amount: ${newRequest['total_amount']}');
        print('   - moov_money_total_amount: ${newRequest['moov_money_total_amount']}');
        print('   - commission: ${newRequest['commission']}');
        print('   - moov_money_fees: ${newRequest['moov_money_fees']}');
        print('   - is_completed: ${newRequest['is_completed']}');
        print('   - is_cancelled: ${newRequest['is_cancelled']}');
        
        setState(() {
          if (_request != null && silent) {
            // En mode silencieux (polling), préserver le statut Firebase si plus récent
            final currentStatus = _request!['status']?.toString();
            final firebaseStatus = _request!['_firebase_status']?.toString();
            final firebaseTimestamp = _request!['_firebase_updated_at'] as int?;
            final newStatus = newRequest['status']?.toString();
            
            print('🔄 Polling - Status actuel: $currentStatus, Firebase: $firebaseStatus, API: $newStatus');
            
            // Déterminer quel statut utiliser AVANT la fusion
            String statusToUse = currentStatus ?? 'pending';
            
            final now = DateTime.now().millisecondsSinceEpoch;
            final isFirebaseRecent = firebaseTimestamp != null && 
                                    (now - firebaseTimestamp) < 30000; // 30 secondes
            
            if (isFirebaseRecent && firebaseStatus != null) {
              // Firebase est récent, utiliser son statut
              statusToUse = firebaseStatus;
              print('✅ Statut Firebase préservé (récent): $firebaseStatus');
            } else if (currentStatus == 'completed' || currentStatus == 'cancelled' || currentStatus == 'failed') {
              // Statut final, le garder
              statusToUse = currentStatus ?? 'pending';  // ✅ Null-safe
              print('✅ Statut final préservé: $currentStatus');
            } else if (newStatus != null && newStatus != currentStatus) {
              // Sinon, utiliser le nouveau statut de l'API
              statusToUse = newStatus;
              print('🔄 Statut API mis à jour: $currentStatus → $newStatus');
            }
            
            // Créer une copie de newRequest SANS le champ status
            final newRequestWithoutStatus = Map<String, dynamic>.from(newRequest);
            newRequestWithoutStatus.remove('status');
            newRequestWithoutStatus.remove('moov_money_status');
            
            // Fonction helper pour vérifier si une valeur est vide
            bool isEmptyValue(dynamic value) {
              if (value == null) return true;
              if (value is String && value.trim().isEmpty) return true;
              if (value is num && value == 0) return true;
              return false;
            }
            
            // Préserver le montant existant si l'API retourne 0, null ou chaîne vide
            final currentAmount = _request!['amount'];
            final currentMoovAmount = _request!['moov_money_amount'];
            if (isEmptyValue(newRequestWithoutStatus['amount']) && !isEmptyValue(currentAmount)) {
              newRequestWithoutStatus['amount'] = currentAmount;
              print('💰 Montant préservé: $currentAmount');
            }
            if (isEmptyValue(newRequestWithoutStatus['moov_money_amount']) && !isEmptyValue(currentMoovAmount)) {
              newRequestWithoutStatus['moov_money_amount'] = currentMoovAmount;
              print('💰 Moov montant préservé: $currentMoovAmount');
            }
            
            // Fusionner les données en préservant les métadonnées Firebase
            final firebaseData = {
              'status': statusToUse,  // ✅ Statut décidé
              if (firebaseStatus != null) '_firebase_status': firebaseStatus,
              if (firebaseTimestamp != null) '_firebase_updated_at': firebaseTimestamp,
            };
            
            // Fusion: existant < API (sans status) < Firebase metadata
            _request = {..._request!, ...newRequestWithoutStatus, ...firebaseData};
            
            print('   → Statut final dans _request: ${_request!['status']}');
          } else {
            // Premier chargement ou chargement non-silencieux
            // Préserver le montant de requestData initial si l'API retourne 0, null ou chaîne vide
            if (_request != null) {
              // Fonction helper pour vérifier si une valeur est vide
              bool isEmptyValue(dynamic value) {
                if (value == null) return true;
                if (value is String && value.trim().isEmpty) return true;
                if (value is num && value == 0) return true;
                return false;
              }
              
              final initialAmount = _request!['amount'];
              final initialMoovAmount = _request!['moov_money_amount'];
              
              if (isEmptyValue(newRequest['amount']) && !isEmptyValue(initialAmount)) {
                newRequest['amount'] = initialAmount;
                print('💰 Montant initial préservé lors du chargement API: $initialAmount');
              }
              if (isEmptyValue(newRequest['moov_money_amount']) && !isEmptyValue(initialMoovAmount)) {
                newRequest['moov_money_amount'] = initialMoovAmount;
                print('💰 Moov montant initial préservé lors du chargement API: $initialMoovAmount');
              }
            }
            
            _request = newRequest;
          }
          
          if (!silent) _isLoading = false;
        });
        
        if (silent) {
          print('🔄 Données rafraîchies en arrière-plan - Status: ${_request!['status']}');
        } else {
          print('✅ Détails chargés avec succès');
        }
      } else if (response.statusCode == 404) {
        // Demande non trouvée - essayer de récupérer depuis Firebase
        print('⚠️ Demande non trouvée en base (404) - tentative Firebase...');
        if (!silent) {
          await _loadFromFirebase();
        }
      } else {
        print('❌ Erreur: ${response.data}');
        if (!silent) {
          setState(() {
            _errorMessage = response.data['message'] ?? 'Demande non trouvée';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement détails: $e');
      
      // Si erreur 404, essayer Firebase
      if (e.toString().contains('404') && !silent) {
        print('⚠️ 404 détecté - tentative Firebase...');
        await _loadFromFirebase();
      } else {
        if (!silent) {
          setState(() {
            _errorMessage = 'Erreur de connexion: ${e.toString()}';
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Charger les données depuis Firebase en cas d'échec de l'API
  Future<void> _loadFromFirebase() async {
    try {
      print('🔥 Chargement depuis Firebase...');
      
      // Attendre que Firebase envoie les données (max 3 secondes)
      await Future.delayed(const Duration(seconds: 3));
      
      if (_request != null && _request!.isNotEmpty) {
        print('✅ Données Firebase disponibles');
        print('   - ID: ${_request!['id']}');
        print('   - Status: ${_request!['status']}');
        print('   - Amount: ${_request!['amount']}');
        
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        print('❌ Aucune donnée Firebase disponible après 3 secondes');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Demande non trouvée (ID: ${widget.requestId})\n\nCette demande n\'existe pas ou n\'est pas accessible.';
        });
      }
    } catch (e) {
      print('❌ Erreur Firebase: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger les données';
      });
    }
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette demande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      print('🚫 Annulation de la demande: ${widget.requestId}');
      
      // Afficher un loader
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Annulation en cours...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }
      
      final token = await AppSharedPreference.getToken();
      print('🔐 Token: ${token.substring(0, min(20, token.length))}...');
      
      // Essayer d'abord l'endpoint /request/moov-money/{id}/cancel
      Response? response;
      try {
        response = await DioProviderImpl().post(
          'api/v1/moov-money/requests/${widget.requestId}/cancel',
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: FormData.fromMap({'reason': 'Annulé par l\'utilisateur'}),
        );
        print('📡 Réponse endpoint 1 - Status: ${response.statusCode}');
      } catch (e) {
        print('⚠️ Endpoint 1 échoué: $e');
        
        // Vérifier si c'est une erreur CSRF (419)
        if (e.toString().contains('419')) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
        
        // Essayer l'ancien endpoint
        try {
          response = await DioProviderImpl().post(
            'api/v1/moov-money/transactions/${widget.requestId}/cancel',
            headers: {'Authorization': token},
            body: FormData.fromMap({}),
          );
          print('📡 Réponse endpoint 2 - Status: ${response.statusCode}');
        } catch (e2) {
          print('⚠️ Endpoint 2 échoué: $e2');
          
          // Vérifier si c'est une erreur CSRF (419)
          if (e2.toString().contains('419')) {
            throw Exception('Session expirée. Veuillez vous reconnecter.');
          }
          
          throw e2;
        }
      }
      
      print('📦 Data: ${response.data}');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Vérifier le code de statut
      if (response.statusCode == 419) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Demande annulée avec succès');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Demande annulée avec succès'),
              backgroundColor: AppColors.moovColor,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Recharger les détails
          await _loadRequestDetails();
          
          // Retourner à la page précédente après 2 secondes
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        print('❌ Erreur: ${response.data}');
        throw Exception(response.data['message'] ?? 'Erreur lors de l\'annulation');
      }
    } catch (e) {
      print('❌ Exception lors de l\'annulation: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _cancelRequest,
            ),
          ),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'assigned':
        return 'Assigné';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  IconData _getTypeIcon(String type) {
    return type == 'deposit' ? Icons.add_card : Icons.account_balance_wallet;
  }

  Color _getTypeColor(String type) {
    return type == 'deposit' ? Colors.green : Colors.red;
  }

  String _getTypeLabel(String type) {
    return type == 'deposit' ? 'Dépôt' : 'Retrait';
  }

  @override
  Widget build(BuildContext context) {
    print('📱 PAGE: MoovMoneyRequestDetailsPage');
    print('   RequestID: ${widget.requestId}');
    print('   Status: ${_request?['status']}');
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Détails MoovMoney',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.moovColor,
                AppColors.moovColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.moovColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.moovColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oups !',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loadRequestDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.moovColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Réessayer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequestDetails,
                  color: AppColors.moovColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte principale avec montant et statut
                        _buildHeaderCard(),
                        const SizedBox(height: 16),
                        
                        // Code de sécurité
                        _buildSecurityCodeCard(),
                        const SizedBox(height: 16),
                        
                        // Bouton de confirmation de paiement
                        Builder(
                          builder: (context) {
                            final currentStatus = (_request!['status'] ?? '').toString().toLowerCase();
                            final moovStatus = (_request!['moov_money_status'] ?? '').toString().toLowerCase();
                            final isDriverArrived = _request!['is_driver_arrived'] == 1 || _request!['is_driver_arrived'] == true;
                            final isDriverStarted = _request!['is_driver_started'] == 1 || _request!['is_driver_started'] == true;
                            final effectiveStatus = currentStatus.isEmpty ? moovStatus : currentStatus;
                            
                            final shouldShowButton = effectiveStatus == 'waiting_payment' ||
                                                     (effectiveStatus == 'processing' && isDriverArrived) ||
                                                     (effectiveStatus == 'processing' && isDriverStarted) ||
                                                     effectiveStatus == 'arrived';
                            
                            if (shouldShowButton) {
                              return Column(
                                children: [
                                  _buildPaymentConfirmationButton(),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        
                        // Widget de statut simplifié
                        Builder(
                          builder: (context) {
                            final moovStatus = (_request!['moov_money_status'] ?? '').toString();
                            final generalStatus = (_request!['status'] ?? '').toString();
                            final currentStatus = moovStatus.isNotEmpty ? moovStatus : generalStatus.isNotEmpty ? generalStatus : 'pending';
                            
                            return MoovMoneyStatusWidget(
                              status: currentStatus,
                              additionalData: _request,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Info agent si assigné
                        if (_request!['driver_name'] != null) ...[
                          _buildDriverCardSimple(),
                          const SizedBox(height: 16),
                        ],
                        
                        // Bouton annuler si en attente
                        if (_request!['status'] == 'pending' || _request!['status'] == 'assigned')
                          _buildCancelButton(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    final type = _request!['request_type'] ?? _request!['type'] ?? 'deposit';
    final status = _request!['status'] ?? 'pending';
    
    // Fonction helper pour vérifier si une valeur est vide
    bool isEmpty(dynamic value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is num && value == 0) return true;
      return false;
    }
    
    // Chercher le montant dans tous les champs possibles
    dynamic amount = 0;
    
    // Essayer moov_money_amount en premier
    if (!isEmpty(_request!['moov_money_amount'])) {
      amount = _request!['moov_money_amount'];
    }
    // Sinon essayer amount
    else if (!isEmpty(_request!['amount'])) {
      amount = _request!['amount'];
    }
    // Sinon essayer total_amount
    else if (!isEmpty(_request!['total_amount'])) {
      amount = _request!['total_amount'];
    }
    // Sinon essayer moov_money_total_amount
    else if (!isEmpty(_request!['moov_money_total_amount'])) {
      amount = _request!['moov_money_total_amount'];
    }
    
    // Convertir en nombre si c'est une chaîne
    if (amount is String) {
      amount = double.tryParse(amount) ?? 0;
    }
    
    // Debug: afficher tous les champs de montant disponibles
    print('💰 DEBUG Montant:');
    print('   - moov_money_amount: "${_request!['moov_money_amount']}" (isEmpty: ${isEmpty(_request!['moov_money_amount'])})');
    print('   - amount: "${_request!['amount']}" (isEmpty: ${isEmpty(_request!['amount'])})');
    print('   - total_amount: "${_request!['total_amount']}" (isEmpty: ${isEmpty(_request!['total_amount'])})');
    print('   - moov_money_total_amount: "${_request!['moov_money_total_amount']}" (isEmpty: ${isEmpty(_request!['moov_money_total_amount'])})');
    print('   → Montant final affiché: $amount');
    
    final isDeposit = type == 'deposit';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDeposit 
            ? [Colors.green.shade400, Colors.green.shade600]
            : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDeposit ? Colors.green : Colors.blue).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icône et type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Type de transaction
            Text(
              _getTypeLabel(type),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Montant
            Text(
              '${amount is double ? amount.toInt() : amount} FCFA',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCodeCard() {
    final securityCode = _request!['moov_money_security_code']?.toString() ?? 
                        _request!['security_code']?.toString() ?? 
                        _request!['ride_otp']?.toString();
    
    if (securityCode == null || securityCode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Code de sécurité',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.shade300, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSecurityCodeVisible ? securityCode : '••••••',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _isSecurityCodeVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.orange.shade600,
                  ),
                  onPressed: () => setState(() => _isSecurityCodeVisible = !_isSecurityCodeVisible),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: securityCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Code copié !'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 20),
              label: const Text('Copier le code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Donnez ce code à l\'agent pour confirmer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDriverCardSimple() {
    final driverName = _request!['driver_name'] ?? 'Agent';
    final driverPhone = _request!['driver_phone'] ?? _request!['driver_mobile'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.moovColor.withOpacity(0.1),
            child: Icon(Icons.person, color: AppColors.moovColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (driverPhone != null)
                  Text(
                    driverPhone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
              ],
            ),
          ),
          if (driverPhone != null)
            IconButton(
              onPressed: () {
                // TODO: Appeler l'agent
              },
              icon: Icon(Icons.phone, color: AppColors.moovColor),
            ),
        ],
      ),
    );
  }


  Widget _buildCompletedTransactionSummary() {
    final type = (_request!['moov_money_type'] ?? _request!['type'] ?? 'deposit').toString();
    final amount = _request!['moov_money_amount'] ?? _request!['amount'] ?? 0;
    final completedAt = _request!['completed_at'] ?? _request!['updated_at'] ?? '';
    final requestNumber = _request!['request_number'] ?? 'N/A';
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Terminée',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Votre ${type == 'deposit' ? 'dépôt' : 'retrait'} a été effectué avec succès',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Montant ${type == 'deposit' ? 'déposé' : 'retiré'}',
                    '${amount.toString()} FCFA',
                    Icons.payments,
                    Colors.green,
                    isBold: true,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Numéro de transaction',
                    requestNumber,
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Date de complétion',
                    _formatDateTime(completedAt),
                    Icons.access_time,
                    Colors.orange,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Statut',
                    'Terminé',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cette transaction a été complétée et validée par l\'agent MoovMoney.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color, {bool isBold = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isBold ? color : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentConfirmationButton() {
    final type = (_request!['moov_money_type'] ?? _request!['type'] ?? 'deposit').toString();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paiement en attente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == 'deposit'
                          ? 'Remettez l\'argent à l\'agent'
                          : 'Récupérez l\'argent de l\'agent',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoovMoneyPaymentConfirmationPage(
                      requestId: widget.requestId,
                      requestData: _request!,
                    ),
                  ),
                );
                
                // Si la confirmation a réussi, naviguer vers la page appropriée
                if (result == true && mounted) {
                  // Recharger les détails d'abord pour avoir le statut mis à jour
                  await _loadRequestDetails();
                  
                  // Invalider le cache des statistiques pour forcer le recalcul
                  await MoovMoneyStatsStorage.invalidateCache();
                  print('🗑️ Cache des statistiques invalidé après confirmation');
                  
                  // Vérifier le nouveau statut et naviguer en conséquence
                  final currentStatus = (_request!['moov_money_status'] ?? _request!['status'] ?? '').toString().toLowerCase();
                  final isCompleted = currentStatus == 'completed' || _request!['is_completed'] == 1;
                  final isCancelled = currentStatus == 'cancelled' || _request!['is_cancelled'] == 1;
                  final isFailed = currentStatus == 'failed' || currentStatus == 'timeout';
                  
                  Widget targetPage;
                  
                  if (isCompleted) {
                    targetPage = MoovMoneyTransactionCompletedPage(requestId: widget.requestId);
                  } else if (isCancelled) {
                    targetPage = MoovMoneyTransactionCancelledPage(requestId: widget.requestId);
                  } else if (isFailed) {
                    targetPage = MoovMoneyTransactionFailedPage(requestId: widget.requestId);
                  } else {
                    // Rester sur la page de détails si pas terminé
                    return;
                  }
                  
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => targetPage),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Confirmer le paiement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _cancelRequest,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Annuler la demande',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
