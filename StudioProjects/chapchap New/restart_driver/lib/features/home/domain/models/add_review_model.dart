import 'dart:convert';

AddReviewModel userDetailResponseModelFromJson(String str) =>
    AddReviewModel.fromJson(json.decode(str));

class AddReviewModel {
  bool success;
  AddReviewModel({required this.success});

  factory AddReviewModel.fromJson(Map<String, dynamic> json) {
    return AddReviewModel(
      success: json["success"],
    );
  }
}
