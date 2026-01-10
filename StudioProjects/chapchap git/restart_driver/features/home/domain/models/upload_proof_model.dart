class UploadProofModel {
  bool success;
  UploadProofModel({required this.success});

  factory UploadProofModel.fromJson(Map<String, dynamic> json) {
    return UploadProofModel(success: json["success"]);
  }
}
