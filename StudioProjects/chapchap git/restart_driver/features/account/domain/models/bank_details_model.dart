class BankDetailsModel {
  bool success;
  List data;
  BankDetailsModel({required this.success, required this.data});

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(success: json["success"], data: json['data']);
  }
}
