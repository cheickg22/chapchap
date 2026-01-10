class EtaDetailsModel {
  bool success;
  String price;
  String currency;
  EtaDetailsModel(
      {required this.success, required this.price, required this.currency});

  factory EtaDetailsModel.fromJson(Map<String, dynamic> json) {
    return EtaDetailsModel(
        success: json["success"],
        price: json["price"],
        currency: json["currency"]);
  }
}
