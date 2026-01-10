import 'package:equatable/equatable.dart';

/// Modèle pour les gains d'une période
class PeriodEarnings extends Equatable {
  final int totalTransactions;
  final int totalCommission;
  final int totalAmountProcessed;
  final int deposits;
  final int withdrawals;

  const PeriodEarnings({
    required this.totalTransactions,
    required this.totalCommission,
    required this.totalAmountProcessed,
    required this.deposits,
    required this.withdrawals,
  });

  factory PeriodEarnings.fromJson(Map<String, dynamic> json) {
    return PeriodEarnings(
      totalTransactions: _parseInt(json['total_transactions']),
      totalCommission: _parseInt(json['total_commission']),
      totalAmountProcessed: _parseInt(json['total_amount_processed']),
      deposits: _parseInt(json['deposits']),
      withdrawals: _parseInt(json['withdrawals']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory PeriodEarnings.empty() {
    return const PeriodEarnings(
      totalTransactions: 0,
      totalCommission: 0,
      totalAmountProcessed: 0,
      deposits: 0,
      withdrawals: 0,
    );
  }

  @override
  List<Object?> get props => [
        totalTransactions,
        totalCommission,
        totalAmountProcessed,
        deposits,
        withdrawals,
      ];
}

/// Modèle pour les données du graphique
class ChartData extends Equatable {
  final String date;
  final String day;
  final int earnings;

  const ChartData({
    required this.date,
    required this.day,
    required this.earnings,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      earnings: _parseInt(json['earnings']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [date, day, earnings];
}

/// Modèle pour tous les gains
class MoovMoneyEarnings extends Equatable {
  final PeriodEarnings today;
  final PeriodEarnings week;
  final PeriodEarnings month;
  final PeriodEarnings year;
  final PeriodEarnings allTime;
  final List<ChartData> chartData;

  const MoovMoneyEarnings({
    required this.today,
    required this.week,
    required this.month,
    required this.year,
    required this.allTime,
    required this.chartData,
  });

  factory MoovMoneyEarnings.fromJson(Map<String, dynamic> json) {
    final earnings = json['earnings'] as Map<String, dynamic>? ?? {};
    final chart = json['chart'] as List<dynamic>? ?? [];

    return MoovMoneyEarnings(
      today: PeriodEarnings.fromJson(
        earnings['today'] as Map<String, dynamic>? ?? {},
      ),
      week: PeriodEarnings.fromJson(
        earnings['week'] as Map<String, dynamic>? ?? {},
      ),
      month: PeriodEarnings.fromJson(
        earnings['month'] as Map<String, dynamic>? ?? {},
      ),
      year: PeriodEarnings.fromJson(
        earnings['year'] as Map<String, dynamic>? ?? {},
      ),
      allTime: PeriodEarnings.fromJson(
        earnings['all_time'] as Map<String, dynamic>? ?? {},
      ),
      chartData: chart
          .map((e) => ChartData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MoovMoneyEarnings.empty() {
    return MoovMoneyEarnings(
      today: PeriodEarnings.empty(),
      week: PeriodEarnings.empty(),
      month: PeriodEarnings.empty(),
      year: PeriodEarnings.empty(),
      allTime: PeriodEarnings.empty(),
      chartData: const [],
    );
  }

  @override
  List<Object?> get props => [today, week, month, year, allTime, chartData];
}
