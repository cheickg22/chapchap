import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MoovMoneyStatsStorage {
  static const String _statsKey = 'moov_money_stats';

  static Future<void> saveStats(int total, int completed, int active, int totalAmount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final stats = {
      'total': total,
      'completed': completed,
      'active': active,
      'totalAmount': totalAmount,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_statsKey, json.encode(stats));
  }

  static Future<Map<String, dynamic>?> getStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_statsKey);
    if (statsString == null) return null;

    try {
      final Map<String, dynamic> stats = json.decode(statsString);
      // Vérifier si les stats ne sont pas expirées (5 minutes)
      final lastUpdated = DateTime.fromMillisecondsSinceEpoch(stats['lastUpdated'] ?? 0);
      if (DateTime.now().difference(lastUpdated).inMinutes > 5) {
        return null; // Stats expirées
      }
      return stats;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }

  static Future<void> invalidateCache() async {
    // Alias pour clearStats pour plus de clarté
    await clearStats();
  }
}
