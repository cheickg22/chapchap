import 'dart:convert';

DriverLevelsModel driverLevelsModelFromJson(String str) =>
    DriverLevelsModel.fromJson(json.decode(str));

String driverLevelsModelToJson(DriverLevelsModel data) =>
    json.encode(data.toJson());

class DriverLevelsModel {
  bool success;
  String message;
  List<DriverLevelsData> data;
  Meta meta;

  DriverLevelsModel({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory DriverLevelsModel.fromJson(Map<String, dynamic> json) =>
      DriverLevelsModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? List<DriverLevelsData>.from(
                json["data"].map((x) => DriverLevelsData.fromJson(x)))
            : [],
        meta: json["meta"] != null
            ? Meta.fromJson(json["meta"])
            : Meta.defaultMeta(),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
      };
}

class DriverLevelsData {
  String id;
  int level;
  String levelName;
  int minRideCount;
  int minRideAmount;
  int isMinRide;
  int isMinEarning;
  String levelIcon;
  String createdAt;
  String levelCompleted;
  LevelDetails? levelDetails;

  DriverLevelsData({
    required this.id,
    required this.level,
    required this.levelName,
    required this.minRideCount,
    required this.minRideAmount,
    required this.isMinRide,
    required this.isMinEarning,
    required this.levelIcon,
    required this.createdAt,
    required this.levelCompleted,
    required this.levelDetails,
  });

  factory DriverLevelsData.fromJson(Map<String, dynamic> json) =>
      DriverLevelsData(
        id: json["id"],
        level: json["level"],
        levelName: json['level_name'],
        minRideCount: json["min_ride_count"],
        minRideAmount: json["min_ride_amount"],
        isMinRide: json["is_min_ride"],
        isMinEarning: json["is_min_earning"],
        levelIcon: json["level_icon"],
        createdAt: json["created_at"],
        levelCompleted: json['level_completed'].toString(),
        levelDetails: json["levelDetails"] == null
            ? null
            : LevelDetails.fromJson(json["levelDetails"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "level": level,
        "level_name": levelName,
        "min_ride_count": minRideCount,
        "min_ride_amount": minRideAmount,
        "is_min_ride": isMinRide,
        "is_min_earning": isMinEarning,
        "level_icon": levelIcon,
        "created_at": createdAt,
        "level_completed": levelCompleted,
        "levelDetails": levelDetails?.toJson(),
      };
}

class LevelDetails {
  LevelDetailsData data;

  LevelDetails({
    required this.data,
  });

  factory LevelDetails.fromJson(Map<String, dynamic> json) => LevelDetails(
        data: LevelDetailsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class LevelDetailsData {
  String id;
  int level;
  String levelName;
  String levelId;
  int isMinRideCompleted;
  int isMinEarningCompleted;
  String levelIcon;
  String createdAt;
  String totalRides;
  String totalEarnings;

  LevelDetailsData(
      {required this.id,
      required this.level,
      required this.levelName,
      required this.levelId,
      required this.isMinRideCompleted,
      required this.isMinEarningCompleted,
      required this.levelIcon,
      required this.createdAt,
      required this.totalRides,
      required this.totalEarnings});

  factory LevelDetailsData.fromJson(Map<String, dynamic> json) =>
      LevelDetailsData(
          id: json["id"],
          level: json["level"],
          levelName: json['level_name'],
          levelId: json["level_id"],
          isMinRideCompleted: json["is_min_ride_completed"],
          isMinEarningCompleted: json["is_min_earning_completed"],
          levelIcon: json["level_icon"],
          createdAt: json["created_at"],
          totalRides: json["total_rides"].toString(),
          totalEarnings: json["total_earnings"].toString());

  Map<String, dynamic> toJson() => {
        "id": id,
        "level": level,
        "level_name": levelName,
        "level_id": levelId,
        "is_min_ride_completed": isMinRideCompleted,
        "is_min_earning_completed": isMinEarningCompleted,
        "level_icon": levelIcon,
        "created_at": createdAt,
        "total_rides": totalRides,
        "total_earnings": totalEarnings
      };
}

class Meta {
  LevelsPagination pagination;

  Meta({
    required this.pagination,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        pagination: json["pagination"] != null
            ? LevelsPagination.fromJson(json["pagination"])
            : LevelsPagination.defaultPagination(),
      );

  factory Meta.defaultMeta() => Meta(
        pagination: LevelsPagination.defaultPagination(),
      );
  Map<String, dynamic> toJson() => {
        "pagination": pagination.toJson(),
      };
}

class LevelsPagination {
  int total;
  int count;
  int perPage;
  int currentPage;
  int totalPages;
  Links links;

  LevelsPagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.links,
  });

  factory LevelsPagination.fromJson(Map<String, dynamic> json) =>
      LevelsPagination(
        total: json["total"] ?? 0,
        count: json["count"] ?? 0,
        perPage: json["per_page"] ?? 10,
        currentPage: json["current_page"] ?? 1,
        totalPages: json["total_pages"] ?? 1,
        links: json["links"] != null ? Links.fromJson(json["links"]) : Links(),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "count": count,
        "per_page": perPage,
        "current_page": currentPage,
        "total_pages": totalPages,
        "links": links.toJson(),
      };

  factory LevelsPagination.defaultPagination() => LevelsPagination(
        total: 0,
        count: 0,
        perPage: 10,
        currentPage: 1,
        totalPages: 1,
        links: Links(),
      );
}

class Links {
  Links();

  factory Links.fromJson(Map<String, dynamic> json) => Links();

  Map<String, dynamic> toJson() => {};
}
