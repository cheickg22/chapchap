import 'dart:convert';

import 'package:restart_tagxi/core/model/user_detail_model.dart';

RideStartModel userDetailResponseModelFromJson(String str) =>
    RideStartModel.fromJson(json.decode(str));

class RideStartModel {
  bool success;
  OnTripData? data;
  RideStartModel({required this.success, required this.data});

  factory RideStartModel.fromJson(Map<String, dynamic> json) {
    return RideStartModel(
      success: json["success"],
      data: (json["data"] != null) ? OnTripData.fromJson(json["data"]) : null,
    );
  }
}
