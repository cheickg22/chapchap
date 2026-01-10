class OwnerDashboardModel {
  bool success;
  DashboardData data;
  List<FleetEarningsData> fleetEarnings;
  List<FleetDriverData> fleetDriverData;
  OwnerDashboardModel(
      {required this.success,
      required this.data,
      required this.fleetEarnings,
      required this.fleetDriverData});

  factory OwnerDashboardModel.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardModel(
        success: json["success"],
        data: DashboardData.fromJson(json['data']),
        fleetEarnings: List<FleetEarningsData>.from(json['data']['fleetDetail']
                ['data']
            .map((x) => FleetEarningsData.fromJson(x))),
        fleetDriverData: List<FleetDriverData>.from(json['data']['driverDetail']
                ['data']
            .map((x) => FleetDriverData.fromJson(x))));
  }
}

class DashboardData {
  int userId;
  String blockedFleets;
  String activeFleets;
  String inactiveFleets;
  String cash;
  String digitalEarnings;
  String revenue;
  String netEarnings;
  String discount;
  DashboardData(
      {required this.userId,
      required this.blockedFleets,
      required this.activeFleets,
      required this.inactiveFleets,
      required this.cash,
      required this.digitalEarnings,
      required this.revenue,
      required this.netEarnings,
      required this.discount});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
        userId: json['user_id'],
        blockedFleets: json['blocked_fleets'].toString(),
        activeFleets: json['active_fleets'].toString(),
        inactiveFleets: json['inactive_fleets'].toString(),
        cash: json['cash_earnings'].toString(),
        digitalEarnings: json['digital_earnings'].toString(),
        revenue: json['revenue'].toString(),
        netEarnings: json['net_earnings'].toString(),
        discount: json['discount'].toString());
  }
}

class FleetEarningsData {
  String fleetId;
  String licenseNo;
  String vehicleTypeName;
  String totalEarnings;
  String totalCompletedRequests;
  String averageRating;
  FleetEarningsData(
      {required this.fleetId,
      required this.licenseNo,
      required this.vehicleTypeName,
      required this.totalEarnings,
      required this.totalCompletedRequests,
      required this.averageRating});
  factory FleetEarningsData.fromJson(Map<String, dynamic> json) {
    return FleetEarningsData(
        fleetId: json['id'].toString(),
        licenseNo: json['license_number'].toString(),
        vehicleTypeName: json['vehicle_type_name'].toString(),
        totalEarnings: json['total_earnings'].toString(),
        totalCompletedRequests: json['completed_requests'].toString(),
        averageRating: double.parse(json['average_user_rating'].toString())
            .toStringAsFixed(0));
  }
}

class FleetDriverData {
  String driverId;
  String name;
  String totalEarnings;
  String totalCompletedRequests;
  String averageRating;
  String profile;
  bool isApproved;
  FleetDriverData(
      {required this.driverId,
      required this.name,
      required this.totalEarnings,
      required this.totalCompletedRequests,
      required this.averageRating,
      required this.profile,
      required this.isApproved});
  factory FleetDriverData.fromJson(Map<String, dynamic> json) {
    return FleetDriverData(
        driverId: json['id'].toString(),
        name: json['name'].toString(),
        totalEarnings: json['total_earnings'].toString(),
        totalCompletedRequests: json['completed_requests'].toString(),
        averageRating: json['average_user_rating'].toString(),
        profile: json['profile_picture'],
        isApproved: json['approve']);
  }
}
