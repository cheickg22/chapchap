import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/core/network/failure.dart';
import 'package:restart_tagxi/features/home/domain/models/add_review_model.dart';
import 'package:restart_tagxi/features/home/domain/models/address_auto_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_reason_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_request_model.dart';
import 'package:restart_tagxi/features/home/domain/models/chat_seen_model.dart';
import 'package:restart_tagxi/features/home/domain/models/geocoding_address_model.dart';
import 'package:restart_tagxi/features/home/domain/models/geocoding_lat_lng_model.dart';
import 'package:restart_tagxi/features/home/domain/models/instant_ride_model.dart';
import 'package:restart_tagxi/features/home/domain/models/payment_recieved_model.dart';
import 'package:restart_tagxi/features/home/domain/models/polyline_model.dart';
import 'package:restart_tagxi/features/home/domain/models/respond_request_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_arrived_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_chat_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_end_model.dart';
import 'package:restart_tagxi/features/home/domain/models/ride_start_model.dart';
import 'package:restart_tagxi/features/home/domain/models/send_chat_model.dart';
import 'package:restart_tagxi/features/home/domain/models/eta_details_model.dart';
import 'package:restart_tagxi/features/home/domain/models/goods_type_model.dart';
import 'package:restart_tagxi/features/home/domain/models/stop_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/upload_proof_model.dart';
import 'package:restart_tagxi/features/home/domain/repositories/ride_repo.dart';

import '../../domain/models/additional_charges_model.dart';

class RideUsecases {
  final RideRepository _rideRepository;

  const RideUsecases(this._rideRepository);

  Future<Either<Failure, RespondRequestModel>> respondRequest(
      {required String requestId, required int status}) async {
    return _rideRepository.respondRequest(requestId: requestId, status: status);
  }

  Future<Either<Failure, RideArrivedModel>> rideArrived(
      {required String requestId}) async {
    return _rideRepository.rideArrived(requestId: requestId);
  }

  Future<Either<Failure, RideStartModel>> rideStart(
      {required String requestId,
      required String otp,
      required double pickLat,
      required double pickLng}) async {
    return _rideRepository.rideStart(
        requestId: requestId, otp: otp, pickLat: pickLat, pickLng: pickLng);
  }

  Future<Either<Failure, RideEndModel>> rideEnd(
      {required String requestId,
      required double distance,
      required int beforeTripStartWaitingTime,
      required int afterTripStartWaitingTime,
      required double dropLat,
      required double dropLng,
      required String dropAddress,
      required String polyString}) async {
    return _rideRepository.rideEnd(
      requestId: requestId,
      distance: distance,
      dropLat: dropLat,
      dropLng: dropLng,
      dropAddress: dropAddress,
      beforeTripStartWaitingTime: beforeTripStartWaitingTime,
      afterTripStartWaitingTime: afterTripStartWaitingTime,
      polyString: polyString,
    );
  }

  Future<Either<Failure, PaymentRecievedModel>> paymentRecieved(
      {required String requestId}) async {
    return _rideRepository.paymentRecieved(requestId: requestId);
  }

  Future<Either<Failure, RideChatModel>> getRideChat(
      {required String requestId}) async {
    return _rideRepository.getRideChat(requestId: requestId);
  }

  Future<Either<Failure, CancelReasonModel>> getCancelReason(
      {required String requestId, required String arrived}) async {
    return _rideRepository.getCancelReason(
        requestId: requestId, arrived: arrived);
  }

  Future<Either<Failure, CancelRequestModel>> cancelRequest(
      {required String requestId,
      required String reason,
      String? choosenReason}) async {
    return _rideRepository.cancelRequest(
        requestId: requestId, reason: reason, choosenReason: choosenReason);
  }

  Future<Either<Failure, ChatSeenModel>> chatSeen(
      {required String requestId}) async {
    return _rideRepository.chatSeen(requestId: requestId);
  }

  Future<Either<Failure, SendChatModel>> sendChat(
      {required String requestId, required String message}) async {
    return _rideRepository.sendChat(requestId: requestId, message: message);
  }

  Future<Either<Failure, PolylineModel>> getPolyline(
      {required double pickLat,
      required double pickLng,
      required double dropLat,
      required double dropLng,
      required List stops,
      required String packageName,
      required String signKey,
      required String map}) async {
    return _rideRepository.getPolyline(
        pickLat: pickLat,
        pickLng: pickLng,
        dropLat: dropLat,
        dropLng: dropLng,
        stops: stops,
        packageName: packageName,
        signKey: signKey,
        map: map);
  }

  Future<Either<Failure, GeocodingLatLngModel>> getGeocodingAddress(
      {required double lat,
      required double lng,
      required String packageName,
      required String signKey}) async {
    return _rideRepository.getGeocodingAddress(
        lat: lat, lng: lng, packageName: packageName, signKey: signKey);
  }

  Future<Either<Failure, GeocodingAddressModel>> getGeocodingLatLng(
      {required String placeId,
      required String sessionToken,
      required String packageName,
      required String signKey}) async {
    return _rideRepository.getGeocodingLatLng(
        placeId: placeId,
        sessionToken: sessionToken,
        packageName: packageName,
        signKey: signKey);
  }

  Future<Either<Failure, AddressAutoCompleteModel>> getAutoCompleteAddress(
      {required String input,
      required String sessionToken,
      required String packageName,
      required String signKey,
      required String lat,
      required String lng}) async {
    return _rideRepository.getAutoCompleteAddress(
        input: input,
        lat: lat,
        lng: lng,
        sessionToken: sessionToken,
        packageName: packageName,
        signKey: signKey);
  }

  Future<Either<Failure, AddReviewModel>> addReview(
      {required String requestId,
      required int rating,
      required String comment}) async {
    return _rideRepository.addReview(
        requestId: requestId, rating: rating, comment: comment);
  }

  Future<Either<Failure, EtaDetailsModel>> etaRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String distance,
      required String duration}) async {
    return _rideRepository.etaRequest(
        pickLat: pickLat,
        pickLng: pickLng,
        dropLat: dropLat,
        dropLng: dropLng,
        rideType: rideType,
        distance: distance,
        duration: duration);
  }

  Future<Either<Failure, GoodsTypeModel>> getGoodsType() async {
    return _rideRepository.getGoodsType();
  }

  Future<Either<Failure, StopCompleteModel>> stopComplete(
      {required String id}) async {
    return _rideRepository.stopComplete(id: id);
  }

  Future<Either<Failure, UploadProofModel>> uploadProof({
    required String proofImage,
    required bool isBefore,
    required String id,
  }) async {
    return _rideRepository.uploadProof(
        proofImage: proofImage, isBefore: isBefore, id: id);
  }

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
    return _rideRepository.createInstantRequest(
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
        goodsTypeId: goodsTypeId,
        distance: distance,
        duration: duration,
        goodsTypeQuantity: goodsTypeQuantity);
  }

  Future<Either<Failure, AdditionalCharges>> additionalChargeApi(
      {required String requestId,
      required String reason,
      required String price}) async {
    return _rideRepository.additionalChargeApi(
        requestId: requestId, reason: reason, price: price);
  }

  Future<Either<Failure, dynamic>> stopOtpVerify(
      {required String stopId, String? requestId, required String otp}) async {
    return _rideRepository.stopOtpVerify(
        stopId: stopId, requestId: requestId, otp: otp);
  }
}
