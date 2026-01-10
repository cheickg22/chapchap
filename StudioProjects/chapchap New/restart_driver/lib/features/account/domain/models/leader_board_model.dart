class LeaderBoardModel {
  bool success;
  List<LeaderBoardData> data;
  LeaderBoardModel({required this.success, required this.data});

  factory LeaderBoardModel.fromJson(Map<String, dynamic> json) {
    return LeaderBoardModel(
      success: json["success"],
      data: List<LeaderBoardData>.from(
          json["data"].map((x) => LeaderBoardData.fromJson(x))),
    );
  }
}

class LeaderBoardData {
  String driverId;
  String driverName;
  String profile;
  String? commission;
  String? trips;
  String? totalRides;

  LeaderBoardData(
      {required this.driverId,
      required this.driverName,
      required this.profile,
      required this.commission,
      required this.trips,
      required this.totalRides});

  factory LeaderBoardData.fromJson(Map<String, dynamic> json) {
    return LeaderBoardData(
        driverId: json['driver_id'].toString(),
        driverName: json['driver_name'],
        profile: json['profile_picture'],
        commission: json['commission'].toString(),
        trips: json['total_trips'].toString(),
        totalRides: json['total_trips'].toString());
  }
}
