import 'dart:io';
import '../db/app_database.dart';
import '../features/language/domain/models/language_listing_model.dart';

class AppConstants {
  static const String title = 'chapchap conducteur';
  static const String baseUrl = 'http://46.202.171.118/';
  static String firbaseApiKey = (Platform.isAndroid)
      ? "AIzaSyA101Qj9lm79JhFfBiLBIM_9eIpyr_Vb54"
      : "AIzaSyByQWbVva1mzixtld1tkgAB8jzyBjAmD6I";
  static String firebaseAppId =
  (Platform.isAndroid) ? "1:1021781820888:android:c498c508900b9aa1c59ead" : "1:1021781820888:ios:aa83f53464894e1ac59ead";
  static String firebasemessagingSenderId = (Platform.isAndroid)
      ? "1021781820888"
      : "1021781820888";
  static String firebaseProjectId = (Platform.isAndroid)
      ? "chapchap-e45b0"
      : "chapchap-e45b0";

  static String mapKey =
  (Platform.isAndroid) ? "AIzaSyA101Qj9lm79JhFfBiLBIM_9eIpyr_Vb54" : 'AIzaSyByQWbVva1mzixtld1tkgAB8jzyBjAmD6I';
  static const String privacyPolicy = 'http://46.202.171.118/privacy';
  static const String termsCondition = 'http://46.202.171.118/terms';

  static const String playStoreLink =  'https://play.google.com/store/apps/details?id=com.chapchap_livraison.user';
  static const String appleStoreLink = 'https://apps.apple.com/ml/app/chapchap-utilisateur/id6741466576?l=fr-FR';

  static const String stripPublishKey = '';
  static List<LocaleLanguageList> languageList = [
    LocaleLanguageList(name: 'English', lang: 'en'),
    LocaleLanguageList(name: 'Arabic', lang: 'ar'),
    LocaleLanguageList(name: 'French', lang: 'fr'),
    LocaleLanguageList(name: 'Spanish', lang: 'es')
  ];
  static String packageName = '';
  static String signKey = '';
}
bool showBubbleIcon = false;
bool subscriptionSkip = false;
String choosenLanguage = 'en';
String mapType = '';
bool isAppMapChange = false;

AppDatabase db = AppDatabase();
