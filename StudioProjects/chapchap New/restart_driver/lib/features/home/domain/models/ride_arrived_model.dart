import 'dart:convert';

import 'package:restart_tagxi/core/model/user_detail_model.dart';

RideArrivedModel userDetailResponseModelFromJson(String str) =>
    RideArrivedModel.fromJson(json.decode(str));

class RideArrivedModel {
  bool success;
  OnTripData? data;
  RideArrivedModel({required this.success, required this.data});

  factory RideArrivedModel.fromJson(Map<String, dynamic> json) {
    return RideArrivedModel(
      success: json["success"],
      data: (json["data"] != null) ? OnTripData.fromJson(json["data"]) : null,
    );
  }
}
