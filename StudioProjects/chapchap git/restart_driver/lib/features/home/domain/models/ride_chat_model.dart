class RideChatModel {
  bool success;
  List chats;
  RideChatModel({required this.success, required this.chats});

  factory RideChatModel.fromJson(Map<String, dynamic> json) {
    return RideChatModel(
      success: json["success"],
      chats: json["data"],
    );
  }
}
