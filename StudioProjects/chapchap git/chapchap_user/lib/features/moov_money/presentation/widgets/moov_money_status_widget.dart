import 'package:flutter/material.dart';
import '../../../../common/app_colors.dart';

/// Widget pour afficher le statut d'une transaction MoovMoney
class MoovMoneyStatusWidget extends StatelessWidget {
  final String status;
  final Map<String, dynamic>? additionalData;

  const MoovMoneyStatusWidget({
    Key? key,
    required this.status,
    this.additionalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _PendingStatusWidget(data: additionalData);
      case 'accepted':
      case 'assigned':
        return _AcceptedStatusWidget(data: additionalData);
      case 'arrived':
        return _ArrivedStatusWidget(data: additionalData);
      case 'processing':
      case 'in_progress':
        return _ProcessingStatusWidget(data: additionalData);
      case 'completed':
        return _CompletedStatusWidget(data: additionalData);
      case 'cancelled':
        return _CancelledStatusWidget(data: additionalData);
      case 'failed':
        return _FailedStatusWidget(data: additionalData);
      default:
        return _DefaultStatusWidget(status: status, data: additionalData);
    }
  }
}

/// Widget pour le statut "pending" avec animation radar
class _PendingStatusWidget extends StatefulWidget {
  final Map<String, dynamic>? data;

  const _PendingStatusWidget({this.data});

  @override
  State<_PendingStatusWidget> createState() => _PendingStatusWidgetState();
}

class _PendingStatusWidgetState extends State<_PendingStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _messageIndex = 0;
  int _elapsedSeconds = 0;
  
  // Messages de détente qui alternent
  final List<String> _waitingMessages = [
    'Nous recherchons un agent disponible près de vous',
    'Détendez-vous, un agent va bientôt accepter votre demande',
    'Nos agents sont en route pour vous servir',
    'Merci de votre patience, nous trouvons le meilleur agent',
    'Quelques instants encore, un agent va vous contacter',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Changer le message toutes les 4 secondes
    Future.delayed(Duration.zero, () {
      _startMessageRotation();
      _startTimeCounter();
    });
  }
  
  void _startMessageRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _waitingMessages.length;
        });
        _startMessageRotation();
      }
    });
  }
  
  void _startTimeCounter() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
        _startTimeCounter();
      }
    });
  }
  
  String _formatElapsedTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    if (minutes > 0) {
      return '$minutes min ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.moovColor.withOpacity(0.3), AppColors.moovColor.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.moovColor),
      ),
      child: Column(
        children: [
          // Animation radar
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ondes radar animées
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Onde 1
                        _buildRadarWave(
                          _controller.value,
                          AppColors.moovColor.withOpacity(0.3),
                        ),
                        // Onde 2
                        _buildRadarWave(
                          (_controller.value + 0.33) % 1.0,
                          AppColors.moovColor.withOpacity(0.2),
                        ),
                        // Onde 3
                        _buildRadarWave(
                          (_controller.value + 0.66) % 1.0,
                          AppColors.moovColor.withOpacity(0.1),
                        ),
                      ],
                    );
                  },
                ),
                // Icône centrale
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recherche d\'un agent...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Message qui change toutes les 4 secondes
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _waitingMessages[_messageIndex],
              key: ValueKey<int>(_messageIndex),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          // Temps écoulé
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'Temps écoulé: ${_formatElapsedTime()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarWave(double progress, Color color) {
    final size = 120.0 * progress;
    final opacity = 1.0 - progress;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }
}

/// Widget pour le statut "accepted"
class _AcceptedStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _AcceptedStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    final agentName = data?['driver_name'] ?? data?['agent_name'] ?? 'Agent';
    final agentPhone = data?['driver_phone'] ?? data?['agent_phone'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.moovColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.moovColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_pin_circle,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Agent trouvé, en route...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.moovColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$agentName se dirige vers vous',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.moovColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (agentPhone != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, color: AppColors.moovColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    agentPhone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, color: AppColors.moovColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'En route',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget pour le statut "arrived"
class _ArrivedStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _ArrivedStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    final securityCode = data?['moov_money_security_code']?.toString() ?? 
                        data?['security_code']?.toString() ?? 
                        data?['ride_otp']?.toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Agent arrivé !',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Montrez votre code de sécurité à l\'agent',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (securityCode != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Code de sécurité',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    securityCode,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour le statut "processing"
class _ProcessingStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _ProcessingStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade100, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sync,
              size: 48,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction en cours...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'L\'agent traite votre demande',
            style: TextStyle(
              fontSize: 14,
              color: Colors.indigo.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
        ],
      ),
    );
  }
}

/// Widget pour le statut "completed"
class _CompletedStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _CompletedStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    // Récupérer le montant avec gestion de différents types
    dynamic amountValue = data?['amount'] ?? data?['moov_money_amount'] ?? 0;
    
    // Convertir en double
    double amountDouble = 0;
    if (amountValue is int) {
      amountDouble = amountValue.toDouble();
    } else if (amountValue is double) {
      amountDouble = amountValue;
    } else if (amountValue is String) {
      amountDouble = double.tryParse(amountValue) ?? 0;
    }
    
    // Formater le montant avec séparateur de milliers
    String formattedAmount = amountDouble.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    
    final transactionId = data?['transaction_id']?.toString() ?? 
                          data?['id']?.toString() ?? 
                          data?['request_number']?.toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '✅ Transaction réussie !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Votre transaction a été effectuée avec succès',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (amountDouble > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Montant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedAmount FCFA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (transactionId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID: $transactionId',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour le statut "cancelled"
class _CancelledStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _CancelledStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade200, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction annulée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cette demande a été annulée',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget pour le statut "failed"
class _FailedStatusWidget extends StatelessWidget {
  final Map<String, dynamic>? data;

  const _FailedStatusWidget({this.data});

  @override
  Widget build(BuildContext context) {
    final errorMessage = data?['error_message']?.toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade100, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction échouée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Une erreur s\'est produite',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget par défaut pour les statuts inconnus
class _DefaultStatusWidget extends StatelessWidget {
  final String status;
  final Map<String, dynamic>? data;

  const _DefaultStatusWidget({required this.status, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            status,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
