class BankDetailsUpdateModel {
  bool success;
  BankDetailsUpdateModel({
    required this.success,
  });

  factory BankDetailsUpdateModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsUpdateModel(
      success: json["success"],
    );
  }
}
