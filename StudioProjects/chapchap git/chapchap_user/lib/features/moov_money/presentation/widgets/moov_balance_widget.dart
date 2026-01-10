import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/moov_balance_model.dart';
import '../../data/services/moov_balance_service.dart';
import '../../../../common/app_colors.dart';

/// Widget pour afficher le solde Moov Money
class MoovBalanceWidget extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool autoRefresh;

  const MoovBalanceWidget({
    Key? key,
    this.onRefresh,
    this.onTap,
    this.showDetails = true,
    this.autoRefresh = true,
  }) : super(key: key);

  @override
  State<MoovBalanceWidget> createState() => _MoovBalanceWidgetState();
}

class _MoovBalanceWidgetState extends State<MoovBalanceWidget>
    with SingleTickerProviderStateMixin {
  final MoovBalanceService _service = MoovBalanceService();
  MoovBalanceModel? _balance;
  bool _isLoading = true;
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadBalance();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    // Essayer d'abord le cache
    final cachedBalance = _service.getCachedBalance();
    if (cachedBalance != null && mounted) {
      setState(() {
        _balance = cachedBalance;
        _isLoading = false;
      });
      _animationController.forward();
    }

    // Puis charger depuis l'API
    final balance = await _service.getBalance();
    if (mounted) {
      setState(() {
        _balance = balance;
        _isLoading = false;
      });
      if (balance != null) {
        _service.cacheBalance(balance);
        _animationController.forward();
      }
    }
  }

  Future<void> _refreshBalance() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Vibration légère
    HapticFeedback.lightImpact();

    final balance = await _service.refreshBalance();
    if (mounted) {
      setState(() {
        _balance = balance;
        _isRefreshing = false;
      });
      if (balance != null) {
        _service.cacheBalance(balance);
      }
    }

    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.moovColor,
              AppColors.moovColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.moovColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _balance == null
                ? _buildErrorState()
                : _buildBalanceContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Chargement du solde...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.signal_wifi_off,
          color: Colors.white.withOpacity(0.8),
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          'Connexion au service Moov',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vérifiez votre connexion',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loadBalance,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Réessayer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Solde Moov Money',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _balance!.formattedBalance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _isRefreshing ? null : _refreshBalance,
                icon: AnimatedRotation(
                  turns: _isRefreshing ? 1 : 0,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.refresh,
                    color: _isRefreshing ? Colors.white30 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (widget.showDetails) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              'Disponible',
              _balance!.formattedAvailableBalance,
              Icons.account_balance_wallet,
            ),
            if (_balance!.pendingDeposits > 0)
              _buildDetailRow(
                'Dépôts en attente',
                '${_balance!.pendingDeposits.toStringAsFixed(0)} ${_balance!.currency}',
                Icons.arrow_downward,
                color: Colors.greenAccent,
              ),
            if (_balance!.pendingWithdrawals > 0)
              _buildDetailRow(
                'Retraits en attente',
                '${_balance!.pendingWithdrawals.toStringAsFixed(0)} ${_balance!.currency}',
                Icons.arrow_upward,
                color: Colors.orangeAccent,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  size: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _balance!.phoneNumber,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  'Mis à jour ${_getTimeAgo(_balance!.lastUpdated)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours}h';
    } else {
      return 'il y a ${difference.inDays}j';
    }
  }
}
