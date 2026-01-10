import 'package:restart_tagxi/core/model/user_detail_model.dart';

class InstantRideModel {
  bool success;
  OnTripData ontripData;
  InstantRideModel({required this.success, required this.ontripData});

  factory InstantRideModel.fromJson(Map<String, dynamic> json) {
    return InstantRideModel(
        success: json["success"],
        ontripData: OnTripData.fromJson(json["data"]));
  }
}
