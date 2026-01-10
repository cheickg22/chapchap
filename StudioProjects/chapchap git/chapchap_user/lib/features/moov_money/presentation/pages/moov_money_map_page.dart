import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/app_arguments.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/local_data.dart';
import '../../../../core/network/dio_provider_impl.dart';
import '../../../bookingpage/presentation/page/booking/page/booking_page.dart';
import '../../../home/domain/models/stop_address_model.dart';
import '../../../home/domain/models/user_details_model.dart';
import 'moov_money_request_details_page.dart';

class MoovMoneyMapPage extends StatefulWidget {
  final String type; // 'deposit' ou 'withdrawal'
  final String amount;
  final String phone;
  final UserDetail userData;

  const MoovMoneyMapPage({
    Key? key,
    required this.type,
    required this.amount,
    required this.phone,
    required this.userData,
  }) : super(key: key);

  @override
  State<MoovMoneyMapPage> createState() => _MoovMoneyMapPageState();
}

class _MoovMoneyMapPageState extends State<MoovMoneyMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _currentAddress = 'Chargement...';
  bool _isLoading = false;
  bool _isCreatingRequest = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Permission de localisation refusée');
        return;
      }

      // Obtenir la position actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Obtenir l'adresse
      await _getAddressFromLatLng(_currentPosition!);

      // Déplacer la caméra
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }
    } catch (e) {
      _showError('Erreur lors de la récupération de la position: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Adresse non disponible';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
    });
  }

  void _onCameraIdle() {
    if (_currentPosition != null) {
      _getAddressFromLatLng(_currentPosition!);
    }
  }

  Future<void> _confirmPosition() async {
    if (_currentPosition == null) {
      _showError('Veuillez sélectionner une position');
      return;
    }

    print('📍 Position actuelle: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    print('📍 Adresse: $_currentAddress');
    print('💰 Montant: ${widget.amount}');
    print('📱 Téléphone: ${widget.phone}');
    print('🔄 Type: ${widget.type}');

    setState(() {
      _isCreatingRequest = true;
    });

    try {
      if (widget.type == 'deposit') {
        print('💳 Création d\'une demande de dépôt...');
        await _createDepositRequest();
      } else {
        print('💵 Création d\'une demande de retrait...');
        await _createWithdrawalRequest();
      }
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la création de la demande: $e');
      print('📚 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isCreatingRequest = false;
        });
        _showError('Erreur: $e');
      }
    }
  }

  Future<void> _createDepositRequest() async {
    try {
      print('🔐 Récupération du token...');
      // Récupérer le token depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        print('❌ Token vide!');
        throw Exception('Non authentifié. Veuillez vous reconnecter.');
      }
      print('✅ Token récupéré: ${token.substring(0, 20)}...');

      // Récupérer les IDs nécessaires (optionnels)
      final serviceLocationId = prefs.getString('service_location_id');
      final zoneTypeId = prefs.getString('zone_type_id');
      print('🎯 Service Location ID: $serviceLocationId');
      print('🎯 Zone Type ID: $zoneTypeId');

      // Préparer le body
      final Map<String, dynamic> body = {
        'pick_lat': _currentPosition!.latitude.toString(),
        'pick_lng': _currentPosition!.longitude.toString(),
        'pick_address': _currentAddress,
        'amount': widget.amount,
        'phone_number': widget.phone,
      };
      
      // Ajouter les IDs seulement s'ils existent
      if (serviceLocationId != null && serviceLocationId.isNotEmpty) {
        body['service_location_id'] = serviceLocationId;
      }
      if (zoneTypeId != null && zoneTypeId.isNotEmpty) {
        body['zone_type_id'] = zoneTypeId;
      }

      print('📦 Body de la requête: $body');
      print('🌐 Envoi de la requête à l\'API...');

      // Utiliser Dio pour faire la requête
      final dioProvider = DioProviderImpl();
      final response = await dioProvider.post(
        'https://chapchap-livraison.com/api/v1/moov-money/deposit/create',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );
      
      print('📡 Réponse reçue - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('✅ Demande de dépôt créée avec succès');
        print('📦 Data reçue: $data');
        
        if (mounted) {
          final requestData = data['data'];
          final requestId = requestData['id']?.toString() ?? '';
          final securityCode = requestData['moov_money_security_code']?.toString() ?? '';
          
          print('🆔 Request ID: $requestId');
          print('🔐 Code de sécurité: $securityCode');
          print('💰 DEBUG - Tous les champs de requestData:');
          print('   - Keys disponibles: ${requestData.keys.toList()}');
          print('   - amount: ${requestData['amount']}');
          print('   - moov_money_amount: ${requestData['moov_money_amount']}');
          print('   - total_amount: ${requestData['total_amount']}');
          print('   - moov_money_total_amount: ${requestData['moov_money_total_amount']}');
          
          // Réinitialiser l'état avant la navigation
          setState(() {
            _isCreatingRequest = false;
          });
          
          // Afficher un dialog avec le code de sécurité
          if (securityCode.isNotEmpty) {
            await _showSecurityCodeDialog(securityCode, requestId);
          } else {
            print('⚠️ Code de sécurité non reçu');
          }
          
          // Ajouter le type et le montant explicitement dans requestData
          requestData['type'] = 'deposit';
          requestData['moov_money_type'] = 'deposit';
          // S'assurer que le montant est présent (utiliser celui du formulaire si absent)
          if (requestData['amount'] == null || requestData['amount'] == 0) {
            requestData['amount'] = double.tryParse(widget.amount) ?? 0;
          }
          if (requestData['moov_money_amount'] == null || requestData['moov_money_amount'] == 0) {
            requestData['moov_money_amount'] = double.tryParse(widget.amount) ?? 0;
          }
          print('💰 Montant ajouté à requestData: ${requestData['amount']}');
          
          // Naviguer vers la page de détails avec les données
          print('🚀 Navigation vers la page de détails (DEPOT)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MoovMoneyRequestDetailsPage(
                requestId: requestId,
                requestData: requestData, // Passer les données directement
              ),
            ),
          ).then((_) {
            print('✅ Navigation vers détails terminée');
          }).catchError((error) {
            print('❌ Erreur lors de la navigation: $error');
          });
        }
      } else {
        final errorMessage = response.data is Map 
            ? (response.data['message'] ?? response.data['error'] ?? 'Erreur lors de la création de la demande')
            : 'Erreur lors de la création de la demande';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map 
            ? (errorData['message'] ?? errorData['error'] ?? e.message)
            : e.message;
        throw Exception(errorMessage ?? 'Erreur réseau');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> _createWithdrawalRequest() async {
    try {
      // Récupérer le token depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      if (token.isEmpty) {
        throw Exception('Non authentifié. Veuillez vous reconnecter.');
      }

      // Récupérer les IDs nécessaires (optionnels)
      final serviceLocationId = prefs.getString('service_location_id');
      final zoneTypeId = prefs.getString('zone_type_id');

      // Préparer le body
      final Map<String, dynamic> body = {
        'pick_lat': _currentPosition!.latitude.toString(),
        'pick_lng': _currentPosition!.longitude.toString(),
        'pick_address': _currentAddress,
        'amount': widget.amount,
        'phone_number': widget.phone,
      };
      
      // Ajouter les IDs seulement s'ils existent
      if (serviceLocationId != null && serviceLocationId.isNotEmpty) {
        body['service_location_id'] = serviceLocationId;
      }
      if (zoneTypeId != null && zoneTypeId.isNotEmpty) {
        body['zone_type_id'] = zoneTypeId;
      }

      // Utiliser Dio pour faire la requête
      final dioProvider = DioProviderImpl();
      final response = await dioProvider.post(
        'https://chapchap-livraison.com/api/v1/moov-money/withdrawal/create',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        print('✅ Demande de retrait créée avec succès');
        print('📦 Data reçue: $data');
        
        if (mounted) {
          final requestData = data['data'];
          final requestId = requestData['id']?.toString() ?? '';
          final securityCode = requestData['moov_money_security_code']?.toString() ?? '';
          
          print('🆔 Request ID: $requestId');
          print('🔐 Code de sécurité: $securityCode');
          
          // Réinitialiser l'état avant la navigation
          setState(() {
            _isCreatingRequest = false;
          });
          
          // Afficher un dialog avec le code de sécurité
          if (securityCode.isNotEmpty) {
            await _showSecurityCodeDialog(securityCode, requestId);
          } else {
            print('⚠️ Code de sécurité non reçu');
          }
          
          // Ajouter le type et le montant explicitement dans requestData
          requestData['type'] = 'withdrawal';
          requestData['moov_money_type'] = 'withdrawal';
          // S'assurer que le montant est présent (utiliser celui du formulaire si absent)
          if (requestData['amount'] == null || requestData['amount'] == 0) {
            requestData['amount'] = double.tryParse(widget.amount) ?? 0;
          }
          if (requestData['moov_money_amount'] == null || requestData['moov_money_amount'] == 0) {
            requestData['moov_money_amount'] = double.tryParse(widget.amount) ?? 0;
          }
          print('💰 Montant ajouté à requestData: ${requestData['amount']}');
          
          // Naviguer vers la page de détails avec les données
          print('🚀 Navigation vers la page de détails (RETRAIT)');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MoovMoneyRequestDetailsPage(
                requestId: requestId,
                requestData: requestData, // Passer les données directement
              ),
            ),
          ).then((_) {
            print('✅ Navigation vers détails terminée');
          }).catchError((error) {
            print('❌ Erreur lors de la navigation: $error');
          });
        }
      } else {
        final errorMessage = response.data is Map 
            ? (response.data['message'] ?? response.data['error'] ?? 'Erreur lors de la création de la demande')
            : 'Erreur lors de la création de la demande';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map 
            ? (errorData['message'] ?? errorData['error'] ?? e.message)
            : e.message;
        throw Exception(errorMessage ?? 'Erreur réseau');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void _showVoucherDialog(String requestId, String voucherCode, String validationCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text('Demande créée !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Montant
            Text(
              '${widget.amount} FCFA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            // Message simple
            Text(
              'Un agent va vous rejoindre.\nVous recevrez un USSD pour confirmer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              
              // Réinitialiser l'état
              setState(() {
                _isCreatingRequest = false;
              });
              
              // Naviguer vers la page de suivi avec animation radar
              if (_currentPosition != null) {
                print('🚀 Navigation vers /booking depuis voucher dialog avec requestId: $requestId');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BookingPage(
                      arg: BookingPageArguments(
                        picklat: _currentPosition!.latitude.toString(),
                        picklng: _currentPosition!.longitude.toString(),
                        droplat: '',
                        droplng: '',
                        pickupAddressList: [AddressModel(
                          orderId: '0',
                          lat: _currentPosition!.latitude,
                          lng: _currentPosition!.longitude,
                          address: _currentAddress,
                          pickup: true,
                        )],
                        stopAddressList: [],
                        userData: widget.userData,
                        transportType: 'taxi',
                        requestId: requestId,
                        polyString: '',
                        distance: '',
                        duration: '',
                        mapType: 'google_map',
                        isOutstationRide: false,
                      ),
                    ),
                  ),
                ).then((_) {
                  print('✅ Navigation vers /booking terminée depuis voucher dialog');
                }).catchError((error) {
                  print('❌ Erreur lors de la navigation depuis voucher dialog: $error');
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Attendre un driver', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'deposit'
              ? 'Sélectionner votre position - Dépôt'
              : 'Sélectionner votre position - Retrait',
        ),
        backgroundColor: widget.type == 'deposit' ? AppColors.primary : Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // Carte
          _currentPosition == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text('Chargement de la carte...'),
                    ],
                  ),
                )
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),

          // Pin central
          Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: widget.type == 'deposit' ? AppColors.moovColor : Colors.blue,
            ),
          ),

          // Carte d'information en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informations
                  Row(
                    children: [
                      Icon(
                        widget.type == 'deposit'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: widget.type == 'deposit'
                            ? Colors.green
                            : Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.type == 'deposit' ? 'Dépôt' : 'Retrait',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              '${widget.amount} FCFA',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Adresse
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentAddress,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Bouton de confirmation
                  ElevatedButton(
                    onPressed: _isCreatingRequest ? null : _confirmPosition,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.type == 'deposit'
                          ? AppColors.moovColor
                          : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isCreatingRequest
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Confirmer et demander un agent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 25)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSecurityCodeDialog(String securityCode, String requestId) async {
    // Auto-fermer après 5 secondes et naviguer vers les détails
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true); // Retourner true pour indiquer de naviguer
      }
    });
    
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Demande envoyée !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Un agent va vous rejoindre',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );
    
    // Si le dialog retourne true (bouton cliqué ou auto-fermé), ne rien faire
    // La navigation se fera après le dialog
    return;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
