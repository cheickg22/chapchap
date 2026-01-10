import 'dart:convert';

class MoovMoneyStats {
  final int total;
  final int completed;
  final int active;
  final int totalAmount;
  final DateTime lastUpdated;

  MoovMoneyStats({
    required this.total,
    required this.completed,
    required this.active,
    required this.totalAmount,
    required this.lastUpdated,
  });

  // Créer depuis les données calculées
  factory MoovMoneyStats.fromData(Map<String, dynamic> data) {
    return MoovMoneyStats(
      total: data['total'] ?? 0,
      completed: data['completed'] ?? 0,
      active: data['active'] ?? 0,
      totalAmount: data['totalAmount'] ?? 0,
      lastUpdated: DateTime.now(),
    );
  }

  // Convertir en Map pour SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'totalAmount': totalAmount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  // Créer depuis SharedPreferences
  factory MoovMoneyStats.fromMap(Map<String, dynamic> map) {
    return MoovMoneyStats(
      total: map['total'] ?? 0,
      completed: map['completed'] ?? 0,
      active: map['active'] ?? 0,
      totalAmount: map['totalAmount'] ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }

  // Sérialisation pour SharedPreferences
  String toJson() => json.encode(toMap());

  factory MoovMoneyStats.fromJson(String jsonStr) {
    return MoovMoneyStats.fromMap(json.decode(jsonStr));
  }

  // Vérifier si les statistiques sont périmées (plus de 5 minutes)
  bool get isExpired {
    return DateTime.now().difference(lastUpdated).inMinutes > 5;
  }
}
