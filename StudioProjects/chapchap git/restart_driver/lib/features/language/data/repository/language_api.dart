import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../../common/common.dart';
import '../../../../core/network/network.dart';

class LanguageApi {
  Future getLanguages() async {
    try {
      Response response =
          await DioProviderImpl().get(ApiEndpoints.languageList);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updateLanguage(String langCode) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateLanguage,
        headers: {'Authorization': token},
        body: jsonEncode(
          {'lang': langCode},
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
