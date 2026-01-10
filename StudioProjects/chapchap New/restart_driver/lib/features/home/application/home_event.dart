part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetDirectionEvent extends HomeEvent {
  dynamic vsync;
  GetDirectionEvent({required this.vsync});
}

class GetUserDetailsEvent extends HomeEvent {
  final int? loading;
  final bool? isRideEnd;
  GetUserDetailsEvent({this.loading, this.isRideEnd});
}

class ShowCarMenuEvent extends HomeEvent {}

class ChooseCarMenuEvent extends HomeEvent {
  final int menu;
  ChooseCarMenuEvent({required this.menu});
}

class UpdatePricePerDistanceEvent extends HomeEvent {
  final String price;
  UpdatePricePerDistanceEvent({required this.price});
}

class EnableBubbleEvent extends HomeEvent {
  final bool isEnabled;
  EnableBubbleEvent({required this.isEnabled});
}

class StreamRequestEvent extends HomeEvent {}

class UploadProofEvent extends HomeEvent {
  final String image;
  final bool isBefore;
  final String id;
  UploadProofEvent(
      {required this.image, required this.isBefore, required this.id});
}

class ShowGetDropAddressEvent extends HomeEvent {}

class GetGoodsTypeEvent extends HomeEvent {}

class ShowBidRideEvent extends HomeEvent {
  final String id;
  final double pickLat;
  final double pickLng;
  final double dropLat;
  final double dropLng;
  final List stops;
  final String pickAddress;
  final String dropAddress;
  final String acceptedRideFare;
  final String polyString;
  final String distance;
  final String duration;
  final bool isOutstationRide;
  final bool isNormalBidRide;
  ShowBidRideEvent({
    required this.id,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
    required this.stops,
    required this.pickAddress,
    required this.dropAddress,
    required this.acceptedRideFare,
    required this.polyString,
    required this.distance,
    required this.duration,
    required this.isOutstationRide,
    required this.isNormalBidRide,
  });
}

class ChangeDistanceEvent extends HomeEvent {
  final double distance;
  ChangeDistanceEvent({required this.distance});
}

class AcceptRejectEvent extends HomeEvent {
  final String requestId;
  final int status;

  AcceptRejectEvent({required this.requestId, required this.status});
}

class AcceptBidRideEvent extends HomeEvent {
  final String id;
  AcceptBidRideEvent({required this.id});
}

class DeclineBidRideEvent extends HomeEvent {
  final String id;
  DeclineBidRideEvent({required this.id});
}

class RideArrivedEvent extends HomeEvent {
  final String requestId;
  RideArrivedEvent({required this.requestId});
}

class ImageCaptureEvent extends HomeEvent {}

class ShowOtpEvent extends HomeEvent {}

class ShowImagePickEvent extends HomeEvent {}

class ShowSignatureEvent extends HomeEvent {}

class UpdateSignEvent extends HomeEvent {
  final Map? points;
  UpdateSignEvent({required this.points});
}

class CompleteStopEvent extends HomeEvent {
  final String id;
  CompleteStopEvent({required this.id});
}

class ShowChooseStopEvent extends HomeEvent {}

class RideStartEvent extends HomeEvent {
  final String requestId;
  final String otp;
  final double pickLat;
  final double pickLng;
  RideStartEvent(
      {required this.requestId,
      required this.otp,
      required this.pickLat,
      required this.pickLng});
}

class RideEndEvent extends HomeEvent {
  final bool isAfterGeoCodeEnd;
  final bool isAfterRoutesDistanceCall;

  RideEndEvent(
      {required this.isAfterGeoCodeEnd,
      required this.isAfterRoutesDistanceCall});
}

class PolylineEvent extends HomeEvent {
  final double pickLat;
  final double pickLng;
  final double dropLat;
  final double dropLng;
  final List stops;
  final String packageName;
  final String signKey;
  final String pickAddress;
  final String dropAddress;
  final bool isTripEndCall;
  final bool? isInstantRide;
  final bool? isFromAnimate;
  PolylineEvent(
      {required this.pickLat,
      required this.pickLng,
      required this.dropLat,
      required this.dropLng,
      required this.stops,
      required this.packageName,
      required this.signKey,
      required this.pickAddress,
      required this.dropAddress,
      required this.isTripEndCall,
      this.isInstantRide,
      this.isFromAnimate});
}

class GeocodingLatLngEvent extends HomeEvent {
  final double lat;
  final double lng;
  GeocodingLatLngEvent({
    required this.lat,
    required this.lng,
  });
}

class GeocodingAddressEvent extends HomeEvent {
  final String placeId;
  final String address;
  final LatLng? position;
  GeocodingAddressEvent(
      {required this.placeId, required this.address, this.position});
}

class GetAutoCompleteAddressEvent extends HomeEvent {
  final String searchText;

  GetAutoCompleteAddressEvent({required this.searchText});
}

class GetEtaRequestEvent extends HomeEvent {}

class CreateInstantRideEvent extends HomeEvent {}

class ClearAutoCompleteEvent extends HomeEvent {}

class ChangeMenuEvent extends HomeEvent {
  final int menu;
  ChangeMenuEvent({required this.menu});
}

class PolylineSuccessEvent extends HomeEvent {}

class OpenAnotherFeatureEvent extends HomeEvent {
  final String value;
  OpenAnotherFeatureEvent({required this.value});
}

class BidRideRequestEvent extends HomeEvent {}

class ShowBiddingPageEvent extends HomeEvent {}

class RemoveChoosenRideEvent extends HomeEvent {}

class PaymentRecievedEvent extends HomeEvent {}

class WaitingTimeEvent extends HomeEvent {}

class RequestTimerEvent extends HomeEvent {}

class GetCurrentLocationEvent extends HomeEvent {}

class ReviewUpdateEvent extends HomeEvent {
  final int star;

  ReviewUpdateEvent({required this.star});
}

class ChangeOnlineOfflineEvent extends HomeEvent {}

class AddReviewEvent extends HomeEvent {}

class ChangeGoodsEvent extends HomeEvent {
  String id;
  ChangeGoodsEvent({required this.id});
}

class ShowChatEvent extends HomeEvent {}

class UploadReviewEvent extends HomeEvent {}

class GetRideChatEvent extends HomeEvent {}

class ChatSeenEvent extends HomeEvent {}

class SendChatEvent extends HomeEvent {
  final String message;

  SendChatEvent({required this.message});
}

class HideCancelReasonEvent extends HomeEvent {}

class GetCancelReasonEvent extends HomeEvent {}

class ChooseCancelReasonEvent extends HomeEvent {
  final int? choosen;
  ChooseCancelReasonEvent({required this.choosen});
}

class CancelRequestEvent extends HomeEvent {}

class UpdateLocationEvent extends HomeEvent {
  final LatLng latLng;

  UpdateLocationEvent({required this.latLng});
}

class UpdateEvent extends HomeEvent {}

class UpdateReducedTimeEvent extends HomeEvent {
  final int reducedTimeInMinutes;
  UpdateReducedTimeEvent(this.reducedTimeInMinutes);
}

class UpdateOnlineTimeEvent extends HomeEvent {
  final int minutes;

  UpdateOnlineTimeEvent({required this.minutes});
}

class NavigationTypeEvent extends HomeEvent {
  final bool isMapNavigation;
  NavigationTypeEvent({required this.isMapNavigation});
}

class BiddingIncreaseOrDecreaseEvent extends HomeEvent {
  final bool isIncrease;
  BiddingIncreaseOrDecreaseEvent({required this.isIncrease});
}

class ShowoutsationpageEvent extends HomeEvent {
  final bool isVisible;
  ShowoutsationpageEvent({required this.isVisible});
}

class OutstationSuccessEvent extends HomeEvent {}

class GetSubVehicleTypesEvent extends HomeEvent {
  final String serviceLocationId;
  final String vehicleType;

  GetSubVehicleTypesEvent(
      {required this.serviceLocationId, required this.vehicleType});
}

class UpdateSubVehiclesTypeEvent extends HomeEvent {
  final List subTypes;

  UpdateSubVehiclesTypeEvent({required this.subTypes});
}

class UpdateBottomHeightEvent extends HomeEvent {
  final dynamic bottomHeight;

  UpdateBottomHeightEvent({required this.bottomHeight});
}

class UpdateMarkersEvent extends HomeEvent {
  final List<Marker> markers;

  UpdateMarkersEvent({required this.markers});
}

class SetMapStyleEvent extends HomeEvent {
  final BuildContext context;

  SetMapStyleEvent({required this.context});
}

class TripMarkersAddEvent extends HomeEvent {}

class DiagnosticCheckEvent extends HomeEvent {
  final bool isDiagnosticsCheckPage;
  DiagnosticCheckEvent({required this.isDiagnosticsCheckPage});
}

class CheckInternet extends HomeEvent {}

class CheckLocation extends HomeEvent {}

class CheckNotification extends HomeEvent {
  final bool? isNotificationReceived;

  CheckNotification({this.isNotificationReceived});
}

class CheckSound extends HomeEvent {}

class DiagnosticCompleteEvent extends HomeEvent {}

class AdditionalChargeEvent extends HomeEvent {}

class AdditionalChargeOnTapEvent extends HomeEvent {
  final String chargeDetails;
  final String amount;
  final String requestId;
  AdditionalChargeOnTapEvent(
      {required this.chargeDetails,
      required this.amount,
      required this.requestId});
}

class StopVerifyOtpEvent extends HomeEvent {
  final String otp;
  final String stopId;
  final String? requestId;

  StopVerifyOtpEvent({required this.otp, required this.stopId, this.requestId});
}

class GetPeakZoneEvent extends HomeEvent {}

class ShowZoneNavigationEvent extends HomeEvent {
  final String zoneName;
  final LatLng zoneLatLng;
  final int endTimestamp;
  ShowZoneNavigationEvent(
      {required this.zoneName,
      required this.zoneLatLng,
      required this.endTimestamp});
}

class GetPreferencesDetailsEvent extends HomeEvent {}

class UpdatePreferencesEvent extends HomeEvent {
  final List id;

  UpdatePreferencesEvent({required this.id});
}

class SelectedPreferenceEvent extends HomeEvent {
  final int prefId;
  final bool isSelected;
  SelectedPreferenceEvent({required this.prefId, required this.isSelected});
}

class ConfirmPreferenceEvent extends HomeEvent {}

class ClearTempPreferenceEvent extends HomeEvent {}

class ToggleAcceptSharedRidesEvent extends HomeEvent {
  final bool accept;
  ToggleAcceptSharedRidesEvent({required this.accept});
}

class SelectOnTripRideEvent extends HomeEvent {
  final String requestId;
  SelectOnTripRideEvent({required this.requestId});
}

class EnsureOnTripSelectionEvent extends HomeEvent {}

class ShowAcceptRejectEvent extends HomeEvent {}
