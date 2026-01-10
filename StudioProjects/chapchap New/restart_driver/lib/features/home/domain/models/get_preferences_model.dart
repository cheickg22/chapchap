// To parse this JSON data, do
//
//     final getPreferencesModel = getPreferencesModelFromJson(jsonString);

import 'dart:convert';

GetPreferencesModel getPreferencesModelFromJson(String str) =>
    GetPreferencesModel.fromJson(json.decode(str));

String getPreferencesModelToJson(GetPreferencesModel data) =>
    json.encode(data.toJson());

class GetPreferencesModel {
  bool success;
  String message;
  List<GetPreferencesModelData> data;

  GetPreferencesModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetPreferencesModel.fromJson(Map<String, dynamic> json) =>
      GetPreferencesModel(
        success: json["success"],
        message: json["message"] ?? '',
        data: List<GetPreferencesModelData>.from(
            json["data"].map((x) => GetPreferencesModelData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class GetPreferencesModelData {
  int id;
  String name;
  String icon;
  DateTime createdAt;
  DateTime updatedAt;
  bool driverSelected;

  GetPreferencesModelData({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
    required this.driverSelected,
  });

  factory GetPreferencesModelData.fromJson(Map<String, dynamic> json) =>
      GetPreferencesModelData(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        driverSelected: json["driver_selected"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "driver_selected": driverSelected,
      };
}
