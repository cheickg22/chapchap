// To parse this JSON data, do
//
//     final diagnosticNotification = diagnosticNotificationFromJson(jsonString);

import 'dart:convert';

DiagnosticNotification diagnosticNotificationFromJson(String str) =>
    DiagnosticNotification.fromJson(json.decode(str));

String diagnosticNotificationToJson(DiagnosticNotification data) =>
    json.encode(data.toJson());

class DiagnosticNotification {
  bool success;
  String message;
  DiagnosticData data;

  DiagnosticNotification({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DiagnosticNotification.fromJson(Map<String, dynamic> json) =>
      DiagnosticNotification(
        success: json["success"],
        message: json["message"],
        data: DiagnosticData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class DiagnosticData {
  int approve;
  int available;

  DiagnosticData({
    required this.approve,
    required this.available,
  });

  factory DiagnosticData.fromJson(Map<String, dynamic> json) => DiagnosticData(
        approve: json["approve"],
        available: json["available"],
      );

  Map<String, dynamic> toJson() => {
        "approve": approve,
        "available": available,
      };
}
