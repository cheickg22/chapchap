import 'package:dartz/dartz.dart';
import 'package:restart_tagxi/features/home/domain/models/add_review_model.dart';
// import 'package:restart_tagxi/features/home/domain/models/additional_charges_model.dart';
import 'package:restart_tagxi/features/home/domain/models/address_auto_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_reason_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_request_model.dart';
import 'package:restart_tagxi/features/home/domain/models/chat_seen_model.dart';
import 'package:restart_tagxi/features/home/domain/models/eta_details_model.dart';
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
import 'package:restart_tagxi/features/home/domain/models/goods_type_model.dart';
import 'package:restart_tagxi/features/home/domain/models/send_chat_model.dart';
import 'package:restart_tagxi/features/home/domain/models/stop_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/upload_proof_model.dart';

import '../../../../core/network/network.dart';
import '../models/additional_charges_model.dart';

abstract class RideRepository {
  Future<Either<Failure, RespondRequestModel>> respondRequest(
      {required String requestId, required int status});

  Future<Either<Failure, RideArrivedModel>> rideArrived(
      {required String requestId});

  Future<Either<Failure, PolylineModel>> getPolyline(
      {required double pickLat,
      required double pickLng,
      required double dropLat,
      required double dropLng,
      required List stops,
      required String packageName,
      required String signKey,
      required String map});

  Future<Either<Failure, GeocodingLatLngModel>> getGeocodingAddress(
      {required double lat,
      required double lng,
      required String packageName,
      required String signKey});

  Future<Either<Failure, GeocodingAddressModel>> getGeocodingLatLng(
      {required String placeId,
      required String sessionToken,
      required String packageName,
      required String signKey});

  Future<Either<Failure, AddressAutoCompleteModel>> getAutoCompleteAddress(
      {required String input,
      required String sessionToken,
      required String packageName,
      required String signKey,
      required String lat,
      required String lng});

  Future<Either<Failure, RideStartModel>> rideStart(
      {required String requestId,
      required String otp,
      required double pickLat,
      required double pickLng});

  Future<Either<Failure, RideEndModel>> rideEnd({
    required String requestId,
    required double distance,
    required int beforeTripStartWaitingTime,
    required int afterTripStartWaitingTime,
    required double dropLat,
    required double dropLng,
    required String dropAddress,
    required String polyString,
  });

  Future<Either<Failure, PaymentRecievedModel>> paymentRecieved(
      {required String requestId});

  Future<Either<Failure, RideChatModel>> getRideChat(
      {required String requestId});

  Future<Either<Failure, CancelReasonModel>> getCancelReason(
      {required String requestId, required String arrived});

  Future<Either<Failure, CancelRequestModel>> cancelRequest(
      {required String requestId,
      required String reason,
      String? choosenReason});

  Future<Either<Failure, SendChatModel>> sendChat(
      {required String requestId, required String message});

  Future<Either<Failure, ChatSeenModel>> chatSeen({required String requestId});

  Future<Either<Failure, AddReviewModel>> addReview(
      {required String requestId,
      required int rating,
      required String comment});

  Future<Either<Failure, EtaDetailsModel>> etaRequest(
      {required String pickLat,
      required String pickLng,
      required String dropLat,
      required String dropLng,
      required String rideType,
      required String distance,
      required String duration});

  Future<Either<Failure, GoodsTypeModel>> getGoodsType();

  Future<Either<Failure, UploadProofModel>> uploadProof(
      {required String proofImage, required bool isBefore, required String id});

  Future<Either<Failure, StopCompleteModel>> stopComplete({required String id});

  Future<Either<Failure, AdditionalCharges>> additionalChargeApi(
      {required String requestId,
      required String reason,
      required String price});

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
      String? goodsTypeQuantity});

  Future<Either<Failure, dynamic>> stopOtpVerify(
      {required String stopId, String? requestId, required String otp});
}
