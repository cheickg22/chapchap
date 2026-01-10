import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/local_data.dart';

class MoovMoneyPaymentConfirmationPage extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const MoovMoneyPaymentConfirmationPage({
    Key? key,
    required this.requestId,
    required this.requestData,
  }) : super(key: key);

  @override
  State<MoovMoneyPaymentConfirmationPage> createState() =>
      _MoovMoneyPaymentConfirmationPageState();
}

class _MoovMoneyPaymentConfirmationPageState
    extends State<MoovMoneyPaymentConfirmationPage> {
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final type = (widget.requestData['moov_money_type'] ?? 
                  widget.requestData['type'] ?? 
                  'deposit').toString();
    final amount = widget.requestData['moov_money_amount'] ?? 
                   widget.requestData['amount'] ?? 0;
    final phone = (widget.requestData['moov_money_phone'] ?? '').toString();
    final requestNumber = (widget.requestData['request_number'] ?? 'N/A').toString();
    final agentName = (widget.requestData['driver_name'] ?? 
                       widget.requestData['agent_name'] ?? 
                       'Agent').toString();

    return Scaffold(
      backgroundColor: AppColors.moovColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmation de paiement',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon de succès
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Titre
                  Text(
                    type == 'deposit' ? 'Dépôt en attente' : 'Retrait en attente',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Message
                  Text(
                    type == 'deposit'
                        ? 'Veuillez remettre l\'argent à l\'agent et confirmer le paiement'
                        : 'Veuillez récupérer l\'argent de l\'agent et confirmer la réception',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Carte d'informations
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Montant
                        _buildInfoRow(
                          icon: Icons.payments,
                          label: 'Montant',
                          value: '$amount FCFA',
                          valueColor: type == 'deposit' ? Colors.green : Colors.red,
                          isBold: true,
                          fontSize: 24,
                        ),
                        
                        const Divider(height: 30),
                        
                        // Numéro de téléphone
                        _buildInfoRow(
                          icon: Icons.phone,
                          label: 'Numéro MoovMoney',
                          value: phone,
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Agent
                        _buildInfoRow(
                          icon: Icons.person,
                          label: 'Agent',
                          value: agentName,
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Numéro de demande
                        _buildInfoRow(
                          icon: Icons.receipt_long,
                          label: 'N° de demande',
                          value: requestNumber,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (type == 'deposit') ...[
                          _buildInstruction('1. Remettez $amount FCFA à l\'agent'),
                          _buildInstruction('2. Vérifiez que l\'agent confirme la réception'),
                          _buildInstruction('3. Cliquez sur "Confirmer le paiement"'),
                        ] else ...[
                          _buildInstruction('1. Récupérez $amount FCFA de l\'agent'),
                          _buildInstruction('2. Comptez et vérifiez le montant'),
                          _buildInstruction('3. Cliquez sur "Confirmer la réception"'),
                        ],
                      ],
                    ),
                  ),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
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
          
          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isConfirming
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                type == 'deposit'
                                    ? 'Confirmer le paiement'
                                    : 'Confirmer la réception',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Bouton annuler
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isConfirming ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.moovColor, size: 24),
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
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment() async {
    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    try {
      print('💰 Confirmation du paiement pour: ${widget.requestId}');
      
      final dio = Dio();
      final token = await AppSharedPreference.getToken();
      
      if (token.isEmpty) {
        throw Exception('Token non disponible');
      }

      final url = 'https://chapchap-livraison.com/api/v1/moov-money/requests/${widget.requestId}/confirm-payment';
      
      print('🌐 URL: $url');
      
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('📡 Réponse confirmation - Status: ${response.statusCode}');
      print('📦 Data: ${response.data}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        // Afficher message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Paiement confirmé avec succès!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Attendre un peu pour que l'utilisateur voie le message
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        
        // Retourner à la page précédente avec succès
        Navigator.pop(context, true);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur confirmation paiement: $e');
      
      setState(() {
        _errorMessage = 'Erreur lors de la confirmation: ${e.toString()}';
        _isConfirming = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('❌ Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
