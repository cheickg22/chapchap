class CancelReasonModel {
  bool success;
  List<CancelReasonData> data;
  CancelReasonModel({required this.success, required this.data});

  factory CancelReasonModel.fromJson(Map<String, dynamic> json) {
    List<CancelReasonData> data = [];
    json['data'].forEach((e) {
      data.add(CancelReasonData.fromJson(e));
    });
    return CancelReasonModel(
      success: json["success"],
      data: data,
    );
  }
}

class CancelReasonData {
  String id;
  String reason;
  CancelReasonData({required this.id, required this.reason});

  factory CancelReasonData.fromJson(Map<String, dynamic> json) {
    return CancelReasonData(id: json['id'], reason: json['reason']);
  }
}
