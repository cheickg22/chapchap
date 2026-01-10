// To parse this JSON data, do
//
//     final driverPerformanceModel = driverPerformanceModelFromJson(jsonString);

import 'dart:convert';

DriverPerformanceModel driverPerformanceModelFromJson(String str) =>
    DriverPerformanceModel.fromJson(json.decode(str));

String driverPerformanceModelToJson(DriverPerformanceModel data) =>
    json.encode(data.toJson());

class DriverPerformanceModel {
  bool success;
  DriverPerformanceDatas driverData;

  DriverPerformanceModel({
    required this.success,
    required this.driverData,
  });

  factory DriverPerformanceModel.fromJson(Map<String, dynamic> json) =>
      DriverPerformanceModel(
        success: json["success"],
        driverData: DriverPerformanceDatas.fromJson(json["driver_data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "driver_data": driverData.toJson(),
      };
}

class DriverPerformanceDatas {
  String driverId;
  String mobile;
  String totalEarnings;
  String totalDistance;
  String totalAdminEarnings;
  String totalRevenue;
  String perDayRevenue;
  String totalTrips;
  String completedRequests;
  String averageUserRating;
  String rating1Average;
  String rating2Average;
  String rating3Average;
  String rating4Average;
  String rating5Average;
  String totalDurationInHours;
  String averageLoginHoursPerDay;

  DriverPerformanceDatas({
    required this.driverId,
    required this.mobile,
    required this.totalEarnings,
    required this.totalDistance,
    required this.totalAdminEarnings,
    required this.totalRevenue,
    required this.perDayRevenue,
    required this.totalTrips,
    required this.completedRequests,
    required this.averageUserRating,
    required this.rating1Average,
    required this.rating2Average,
    required this.rating3Average,
    required this.rating4Average,
    required this.rating5Average,
    required this.totalDurationInHours,
    required this.averageLoginHoursPerDay,
  });

  factory DriverPerformanceDatas.fromJson(Map<String, dynamic> json) =>
      DriverPerformanceDatas(
        driverId: json["driver_id"].toString(),
        mobile: json["mobile"].toString(),
        totalEarnings: json["total_earnings"].toString(),
        totalDistance: json["total_distance"].toStringAsFixed(2).toString(),
        totalAdminEarnings: json["total_admin_earnings"].toString(),
        totalRevenue: json["total_revenue"].toString(),
        perDayRevenue: json["per_day_revenue"].toString(),
        totalTrips: json["total_trips"].toString(),
        completedRequests: json["completed_requests"].toString(),
        averageUserRating: json["average_user_rating"].toString(),
        rating1Average: json["rating_1_average"].toString(),
        rating2Average: json["rating_2_average"].toString(),
        rating3Average: json["rating_3_average"].toString(),
        rating4Average: json["rating_4_average"].toString(),
        rating5Average: json["rating_5_average"].toString(),
        totalDurationInHours: json["total_duration_in_hours"].toString(),
        averageLoginHoursPerDay: json["average_login_hours_per_day"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "driver_id": driverId,
        "mobile": mobile,
        "total_earnings": totalEarnings,
        "total_distance": totalDistance,
        "total_admin_earnings": totalAdminEarnings,
        "total_revenue": totalRevenue,
        "per_day_revenue": perDayRevenue,
        "total_trips": totalTrips,
        "completed_requests": completedRequests,
        "average_user_rating": averageUserRating,
        "rating_1_average": rating1Average,
        "rating_2_average": rating2Average,
        "rating_3_average": rating3Average,
        "rating_4_average": rating4Average,
        "rating_5_average": rating5Average,
        "total_duration_in_hours": totalDurationInHours,
        "average_login_hours_per_day": averageLoginHoursPerDay,
      };
}
