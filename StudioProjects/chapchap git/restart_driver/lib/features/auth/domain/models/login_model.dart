import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

class LoginResponseModel {
  bool success;
  String message;
  String accessToken;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        accessToken: json["access_token"] ?? '',
      );
}
