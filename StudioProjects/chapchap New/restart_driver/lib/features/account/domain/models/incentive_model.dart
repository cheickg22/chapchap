// ignore_for_file: constant_identifier_names

import 'dart:convert';

IncentiveModel incentiveModelFromJson(String str) =>
    IncentiveModel.fromJson(json.decode(str));

String incentiveModelToJson(IncentiveModel data) => json.encode(data.toJson());

class IncentiveModel {
  bool success;
  String message;
  IncentiveData data;

  IncentiveModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IncentiveModel.fromJson(Map<String, dynamic> json) => IncentiveModel(
        success: json["success"],
        message: json["message"],
        data: IncentiveData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class IncentiveData {
  List<IncentiveHistory> incentiveHistory;

  IncentiveData({
    required this.incentiveHistory,
  });

  factory IncentiveData.fromJson(Map<String, dynamic> json) => IncentiveData(
        incentiveHistory: List<IncentiveHistory>.from(
            json["incentive_history"].map((x) => IncentiveHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "incentive_history":
            List<dynamic>.from(incentiveHistory.map((x) => x.toJson())),
      };
}

class IncentiveHistory {
  String fromDate;
  String toDate;
  List<IncentiveDates> dates;

  IncentiveHistory({
    required this.fromDate,
    required this.toDate,
    required this.dates,
  });

  factory IncentiveHistory.fromJson(Map<String, dynamic> json) =>
      IncentiveHistory(
        fromDate: json["from_date"],
        toDate: json["to_date"],
        dates: List<IncentiveDates>.from(
            json["dates"].map((x) => IncentiveDates.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "from_date": fromDate,
        "to_date": toDate,
        "dates": List<dynamic>.from(dates.map((x) => x.toJson())),
      };
}

class IncentiveDates {
  String day;
  String date;
  bool isCurrentWeek;
  bool isCurrentDate;
  int totalRides;
  double? totalIncentiveEarned;
  int earnUpto;
  List<UpcomingIncentive> upcomingIncentives;

  IncentiveDates({
    required this.day,
    required this.date,
    required this.totalIncentiveEarned,
    required this.earnUpto,
    required this.upcomingIncentives,
    required this.isCurrentDate,
    required this.isCurrentWeek,
    required this.totalRides,
  });

  factory IncentiveDates.fromJson(Map<String, dynamic> json) => IncentiveDates(
        day: json["day"],
        date: json["date"],
        totalIncentiveEarned: json["total_incentive_earned"].toDouble() ?? 0.0,
        isCurrentDate: json['is_today'] ?? false,
        isCurrentWeek: json['is_current_week'] ?? false,
        totalRides: json["total_rides"],
        earnUpto: json["earn_upto"],
        upcomingIncentives: List<UpcomingIncentive>.from(
            json["upcoming_incentives"]
                .map((x) => UpcomingIncentive.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "date": date,
        "is_current_week": isCurrentWeek,
        "is_today": isCurrentDate,
        "total_rides": totalRides,
        "total_incentive_earned": totalIncentiveEarned,
        "earn_upto": earnUpto,
        "upcoming_incentives":
            List<dynamic>.from(upcomingIncentives.map((x) => x.toJson())),
      };
}

class UpcomingIncentive {
  int rideCount;
  double? incentiveAmount;
  bool isCompleted;

  UpcomingIncentive({
    required this.rideCount,
    required this.incentiveAmount,
    required this.isCompleted,
  });

  factory UpcomingIncentive.fromJson(Map<String, dynamic> json) =>
      UpcomingIncentive(
        rideCount: json["ride_count"],
        incentiveAmount: json["incentive_amount"].toDouble() ?? 0.0,
        isCompleted: json["is_completed"],
      );

  Map<String, dynamic> toJson() => {
        "ride_count": rideCount,
        "incentive_amount": incentiveAmount,
        "is_completed": isCompleted,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
