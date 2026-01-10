import 'dart:convert';

import 'package:restart_tagxi/core/model/user_detail_model.dart';

RespondRequestModel userDetailResponseModelFromJson(String str) =>
    RespondRequestModel.fromJson(json.decode(str));

class RespondRequestModel {
  bool success;
  OnTripData? data;
  RespondRequestModel({required this.success, required this.data});

  factory RespondRequestModel.fromJson(Map<String, dynamic> json) {
    return RespondRequestModel(
      success: json["success"],
      data: (json["data"] != null) ? OnTripData.fromJson(json["data"]) : null,
    );
  }
}
