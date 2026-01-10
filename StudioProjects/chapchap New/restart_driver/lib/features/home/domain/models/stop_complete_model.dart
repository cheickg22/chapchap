class StopCompleteModel {
  bool success;
  StopCompleteModel({required this.success});

  factory StopCompleteModel.fromJson(Map<String, dynamic> json) {
    return StopCompleteModel(success: json["success"]);
  }
}
