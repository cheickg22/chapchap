import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {
  // SET LOCAL DATA
  static Future setSelectedLanguageCode(String choosenLanguage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('choosenLanguage', choosenLanguage);
  }

  static Future setLanguageDirection(String direction) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('direction', direction);
  }

  static Future setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('token', token);
  }

  static Future setLoginStatus(bool loginStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('login', loginStatus);
  }

  static Future setLandingStatus(bool landingStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('landing', landingStatus);
  }

  static Future setMapType(String setMapType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('mapType', setMapType);
  }

  static Future setDistanceBetween(double distance) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble('distanceBetween', distance);
  }

  static Future setBidSettingStatus(bool isBidEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isBidEnabled', isBidEnabled);
  }

  static Future setBubbleSettingStatus(bool isBidEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isBubbleEnabled', isBidEnabled);
  }

  // static Future setSharedRideSettingStatus(bool isSharedRideEnabled) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return await prefs.setBool('isSharedRideEnabled', isSharedRideEnabled);
  // }

  static Future setSubscriptionSkipStatus(bool skipSubscription) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('skipSubscription', skipSubscription);
  }

  static Future setUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('userType', userType);
  }

  static Future setUserTypeStatus(bool isUserChoosed) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('isUserChoosed', isUserChoosed);
  }

  static Future<void> setGeocodingResult(
      String placeId, LatLng position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(placeId,
        jsonEncode({'lat': position.latitude, 'lng': position.longitude}));
  }

  static Future setDarkThemeStatus(bool darkTheme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('dark', darkTheme);
  }

  // GET LOCAL DATA
  static Future<String> getSelectedLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('choosenLanguage') ?? '';
  }

  static Future<String> getLanguageDirection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('direction') ?? 'ltr';
  }

  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<String> getMapType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('mapType') ?? '';
  }

  static Future getLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('login') ?? false;
  }

  static Future getBidSettingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBidEnabled') ?? false;
  }

  static Future getUserTypeStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserChoosed');
  }

  static Future getBubbleSettingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBubbleEnabled') ?? false;
  }

  // static Future getSharedRideSettingStatus() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('isSharedRideEnabled') ?? false;
  // }

  static Future getSubscriptionSkipStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('skipSubscription') ?? false;
  }

  static Future getLandingStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('landing') ?? false;
  }

  static Future getDistanceBetween() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('distanceBetween');
  }

  static Future<String> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? '';
  }

  static Future<LatLng?> getGeocodingResult(String placeId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final geocodingData = prefs.getString(placeId);
    if (geocodingData != null) {
      final json = jsonDecode(geocodingData);
      return LatLng(json['lat'], json['lng']);
    }
    return null;
  }

  static Future getDarkThemeStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark') ?? false;
  }

  // CLEAR
  static Future clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static Future remove(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(value);
  }

  static Future<void> logoutRemove() async {
    AppSharedPreference.remove('token');
    AppSharedPreference.remove('login');
    AppSharedPreference.remove('landing');
    AppSharedPreference.remove('mapType');
    AppSharedPreference.remove('distanceBetween');
    AppSharedPreference.remove('isBidEnabled');
    AppSharedPreference.remove('isBubbleEnabled');
    AppSharedPreference.remove('skipSubscription');
    AppSharedPreference.remove('userType');
  }
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
