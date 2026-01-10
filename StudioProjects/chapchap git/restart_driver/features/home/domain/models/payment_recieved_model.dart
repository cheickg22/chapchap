import 'dart:convert';

PaymentRecievedModel userDetailResponseModelFromJson(String str) =>
    PaymentRecievedModel.fromJson(json.decode(str));

class PaymentRecievedModel {
  bool success;
  PaymentRecievedModel({required this.success});

  factory PaymentRecievedModel.fromJson(Map<String, dynamic> json) {
    return PaymentRecievedModel(success: json["success"]);
  }
}
