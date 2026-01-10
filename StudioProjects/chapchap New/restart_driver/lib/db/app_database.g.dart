// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SearchPlacesTable extends SearchPlaces
    with TableInfo<$SearchPlacesTable, SearchPlace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchPlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _placeIdMeta =
      const VerificationMeta('placeId');
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
      'place_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<String> lat = GeneratedColumn<String>(
      'lat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<String> lon = GeneratedColumn<String>(
      'lon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [placeId, address, lat, lon, displayName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_places';
  @override
  VerificationContext validateIntegrity(Insertable<SearchPlace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('place_id')) {
      context.handle(_placeIdMeta,
          placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta));
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SearchPlace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchPlace(
      placeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_id'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lat']),
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lon']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
    );
  }

  @override
  $SearchPlacesTable createAlias(String alias) {
    return $SearchPlacesTable(attachedDatabase, alias);
  }
}

class SearchPlace extends DataClass implements Insertable<SearchPlace> {
  final String placeId;
  final String? address;
  final String? lat;
  final String? lon;
  final String? displayName;
  const SearchPlace(
      {required this.placeId,
      this.address,
      this.lat,
      this.lon,
      this.displayName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['place_id'] = Variable<String>(placeId);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<String>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<String>(lon);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    return map;
  }

  SearchPlacesCompanion toCompanion(bool nullToAbsent) {
    return SearchPlacesCompanion(
      placeId: Value(placeId),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
    );
  }

  factory SearchPlace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchPlace(
      placeId: serializer.fromJson<String>(json['placeId']),
      address: serializer.fromJson<String?>(json['address']),
      lat: serializer.fromJson<String?>(json['lat']),
      lon: serializer.fromJson<String?>(json['lon']),
      displayName: serializer.fromJson<String?>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'placeId': serializer.toJson<String>(placeId),
      'address': serializer.toJson<String?>(address),
      'lat': serializer.toJson<String?>(lat),
      'lon': serializer.toJson<String?>(lon),
      'displayName': serializer.toJson<String?>(displayName),
    };
  }

  SearchPlace copyWith(
          {String? placeId,
          Value<String?> address = const Value.absent(),
          Value<String?> lat = const Value.absent(),
          Value<String?> lon = const Value.absent(),
          Value<String?> displayName = const Value.absent()}) =>
      SearchPlace(
        placeId: placeId ?? this.placeId,
        address: address.present ? address.value : this.address,
        lat: lat.present ? lat.value : this.lat,
        lon: lon.present ? lon.value : this.lon,
        displayName: displayName.present ? displayName.value : this.displayName,
      );
  SearchPlace copyWithCompanion(SearchPlacesCompanion data) {
    return SearchPlace(
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      address: data.address.present ? data.address.value : this.address,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchPlace(')
          ..write('placeId: $placeId, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(placeId, address, lat, lon, displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchPlace &&
          other.placeId == this.placeId &&
          other.address == this.address &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.displayName == this.displayName);
}

class SearchPlacesCompanion extends UpdateCompanion<SearchPlace> {
  final Value<String> placeId;
  final Value<String?> address;
  final Value<String?> lat;
  final Value<String?> lon;
  final Value<String?> displayName;
  final Value<int> rowid;
  const SearchPlacesCompanion({
    this.placeId = const Value.absent(),
    this.address = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchPlacesCompanion.insert({
    required String placeId,
    this.address = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : placeId = Value(placeId);
  static Insertable<SearchPlace> custom({
    Expression<String>? placeId,
    Expression<String>? address,
    Expression<String>? lat,
    Expression<String>? lon,
    Expression<String>? displayName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (placeId != null) 'place_id': placeId,
      if (address != null) 'address': address,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (displayName != null) 'display_name': displayName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchPlacesCompanion copyWith(
      {Value<String>? placeId,
      Value<String?>? address,
      Value<String?>? lat,
      Value<String?>? lon,
      Value<String?>? displayName,
      Value<int>? rowid}) {
    return SearchPlacesCompanion(
      placeId: placeId ?? this.placeId,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      displayName: displayName ?? this.displayName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (lat.present) {
      map['lat'] = Variable<String>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<String>(lon.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchPlacesCompanion(')
          ..write('placeId: $placeId, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('displayName: $displayName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeocodingCacheTable extends GeocodingCache
    with TableInfo<$GeocodingCacheTable, GeocodingCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeocodingCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _placeIdMeta =
      const VerificationMeta('placeId');
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
      'place_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [placeId, lat, lng];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geocoding_cache';
  @override
  VerificationContext validateIntegrity(Insertable<GeocodingCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('place_id')) {
      context.handle(_placeIdMeta,
          placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta));
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {placeId};
  @override
  GeocodingCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeocodingCacheData(
      placeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}place_id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
    );
  }

  @override
  $GeocodingCacheTable createAlias(String alias) {
    return $GeocodingCacheTable(attachedDatabase, alias);
  }
}

class GeocodingCacheData extends DataClass
    implements Insertable<GeocodingCacheData> {
  final String placeId;
  final double lat;
  final double lng;
  const GeocodingCacheData(
      {required this.placeId, required this.lat, required this.lng});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['place_id'] = Variable<String>(placeId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    return map;
  }

  GeocodingCacheCompanion toCompanion(bool nullToAbsent) {
    return GeocodingCacheCompanion(
      placeId: Value(placeId),
      lat: Value(lat),
      lng: Value(lng),
    );
  }

  factory GeocodingCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeocodingCacheData(
      placeId: serializer.fromJson<String>(json['placeId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'placeId': serializer.toJson<String>(placeId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
    };
  }

  GeocodingCacheData copyWith({String? placeId, double? lat, double? lng}) =>
      GeocodingCacheData(
        placeId: placeId ?? this.placeId,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );
  GeocodingCacheData copyWithCompanion(GeocodingCacheCompanion data) {
    return GeocodingCacheData(
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeocodingCacheData(')
          ..write('placeId: $placeId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(placeId, lat, lng);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeocodingCacheData &&
          other.placeId == this.placeId &&
          other.lat == this.lat &&
          other.lng == this.lng);
}

class GeocodingCacheCompanion extends UpdateCompanion<GeocodingCacheData> {
  final Value<String> placeId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> rowid;
  const GeocodingCacheCompanion({
    this.placeId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeocodingCacheCompanion.insert({
    required String placeId,
    required double lat,
    required double lng,
    this.rowid = const Value.absent(),
  })  : placeId = Value(placeId),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<GeocodingCacheData> custom({
    Expression<String>? placeId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (placeId != null) 'place_id': placeId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeocodingCacheCompanion copyWith(
      {Value<String>? placeId,
      Value<double>? lat,
      Value<double>? lng,
      Value<int>? rowid}) {
    return GeocodingCacheCompanion(
      placeId: placeId ?? this.placeId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeocodingCacheCompanion(')
          ..write('placeId: $placeId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SearchPlacesTable searchPlaces = $SearchPlacesTable(this);
  late final $GeocodingCacheTable geocodingCache = $GeocodingCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [searchPlaces, geocodingCache];
}

typedef $$SearchPlacesTableCreateCompanionBuilder = SearchPlacesCompanion
    Function({
  required String placeId,
  Value<String?> address,
  Value<String?> lat,
  Value<String?> lon,
  Value<String?> displayName,
  Value<int> rowid,
});
typedef $$SearchPlacesTableUpdateCompanionBuilder = SearchPlacesCompanion
    Function({
  Value<String> placeId,
  Value<String?> address,
  Value<String?> lat,
  Value<String?> lon,
  Value<String?> displayName,
  Value<int> rowid,
});

class $$SearchPlacesTableFilterComposer
    extends Composer<_$AppDatabase, $SearchPlacesTable> {
  $$SearchPlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));
}

class $$SearchPlacesTableOrderingComposer
    extends Composer<_$AppDatabase, $SearchPlacesTable> {
  $$SearchPlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));
}

class $$SearchPlacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SearchPlacesTable> {
  $$SearchPlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<String> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);
}

class $$SearchPlacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SearchPlacesTable,
    SearchPlace,
    $$SearchPlacesTableFilterComposer,
    $$SearchPlacesTableOrderingComposer,
    $$SearchPlacesTableAnnotationComposer,
    $$SearchPlacesTableCreateCompanionBuilder,
    $$SearchPlacesTableUpdateCompanionBuilder,
    (
      SearchPlace,
      BaseReferences<_$AppDatabase, $SearchPlacesTable, SearchPlace>
    ),
    SearchPlace,
    PrefetchHooks Function()> {
  $$SearchPlacesTableTableManager(_$AppDatabase db, $SearchPlacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SearchPlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SearchPlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SearchPlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> placeId = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> lat = const Value.absent(),
            Value<String?> lon = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchPlacesCompanion(
            placeId: placeId,
            address: address,
            lat: lat,
            lon: lon,
            displayName: displayName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String placeId,
            Value<String?> address = const Value.absent(),
            Value<String?> lat = const Value.absent(),
            Value<String?> lon = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SearchPlacesCompanion.insert(
            placeId: placeId,
            address: address,
            lat: lat,
            lon: lon,
            displayName: displayName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SearchPlacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SearchPlacesTable,
    SearchPlace,
    $$SearchPlacesTableFilterComposer,
    $$SearchPlacesTableOrderingComposer,
    $$SearchPlacesTableAnnotationComposer,
    $$SearchPlacesTableCreateCompanionBuilder,
    $$SearchPlacesTableUpdateCompanionBuilder,
    (
      SearchPlace,
      BaseReferences<_$AppDatabase, $SearchPlacesTable, SearchPlace>
    ),
    SearchPlace,
    PrefetchHooks Function()>;
typedef $$GeocodingCacheTableCreateCompanionBuilder = GeocodingCacheCompanion
    Function({
  required String placeId,
  required double lat,
  required double lng,
  Value<int> rowid,
});
typedef $$GeocodingCacheTableUpdateCompanionBuilder = GeocodingCacheCompanion
    Function({
  Value<String> placeId,
  Value<double> lat,
  Value<double> lng,
  Value<int> rowid,
});

class $$GeocodingCacheTableFilterComposer
    extends Composer<_$AppDatabase, $GeocodingCacheTable> {
  $$GeocodingCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));
}

class $$GeocodingCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $GeocodingCacheTable> {
  $$GeocodingCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get placeId => $composableBuilder(
      column: $table.placeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));
}

class $$GeocodingCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeocodingCacheTable> {
  $$GeocodingCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);
}

class $$GeocodingCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GeocodingCacheTable,
    GeocodingCacheData,
    $$GeocodingCacheTableFilterComposer,
    $$GeocodingCacheTableOrderingComposer,
    $$GeocodingCacheTableAnnotationComposer,
    $$GeocodingCacheTableCreateCompanionBuilder,
    $$GeocodingCacheTableUpdateCompanionBuilder,
    (
      GeocodingCacheData,
      BaseReferences<_$AppDatabase, $GeocodingCacheTable, GeocodingCacheData>
    ),
    GeocodingCacheData,
    PrefetchHooks Function()> {
  $$GeocodingCacheTableTableManager(
      _$AppDatabase db, $GeocodingCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeocodingCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeocodingCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeocodingCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> placeId = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GeocodingCacheCompanion(
            placeId: placeId,
            lat: lat,
            lng: lng,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String placeId,
            required double lat,
            required double lng,
            Value<int> rowid = const Value.absent(),
          }) =>
              GeocodingCacheCompanion.insert(
            placeId: placeId,
            lat: lat,
            lng: lng,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GeocodingCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GeocodingCacheTable,
    GeocodingCacheData,
    $$GeocodingCacheTableFilterComposer,
    $$GeocodingCacheTableOrderingComposer,
    $$GeocodingCacheTableAnnotationComposer,
    $$GeocodingCacheTableCreateCompanionBuilder,
    $$GeocodingCacheTableUpdateCompanionBuilder,
    (
      GeocodingCacheData,
      BaseReferences<_$AppDatabase, $GeocodingCacheTable, GeocodingCacheData>
    ),
    GeocodingCacheData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SearchPlacesTableTableManager get searchPlaces =>
      $$SearchPlacesTableTableManager(_db, _db.searchPlaces);
  $$GeocodingCacheTableTableManager get geocodingCache =>
      $$GeocodingCacheTableTableManager(_db, _db.geocodingCache);
}
