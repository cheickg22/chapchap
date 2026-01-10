import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/functions.dart';
import '../../application/cash_service_bloc.dart';
import '../../domain/models/cash_request_model.dart';

class CashRequestCard extends StatelessWidget {
  final CashRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final bool showAcceptButton;
  final bool showActionButtons;

  const CashRequestCard({
    Key? key,
    required this.request,
    this.onTap,
    this.onAccept,
    this.showAcceptButton = false,
    this.showActionButtons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[100]!.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type et statut
              Row(
                children: [
                  _buildTypeChip(),
                  // Badge Moov Money si applicable
                  if (request.isMoovMoney) ..[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[300]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 12,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          MyText(
                            text: 'Moov',
                            textStyle: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations principales
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Montant
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            MyText(
                              text: '${Functions.formatCurrency(request.amount)} XOF',
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Commission
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            MyText(
                              text: 'Commission: ${Functions.formatCurrency(request.commission)} XOF',
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Distance si disponible
                  if (request.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          MyText(
                            text: '${request.distance!.toStringAsFixed(1)} km',
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Adresse
              Row(
                children: [
                  const Icon(
                    Icons.place,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: MyText(
                      text: request.pickupAddress,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Informations client
              if (request.clientName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    MyText(
                      text: request.clientName!,
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (request.clientPhoneNumber != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      MyText(
                        text: request.clientPhoneNumber!,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              
              // Transaction Moov Money si disponible
              if (request.moovTransaction != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMoovStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getMoovStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: _getMoovStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      MyText(
                        text: 'Moov Money: ${request.moovTransaction!.statusLabel}',
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: _getMoovStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Heure de demande
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  MyText(
                    text: _formatDateTime(request.requestedAt),
                    textStyle: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              
              // Boutons d'action
              if (showAcceptButton || showActionButtons) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    final isWithdrawal = request.isWithdrawal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWithdrawal ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWithdrawal ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: isWithdrawal ? Colors.red[700] : Colors.green[700],
          ),
          const SizedBox(width: 4),
          MyText(
            text: request.typeLabel,
            textStyle: TextStyle(
              fontSize: 12,
              color: isWithdrawal ? Colors.red[700] : Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MyText(
        text: request.statusLabel,
        textStyle: TextStyle(
          fontSize: 11,
          color: _getStatusColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (showAcceptButton) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Accepter'),
        ),
      );
    }

    if (showActionButtons) {
      return Row(
        children: [
          // Bouton Navigation
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<CashServiceBloc>().add(
                  StartNavigationToCashRequest(request: request),
                );
              },
              icon: const Icon(Icons.navigation, size: 16),
              label: const Text('Navigation'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Bouton d'action principal selon le statut
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handlePrimaryAction(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPrimaryActionColor(),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_getPrimaryActionLabel()),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _handlePrimaryAction(BuildContext context) {
    if (request.isAssigned && request.needsMoovTransaction) {
      // Effectuer l'opération Moov Money
      if (request.isWithdrawal) {
        _showPhoneInputDialog(context);
      } else {
        context.read<CashServiceBloc>().add(
          PerformCashIn(requestId: request.id),
        );
      }
    } else if (request.isMoovCompleted && request.canValidateSecurityCode) {
      // Valider le code de sécurité
      _showSecurityCodeDialog(context);
    }
  }

  void _showPhoneInputDialog(BuildContext context) {
    final phoneController = TextEditingController(
      text: request.clientPhoneNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Numéro de téléphone client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Confirmez le numéro de téléphone du client :'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                prefixText: '+223 ',
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
              Navigator.pop(context);
              context.read<CashServiceBloc>().add(
                PerformCashOut(
                  requestId: request.id,
                  clientPhoneNumber: phoneController.text.trim(),
                ),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showSecurityCodeDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Code de sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Demandez le code de sécurité au client :'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Code à 6 chiffres',
                border: OutlineInputBorder(),
                counterText: '',
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
              Navigator.pop(context);
              context.read<CashServiceBloc>().add(
                ValidateSecurityCode(
                  requestId: request.id,
                  requestType: request.type,
                  securityCode: codeController.text.trim(),
                ),
              );
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (request.status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'moov_processing':
        return Colors.purple;
      case 'moov_completed':
        return Colors.green;
      case 'completed':
        return Colors.green[700]!;
      case 'moov_failed':
      case 'moov_timeout':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getMoovStatusColor() {
    if (request.moovTransaction == null) return Colors.grey;
    
    switch (request.moovTransaction!.status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPrimaryActionLabel() {
    if (request.isAssigned && request.needsMoovTransaction) {
      return request.isWithdrawal ? 'Cash Out' : 'Cash In';
    } else if (request.isMoovCompleted && request.canValidateSecurityCode) {
      return 'Valider code';
    }
    return 'Action';
  }

  Color _getPrimaryActionColor() {
    if (request.isAssigned && request.needsMoovTransaction) {
      return request.isWithdrawal ? Colors.red : Colors.green;
    } else if (request.isMoovCompleted && request.canValidateSecurityCode) {
      return Colors.blue;
    }
    return Colors.blue; // Couleur par défaut
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
