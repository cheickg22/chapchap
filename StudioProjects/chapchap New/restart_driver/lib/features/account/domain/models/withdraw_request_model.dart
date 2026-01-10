class WithdrawRequestModel {
  bool success;

  WithdrawRequestModel({
    required this.success,
  });

  factory WithdrawRequestModel.fromJson(Map<String, dynamic> json) =>
      WithdrawRequestModel(success: json["success"]);
}
