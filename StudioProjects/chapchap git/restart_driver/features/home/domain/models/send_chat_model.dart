class SendChatModel {
  bool success;
  SendChatModel({required this.success});

  factory SendChatModel.fromJson(Map<String, dynamic> json) {
    return SendChatModel(success: json["success"]);
  }
}
