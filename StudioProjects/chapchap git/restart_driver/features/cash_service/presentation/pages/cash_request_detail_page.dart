import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/functions.dart';
import '../../application/cash_service_bloc.dart';
import '../../domain/models/cash_request_model.dart';

class CashRequestDetailPage extends StatefulWidget {
  static const String routeName = '/cash-request-detail';
  final CashRequestDetailArguments args;

  const CashRequestDetailPage({Key? key, required this.args}) : super(key: key);

  @override
  State<CashRequestDetailPage> createState() => _CashRequestDetailPageState();
}

class _CashRequestDetailPageState extends State<CashRequestDetailPage> {
  late CashRequestModel _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.args.request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la demande'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<CashServiceBloc, CashServiceState>(
        listener: (context, state) {
          if (state is CashServiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Rafraîchir la demande après une opération réussie
            context.read<CashServiceBloc>().add(const LoadMyCashRequests());
          } else if (state is CashServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CashServiceLoaded) {
            debugPrint('📦 CashServiceLoaded reçu - Nombre de demandes: ${state.myRequests.length}');
            
            // Chercher la demande mise à jour
            final updatedRequestIndex = state.myRequests.indexWhere(
              (req) => req.id == _currentRequest.id,
            );
            
            if (updatedRequestIndex == -1) {
              debugPrint('⚠️ Demande ${_currentRequest.id} non trouvée - elle a probablement changé de statut');
              debugPrint('🔙 Navigation arrière car la demande n\'est plus active');
              
              // La demande n'est plus dans la liste active, retourner à l'écran précédent
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demande mise à jour avec succès'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Attendre un peu pour que l'utilisateur voie le message
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
              return;
            }
            
            final updatedRequest = state.myRequests[updatedRequestIndex];
            
            debugPrint('✅ Demande ${updatedRequest.id} trouvée');
            debugPrint('   - Ancien statut: ${_currentRequest.status}');
            debugPrint('   - Nouveau statut: ${updatedRequest.status}');
            
            final oldStatus = _currentRequest.status;
            
            // Mettre à jour la demande
            if (mounted && oldStatus != updatedRequest.status) {
              setState(() {
                _currentRequest = updatedRequest;
              });
              
              debugPrint('🔄 CHANGEMENT DE STATUT: $oldStatus -> ${updatedRequest.status}');
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Statut: ${updatedRequest.statusLabel}'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequestInfoCard(),
              const SizedBox(height: 16),
              _buildClientInfoCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.args.request.type == 'deposit' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: widget.args.request.type == 'deposit' ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.args.request.typeLabel,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Montant', '${Functions.formatCurrency(widget.args.request.amount)} XOF'),
            _buildInfoRow('Commission', '${Functions.formatCurrency(widget.args.request.commission)} XOF'),
            _buildInfoRow('Statut', widget.args.request.statusLabel),
            if (widget.args.request.securityCode != null)
              _buildInfoRow('Code de sécurité', widget.args.request.securityCode!),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations Client',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (widget.args.request.customerName != null)
              _buildInfoRow('Nom', widget.args.request.customerName!),
            if (widget.args.request.phoneNumber != null)
              _buildInfoRow('Téléphone', widget.args.request.phoneNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localisation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Adresse', widget.args.request.pickupAddress),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openNavigation,
                icon: const Icon(Icons.navigation),
                label: const Text('Naviguer vers le client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _currentRequest.status;
    final type = _currentRequest.type;
    
    // Debug: Afficher le statut actuel
    debugPrint('🔍 STATUS ACTUEL: $status');
    debugPrint('🔍 REQUEST ID: ${_currentRequest.id}');
    debugPrint('🔍 REQUEST TYPE: $type');
    debugPrint('🔍 STATUS == "verified": ${status == 'verified'}');
    debugPrint('🔍 TYPE == "deposit": ${type == 'deposit'}');
    
    return Column(
      children: [
        // Étape 0: Accepter la demande (si status = pending)
        if (status == 'pending') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _acceptRequest,
              icon: const Icon(Icons.check_circle),
              label: const Text('Accepter la demande'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        // Étape 1: Marquer comme arrivé (si status = assigned)
        if (status == 'assigned') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markAsArrived,
              icon: const Icon(Icons.location_on),
              label: const Text('Marquer arrivé'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        // Étape 2: Valider le code de sécurité (si status == 'arrived')
        if (status == 'arrived') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showSecurityCodeDialog,
              icon: const Icon(Icons.security),
              label: const Text('Valider le code de sécurité'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
        
        // Étape 3: Effectuer le dépôt/retrait (si status == 'verified')
        if (status == 'verified') ...[
          // Pour les dépôts
          if (_currentRequest.type == 'deposit') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performCashIn,
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Effectuer Cash In (Manuel)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performCashOut,
                icon: const Icon(Icons.money_off),
                label: const Text('Effectuer Cash Out (Manuel)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
        
        // Bouton de finalisation (toujours disponible)
        if (status != 'completed') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _markAsCompleted,
              icon: const Icon(Icons.check_circle),
              label: const Text('Marquer comme terminé'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _openNavigation() async {
    final lat = widget.args.request.pickupLatitude;
    final lng = widget.args.request.pickupLongitude;
    
    if (lat != null && lng != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          _showErrorSnackBar('Impossible d\'ouvrir la navigation');
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de l\'ouverture de la navigation');
      }
    } else {
      _showErrorSnackBar('Coordonnées GPS non disponibles');
    }
  }

  void _acceptRequest() {
    context.read<CashServiceBloc>().add(
      AcceptCashRequest(
        requestId: _currentRequest.id,
        requestType: _currentRequest.type,
      ),
    );
  }

  void _markAsArrived() {
    context.read<CashServiceBloc>().add(
      MarkArrivedAtClient(
        requestId: _currentRequest.id,
        requestType: _currentRequest.type,
      ),
    );
  }

  void _showSecurityCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code de sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Demandez le code de sécurité à 6 chiffres au client :'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Code de sécurité',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
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
              final code = codeController.text.trim();
              if (code.length == 6) {
                Navigator.pop(context);
                context.read<CashServiceBloc>().add(
                  ValidateSecurityCode(
                    requestId: _currentRequest.id,
                    requestType: _currentRequest.type,
                    securityCode: code,
                  ),
                );
              } else {
                _showErrorSnackBar('Le code doit contenir exactement 6 chiffres');
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _performCashIn() {
    context.read<CashServiceBloc>().add(
      PerformCashIn(requestId: _currentRequest.id),
    );
  }

  void _performCashOut() {
    final phoneNumber = _currentRequest.phoneNumber;
    if (phoneNumber != null) {
      context.read<CashServiceBloc>().add(
        PerformCashOut(
          requestId: _currentRequest.id,
          clientPhoneNumber: phoneNumber,
        ),
      );
    } else {
      _showErrorSnackBar('Numéro de téléphone du client manquant');
    }
  }

  void _markAsCompleted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Marquer cette demande comme terminée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CashServiceBloc>().add(
                UpdateRequestStatus(
                  requestId: _currentRequest.id,
                  requestType: _currentRequest.type,
                  status: 'completed',
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
