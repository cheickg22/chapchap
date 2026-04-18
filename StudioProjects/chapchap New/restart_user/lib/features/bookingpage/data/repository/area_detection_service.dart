import 'dart:convert';
import 'package:flutter/services.dart';

/// Represents a named geographic area defined by a polygon.
class _Area {
  final String name;
  // Each point is [longitude, latitude]
  final List<List<double>> coordinates;

  const _Area({required this.name, required this.coordinates});

  factory _Area.fromJson(Map<String, dynamic> json) {
    return _Area(
      name: json['name'] as String,
      coordinates: (json['coordinates'] as List)
          .map((c) => [
                (c[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ])
          .toList(),
    );
  }
}

class AreaDetectionService {
  static AreaDetectionService? _instance;
  static AreaDetectionService get instance =>
      _instance ??= AreaDetectionService._();

  AreaDetectionService._();

  List<_Area>? _areas;

  /// Call once at app startup (e.g. in main() after WidgetsFlutterBinding).
  Future<void> init() async {
    if (_areas != null) return;
    final raw = await rootBundle.loadString('assets/data/nouakchott_areas.json');
    final list = jsonDecode(raw) as List;
    _areas = list.map((e) => _Area.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns the area name for the given [latitude]/[longitude], or null if
  /// the point falls outside every known polygon.
  String? getAreaName(double latitude, double longitude) {
    assert(_areas != null,
        'AreaDetectionService.init() must be called before getAreaName()');

    for (final area in _areas!) {
      if (_pointInPolygon(longitude, latitude, area.coordinates)) {
        return area.name;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Ray-casting algorithm  (O(n) per polygon)
  // px/py are the test-point coordinates (longitude, latitude).
  // polygon is a list of [longitude, latitude] vertices.
  // ---------------------------------------------------------------------------
  static bool _pointInPolygon(
      double px, double py, List<List<double>> polygon) {
    final n = polygon.length;
    if (n < 3) return false;

    bool inside = false;
    int j = n - 1;

    for (int i = 0; i < n; i++) {
      final xi = polygon[i][0], yi = polygon[i][1];
      final xj = polygon[j][0], yj = polygon[j][1];

      final intersects =
          ((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi);

      if (intersects) inside = !inside;
      j = i;
    }
    return inside;
  }
}
