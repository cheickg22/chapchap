import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/local_data.dart';
import '../../data/models/moov_balance_model.dart';
import '../../data/services/moov_balance_service.dart';

/// Page de test pour déboguer la connexion à l'API Moov Money
class MoovTestPage extends StatefulWidget {
  const MoovTestPage({Key? key}) : super(key: key);

  @override
  State<MoovTestPage> createState() => _MoovTestPageState();
}

class _MoovTestPageState extends State<MoovTestPage> {
  final MoovBalanceService _service = MoovBalanceService();
  final Dio _dio = DioProviderImpl.dioClient;
  
  String _status = 'Prêt pour le test';
  String _apiResponse = '';
  bool _isLoading = false;
  MoovBalanceModel? _balance;
  
  // Test direct de l'API
  Future<void> _testDirectApi() async {
    setState(() {
      _isLoading = true;
      _status = 'Test de l\'API en cours...';
      _apiResponse = '';
    });
    
    try {
      // Test 1: Vérifier l'URL de base
      String baseUrl = AppConstants.baseUrl;
      _updateStatus('URL de base: $baseUrl');
      
      // Nettoyer l'URL pour éviter les doubles barres obliques
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      // Test 2: Récupérer le token
      final token = await AppSharedPreference.getToken();
      if (token.isEmpty) {
        _updateStatus('⚠️ Pas de token d\'authentification');
        _updateStatus('Connectez-vous d\'abord à l\'application');
      } else {
        _updateStatus('✅ Token trouvé: ${token.substring(0, 20)}...');
      }
      
      // Test 3: Appel direct à l'API
      _updateStatus('Appel API: GET $baseUrl/api/v1/moov-money/balance');
      
      final response = await _dio.get(
        '$baseUrl/api/v1/moov-money/balance',
        options: Options(
          headers: token.isNotEmpty ? {
            'Authorization': token,
            'Accept': 'application/json',
          } : null,
          validateStatus: (status) => true, // Accepter tous les codes de statut
        ),
      );
      
      _updateStatus('Code de réponse: ${response.statusCode}');
      _updateStatus('Headers reçus: ${response.headers}');
      
      // Afficher la réponse complète
      if (response.data != null) {
        _apiResponse = response.data.toString();
        _updateStatus('Données reçues: voir ci-dessous');
        
        // Essayer de parser si c'est du JSON valide
        if (response.data is Map) {
          try {
            if (response.data['success'] == true && response.data['data'] != null) {
              _balance = MoovBalanceModel.fromJson(response.data['data']);
              _updateStatus('✅ Balance parsée avec succès!');
            } else {
              _updateStatus('⚠️ Réponse API invalide ou erreur');
            }
          } catch (e) {
            _updateStatus('❌ Erreur de parsing: $e');
          }
        }
      }
      
    } catch (e, stackTrace) {
      _updateStatus('❌ Erreur: $e');
      _apiResponse = 'Stack trace:\n$stackTrace';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Test via le service
  Future<void> _testViaService() async {
    setState(() {
      _isLoading = true;
      _status = 'Test via MoovBalanceService...';
      _apiResponse = '';
      _balance = null;
    });
    
    try {
      final balance = await _service.getBalance();
      
      if (balance != null) {
        setState(() {
          _balance = balance;
          _status = '✅ Balance récupérée avec succès!';
          _apiResponse = '''
Solde: ${balance.formattedBalance}
Numéro: ${balance.phoneNumber}
Dernière MAJ: ${balance.lastUpdated}
Transactions récentes: ${balance.recentTransactions.length}
          ''';
        });
      } else {
        setState(() {
          _status = '⚠️ Aucune donnée reçue';
          _apiResponse = 'Le service a retourné null';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur du service';
        _apiResponse = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Test de calcul des frais
  Future<void> _testFeeCalculation() async {
    setState(() {
      _isLoading = true;
      _status = 'Test du calcul des frais...';
      _apiResponse = '';
    });
    
    try {
      String baseUrl = AppConstants.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      
      final token = await AppSharedPreference.getToken();
      _updateStatus('Token: ${token.isNotEmpty ? "Disponible" : "Non disponible"}');
      
      final response = await _dio.post(
        '$baseUrl/api/v1/moov-money/fees/calculate',
        data: {
          'amount': 10000,
          'type': 'withdrawal',
        },
        options: Options(
          headers: token.isNotEmpty ? {
            'Authorization': token,
            'Accept': 'application/json',
          } : null,
          validateStatus: (status) => true,
        ),
      );
      
      setState(() {
        _status = 'Code de réponse: ${response.statusCode}';
        _apiResponse = response.data.toString();
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Erreur';
        _apiResponse = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _updateStatus(String message) {
    setState(() {
      _status = '$_status\n$message';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Moov Money'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Boutons de test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Tests disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testDirectApi,
                      icon: const Icon(Icons.api),
                      label: const Text('Test API Direct'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testViaService,
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Test via Service'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testFeeCalculation,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Test Calcul Frais'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statut
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Statut:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        _status,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Balance si disponible
            if (_balance != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance récupérée:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _balance!.formattedBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Numéro: ${_balance!.phoneNumber}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Réponse API
            if (_apiResponse.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réponse API:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _apiResponse,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
