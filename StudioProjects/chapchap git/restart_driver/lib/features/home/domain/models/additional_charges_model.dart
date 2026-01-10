import 'dart:convert';

AdditionalCharges additionalChargesResponseModelFromJson(String str) =>
    AdditionalCharges.fromJson(json.decode(str));

class AdditionalCharges {
  bool success;
  String message;
  AdditionalCharges({required this.success,required this.message});

  factory AdditionalCharges.fromJson(Map<String, dynamic> json) {
    return AdditionalCharges(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
    );
  }
}
