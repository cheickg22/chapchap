class EnableMyRouteBookingResponse {
  final bool success;
  final String message;

  EnableMyRouteBookingResponse({
    required this.success,
    required this.message,
  });

  factory EnableMyRouteBookingResponse.fromJson(Map<String, dynamic> json) {
    return EnableMyRouteBookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class MyRouteModel {
  final String selectedAddress;
  final double lat;
  final double lng;

  MyRouteModel(
      {required this.selectedAddress, required this.lat, required this.lng});
}
