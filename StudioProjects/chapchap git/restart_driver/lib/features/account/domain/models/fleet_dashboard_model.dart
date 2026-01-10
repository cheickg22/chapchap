class FleetDashboardModel {
  bool success;
  FleetData data;
  // OverallEarningData overallEarnings;
  // List<FleetEarningsData> fleetEarnings;
  // List<FleetDriverData> fleetDriverData;
  FleetDashboardModel({required this.success, required this.data});

  factory FleetDashboardModel.fromJson(Map<String, dynamic> json) {
    // List<DriverData> data = [];
    // if(json['data'] != null){
    // json['data'].forEach((e){
    //            data.add(DriverData.fromJson(e));
    //     });
    // }
    return FleetDashboardModel(
      success: json["success"],
      data: FleetData.fromJson(json['fleet_data']),
      // overallEarnings: OverallEarningData.fromJson(json['overallEarnings']),
    );
  }
}

class FleetData {
  String fleetId;
  String licenseNo;
  String vehicleName;
  String totalEarnings;
  String totalDistance;
  String adminEarnings;
  String totalRevenue;
  String perDayRevenue;
  String totalTrips;
  String completedRequests;
  String avgRating;
  String ratingOne;
  String ratingTwo;
  String ratingThree;
  String ratingFour;
  String ratingFive;
  String totalDuration;
  String avgLoginHours;

  FleetData(
      {required this.fleetId,
      required this.licenseNo,
      required this.vehicleName,
      required this.totalEarnings,
      required this.totalDistance,
      required this.adminEarnings,
      required this.totalRevenue,
      required this.perDayRevenue,
      required this.totalTrips,
      required this.completedRequests,
      required this.avgRating,
      required this.ratingOne,
      required this.ratingTwo,
      required this.ratingThree,
      required this.ratingFour,
      required this.ratingFive,
      required this.totalDuration,
      required this.avgLoginHours});

  factory FleetData.fromJson(Map<String, dynamic> json) {
    return FleetData(
        fleetId: json['fleet_id'].toString(),
        licenseNo: json['license_number'].toString(),
        vehicleName: json['vehicle_type_name'].toString(),
        totalEarnings: json['total_earnings'].toString(),
        totalDistance: json['total_distance'].toStringAsFixed(2),
        adminEarnings: json['total_admin_earnings'].toString(),
        totalRevenue: json['total_revenue'].toString(),
        perDayRevenue: json['per_day_revenue'].toString(),
        totalTrips: json['total_trips'].toString(),
        completedRequests: json['completed_requests'].toString(),
        avgRating: json['average_user_rating'].toString(),
        ratingOne: json['rating_1_average'].toString(),
        ratingTwo: json['rating_2_average'].toString(),
        ratingThree: json['rating_3_average'].toString(),
        ratingFour: json['rating_4_average'].toString(),
        ratingFive: json['rating_5_average'].toString(),
        totalDuration: json['total_duration_in_hours'].toString(),
        avgLoginHours: json['average_login_hours_per_day'].toString());
  }
}
