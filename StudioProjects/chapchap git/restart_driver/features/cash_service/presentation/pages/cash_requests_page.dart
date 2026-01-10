import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/functions.dart';
import '../../../../common/app_arguments.dart';
import '../../application/cash_service_bloc.dart';
import '../../domain/models/cash_request_model.dart';
import '../widgets/cash_request_card.dart';
import '../widgets/cash_request_filter_bar.dart';
import '../widgets/cash_request_stats_card.dart';
import 'cash_request_detail_page.dart';
import '../../../moov_money/presentation/widgets/moov_money_request_card.dart';
import '../../../moov_money/presentation/pages/moov_money_request_details_page.dart';

class CashRequestsPage extends StatefulWidget {
  static const String routeName = '/cash-requests';
  const CashRequestsPage({Key? key}) : super(key: key);

  @override
  State<CashRequestsPage> createState() => _CashRequestsPageState();
}

class _CashRequestsPageState extends State<CashRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Charger les demandes au démarrage
    context.read<CashServiceBloc>().add(const LoadAvailableCashRequests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyText(
          text: 'Service Money',
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Disponibles'),
            Tab(text: 'Mes demandes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CashServiceBloc>().add(const RefreshAvailableCashRequests());
            },
          ),
        ],
      ),
      body: BlocConsumer<CashServiceBloc, CashServiceState>(
        listener: (context, state) {
          if (state is CashServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: state.canRetry
                    ? SnackBarAction(
                        label: 'Réessayer',
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<CashServiceBloc>().add(const ClearCashServiceError());
                        },
                      )
                    : null,
              ),
            );
          } else if (state is CashServiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            
            // Si c'est une acceptation réussie, naviguer vers les détails
            if (state.operationType == 'accepting' && state.data != null) {
              _navigateToAcceptedRequest(state.data!);
            }
          } else if (state is CashServiceRequestCompleted) {
            _showCompletionDialog(state);
          }
        },
        builder: (context, state) {
          if (state is CashServiceInitial || state is CashServiceLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is CashServiceError) {
            return _buildErrorView(state);
          }

          if (state is CashServiceLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableRequestsTab(state),
                _buildMyRequestsTab(state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAvailableRequestsTab(CashServiceLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CashServiceBloc>().add(const RefreshAvailableCashRequests());
      },
      child: Column(
        children: [
          // Statistiques
          CashRequestStatsCard(
            totalRequests: state.totalAvailableRequests,
            totalCommissions: state.totalPotentialCommissions,
            withdrawalCount: state.withdrawalRequests.length,
            depositCount: state.depositRequests.length,
          ),
          
          // Barre de filtres
          CashRequestFilterBar(
            currentFilter: state.filterType,
            currentSort: state.sortCriteria,
            onFilterChanged: (filter) {
              context.read<CashServiceBloc>().add(
                FilterCashRequestsByType(filterType: filter),
              );
            },
            onSortChanged: (sort) {
              context.read<CashServiceBloc>().add(
                SortCashRequests(sortCriteria: sort),
              );
            },
          ),
          
          // Liste des demandes
          Expanded(
            child: state.filteredRequests.isEmpty
                ? _buildEmptyView('Aucune demande disponible')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = state.filteredRequests[index];
                      return _buildRequestCard(request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestsTab(CashServiceLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CashServiceBloc>().add(const LoadMyCashRequests());
      },
      child: state.myRequests.isEmpty
          ? _buildEmptyView('Aucune demande assignée')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.myRequests.length,
              itemBuilder: (context, index) {
                final request = state.myRequests[index];
                return _buildRequestCard(request, showActionButtons: true);
              },
            ),
    );
  }

  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          MyText(
            text: message,
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<CashServiceBloc>().add(const RefreshAvailableCashRequests());
            },
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(CashServiceError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            MyText(
              text: 'Erreur',
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MyText(
              text: state.message,
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (state.canRetry)
              ElevatedButton(
                onPressed: () {
                  context.read<CashServiceBloc>().add(const ClearCashServiceError());
                },
                child: const Text('Réessayer'),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(CashRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashRequestDetailPage(args: CashRequestDetailArguments(request: request)),
      ),
    );
  }

  void _navigateToAcceptedRequest(Map<String, dynamic> requestData) {
    // Créer un modèle de demande à partir des données retournées
    final acceptedRequest = CashRequestModel(
      id: requestData['request']['id'].toString(),
      type: requestData['request']['type'],
      typeLabel: requestData['request']['type'] == 'deposit' ? 'Dépôt' : 'Retrait',
      amount: (requestData['request']['amount'] as num).toDouble(),
      commission: (requestData['request']['commission'] as num).toDouble(),
      totalAmount: (requestData['request']['amount'] as num).toDouble() + (requestData['request']['commission'] as num).toDouble(),
      status: requestData['request']['status'],
      statusLabel: requestData['request']['status'] == 'assigned' ? 'Assignée' : 'En cours',
      pickupAddress: requestData['request']['pickup_address'],
      pickupLatitude: (requestData['request']['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (requestData['request']['pickup_longitude'] as num).toDouble(),
      phoneNumber: requestData['request']['phone_number'],
      customerName: requestData['request']['customer_name'],
      securityCode: requestData['request']['security_code'],
      requestedAt: DateTime.now().toIso8601String(),
      assignedAt: DateTime.now().toIso8601String(),
    );

    // Naviguer vers la page de détail avec navigation et cash in
    Navigator.pushNamed(
      context,
      CashRequestDetailPage.routeName,
      arguments: CashRequestDetailArguments(request: acceptedRequest),
    );
  }

  void _acceptRequest(CashRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accepter la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${request.typeLabel}'),
            Text('Montant: ${Functions.formatCurrency(request.amount)} XOF'),
            Text('Commission: ${Functions.formatCurrency(request.commission)} XOF'),
            if (request.distance != null)
              Text('Distance: ${request.distance!.toStringAsFixed(1)} km'),
            const SizedBox(height: 16),
            const Text(
              'Voulez-vous accepter cette demande ?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CashServiceBloc>().add(
                AcceptCashRequest(
                  requestId: request.id,
                  requestType: request.type,
                ),
              );
            },
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  /// Construit la carte de requête appropriée selon le type (Moov Money ou normale)
  Widget _buildRequestCard(CashRequestModel request, {bool showActionButtons = false}) {
    // Vérifier si c'est une requête Moov Money
    if (request.isMoovMoney) {
      return MoovMoneyRequestCard(
        request: request.toJson(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MoovMoneyRequestDetailsPage(
                request: request.toJson(),
              ),
            ),
          );
        },
      );
    }
    
    // Carte normale pour les requêtes cash classiques
    return CashRequestCard(
      request: request,
      onTap: () => _navigateToDetail(request),
      onAccept: showActionButtons ? null : () => _acceptRequest(request),
      showAcceptButton: !showActionButtons,
      showActionButtons: showActionButtons,
    );
  }

  void _showCompletionDialog(CashServiceRequestCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Demande terminée !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Félicitations ! Vous avez terminé la demande ${state.request.typeLabel.toLowerCase()}.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Commission gagnée',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Functions.formatCurrency(state.earnedCommission)} XOF',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retourner à l'onglet des demandes disponibles
              _tabController.animateTo(0);
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
