import 'dart:convert';

OnlineOfflineResponseModel userDetailResponseModelFromJson(String str) =>
    OnlineOfflineResponseModel.fromJson(json.decode(str));

class OnlineOfflineResponseModel {
  bool success;
  bool isOnline;
  OnlineOfflineResponseModel({required this.success, required this.isOnline});

  factory OnlineOfflineResponseModel.fromJson(Map<String, dynamic> json) {
    return OnlineOfflineResponseModel(
      success: json["success"],
      isOnline: json['data']["active"],
    );
  }
}
