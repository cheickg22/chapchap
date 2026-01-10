import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../common/common.dart';
import '../../../../core/network/network.dart';

class HomeApi {
  Future getUserDetailsApi({String? requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      final queryParams =
          (requestId != null) ? {"current_ride": requestId} : null;

      Response response = await DioProviderImpl().get(
        ApiEndpoints.userDetails,
        queryParams: queryParams,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future onlineOfflineApi() async {
    try {
      final token = await AppSharedPreference.getToken();

      Response response = await DioProviderImpl().post(
        ApiEndpoints.onlineOffline,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future updatePricePerDistance({required String price}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
          ApiEndpoints.updatePricePerDistance,
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: {'price_per_distance': price});
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getSubVehicleTypesApi(
      {required String serviceLocationId, required String vehicleType}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.subVehiclesTypes}/$serviceLocationId',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        queryParams: {'vehicle_type': vehicleType},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getDiagnostiNotification() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.diagnosticNotification,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future updateVehicleTypesApi({required List subTypes}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updateUserDetailsButton,
        body: {
          "sub_vehicle_type": subTypes,
        },
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getPreferencesDetailsApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getPreferences,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      if (kDebugMode) {
        printWrapped("get preferences Api========>$response");
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future updatePreferences({required List id}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updatePreferences,
        body: {
          "preferences": jsonEncode(id),
        },
        headers: {'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
