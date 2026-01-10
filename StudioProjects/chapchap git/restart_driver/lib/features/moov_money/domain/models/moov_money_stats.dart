import 'package:equatable/equatable.dart';

/// Modèle pour les statistiques Moov Money
class MoovMoneyStats extends Equatable {
  final int totalTransactions;
  final int totalCompleted;
  final int totalCancelled;
  final int totalDeposits;
  final int totalWithdrawals;
  final int totalCommission;
  final int amountDeposits;
  final int amountWithdrawals;
  final int totalAmount;

  const MoovMoneyStats({
    required this.totalTransactions,
    required this.totalCompleted,
    required this.totalCancelled,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.totalCommission,
    required this.amountDeposits,
    required this.amountWithdrawals,
    required this.totalAmount,
  });

  factory MoovMoneyStats.fromJson(Map<String, dynamic> json) {
    return MoovMoneyStats(
      totalTransactions: _parseInt(json['total_transactions']),
      totalCompleted: _parseInt(json['total_completed']),
      totalCancelled: _parseInt(json['total_cancelled']),
      totalDeposits: _parseInt(json['total_deposits']),
      totalWithdrawals: _parseInt(json['total_withdrawals']),
      totalCommission: _parseInt(json['total_commission']),
      amountDeposits: _parseInt(json['amount_deposits']),
      amountWithdrawals: _parseInt(json['amount_withdrawals']),
      totalAmount: _parseInt(json['total_amount']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory MoovMoneyStats.empty() {
    return const MoovMoneyStats(
      totalTransactions: 0,
      totalCompleted: 0,
      totalCancelled: 0,
      totalDeposits: 0,
      totalWithdrawals: 0,
      totalCommission: 0,
      amountDeposits: 0,
      amountWithdrawals: 0,
      totalAmount: 0,
    );
  }

  @override
  List<Object?> get props => [
        totalTransactions,
        totalCompleted,
        totalCancelled,
        totalDeposits,
        totalWithdrawals,
        totalCommission,
        amountDeposits,
        amountWithdrawals,
        totalAmount,
      ];
}
