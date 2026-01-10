import 'package:equatable/equatable.dart';

/// Modèle pour représenter le solde Moov Money de l'utilisateur
class MoovBalanceModel extends Equatable {
  final double balance;
  final String currency;
  final DateTime lastUpdated;
  final String phoneNumber;
  final bool isActive;
  final double pendingDeposits;
  final double pendingWithdrawals;
  final List<TransactionSummary> recentTransactions;

  const MoovBalanceModel({
    required this.balance,
    this.currency = 'XOF',
    required this.lastUpdated,
    required this.phoneNumber,
    this.isActive = true,
    this.pendingDeposits = 0.0,
    this.pendingWithdrawals = 0.0,
    this.recentTransactions = const [],
  });

  /// Solde disponible (balance - pending withdrawals)
  double get availableBalance => balance - pendingWithdrawals;

  /// Solde total (balance + pending deposits)
  double get totalBalance => balance + pendingDeposits;

  /// Formater le solde pour l'affichage
  String get formattedBalance => '${balance.toStringAsFixed(0)} $currency';
  String get formattedAvailableBalance => '${availableBalance.toStringAsFixed(0)} $currency';

  factory MoovBalanceModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return MoovBalanceModel(
      balance: parseDouble(json['balance']),
      currency: json['currency']?.toString() ?? 'XOF',
      lastUpdated: json['last_updated'] != null 
        ? DateTime.tryParse(json['last_updated'].toString()) ?? DateTime.now()
        : DateTime.now(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      pendingDeposits: parseDouble(json['pending_deposits']),
      pendingWithdrawals: parseDouble(json['pending_withdrawals']),
      recentTransactions: json['recent_transactions'] != null && json['recent_transactions'] is List
        ? (json['recent_transactions'] as List)
            .map((e) => TransactionSummary.fromJson(e as Map<String, dynamic>))
            .toList()
        : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      'last_updated': lastUpdated.toIso8601String(),
      'phone_number': phoneNumber,
      'is_active': isActive,
      'pending_deposits': pendingDeposits,
      'pending_withdrawals': pendingWithdrawals,
      'recent_transactions': recentTransactions.map((e) => e.toJson()).toList(),
    };
  }

  MoovBalanceModel copyWith({
    double? balance,
    String? currency,
    DateTime? lastUpdated,
    String? phoneNumber,
    bool? isActive,
    double? pendingDeposits,
    double? pendingWithdrawals,
    List<TransactionSummary>? recentTransactions,
  }) {
    return MoovBalanceModel(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      pendingDeposits: pendingDeposits ?? this.pendingDeposits,
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  @override
  List<Object?> get props => [
    balance,
    currency,
    lastUpdated,
    phoneNumber,
    isActive,
    pendingDeposits,
    pendingWithdrawals,
    recentTransactions,
  ];
}

/// Résumé d'une transaction récente
class TransactionSummary extends Equatable {
  final String id;
  final String type; // 'deposit', 'withdrawal'
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime date;
  final String? description;

  const TransactionSummary({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.description,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return TransactionSummary(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      amount: parseDouble(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      date: json['date'] != null 
        ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
        : DateTime.now(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, type, amount, status, date, description];
}
