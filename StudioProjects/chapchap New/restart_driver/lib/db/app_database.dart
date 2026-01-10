import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'geocode_db.dart';
import 'search_db.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [SearchPlaces, GeocodingCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from == 1) {
            await migrator.createTable(geocodingCache);
          }
        },
      );
//searchAddress
  Future<List<SearchPlace>> getAllCachedAddresses() =>
      select(searchPlaces).get();
  Future<void> insertCachedAddress(SearchPlace address) =>
      into(searchPlaces).insert(address);
  Future<void> clearCachedAddresses() => delete(searchPlaces).go();

//Geocoding
  Future<LatLng?> getCachedGeocoding(String placeId) async {
    final result = await (select(geocodingCache)
          ..where((tbl) => tbl.placeId.equals(placeId)))
        .getSingleOrNull();

    if (result != null) {
      return LatLng(result.lat, result.lng);
    }
    return null;
  }

  Future<void> cacheGeocodingResult(String placeId, LatLng position) async {
    into(geocodingCache).insertOnConflictUpdate(
      GeocodingCacheCompanion(
        placeId: Value(placeId),
        lat: Value(position.latitude),
        lng: Value(position.longitude),
      ),
    );
  }

  Future<void> clearGeocodingCache() => delete(geocodingCache).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}
