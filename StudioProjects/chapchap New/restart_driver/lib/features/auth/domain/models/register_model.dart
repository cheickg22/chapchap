import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) =>
    RegisterResponseModel.fromJson(json.decode(str));

class RegisterResponseModel {
  String tokenType;
  int expiresIn;
  String accessToken;

  RegisterResponseModel({
    required this.tokenType,
    required this.expiresIn,
    required this.accessToken,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      RegisterResponseModel(
        tokenType: json["token_type"] ?? 'Bearer',
        expiresIn: json["expires_in"] ?? 0,
        accessToken: json["access_token"] ?? '',
      );
}
