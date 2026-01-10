import 'package:drift/drift.dart';

class SearchPlaces extends Table {
  TextColumn get placeId => text()();
  TextColumn get address => text().nullable()();
  TextColumn get lat => text().nullable()();
  TextColumn get lon => text().nullable()();
  TextColumn get displayName => text().nullable()();
}
