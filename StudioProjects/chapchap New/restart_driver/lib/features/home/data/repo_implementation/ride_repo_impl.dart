import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/features/home/data/repository/ride_api.dart';
import 'package:restart_tagxi/features/home/domain/models/add_review_model.dart';
import 'package:restart_tagxi/features/home/domain/models/address_auto_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_reason_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_request_model.dart';
import 'package:restart_tagxi/features/home/domain/models/chat_seen_model.dart';
import 'package:restart_tagxi/features/home/domain/models/eta_details_model.dart';
import 'package:restart_tagxi/features/home/domain/models/geocoding_address_model.dart';
import 'package:restart_tagxi/features/home/domain/models/geocoding_lat_lng_model.dart';
import 'package:restart_tagxi/features/home/domain/models/payment_recieved_model.dart';
import 'package:restart_tagxi/features/home/domain/models/polyline_model.dart';
import 'package:restart_tagxi/features/home/domain/models/respond_request_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_arrived_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_chat_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_end_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_start_model.dart';
import 'package:restart_tagxi/features/home/domain/models/send_chat_model.dart';
import 'package:restart_tagxi/features/home/domain/models/instant_ride_model.dart';
import 'package:restart_tagxi/features/home/domain/models/goods_type_model.dart';
import 'package:restart_tagxi/features/home/domain/models/stop_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/upload_proof_model.dart';
import 'package:restart_tagxi/features/home/domain/repositories/ride_repo.dart';

import '../../../../common/common.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../domain/models/additional_charges_model.dart';

class RideRepositoryImpl implements RideRepository {
  final RideApi _rideApi;

  RideRepositoryImpl(this._rideApi);
  // UserDetailData
  @override
  Future<Either<Failure, RespondRequestModel>> respondRequest(
      {required String requestId, required int status}) async {
    RespondRequestModel respondRequestModel;
    try {
      Response response =
          await _rideApi.respondRequest(requestId: requestId, status: status);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          respondRequestModel = RespondRequestModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(respondRequestModel);
  }

  @override
  Future<Either<Failure, RideArrivedModel>> rideArrived(
      {required String requestId}) async {
    RideArrivedModel rideArrivedModel;
    try {
      Response response = await _rideApi.rideArrived(requestId: requestId);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          rideArrivedModel = RideArrivedModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(rideArrivedModel);
  }

  @override
  Future<Either<Failure, RideStartModel>> rideStart(
      {required String requestId,
      required String otp,
      required double pickLat,
      required double pickLng}) async {
    RideStartModel rideStartModel;
    try {
      Response response = await _rideApi.rideStart(
          requestId: requestId, otp: otp, pickLat: pickLat, pickLng: pickLng);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          rideStartModel = RideStartModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(rideStartModel);
  }

  @override
  Future<Either<Failure, RideEndModel>> rideEnd(
      {required String requestId,
      required double distance,
      required int beforeTripStartWaitingTime,
      required int afterTripStartWaitingTime,
      required double dropLat,
      required double dropLng,
      required String dropAddress,
      required String polyString}) async {
    RideEndModel rideEndModel;
    try {
      Response response = await _rideApi.rideEnd(
        requestId: requestId,
        distance: distance,
        dropLat: dropLat,
        dropLng: dropLng,
        beforeTripStartWaitingTime: beforeTripStartWaitingTime,
        afterTripStartWaitingTime: afterTripStartWaitingTime,
        dropAddress: dropAddress,
        polyString: polyString,
      );
      printWrapped(
          'Ride End Response : ${response.data}=======================');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          rideEndModel = RideEndModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(rideEndModel);
  }

  @override
  Future<Either<Failure, PolylineModel>> getPolyline(
      {required double pickLat,
      required double pickLng,
      required double dropLat,
      required double dropLng,
      required List stops,
      required String packageName,
      required String signKey,
      required String map}) async {
    PolylineModel polylineModel;
    try {
      Response response = await _rideApi.getPolyline(
          pickLat: pickLat,
          dropLat: dropLat,
          pickLng: pickLng,
          dropLng: dropLng,
          stops: stops,
          packageName: packageName,
          signKey: signKey,
          map: map);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          if (map != 'google_map') {
            final List<dynamic> routes = response.data['routes'];
            dynamic etaDistance = 0;
            dynamic etaDuration = 0;
            if (mapType != 'google_map') {
              for (var i = 0; i < routes[0]["legs"].length; i++) {
                etaDistance = etaDistance + (routes[0]["legs"][i]['distance']);
                etaDuration = etaDuration + (routes[0]["legs"][i]['duration']);
              }
            }
            polylineModel = PolylineModel.fromJson({
              'success': true,
              'polyString': routes[0]['geometry'],
              'distance': etaDistance.toString(),
              'duration': (etaDuration / 60).roundToDouble().toString(),
              'polyList': [],
            });
          } else {
            String duration = response.data['routes'][0]['duration']
                .toString()
                .replaceAll('s', '');
            polylineModel = PolylineModel.fromJson({
              'success': true,
              'polyString': response.data['routes'][0]['polyline']
                  ['encodedPolyline'],
              'distance':
                  (response.data['routes'][0]['distanceMeters']).toString(),
              'duration': (double.parse(duration) / 60).toString(),
              'polyList': [],
            });
          }
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(polylineModel);
  }

  /// ✅ SAFE ERROR MESSAGE EXTRACTOR (Google + OSM)
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';

    // OSM sometimes returns plain text
    if (data is String) {
      return data;
    }

    // Normal JSON error
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? 'Something went wrong';
    }

    return 'Something went wrong';
  }

  @override
  Future<Either<Failure, GeocodingLatLngModel>> getGeocodingAddress({
    required double lat,
    required double lng,
    required String packageName,
    required String signKey,
  }) async {
    GeocodingLatLngModel geocodingLatLngModel =
        GeocodingLatLngModel.fromJson({'success': true, 'address': ''});

    try {
      final Response response = await _rideApi.getGeocodingAddress(
        lat: lat,
        lng: lng,
        packageName: packageName,
        signKey: signKey,
      );

      printWrapped('Response : ${response.data}');

      ///  NULL OR EMPTY RESPONSE
      if (response.data == null || response.data.toString().isEmpty) {
        return Left(GetDataFailure(message: 'Bad request'));
      }

      ///  UNAUTHORIZED
      if (response.statusCode == 401) {
        return Left(
          GetDataFailure(
            message: 'logout',
            statusCode: response.statusCode,
          ),
        );
      }

      ///  NON-200 STATUS
      if (response.statusCode != 200) {
        return Left(
          GetDataFailure(
            message: _extractErrorMessage(response.data),
            statusCode: response.statusCode,
          ),
        );
      }

      ///  GOOGLE MAP FLOW
      if (mapType == 'google_map') {
        if (response.data is Map<String, dynamic>) {
          /// Google error response
          if (response.data['error'] != null) {
            return Left(
              GetDataFailure(message: response.data['error'].toString()),
            );
          }

          final List<dynamic>? results =
              response.data['results'] as List<dynamic>?;

          if (results != null && results.isNotEmpty) {
            for (final item in results) {
              final List<dynamic>? components =
                  item['address_components'] as List<dynamic>?;

              if (components != null &&
                  components.isNotEmpty &&
                  components.first['types'] != null &&
                  components.first['types'][0] != 'plus_code') {
                geocodingLatLngModel = GeocodingLatLngModel.fromJson({
                  'success': true,
                  'address': item['formatted_address'] ?? '',
                });
                break;
              }
            }
          }
        }
      }

      ///  OPENSTREET MAP FLOW
      else {
        if (response.data is Map<String, dynamic>) {
          geocodingLatLngModel = GeocodingLatLngModel.fromJson({
            'success': true,
            'address': response.data['display_name'] ?? '',
          });
        } else if (response.data is String) {
          /// OSM sometimes returns plain text errors
          return Left(
            GetDataFailure(message: response.data),
          );
        }
      }

      return Right(geocodingLatLngModel);
    }

    ///  NETWORK ERROR
    on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    }

    ///  BAD INPUT
    on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    ///  UNKNOWN ERROR
    catch (e) {
      return Left(GetDataFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GeocodingAddressModel>> getGeocodingLatLng(
      {required String placeId,
      required String sessionToken,
      required String packageName,
      required String signKey}) async {
    GeocodingAddressModel geocodingAddressModel;
    try {
      final response = await _rideApi.getGeocodingLatLng(
          placeId: placeId,
          sessionToken: sessionToken,
          packageName: packageName,
          signKey: signKey);
      printWrapped('Place LatLng Response : $response');
      geocodingAddressModel = GeocodingAddressModel.fromJson({
        'success': true,
        'position': LatLng(response.data['location']['latitude'],
            response.data['location']['longitude'])
      });
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(geocodingAddressModel);
  }

  @override
  Future<Either<Failure, AddressAutoCompleteModel>> getAutoCompleteAddress(
      {required String input,
      required String sessionToken,
      required String packageName,
      required String signKey,
      required String lat,
      required String lng}) async {
    AddressAutoCompleteModel addressAutoCompleteModel;
    try {
      final response = await _rideApi.getAutoCompleteAddress(
          input: input,
          sessionToken: sessionToken,
          packageName: packageName,
          signKey: signKey,
          lat: lat,
          lng: lng);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (mapType == 'google_map' && response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          List addAutoFill = [];
          if (response.data.toString() != '{}') {
            if (mapType == 'google_map') {
              for (var element in response.data["suggestions"]) {
                addAutoFill.add({
                  'place_id': element['placePrediction']['placeId'],
                  'description': element['placePrediction']['text']['text'],
                  'lat': '',
                  'lon': '',
                  'display_name': element['placePrediction']['structuredFormat']
                      ['mainText']['text'],
                });
              }
            } else {
              for (var element in response.data) {
                addAutoFill.add({
                  'place_id': '${element['place_id']}',
                  'description': element['display_name'],
                  'lat': element['lat'],
                  'lon': element['lon'],
                  'display_name': element['display_name'],
                });
              }
            }
          }
          addressAutoCompleteModel = AddressAutoCompleteModel.fromJson(
              {'success': true, 'address': addAutoFill});
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(addressAutoCompleteModel);
  }

  @override
  Future<Either<Failure, PaymentRecievedModel>> paymentRecieved(
      {required String requestId}) async {
    PaymentRecievedModel paymentRecievedModel;
    try {
      Response response = await _rideApi.paymentRecieved(requestId: requestId);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          paymentRecievedModel =
              PaymentRecievedModel.fromJson({'success': true});
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(paymentRecievedModel);
  }

  @override
  Future<Either<Failure, RideChatModel>> getRideChat(
      {required String requestId}) async {
    RideChatModel rideChatModel;
    try {
      Response response = await _rideApi.getChatData(requestId: requestId);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          rideChatModel = RideChatModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(rideChatModel);
  }

  @override
  Future<Either<Failure, CancelReasonModel>> getCancelReason(
      {required String requestId, required String arrived}) async {
    CancelReasonModel cancelReasonModel;
    try {
      Response response = await _rideApi.getCancelReason(
          arrived: arrived, requestId: requestId);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          cancelReasonModel = CancelReasonModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(cancelReasonModel);
  }

  @override
  Future<Either<Failure, CancelRequestModel>> cancelRequest(
      {required String requestId,
      required String reason,
      String? choosenReason}) async {
    CancelRequestModel cancelRequestModel;
    try {
      Response response = await _rideApi.cancelRequest(
          requestId: requestId, reason: reason, choosenReason: choosenReason);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          cancelRequestModel = CancelRequestModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(cancelRequestModel);
  }

  @override
  Future<Either<Failure, ChatSeenModel>> chatSeen(
      {required String requestId}) async {
    ChatSeenModel chatSeenModel;
    try {
      Response response = await _rideApi.chatSeen(requestId: requestId);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          chatSeenModel = ChatSeenModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(chatSeenModel);
  }

  @override
  Future<Either<Failure, SendChatModel>> sendChat(
      {required String requestId, required String message}) async {
    SendChatModel sendChatModel;
    try {
      Response response =
          await _rideApi.sendChat(requestId: requestId, message: message);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          sendChatModel = SendChatModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(sendChatModel);
  }

  @override
  Future<Either<Failure, AddReviewModel>> addReview(
      {required String requestId,
      required int rating,
      required String comment}) async {
    printWrapped('$requestId $rating $comment');
    AddReviewModel addReviewModel;
    try {
      Response response = await _rideApi.addReview(
          requestId: requestId, rating: rating, comment: comment);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          addReviewModel = AddReviewModel.fromJson({'success': true});
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(addReviewModel);
  }

  @override
  Future<Either<Failure, EtaDetailsModel>> etaRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String distance,
      required String duration}) async {
    EtaDetailsModel etaDetailsModel;
    try {
      Response response = await _rideApi.etaRequest(
          pickLat: pickLat,
          pickLng: pickLng,
          dropLat: dropLat,
          dropLng: dropLng,
          rideType: rideType,
          distance: distance,
          duration: duration);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          etaDetailsModel = EtaDetailsModel.fromJson({
            'success': true,
            'price': '${response.data['data']['total']}',
            'currency': response.data['data']['currency']
          });
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(etaDetailsModel);
  }

  @override
  Future<Either<Failure, StopCompleteModel>> stopComplete({
    required String id,
  }) async {
    StopCompleteModel stopCompleteModel;
    try {
      Response response = await _rideApi.stopComplete(id: id);
      printWrapped('Response : ${response.data} $id');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          stopCompleteModel = StopCompleteModel.fromJson({
            'success': true,
          });
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(stopCompleteModel);
  }

  @override
  Future<Either<Failure, UploadProofModel>> uploadProof({
    required String proofImage,
    required bool isBefore,
    required String id,
  }) async {
    UploadProofModel uploadProofModel;
    try {
      Response response = await _rideApi.uploadProof(
          proofImage: proofImage, isBefore: isBefore, id: id);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          uploadProofModel = UploadProofModel.fromJson({
            'success': true,
          });
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(uploadProofModel);
  }

  @override
  Future<Either<Failure, InstantRideModel>> createInstantRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String pickAddress,
      required String dropAddress,
      required String name,
      required String mobile,
      required String price,
      required String distance,
      required String duration,
      String? goodsTypeId,
      String? goodsTypeQuantity}) async {
    InstantRideModel instantRideModel;
    try {
      Response response = await _rideApi.createInstantRequest(
          pickLat: pickLat,
          pickLng: pickLng,
          dropLat: dropLat,
          dropLng: dropLng,
          rideType: rideType,
          pickAddress: pickAddress,
          dropAddress: dropAddress,
          name: name,
          mobile: mobile,
          price: price,
          distance: distance,
          duration: duration,
          goodsTypeId: goodsTypeId,
          goodsTypeQuantity: goodsTypeQuantity);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          instantRideModel = InstantRideModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(instantRideModel);
  }

  @override
  Future<Either<Failure, GoodsTypeModel>> getGoodsType() async {
    GoodsTypeModel goodsTypeModel;
    try {
      Response response = await _rideApi.getGoodsType();
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else if (response.statusCode == 401) {
        return Left(
            GetDataFailure(message: 'logout', statusCode: response.statusCode));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          goodsTypeModel = GoodsTypeModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(goodsTypeModel);
  }

  @override
  Future<Either<Failure, AdditionalCharges>> additionalChargeApi(
      {required String requestId,
      required String reason,
      required String price}) async {
    AdditionalCharges additionalCharges;
    try {
      Response response = await _rideApi.additionalChargeApi(
          requestId: requestId, reason: reason, price: price);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          additionalCharges = AdditionalCharges.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(additionalCharges);
  }

  @override
  Future<Either<Failure, dynamic>> stopOtpVerify(
      {required String stopId, String? requestId, required String otp}) async {
    dynamic result;
    try {
      Response response = await _rideApi.stopOtpVerify(
          stopId: stopId, requestId: requestId, otp: otp);
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          result = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(result);
  }
}
