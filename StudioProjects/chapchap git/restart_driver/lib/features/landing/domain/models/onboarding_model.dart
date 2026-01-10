import 'dart:convert';

OnBoardingResponseModel onBoardingResponseModelFromJson(String str) =>
    OnBoardingResponseModel.fromJson(json.decode(str));

class OnBoardingResponseModel {
  bool success;
  OnBoardingList data;

  OnBoardingResponseModel({
    required this.success,
    required this.data,
  });

  factory OnBoardingResponseModel.fromJson(Map<String, dynamic> json) =>
      OnBoardingResponseModel(
        success: json["success"] ?? false,
        data: json["data"] != null 
            ? OnBoardingList.fromJson(json["data"]) 
            : OnBoardingList(onboarding: Onboarding(data: [])),
      );
}

class OnBoardingList {
  Onboarding onboarding;

  OnBoardingList({
    required this.onboarding,
  });

  factory OnBoardingList.fromJson(Map<String, dynamic> json) => OnBoardingList(
        onboarding: json["onboarding"] != null 
            ? Onboarding.fromJson(json["onboarding"]) 
            : Onboarding(data: []),
      );
}

class Onboarding {
  List<OnBoardingData> data;

  Onboarding({
    required this.data,
  });

  factory Onboarding.fromJson(Map<String, dynamic> json) => Onboarding(
        data: json["data"] != null 
            ? List<OnBoardingData>.from(
                json["data"].map((x) => OnBoardingData.fromJson(x)))
            : [],
      );
}

class OnBoardingData {
  int order;
  int id;
  String screen;
  String title;
  String onboardingImage;
  String description;
  int active;

  OnBoardingData({
    required this.order,
    required this.id,
    required this.screen,
    required this.title,
    required this.onboardingImage,
    required this.description,
    required this.active,
  });

  factory OnBoardingData.fromJson(Map<String, dynamic> json) => OnBoardingData(
        order: json["order"] ?? 0,
        id: json["id"] ?? 0,
        screen: json["screen"] ?? '',
        title: json["title"] ?? '',
        onboardingImage: json["onboarding_image"] ?? '',
        description: json["description"] ?? '',
        active: json["active"] ?? 0,
      );
}
