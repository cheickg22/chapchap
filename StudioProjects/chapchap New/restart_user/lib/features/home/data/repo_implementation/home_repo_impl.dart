import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../common/common.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../../account/domain/models/history_model.dart';
import '../../domain/models/recent_routes_model.dart';
import '../../domain/models/ride_modules_model.dart';
import '../../domain/models/stop_address_model.dart';
import '../../domain/models/user_details_model.dart';
import '../../domain/repositories/home_repo.dart';
import '../repository/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApi _homeApi;

  HomeRepositoryImpl(this._homeApi);

  // UserDetailData
  @override
  Future<Either<Failure, UserDetailResponseModel>> getUserDetails(
      {String? requestId}) async {
    UserDetailResponseModel userDetailsResponseModel;
    try {
      Response response =
          await _homeApi.getUserDetailsApi(requestId: requestId);
      printWrapped('Get User Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else if (response.statusCode == 401) {
          return Left(GetDataFailure(message: 'logout'));
        } else if (response.statusCode == 429) {
          return Left(GetDataFailure(message: 'Too many attempts'));
        } else {
          userDetailsResponseModel =
              UserDetailResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(userDetailsResponseModel);
  }

  @override
  Future<Either<Failure, dynamic>> getAutoCompletePlaces({
    required String input,
    required String mapType,
    required String? countryCode,
    required String enbleContryRestrictMap,
    required LatLng currentLatLng,
  }) async {
    List<dynamic> placesResponse = [];
    try {
      final response = await _homeApi.getAutocompletePlaces(
          countryCode: countryCode,
          enbleContryRestrictMap: enbleContryRestrictMap,
          input: input,
          mapType: mapType,
          currentLatLng: currentLatLng);
      printWrapped('Places Response : $response');
      if (response.data.toString() != '{}') {
        if (mapType == 'google_map') {
          for (var element in response.data["suggestions"]) {
            placesResponse.add({
              'place_id': element['placePrediction']['placeId'],
              'description': element['placePrediction']['text']['text'],
              'lat': '',
              'lon': '',
              'display_name': element['placePrediction']['structuredFormat']
                  ['mainText']['text'],
            });
          }
        } else {
          // for (var element in response.data) {
          //   placesResponse.add(element);
          // }
          if (response.data != null && response.data is List) {
            for (var element in response.data) {
              placesResponse.add({
                'place_id': element['osm_id'].toString(),
                'description': element['display_name'],
                'lat': element['lat'],
                'lon': element['lon'],
                'display_name': element['display_name'],
              });
            }
          }
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(placesResponse);
  }

  @override
  Future<Either<Failure, dynamic>> getAutoCompletePlaceLatLng(
      {required String placeId}) async {
    LatLng placesResponse;
    try {
      final response =
          await _homeApi.getAutocompletePlaceLatLng(placeId: placeId);
      printWrapped('Place LatLng Response : $response');
      placesResponse = response;
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(placesResponse);
  }

  @override
  Future<Either<Failure, dynamic>> getAddressFromLatLng({
    required double lat,
    required double lng,
    required String mapType,
  }) async {
    String placesResponse = '';
    try {
      final response = await _homeApi.getAddressFromLatLng(
          lat: lat, lng: lng, mapType: mapType);

      if (mapType == 'google_map') {
        if (response.data.toString() != '{}' &&
            response.data['results'] != null &&
            response.data['results'].isNotEmpty) {
          for (var i = 0; i < response.data['results'].length; i++) {
            if (response.data['results'][i]['address_components'][0]['types']
                    [0] !=
                'plus_code') {
              placesResponse = response.data['results'][i]['formatted_address'];
              break;
            }
          }
        }
      } else {
        // OSM response mapping
        if (response.data != null && response.data['display_name'] != null) {
          placesResponse = response.data['display_name'];
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(placesResponse);
  }

  @override
  Future<Either<Failure, HistoryResponseModel>> getOnGoingRides(
      {required String historyFilter}) async {
    HistoryResponseModel onGoingRidesResponse;
    try {
      Response response =
          await _homeApi.getOnGoingRidesApi(historyFilter: historyFilter);
      // printWrapped('Get User Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else if (response.statusCode == 401) {
          return Left(GetDataFailure(message: 'logout'));
        } else {
          onGoingRidesResponse = HistoryResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(onGoingRidesResponse);
  }

  @override
  Future<Either<Failure, RecentRoutesModel>> getRecentRoutes() async {
    RecentRoutesModel recentRoutes;
    try {
      Response response = await _homeApi.getRecentRoutesApi();
      printWrapped('Recent Routes Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else if (response.statusCode == 401) {
          return Left(GetDataFailure(message: 'logout'));
        } else if (response.statusCode == 429) {
          return Left(GetDataFailure(message: 'Too many attempts'));
        } else {
          recentRoutes = RecentRoutesModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(recentRoutes);
  }

  @override
  Future<Either<Failure, dynamic>> serviceLocationVerify({
    required String rideType,
    required List<AddressModel> address,
  }) async {
    dynamic res;
    try {
      Response response = await _homeApi.serviceLocationVerifyApi(
          rideType: rideType, address: address);
      printWrapped('Service Available Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(message: response.data["message"]));
        } else if (response.statusCode == 401) {
          return Left(GetDataFailure(message: 'logout'));
        } else if (response.statusCode == 429) {
          return Left(GetDataFailure(message: 'Too many attempts'));
        } else {
          res = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(res);
  }

  @override
  Future<Either<Failure, RideModulesModel>> rideModules() async {
    RideModulesModel res;
    try {
      Response response = await _homeApi.rideModulesApi();
      printWrapped('Ride Modules Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode == 400 || response.statusCode == 401) {
          return Left(GetDataFailure(message: 'logout'));
        } else if (response.statusCode == 429) {
          return Left(GetDataFailure(message: 'Too many attempts'));
        } else if (response.statusCode != 200) {
          return Left(GetDataFailure(message: response.data['message']));
        } else {
          res = RideModulesModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(res);
  }
}
