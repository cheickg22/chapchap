// To parse this JSON data, do
//
//     final reportModel = reportModelFromJson(jsonString);

import 'dart:convert';

ReportModel reportModelFromJson(String str) =>
    ReportModel.fromJson(json.decode(str));

String reportModelToJson(ReportModel data) => json.encode(data.toJson());

class ReportModel {
  bool success;
  String message;
  ReportData data;

  ReportModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        success: json["success"],
        message: json["message"],
        data: ReportData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class ReportData {
  String fromDate;
  String toDate;
  int totalTripsCount;
  double? totalTripKms;
  double? totalEarnings;
  double? totalCashTripAmount;
  double? totalWalletTripAmount;
  int totalCashTripCount;
  int totalWalletTripCount;
  String currencySymbol;
  String totalHoursWorked;

  ReportData({
    required this.fromDate,
    required this.toDate,
    required this.totalTripsCount,
    required this.totalTripKms,
    required this.totalEarnings,
    required this.totalCashTripAmount,
    required this.totalWalletTripAmount,
    required this.totalCashTripCount,
    required this.totalWalletTripCount,
    required this.currencySymbol,
    required this.totalHoursWorked,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) => ReportData(
        fromDate: json["from_date"],
        toDate: json["to_date"],
        totalTripsCount: json["total_trips_count"],
        totalTripKms: json["total_trip_kms"].toDouble() ?? 0.0,
        totalEarnings: json["total_earnings"]?.toDouble() ?? 0.0,
        totalCashTripAmount: json["total_cash_trip_amount"]?.toDouble() ?? 0.0,
        totalWalletTripAmount:
            json["total_wallet_trip_amount"]?.toDouble() ?? 0.0,
        totalCashTripCount: json["total_cash_trip_count"],
        totalWalletTripCount: json["total_wallet_trip_count"],
        currencySymbol: json["currency_symbol"],
        totalHoursWorked: json["total_hours_worked"],
      );

  Map<String, dynamic> toJson() => {
        "from_date": fromDate,
        "to_date": toDate,
        "total_trips_count": totalTripsCount,
        "total_trip_kms": totalTripKms,
        "total_earnings": totalEarnings,
        "total_cash_trip_amount": totalCashTripAmount,
        "total_wallet_trip_amount": totalWalletTripAmount,
        "total_cash_trip_count": totalCashTripCount,
        "total_wallet_trip_count": totalWalletTripCount,
        "currency_symbol": currencySymbol,
        "total_hours_worked": totalHoursWorked,
      };
}
