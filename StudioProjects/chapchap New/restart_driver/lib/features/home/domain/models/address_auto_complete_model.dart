import 'package:restart_tagxi/common/app_constants.dart';

class AddressAutoCompleteModel {
  bool success;
  List<AddressData> predictions;
  AddressAutoCompleteModel({required this.success, required this.predictions});

  factory AddressAutoCompleteModel.fromJson(Map<String, dynamic> json) {
    List<AddressData> data = [];
    if (mapType == 'google_map') {
      json['address'].forEach((e) {
        data.add(AddressData.fromJson(e));
      });
    } else {
      json['address'].forEach((e) {
        data.add(AddressData.fromJson(e));
      });
    }
    return AddressAutoCompleteModel(
      success: json["success"],
      predictions: data,
    );
  }
}

class AddressData {
  String placeId;
  String? address;
  String? lat;
  String? lon;
  String? displayName;
  AddressData(
      {required this.placeId,
      this.address,
      this.lat,
      this.lon,
      this.displayName});

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
        placeId: json['place_id'].toString(),
        address: json['description'] ?? json['address'],
        lat: json['lat'].toString(),
        lon: json['lon'].toString(),
        displayName: json['display_name']);
  }

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "description": address,
        "lat": lat,
        "lon": lon,
        "display_name": displayName,
      };
}
