class OwnerVehicleModel {
  bool success;
  List<VehicleData> data;
  OwnerVehicleModel({required this.success, required this.data});

  factory OwnerVehicleModel.fromJson(Map<String, dynamic> json) {
    List<VehicleData> data = [];
    if (json['data'] != null) {
      json['data'].forEach((e) {
        data.add(VehicleData.fromJson(e));
      });
    }
    return OwnerVehicleModel(
      success: json["success"],
      data: data,
    );
  }
}

class VehicleData {
  String id;
  String name;
  String number;
  String brand;
  String model;
  String? icon;
  int approve;
  bool isDeclined;
  Map? driverDetail;
  VehicleData(
      {required this.id,
      required this.name,
      required this.number,
      required this.brand,
      required this.model,
      required this.icon,
      required this.approve,
      required this.isDeclined,
      required this.driverDetail});

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
        id: json['id'].toString(),
        name: json['vehicle_type'],
        number: json['license_number'],
        brand: json['brand'],
        model: json['model'],
        icon: json['type_icon'],
        approve: json['approve'],
        isDeclined: json['is_declined'],
        driverDetail:
            json['driverDetail'] == null ? null : json['driverDetail']['data']);
  }
}
