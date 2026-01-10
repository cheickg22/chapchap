// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_tagxi/common/app_constants.dart';

import '../../../../common/common.dart';
import '../../../../core/network/network.dart';

class RideApi {
  Future respondRequest(
      {required String requestId, required int status}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.respondRequest,
        body: {'request_id': requestId, 'is_accept': status},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future rideArrived({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.rideArrived,
        body: {
          'request_id': requestId,
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future rideStart(
      {required String requestId,
      required String otp,
      required double pickLat,
      required double pickLng}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.rideStart,
        body: {
          'request_id': requestId,
          if (otp != '') 'ride_otp': otp,
          'pick_lat': pickLat,
          'pick_lng': pickLng
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future rideEnd(
      {required String requestId,
      required double distance,
      required int beforeTripStartWaitingTime,
      required int afterTripStartWaitingTime,
      required double dropLat,
      required double dropLng,
      required String dropAddress,
      required String polyString}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.rideEnd,
        body: {
          'request_id': requestId,
          'distance': distance,
          'poly_line': polyString,
          'before_trip_start_waiting_time': beforeTripStartWaitingTime,
          'after_trip_start_waiting_time': afterTripStartWaitingTime,
          'drop_lat': dropLat,
          'drop_lng': dropLng,
          'drop_address': dropAddress,
          'after_arrival_waiting_time': 0,
          'before_arrival_waiting_time': 0
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getPolyline(
      {required double pickLat,
      required double pickLng,
      required double dropLat,
      required double dropLng,
      required List stops,
      required String packageName,
      required String signKey,
      required String map}) async {
    try {
      List intermediates = [];

      // Construct waypoints if any
      if (map != 'google_map') {
        String wayPoints = '';
        String url = '';
        if (stops.isNotEmpty) {
          for (var stop in stops) {
            wayPoints +=
                '${stop["longitude"]},${stop["latitude"]};'; // OSRM requires "lng,lat"
          }
          // Remove the last semicolon
          wayPoints = wayPoints.substring(0, wayPoints.length - 1);
        }

        // Construct the API request URL
        if (wayPoints.isNotEmpty) {
          url = 'https://routing.openstreetmap.de/routed-car/route/v1/driving/'
              '$pickLng,$pickLat;$wayPoints?overview=full';
        } else {
          url = 'https://routing.openstreetmap.de/routed-car/route/v1/driving/'
              '$pickLng,$pickLat;$dropLng,$dropLat?overview=full';
        }

        // Make the HTTP request
        Response response = await DioProviderImpl().getUri(Uri.parse(url));
        return response;
      } else {
        if (stops.isNotEmpty) {
          for (var stop in stops) {
            intermediates.add({
              "location": {
                "latLng": {
                  "latitude": stop['latitude'],
                  "longitude": stop['longitude']
                }
              }
            });
          }
        }
        Response response = await DioProviderImpl().post(
          ApiEndpoints.getPolyline,
          body: {
            "origin": {
              "location": {
                "latLng": {"latitude": pickLat, "longitude": pickLng}
              }
            },
            "destination": {
              "location": {
                "latLng": {"latitude": dropLat, "longitude": dropLng}
              }
            },
            "intermediates": intermediates,
            "travelMode": "DRIVE",
            "routingPreference": "TRAFFIC_AWARE",
            "computeAlternativeRoutes": false,
            "routeModifiers": {
              "avoidTolls": false,
              "avoidHighways": false,
              "avoidFerries": false
            },
            "languageCode": "en-US",
            "units": "IMPERIAL"
          },
          headers: {
            'X-Goog-Api-Key': AppConstants.mapKey,
            'Content-Type': 'application/json',
            'X-Goog-FieldMask':
                'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs',
            if (Platform.isAndroid) 'X-Android-Package': packageName,
            if (Platform.isAndroid) 'X-Android-Cert': signKey,
            if (Platform.isIOS) 'X-IOS-Bundle-Identifier': packageName,
          },
        );
        return response;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getChatData({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.getRideChats}/$requestId',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future chatSeen({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.chatsSeen,
        body: {'request_id': requestId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future sendChat({required String requestId, required String message}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.sendChat,
        body: {'request_id': requestId, 'message': message},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getCancelReason(
      {required String requestId, required String arrived}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        '${ApiEndpoints.cancelReason}?arrived=$arrived&request_id=$requestId',
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future stopComplete({required String id}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.stopComplete,
        body: {
          'stop_id': id,
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future cancelRequest(
      {required String requestId,
      required String reason,
      String? choosenReason}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.cancelRequest,
        body: {
          'request_id': requestId,
          if (reason != '' && choosenReason == '') 'custom_reason': reason,
          if (reason == '' && choosenReason != '') 'reason': choosenReason
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getGeocodingAddress({
    required double lat,
    required double lng,
    required String packageName,
    required String signKey,
  }) async {
    try {
      final isGoogle = mapType == 'google_map';

      final response = await DioProviderImpl().get(
        isGoogle
            ? ApiEndpoints.getAddressFromLatLng
                .replaceAll('addlat', '$lat')
                .replaceAll('addlng', '$lng')
                .replaceAll('mapkey', AppConstants.mapKey)
            : ApiEndpoints.getAddressFromLatLngOpenstreet
                    .replaceAll('addlat', '$lat')
                    .replaceAll('addlng', '$lng') +
                '&format=json&addressdetails=1',
        headers: isGoogle
            ? (Platform.isAndroid
                ? {
                    'X-Android-Package': packageName,
                    'X-Android-Cert': signKey,
                  }
                : {
                    'X-IOS-Bundle-Identifier': packageName,
                  })
            : {
                /// ✅ MINIMUM REQUIRED
                'User-Agent': 'RestartTagxi-App',
                'Accept': 'application/json',
              },
      );

      printWrapped("OSM RESPONSE ---> ${response.data}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getGeocodingLatLng(
      {required String placeId,
      required String sessionToken,
      required String packageName,
      required String signKey}) async {
    try {
      PackageInfo buildKeys = await PackageInfo.fromPlatform();
      String signKey = buildKeys.buildSignature;
      String packageName = buildKeys.packageName;
      // dynamic latLng;
      Response response = await DioProviderImpl().get(
        'https://places.googleapis.com/v1/places/$placeId?fields=id,displayName,location&key=${AppConstants.mapKey}',
        headers: (Platform.isAndroid)
            ? {'X-Android-Package': packageName, 'X-Android-Cert': signKey}
            : {'X-IOS-Bundle-Identifier': packageName},
      );

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getAutoCompleteAddress(
      {required String input,
      required String sessionToken,
      required String packageName,
      required String signKey,
      required String lat,
      required String lng}) async {
    try {
      if (mapType == 'google_map') {
        var requestBody = {
          "input": input,
          "locationBias": {
            "circle": {
              "center": {"latitude": lat, "longitude": lng},
              "radius": 10000,
            }
          },
          // "sessionToken": sessionToken
        };
        Response response = await DioProviderImpl().post(
          'https://places.googleapis.com/v1/places:autocomplete',
          body: jsonEncode(requestBody),
          headers: {
            'X-Goog-Api-Key': AppConstants.mapKey,
            'Content-Type': 'application/json',
            if (Platform.isAndroid) 'X-Android-Package': packageName,
            if (Platform.isAndroid) 'X-Android-Cert': signKey,
            if (Platform.isIOS) 'X-IOS-Bundle-Identifier': packageName,
          },
        );
        return response;
      } else {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?'
            'q=$input&'
            'lat=$lat&'
            'lon=$lng&'
            'format=json&'
            'addressdetails=1&'
            'limit=10' // Adjust the limit as needed
            );
        Response result = await DioProviderImpl().getUri(url);
        return result;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future paymentRecieved({required String requestId}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.paymentRecieved,
        body: {'request_id': requestId},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future addReview(
      {required String requestId,
      required int rating,
      required String comment}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.addReview,
        body: {'request_id': requestId, 'rating': rating, 'comment': comment},
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future etaRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String distance,
      required String duration}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.etaDetails,
        body: {
          'pick_lat': pickLat,
          'pick_lng': pickLng,
          'drop_lat': dropLat,
          'drop_lng': dropLng,
          'ride_type': 1,
          'distance': distance,
          'duration': duration
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future createInstantRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String pickAddress,
      required String dropAddress,
      required String name,
      required String mobile,
      required String distance,
      required String duration,
      required String price,
      String? goodsTypeId,
      String? goodsTypeQuantity}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        (goodsTypeId == null)
            ? ApiEndpoints.createInstantRide
            : ApiEndpoints.createDeliverInstantRide,
        body: {
          'pick_lat': pickLat,
          'pick_lng': pickLng,
          'drop_lat': dropLat,
          'drop_lng': dropLng,
          'ride_type': 1,
          'pick_address': pickAddress,
          'drop_address': dropAddress,
          'name': name,
          'mobile': mobile,
          'distance': distance,
          'duration': duration,
          'request_eta_amount': price,
          if (goodsTypeId != null) 'goods_type_id': goodsTypeId,
          if (goodsTypeQuantity != null)
            'goods_type_quantity': goodsTypeQuantity
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future uploadProof(
      {required String proofImage,
      required bool isBefore,
      required String id}) async {
    try {
      final token = await AppSharedPreference.getToken();
      final formData = FormData.fromMap({
        if (isBefore) 'before_load': '1',
        if (isBefore == false) 'after_load': '1',
        'request_id': id
      });
      if (proofImage.isNotEmpty) {
        formData.files.add(
            MapEntry('proof_image', await MultipartFile.fromFile(proofImage)));
      }
      Response response = await DioProviderImpl().post(
        ApiEndpoints.uploadProof,
        body: formData,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future getGoodsType() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.getGoods,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future additionalChargeApi(
      {required String requestId,
      required String reason,
      required String price}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.additionalCharge,
        body: {
          'request_id': requestId,
          'additional_charges_reason': reason,
          "additional_charges_amount": price
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      printWrapped("Additional Charges ${response.data}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future stopOtpVerify(
      {required String stopId, String? requestId, required String otp}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.stopOtpVerify,
        body: {
          if (stopId.isNotEmpty) 'stop_id': stopId,
          if (requestId != null && requestId.isNotEmpty)
            'request_id': requestId,
          if (otp != '') 'ride_otp': otp,
        },
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
