class ReferralResponseData {
  bool success;
  String message;
  ReferralData data;

  ReferralResponseData({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReferralResponseData.fromJson(Map<String, dynamic> json) =>
      ReferralResponseData(
        success: json["success"],
        message: json["message"],
        data: ReferralData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class ReferralData {
  ReferralContent referralContent;
  DriverBanner driverBanner;

  ReferralData({
    required this.referralContent,
    required this.driverBanner,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) => ReferralData(
        referralContent: ReferralContent.fromJson(json["referral_content"]),
        driverBanner: DriverBanner.fromJson(json["driver_banner"]),
      );

  Map<String, dynamic> toJson() => {
        "referral_content": referralContent.toJson(),
        "driver_banner": driverBanner.toJson(),
      };
}

class ReferralContent {
  ReferralItem data;

  ReferralContent({
    required this.data,
  });

  factory ReferralContent.fromJson(Map<String, dynamic> json) =>
      ReferralContent(
        data: ReferralItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class DriverBanner {
  ReferralItem data;

  DriverBanner({
    required this.data,
  });

  factory DriverBanner.fromJson(Map<String, dynamic> json) => DriverBanner(
        data: ReferralItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class ReferralItem {
  int id;
  String referralType;
  String description;
  String labelReferral;
  String translationDataset;

  ReferralItem({
    required this.id,
    required this.referralType,
    required this.description,
    required this.labelReferral,
    required this.translationDataset,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) => ReferralItem(
        id: json["id"],
        referralType: json["referral_type"],
        description: json["description"],
        labelReferral: json["label_referral"],
        translationDataset: json["translation_dataset"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referral_type": referralType,
        "description": description,
        "label_referral": labelReferral,
        "translation_dataset": translationDataset,
      };
}
