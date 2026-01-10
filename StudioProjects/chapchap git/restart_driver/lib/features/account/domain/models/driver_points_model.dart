// To parse this JSON data, do
//
//     final driverRewardsPointsModel = driverRewardsPointsModelFromJson(jsonString);

import 'dart:convert';

DriverRewardsPointsModel driverRewardsPointsModelFromJson(String str) =>
    DriverRewardsPointsModel.fromJson(json.decode(str));

String driverRewardsPointsModelToJson(DriverRewardsPointsModel data) =>
    json.encode(data.toJson());

class DriverRewardsPointsModel {
  bool success;
  WalletRemarks walletRemarks;
  LoyaltyRemarks loyaltyRemarks;

  DriverRewardsPointsModel({
    required this.success,
    required this.walletRemarks,
    required this.loyaltyRemarks,
  });

  factory DriverRewardsPointsModel.fromJson(Map<String, dynamic> json) =>
      DriverRewardsPointsModel(
        success: json["success"],
        walletRemarks: WalletRemarks.fromJson(json["wallet_remarks"]),
        loyaltyRemarks: LoyaltyRemarks.fromJson(json["loyalty_remarks"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "wallet_remarks": walletRemarks.toJson(),
        "loyalty_remarks": loyaltyRemarks.toJson(),
      };
}

class LoyaltyRemarks {
  String rewardPoints;
  bool isCredit;
  String remarks;
  int userId;
  String id;
  DateTime updatedAt;
  DateTime createdAt;

  LoyaltyRemarks({
    required this.rewardPoints,
    required this.isCredit,
    required this.remarks,
    required this.userId,
    required this.id,
    required this.updatedAt,
    required this.createdAt,
  });

  factory LoyaltyRemarks.fromJson(Map<String, dynamic> json) => LoyaltyRemarks(
        rewardPoints: json["reward_points"],
        isCredit: json["is_credit"],
        remarks: json["remarks"],
        userId: json["user_id"],
        id: json["id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "reward_points": rewardPoints,
        "is_credit": isCredit,
        "remarks": remarks,
        "user_id": userId,
        "id": id,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
      };
}

class WalletRemarks {
  int userId;
  String amount;
  String transactionId;
  String remarks;
  bool isCredit;
  String id;
  DateTime updatedAt;
  DateTime createdAt;
  String convertedCreatedAt;

  WalletRemarks({
    required this.userId,
    required this.amount,
    required this.transactionId,
    required this.remarks,
    required this.isCredit,
    required this.id,
    required this.updatedAt,
    required this.createdAt,
    required this.convertedCreatedAt,
  });

  factory WalletRemarks.fromJson(Map<String, dynamic> json) => WalletRemarks(
        userId: json["user_id"],
        amount: json["amount"],
        transactionId: json["transaction_id"],
        remarks: json["remarks"],
        isCredit: json["is_credit"],
        id: json["id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        convertedCreatedAt: json["converted_created_at"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "amount": amount,
        "transaction_id": transactionId,
        "remarks": remarks,
        "is_credit": isCredit,
        "id": id,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "converted_created_at": convertedCreatedAt,
      };
}
