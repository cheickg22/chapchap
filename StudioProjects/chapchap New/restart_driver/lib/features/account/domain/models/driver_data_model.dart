class DriverDataModel {
  bool success;
  List<DriverData>? data;
  DriverDataModel({required this.success, required this.data});

  factory DriverDataModel.fromJson(Map<String, dynamic> json) {
    List<DriverData> data = [];
    if (json['data'] != null) {
      json['data'].forEach((e) {
        data.add(DriverData.fromJson(e));
      });
    }
    return DriverDataModel(
      success: json["success"],
      data: data,
    );
  }
}

class DriverData {
  String id;
  String name;
  String email;
  String mobile;
  String profile;
  String? fleetId;
  bool approve;
  bool documentUploaded;
  String? carNumber;
  DriverData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profile,
    required this.fleetId,
    required this.approve,
    required this.documentUploaded,
    required this.carNumber,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      profile: json['profile_picture'],
      fleetId: json['fleet_id'],
      approve: json['approve'],
      documentUploaded: json['uploaded_document'],
      carNumber: json['car_number'],
    );
  }
}
