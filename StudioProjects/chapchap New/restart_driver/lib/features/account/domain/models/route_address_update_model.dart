class AddMyRouteAddressResponse {
  final bool success;
  final String message;

  AddMyRouteAddressResponse({
    required this.success,
    required this.message,
  });

  factory AddMyRouteAddressResponse.fromJson(Map<String, dynamic> json) {
    return AddMyRouteAddressResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
