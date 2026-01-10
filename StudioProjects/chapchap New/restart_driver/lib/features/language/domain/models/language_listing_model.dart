import 'dart:convert';

LanguageListResponseModel languageListResponseModelFromJson(String str) =>
    LanguageListResponseModel.fromJson(json.decode(str));

class LanguageListResponseModel {
  bool success;
  String message;
  List<LanguageList> data;

  LanguageListResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LanguageListResponseModel.fromJson(Map<String, dynamic> json) {
    return LanguageListResponseModel(
      success: json["success"],
      message: json["message"],
      data: List<LanguageList>.from(
          json["data"]['data'].map((x) => LanguageList.fromJson(x))),
    );
  }
}

class LanguageList {
  String lang;
  String name;

  LanguageList({
    required this.lang,
    required this.name,
  });

  factory LanguageList.fromJson(Map<String, dynamic> json) => LanguageList(
        lang: json["lang"],
        name: json["name"],
      );
}

class LocaleLanguageList {
  String lang;
  String name;

  LocaleLanguageList({
    required this.lang,
    required this.name,
  });

  factory LocaleLanguageList.fromJson(Map<String, dynamic> json) =>
      LocaleLanguageList(
        lang: json["lang"] ?? '',
        name: json["name"] ?? '',
      );
}
