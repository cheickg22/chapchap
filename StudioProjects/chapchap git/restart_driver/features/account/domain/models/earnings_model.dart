class EarningsModel {
  bool success;
  List<EarningsData> data;
  String currency;
  EarningsModel(
      {required this.success, required this.data, required this.currency});

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    List<EarningsData> data = [];
    json['earnings'].forEach((e) {
      data.add(EarningsData.fromJson(e));
    });
    return EarningsModel(
        success: json["success"],
        data: data,
        currency: json['currency_symbol']);
  }
}

class DailyEarningsModel {
  bool success;
  List<DailyEarningsData> data;
  String currency;
  int totalTrips;
  double totalTripsKm;
  String totalHoursWorked;
  DailyEarningsModel(
      {required this.success,
      required this.data,
      required this.currency,
      required this.totalTrips,
      required this.totalTripsKm,
      required this.totalHoursWorked});

  factory DailyEarningsModel.fromJson(Map<String, dynamic> json) {
    List<DailyEarningsData> data = [];
    json['requests']['data'].forEach((e) {
      data.add(DailyEarningsData.fromJson(e));
    });
    return DailyEarningsModel(
        success: json["success"],
        data: data,
        currency: json['currency_symbol'],
        totalTrips: json['total_trips'],
        totalTripsKm: json['total_trip_kms'].toDouble(),
        totalHoursWorked: json['total_hours_worked']);
  }
}

class DailyEarningsData {
  final String id;
  final String tripTime;
  final dynamic tripCommission;
  DailyEarningsData(
      {required this.id, required this.tripTime, required this.tripCommission});

  factory DailyEarningsData.fromJson(Map<String, dynamic> json) {
    return DailyEarningsData(
        id: json['id'],
        tripTime: json['trip_start_time'],
        tripCommission: json['trip_commission']);
  }
}

class EarningsData {
  final String fromDate;
  final String toDate;
  final dynamic totalAmount;
  final dynamic totalTrips;
  final dynamic totalWalletAmount;
  final dynamic totalCashAmount;
  final String totalLoggedInHours;
  final Map dates;
  EarningsData(
      {required this.fromDate,
      required this.toDate,
      required this.totalAmount,
      required this.totalTrips,
      required this.totalWalletAmount,
      required this.totalCashAmount,
      required this.totalLoggedInHours,
      required this.dates});

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
        fromDate: json['from_date'],
        toDate: json['to_date'],
        totalAmount: json['total_amount'],
        totalTrips: json['total_trips'],
        totalWalletAmount: json['total_wallet_amount'],
        totalCashAmount: json['total_cash_amount'],
        totalLoggedInHours: json['total_logged_in_hours'],
        dates: json['dates']);
  }
}
