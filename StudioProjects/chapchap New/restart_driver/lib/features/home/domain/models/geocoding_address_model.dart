import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingAddressModel {
  bool success;
  LatLng position;
  GeocodingAddressModel({required this.success, required this.position});

  factory GeocodingAddressModel.fromJson(Map<String, dynamic> json) {
    return GeocodingAddressModel(
      success: json["success"],
      position: json["position"],
    );
  }
}
