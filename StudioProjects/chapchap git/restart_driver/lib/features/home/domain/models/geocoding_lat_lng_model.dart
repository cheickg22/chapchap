class GeocodingLatLngModel {
  bool success;
  String address;
  GeocodingLatLngModel({required this.success, required this.address});

  factory GeocodingLatLngModel.fromJson(Map<String, dynamic> json) {
    return GeocodingLatLngModel(
      success: json["success"],
      address: json["address"],
    );
  }
}
