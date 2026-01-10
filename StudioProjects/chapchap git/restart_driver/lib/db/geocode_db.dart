import 'package:drift/drift.dart';

class GeocodingCache extends Table {
  TextColumn get placeId => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();

  @override
  Set<Column> get primaryKey => {placeId};
}
