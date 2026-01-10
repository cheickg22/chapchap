// ignore_for_file: file_names

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/db/app_database.dart';

import '../features/language/domain/models/language_listing_model.dart';
import 'dart:io';

class AppConstants {
  static const String title = 'chapchap livraison';
  static const String baseUrl = 'https://chapchap-livraison.com/';
  static String firbaseApiKey = (Platform.isAndroid)
      ? "AIzaSyA101Qj9lm79JhFfBiLBIM_9eIpyr_Vb54"
      : "AIzaSyByQWbVva1mzixtld1tkgAB8jzyBjAmD6I";
  static String firebaseAppId =
  (Platform.isAndroid) ? "1:1021781820888:android:c577da0c4a80350cc59ead" : "1:1021781820888:ios:d759142ba9153dfcc59ead";
  static String firebasemessagingSenderId = (Platform.isAndroid)
      ? "1021781820888"
      : "1021781820888";
  static String firebaseProjectId = (Platform.isAndroid)
      ? "chapchap-e45b0"
      : "chapchap-e45b0";

  static String mapKey =
  (Platform.isAndroid) ? 'AIzaSyA101Qj9lm79JhFfBiLBIM_9eIpyr_Vb54' : 'AIzaSyByQWbVva1mzixtld1tkgAB8jzyBjAmD6I';
  static const String privacyPolicy = 'https://chapchap-livraison.com/privacy';
  static const String termsCondition = 'https://chapchap-livraison.com/terms';

  //Les liens de télechargement
  static const String appleStoreUrl = 'https://apps.apple.com/us/app/chapchap-driver/id6741163698';
  static const String playStoreUrl =  'https://play.google.com/store/apps/details?id=com.chapchap_livraison.driver';

  static const String stripPublishKey = '';

  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'Azerbaijani', lang: 'az'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es'),
  ];

  static String packageName = '';
  static String signKey = '';
  static LatLng currentLocations = const LatLng(0, 0);
}

AppDatabase db = AppDatabase();
bool isAppMapChange = false;
