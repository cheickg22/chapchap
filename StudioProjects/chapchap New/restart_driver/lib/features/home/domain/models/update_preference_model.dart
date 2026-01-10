// To parse this JSON data, do
//
//     final updatePreferencesModel = updatePreferencesModelFromJson(jsonString);

import 'dart:convert';

UpdatePreferencesModel updatePreferencesModelFromJson(String str) =>
    UpdatePreferencesModel.fromJson(json.decode(str));

String updatePreferencesModelToJson(UpdatePreferencesModel data) =>
    json.encode(data.toJson());

class UpdatePreferencesModel {
  bool success;
  String message;
  List<int> data;

  UpdatePreferencesModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpdatePreferencesModel.fromJson(Map<String, dynamic> json) =>
      UpdatePreferencesModel(
        success: json["success"],
        message: json["message"],
        data: List<int>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}
