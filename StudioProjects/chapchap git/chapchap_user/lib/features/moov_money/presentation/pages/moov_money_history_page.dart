import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/local_data.dart';
import 'moov_money_request_details_page.dart';
import 'moov_money_transaction_completed_page.dart';
import 'moov_money_transaction_cancelled_page.dart';
import 'moov_money_transaction_failed_page.dart';
import '../../data/services/moov_money_stats_storage.dart';
import '../../data/services/moov_money_realtime_service.dart';
import '../../../../core/services/hybrid_status_service.dart';
import '../widgets/moov_money_stats_widget.dart';
import 'dart:async';
import 'dart:math';

class MoovMoneyHistoryPage extends StatefulWidget {
  static const String routeName = '/moovMoneyHistory';

  const MoovMoneyHistoryPage({Key? key}) : super(key: key);

  @override
  State<MoovMoneyHistoryPage> createState() => _MoovMoneyHistoryPageState();
}

class _MoovMoneyHistoryPageState extends State<MoovMoneyHistoryPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, deposit, withdrawal
  String _selectedStatus = 'all'; // all, pending, completed, cancelled
  final Map<String, StreamSubscription<Map<String, dynamic>>> _realtimeSubscriptions = {};
  final Map<String, HybridStatusService> _hybridServices = {};
  final MoovMoneyRealtimeService _realtimeService = MoovMoneyRealtimeService();
  final Set<String> _locallyCancelledRequests = {}; // Track cancelled requests to ignore Firebase updates

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    // Annuler tous les abonnements Firebase
    for (var subscription in _realtimeSubscriptions.values) {
      subscription.cancel();
    }
    _realtimeSubscriptions.clear();
    
    // Annuler tous les services hybrides
    for (var service in _hybridServices.values) {
      service.dispose();
    }
    _hybridServices.clear();
    
    _realtimeService.dispose();
    super.dispose();
  }

  /// Écoute les mises à jour en temps réel pour une demande (avec service hybride)
  void _listenToRequestUpdates(String requestId, int index) {
    // Éviter les doublons
    if (_hybridServices.containsKey(requestId)) return;

    // Utiliser le service hybride
    final hybridService = HybridStatusService();
    _hybridServices[requestId] = hybridService;
    
    hybridService.startListening(
      requestId: requestId,
      onStatusChanged: (status) {
        if (mounted && !_locallyCancelledRequests.contains(requestId)) {
          setState(() {
            if (index < _requests.length && _requests[index]['id'] == requestId) {
              _requests[index]['status'] = status;
              _requests[index]['moov_money_status'] = status;
            }
          });
        }
      },
      apiEndpoint: 'https://chapchap-livraison.com/api/v1/moov-money/requests/{id}',
    );
    
    // Garder aussi le listener Firebase pour les données complètes
    final subscription = _realtimeService.listenToRequest(requestId).listen(
      (data) {
        if (data.isNotEmpty && mounted) {
          final firebaseStatus = data['status']?.toString() ?? data['moov_money_status']?.toString();
          
          // Ignorer les mises à jour Firebase pour les demandes annulées localement
          if (_locallyCancelledRequests.contains(requestId)) {
            print('🚫 Mise à jour Firebase ignorée pour demande annulée: $requestId');
            print('   Firebase voulait mettre: $firebaseStatus');
            print('   Statut local maintenu: cancelled');
            return;
          }
          
          setState(() {
            // Mettre à jour la demande dans la liste
            if (index < _requests.length && _requests[index]['id'] == requestId) {
              print('🔥 Firebase update pour $requestId - Status: $firebaseStatus');
              
              // Si Firebase envoie "failed" mais qu'on a annulé, forcer "cancelled"
              if (firebaseStatus == 'failed' && _locallyCancelledRequests.contains(requestId)) {
                print('⚠️ Firebase a envoyé "failed" mais demande verrouillée → forcer "cancelled"');
                data['status'] = 'cancelled';
                data['moov_money_status'] = 'cancelled';
              }
              
              _requests[index] = {..._requests[index], ...data};
            }
          });
        }
      },
      onError: (error) {
        print('❌ Erreur Firebase pour $requestId: $error');
      },
    );

    _realtimeSubscriptions[requestId] = subscription;
  }

  /// Démarre l'écoute pour toutes les demandes actives
  void _startRealtimeListening() {
    for (int i = 0; i < _requests.length; i++) {
      final request = _requests[i];
      final requestId = request['id']?.toString();
      final status = request['status']?.toString().toLowerCase();
      
      // Écouter uniquement les demandes non terminées
      if (requestId != null && 
          status != 'completed' && 
          status != 'cancelled' && 
          status != 'failed') {
        _listenToRequestUpdates(requestId, i);
      }
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📜 Chargement de l\'historique...');
      final token = await AppSharedPreference.getToken();
      print('🔐 Token: ${token.substring(0, 20)}...');
      
      // Construire l'URL avec les filtres
      String url = 'https://chapchap-livraison.com/api/v1/moov-money/my-requests';
      List<String> params = [];
      if (_selectedFilter != 'all') params.add('type=$_selectedFilter');
      if (_selectedStatus != 'all') params.add('status=$_selectedStatus');
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      print('🌐 URL: $url');

      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': token,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('📡 Réponse - Status: ${response.statusCode}');
      print('📦 Data type: ${response.data.runtimeType}');
      
      // Vérifier si la réponse est du HTML au lieu de JSON
      if (response.data is String && response.data.toString().contains('<script')) {
        print('❌ ERREUR: L\'API retourne du HTML au lieu de JSON!');
        print('🔍 Début de la réponse: ${response.data.toString().substring(0, 200)}');
        setState(() {
          _errorMessage = 'Erreur serveur: L\'API retourne du HTML au lieu de JSON.\nVérifiez l\'endpoint: $url';
          _isLoading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final data = response.data;
        print('📦 Data structure: ${data.runtimeType}');
        
        final List<dynamic> requestsList = data['data'] ?? data['requests'] ?? [];
        setState(() {
          _requests = requestsList.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
          
          // Nettoyer la liste des demandes annulées - garder seulement celles toujours présentes
          final currentRequestIds = _requests.map((r) => r['id']?.toString()).whereType<String>().toSet();
          _locallyCancelledRequests.retainWhere((id) => currentRequestIds.contains(id));
          print('🧹 Liste des demandes annulées nettoyée: ${_locallyCancelledRequests.length} restantes');
        });
        print('✅ ${_requests.length} demandes chargées');
        
        // Forcer la mise à jour des statistiques
        if (mounted) {
          setState(() {}); // Déclenche un rebuild pour mettre à jour les stats
        }
        
        // Démarrer l'écoute en temps réel pour les demandes actives
        _startRealtimeListening();
      } else {
        print('❌ Erreur: ${response.data}');
        setState(() {
          _errorMessage = response.data['message'] ?? 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement historique: $e');
      setState(() {
        _errorMessage = 'Erreur de connexion: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'assigned':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'accepted':
      case 'assigned':
        return 'Assigné';
      case 'arrived':
        return 'Arrivé';
      case 'processing':
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
      case 'assigned':
        return Icons.person_pin;
      case 'arrived':
        return Icons.location_on;
      case 'processing':
      case 'in_progress':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          'Historique Moov Money',
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
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.85),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          if (!_isLoading && _requests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: MoovMoneyStatsWidget(requests: _requests),
            ),
          
          // Filtres rapides
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    'Tous',
                    _selectedFilter == 'all',
                    () => _updateFilter('all'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterChip(
                    'Dépôts',
                    _selectedFilter == 'deposit',
                    () => _updateFilter('deposit'),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterChip(
                    'Retraits',
                    _selectedFilter == 'withdrawal',
                    () => _updateFilter('withdrawal'),
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Liste des demandes
          Expanded(
            child: _isLoading
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
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
                                  onPressed: _loadHistory,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
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
                    : _requests.isEmpty
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
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Aucune demande',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Vos demandes Moov Money\napparaîtront ici',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHistory,
                            color: Theme.of(context).primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                return _buildRequestCard(request);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, [Color? color]) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color ?? Theme.of(context).primaryColor,
                    (color ?? Theme.of(context).primaryColor).withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? Theme.of(context).primaryColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadHistory();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par statut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusFilterOption('Tous', 'all'),
            _buildStatusFilterOption('En attente', 'pending'),
            _buildStatusFilterOption('Terminé', 'completed'),
            _buildStatusFilterOption('Annulé', 'cancelled'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedStatus,
      onChanged: (newValue) {
        setState(() {
          _selectedStatus = newValue!;
        });
        Navigator.pop(context);
        _loadHistory();
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final type = (request['request_type'] ?? request['type'] ?? request['moov_money_type'] ?? 'deposit').toString();
    final status = (request['status'] ?? request['moov_money_status'] ?? 'pending').toString();
    final amount = request['amount'] ?? request['moov_money_amount'] ?? 0;
    final createdAt = request['created_at'] ?? request['requested_at'] ?? DateTime.now().toIso8601String();
    final requestNumber = (request['request_number'] ?? 'N/A').toString();
    final driverName = (request['driver_name'] ?? request['agent_name'] ?? '').toString();
    final isActive = status.toLowerCase() != 'completed' && 
                     status.toLowerCase() != 'cancelled' && 
                     status.toLowerCase() != 'failed';
    
    // Vérifier si la demande est en timeout (plus de 4 minutes en attente)
    final isTimeout = _checkTimeout(createdAt, status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final status = (request['moov_money_status'] ?? request['status'] ?? '').toString().toLowerCase();
          final isCompleted = status == 'completed' || request['is_completed'] == 1;
          final isCancelled = status == 'cancelled' || request['is_cancelled'] == 1;
          final isFailed = status == 'failed' || status == 'timeout';
          
          print('🟢 ========== CLIC DEPUIS HISTORIQUE MOOVMONEY ==========');
          print('   📋 ID: ${request['id']}');
          print('   🔢 Request Number: ${request['request_number']}');
          print('   📊 Status: $status');
          print('   ✅ Is Completed: $isCompleted');
          print('   ❌ Is Cancelled: $isCancelled');
          print('   ⚠️ Is Failed: $isFailed');
          
          Widget targetPage;
          String pageName;
          
          if (isCompleted) {
            targetPage = MoovMoneyTransactionCompletedPage(requestId: (request['id'] ?? '').toString());
            pageName = 'MoovMoneyTransactionCompletedPage';
          } else if (isCancelled) {
            targetPage = MoovMoneyTransactionCancelledPage(requestId: (request['id'] ?? '').toString());
            pageName = 'MoovMoneyTransactionCancelledPage';
          } else if (isFailed) {
            targetPage = MoovMoneyTransactionFailedPage(requestId: (request['id'] ?? '').toString());
            pageName = 'MoovMoneyTransactionFailedPage';
          } else {
            targetPage = MoovMoneyRequestDetailsPage(requestId: (request['id'] ?? '').toString());
            pageName = 'MoovMoneyRequestDetailsPage';
          }
          
          print('   → Navigation vers $pageName');
          print('=========================================================');
          
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getTypeColor(type).withOpacity(0.15),
                          _getTypeColor(type).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(type),
                      color: _getTypeColor(type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTypeLabel(type),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            requestNumber,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(status).withOpacity(0.15),
                              _getStatusColor(status).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: 16,
                              color: _getStatusColor(status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusLabel(status),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        if (_isRequestExpired(request))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Délai dépassé (>4min)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'En cours',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              if (status.toLowerCase() == 'pending') ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${(_getRemainingTime(request) / 60).floor()}:${(_getRemainingTime(request) % 60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.1),
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Montant',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${amount.toString()} FCFA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(type),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Bouton d'annulation pour les demandes en attente ou en recherche
              if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'searching') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(request),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Annuler la demande'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              if (driverName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Agent: $driverName',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    try {
      if (dateStr == null) return 'Date inconnue';
      
      DateTime date;
      
      // Gérer à la fois String et int (timestamp)
      if (dateStr is int) {
        date = DateTime.fromMillisecondsSinceEpoch(dateStr);
      } else if (dateStr is String) {
        if (dateStr.isEmpty) return 'Date inconnue';
        date = DateTime.parse(dateStr);
      } else {
        return 'Date invalide';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} jours';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      print('❌ Erreur format date: $e - dateStr: $dateStr (${dateStr.runtimeType})');
      return 'Date invalide';
    }
  }
  
  bool _checkTimeout(dynamic createdAt, String status) {
    try {
      if (status.toLowerCase() != 'pending' && status.toLowerCase() != 'searching') {
        return false;
      }
      
      if (createdAt == null) return false;
      
      DateTime date;
      
      // Gérer à la fois String et int (timestamp)
      if (createdAt is int) {
        date = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is String) {
        if (createdAt.isEmpty) return false;
        date = DateTime.parse(createdAt);
      } else {
        return false;
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      // Timeout après 4 minutes
      return difference.inMinutes >= 4;
    } catch (e) {
      print('❌ Erreur _checkTimeout: $e - createdAt: $createdAt (${createdAt.runtimeType})');
      return false;
    }
  }

  /// Vérifie si une demande en attente a dépassé le timeout de 4 minutes
  bool _isRequestExpired(Map<String, dynamic> request) {
    final status = request['status']?.toString().toLowerCase() ?? '';
    if (status != 'pending') return false;

    final createdAt = request['created_at'] ?? request['requested_at'];
    if (createdAt == null) return false;
    
    // Gérer à la fois String et int (timestamp)
    if (createdAt is String && createdAt.isEmpty) return false;

    try {
      DateTime date;
      
      // Gérer à la fois String et int (timestamp)
      if (createdAt is int) {
        date = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is String) {
        date = DateTime.parse(createdAt);
      } else {
        return false;
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      // Timeout de 4 minutes
      return difference.inMinutes >= 4;
    } catch (e) {
      print('❌ Erreur vérification expiration: $e');
      return false;
    }
  }

  /// Retourne le temps restant avant expiration (en secondes)
  int _getRemainingTime(Map<String, dynamic> request) {
    final createdAt = request['created_at'] ?? request['requested_at'];
    if (createdAt == null) return 0;

    try {
      DateTime date;
      
      // Gérer à la fois String et int (timestamp)
      if (createdAt is int) {
        date = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt is String) {
        if (createdAt.isEmpty) return 0;
        date = DateTime.parse(createdAt);
      } else {
        return 0;
      }
      
      final now = DateTime.now();
      final elapsed = now.difference(date).inSeconds;
      final remaining = (4 * 60) - elapsed; // 4 minutes en secondes
      
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      print('❌ Erreur _getRemainingTime: $e - createdAt: $createdAt (${createdAt.runtimeType})');
      return 0;
    }
  }

  /// Affiche le dialogue de confirmation d'annulation
  Future<void> _showCancelDialog(Map<String, dynamic> request) async {
    final requestNumber = request['request_number'] ?? 'N/A';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande'),
        content: Text(
          'Voulez-vous vraiment annuler la demande $requestNumber ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cancelRequest(request);
    }
  }

  /// Annule une demande via l'API
  Future<void> _cancelRequest(Map<String, dynamic> request) async {
    final requestId = request['id']?.toString();
    if (requestId == null || requestId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ ID de demande invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('🚫 Annulation de la demande: $requestId');
      
      final token = await AppSharedPreference.getToken();
      print('🔐 Token: ${token.substring(0, min(20, token.length))}...');
      
      // Essayer d'abord l'endpoint principal
      String endpoint = 'https://chapchap-livraison.com/api/v1/moov-money/requests/$requestId/cancel';
      print('🌐 Endpoint: $endpoint');
      
      final dio = Dio();
      Response? response;
      try {
        response = await dio.post(
          endpoint,
          options: Options(
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
          data: {'reason': 'Annulé par l\'utilisateur depuis l\'historique'},
        );
        print('📡 Réponse endpoint 1 - Status: ${response?.statusCode}');
      } catch (e) {
        print('⚠️ Endpoint 1 échoué: $e');
        
        // Essayer l'endpoint alternatif
        endpoint = 'https://chapchap-livraison.com/api/v1/request/$requestId/cancel';
        print('🔄 Essai endpoint alternatif: $endpoint');
        
        response = await dio.post(
          endpoint,
          options: Options(
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
          data: {'reason': 'Annulé par l\'utilisateur depuis l\'historique'},
        );
        print('📡 Réponse endpoint 2 - Status: ${response?.statusCode}');
      }

      print('📦 Réponse data: ${response?.data}');

      if (response?.statusCode == 200) {
        print('✅ Annulation réussie - Mise à jour de l\'UI');
        
        // Invalider le cache des statistiques pour forcer le recalcul
        await MoovMoneyStatsStorage.invalidateCache();
        print('🗑️ Cache des statistiques invalidé');
        
        // Marquer comme annulée localement pour ignorer les futures mises à jour Firebase
        _locallyCancelledRequests.add(requestId);
        print('🔒 Demande $requestId verrouillée comme annulée');
        
        // Arrêter d'écouter Firebase pour cette demande
        final subscription = _realtimeSubscriptions[requestId];
        if (subscription != null) {
          print('🔇 Arrêt du listener Firebase pour $requestId');
          subscription.cancel();
          _realtimeSubscriptions.remove(requestId);
        }
        
        // Mettre à jour immédiatement le statut local
        setState(() {
          final index = _requests.indexWhere((r) => r['id'] == requestId);
          if (index != -1) {
            _requests[index]['status'] = 'cancelled';
            _requests[index]['moov_money_status'] = 'cancelled';
            _requests[index]['cancelled_at'] = DateTime.now().toIso8601String();
            print('✅ Statut mis à jour localement pour index $index');
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demande annulée avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Recharger l'historique après un court délai pour laisser le backend se mettre à jour
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _loadHistory();
          }
        });
      } else {
        final errorMessage = response?.data is Map 
            ? (response?.data['message'] ?? 'Erreur lors de l\'annulation')
            : 'Erreur lors de l\'annulation';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Erreur annulation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
