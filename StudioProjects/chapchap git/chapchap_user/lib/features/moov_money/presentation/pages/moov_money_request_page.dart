import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../common/app_colors.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../../common/local_data.dart';
import '../../../home/domain/models/user_details_model.dart';
import 'moov_money_map_page.dart';

class MoovMoneyRequestPage extends StatefulWidget {
  static const String routeName = '/moovMoneyRequest';
  final String type; // 'deposit' ou 'withdrawal'
  final UserDetail userData;

  const MoovMoneyRequestPage({
    Key? key,
    required this.type,
    required this.userData,
  }) : super(key: key);

  @override
  State<MoovMoneyRequestPage> createState() => _MoovMoneyRequestPageState();
}

class _MoovMoneyRequestPageState extends State<MoovMoneyRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isCalculating = false;
  double? _commission;
  double? _totalAmount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pré-remplir le numéro de téléphone de l'utilisateur si disponible
    _phoneController.text = widget.userData.mobile ?? '';
  }

  Future<void> _calculateCommission(String amountText) async {
    if (amountText.isEmpty) {
      setState(() {
        _commission = null;
        _totalAmount = null;
        _errorMessage = null;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _commission = null;
        _totalAmount = null;
        _errorMessage = null;
      });
      return;
    }

    if (amount < 1000) {
      setState(() {
        _commission = null;
        _totalAmount = null;
        _errorMessage = 'Montant minimum: 1000 FCFA';
      });
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final token = await AppSharedPreference.getToken();
      final response = await DioProviderImpl().get(
        'api/v1/moov-money/calculate-commission?amount=$amount&type=${widget.type}',
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          _commission = (data['commission'] as num).toDouble();
          _totalAmount = (data['total'] as num).toDouble();
          _isCalculating = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur de calcul';
          _isCalculating = false;
        });
      }
    } catch (e) {
      print('❌ Erreur calcul commission: $e');
      setState(() {
        // Calcul local en cas d'erreur (2% de commission par exemple)
        _commission = amount * 0.02;
        _totalAmount = amount + _commission!;
        _isCalculating = false;
      });
    }
  }

  void _continueToMap() {
    if (!_formKey.currentState!.validate()) return;

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoovMoneyMapPage(
          type: widget.type,
          amount: _amountController.text,
          phone: _phoneController.text,
          userData: widget.userData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = widget.type == 'withdrawal';
    final primaryColor = isWithdrawal ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isWithdrawal ? 'Retrait Moov Money' : 'Dépôt Moov Money',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWithdrawal ? Icons.account_balance_wallet : Icons.add_card,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isWithdrawal ? 'Retrait Moov Money' : 'Dépôt Moov Money',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isWithdrawal
                                ? 'Un agent viendra vous apporter l\'argent'
                                : 'Un agent viendra récupérer votre argent',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Champ montant
              Text(
                'Montant (FCFA)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Entrez le montant',
                  prefixIcon: const Icon(Icons.money),
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  if (amount < 1000) {
                    return 'Montant minimum: 1000 FCFA';
                  }
                  return null;
                },
                onChanged: _calculateCommission,
              ),

              // Message d'erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Affichage de la commission
              if (_commission != null && _totalAmount != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Montant demandé:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_amountController.text} FCFA',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Commission:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_commission!.toStringAsFixed(0)} FCFA',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_totalAmount!.toStringAsFixed(0)} FCFA',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Indicateur de calcul
              if (_isCalculating) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Calcul de la commission...'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Champ téléphone
              Text(
                'Numéro de téléphone Moov Money',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Ex: 62335272',
                  prefixIcon: const Icon(Icons.phone),
                  prefixText: '+223 ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro';
                  }
                  if (value.length < 8) {
                    return 'Numéro invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Bouton continuer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continueToMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Informations de sécurité
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.amber[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un code de sécurité vous sera fourni pour valider la transaction avec l\'agent.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber[900],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
