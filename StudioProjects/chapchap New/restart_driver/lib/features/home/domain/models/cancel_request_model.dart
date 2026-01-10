class CancelRequestModel {
  bool success;
  CancelRequestModel({required this.success});

  factory CancelRequestModel.fromJson(Map<String, dynamic> json) {
    return CancelRequestModel(success: json["success"]);
  }
}
