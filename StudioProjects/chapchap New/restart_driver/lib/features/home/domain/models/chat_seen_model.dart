class ChatSeenModel {
  bool success;
  ChatSeenModel({required this.success});

  factory ChatSeenModel.fromJson(Map<String, dynamic> json) {
    return ChatSeenModel(success: json["success"]);
  }
}
