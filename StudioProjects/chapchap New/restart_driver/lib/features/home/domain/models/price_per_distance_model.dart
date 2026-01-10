class PricePerDistanceModel {
  bool success;
  PricePerDistanceModel({required this.success});

  factory PricePerDistanceModel.fromJson(Map<String, dynamic> json) {
    return PricePerDistanceModel(
      success: json["success"],
    );
  }
}
