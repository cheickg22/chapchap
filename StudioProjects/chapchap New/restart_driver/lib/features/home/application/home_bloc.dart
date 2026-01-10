// ignore_for_file: deprecated_member_use, empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/tobitmap.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart' hide MetaData;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_tagxi/common/app_audios.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/geohasher.dart';
import 'package:restart_tagxi/core/utils/custom_payment_stream.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/db/app_database.dart';
import 'package:restart_tagxi/features/home/application/usecase/ride_usecases.dart';
import 'package:restart_tagxi/features/home/domain/models/address_auto_complete_model.dart';
import 'package:restart_tagxi/features/home/domain/models/cancel_reason_model.dart';
import 'package:restart_tagxi/features/home/domain/models/get_preferences_model.dart';
import 'package:restart_tagxi/features/home/domain/models/goods_type_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:restart_tagxi/common/debouncer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:restart_tagxi/features/account/data/repository/acc_api.dart';
import '../../../common/common.dart';
import '../../../core/services/bubble_service.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/utils/functions.dart';
import '../../../di/locator.dart';
import '../../../l10n/app_localizations.dart';
import '../../driverprofile/domain/models/vehicle_types_model.dart';
import 'usecase/home_usecases.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  GoogleMapController? googleMapController;
  final fm.MapController fmController = fm.MapController();
  AudioPlayer audioPlayer = AudioPlayer();

  TextEditingController searchController = TextEditingController();
  TextEditingController pickupAddressController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  TextEditingController dropAddressController = TextEditingController();
  TextEditingController rideOtp = TextEditingController();
  TextEditingController chatField = TextEditingController();
  TextEditingController cancelReasonText = TextEditingController();
  TextEditingController bidRideAmount = TextEditingController();
  TextEditingController outstationRideAmount = TextEditingController();
  TextEditingController instantUserName = TextEditingController();
  TextEditingController instantUserMobile = TextEditingController();
  TextEditingController goodsSizeText = TextEditingController();
  TextEditingController pricePerDistance = TextEditingController();
  TextEditingController additionalChargeDetailText = TextEditingController();
  TextEditingController additionalChargeAmountText = TextEditingController();

  Set<Polyline> polyline = {};
  Set<Polygon> polygons = {};

  bool isAcceptLoading = false;
  bool isRejectLoading = false;
  bool autoSuggestionSearching = false;
  bool isBiddingIncreaseLimitReach = false;
  bool isBiddingDecreaseLimitReach = false;
  bool visibleOutStation = false;
  bool showOutstationWidget = false;
  bool isOutstationRide = false;
  bool isNormalBidRide = false;
  bool isOnline = false;
  bool isUserCancelled = false;
  bool bidDeclined = false;
  bool isLoading = false;
  bool showCancelReason = false;
  bool onlineLoader = false;
  bool addReview = false;
  bool showCarMenu = false;
  bool showChat = false;
  bool showOtp = false;
  bool showImagePick = false;
  bool showSignature = false;
  bool isBiddingEnabled = false;
  bool isSubscriptionShown = false;
  bool navigationType = false;
  bool navigationType1 = false;
  bool confirmPinAddress = false;
  bool showGetDropAddress = false;
  bool showBiddingPage = false;
  bool isBiddingPageRouteActive = false;
  bool vehicleNotUpdated = false;
  bool isOverlayAllowClicked = false;
  bool destinationChanged = false;
  bool showPeakZones = false;
  bool showPeakZoneButton = false;
  bool showDemandArea = false;
  bool onTripSearchNewRide = false;
  double tripDistance = 0.0;
  double lat = 0.0144927536231884;
  double lon = 0.0181818181818182;
  double earningsBottomPosition = -250;
  double earningsBottomCurrentPosition = 0;
  double? distanceBetween;
  double bottomSize = 0.0;
  double onRideBottomCurrentHeight = 0.0;
  double minHeight = 0.0;
  double? bidRideTop;
  double reducedTimeInMinutes = 5;
  double driverTips = 0.0;
  RideRepository rideRepository = RideRepository();
  bool isUserPaidPayment = false;
  String paymentChanged = '';

  int waitingTimeBeforeStart = 0;
  int waitingTimeAfterStart = 0;
  Animation<double>? _animation;
  AnimationController? animationController;
  final debouncer = Debouncer(milliseconds: 1000);

  dynamic vsync;
  String darkMapString = '';
  String lightMapString = '';
  int choosenMenu = 0;
  bool acceptSharedRides = false;

  int timer = 0;
  int? choosenCancelReason;
  LatLng? dropLatLng;
  LatLng? pickLatLng;
  String dropAddress = '';
  String pickAddress = '';
  String languageCode = '';
  Timer? searchTimer;
  double? minFare;
  double? maxFare;

  GeoHasher geo = GeoHasher();
  Query request = FirebaseDatabase.instance.ref('request-meta');
  Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: (Platform.isAndroid)
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 50,
              intervalDuration: const Duration(seconds: 10),
              foregroundNotificationConfig: ForegroundNotificationConfig(
                notificationText:
                    AppLocalizations.of(navigatorKey.currentContext!)!
                        .locationBackgroundServiceNotificationTitle
                        .replaceAll('1111', AppConstants.title),
                notificationTitle:
                    AppLocalizations.of(navigatorKey.currentContext!)!
                        .locationBackgroundServiceTitle,
                enableWakeLock: true,
              ))
          : AppleSettings(
              accuracy: LocationAccuracy.high,
              activityType: ActivityType.otherNavigation,
              distanceFilter: 50,
              showBackgroundLocationIndicator: true,
            ));
  StreamSubscription? positionSubscription;
  StreamSubscription? requestStream;
  StreamSubscription? bidRequestStream;
  StreamSubscription? rideStream;
  StreamSubscription? rideAddStream;
  StreamSubscription? ownersDriver;
  StreamSubscription? zoneStreamRemove;
  BitmapDescriptor? vehicleMarker;
  BitmapDescriptor? onlineCar;
  BitmapDescriptor? onrideCar;
  BitmapDescriptor? offlineCar;
  BitmapDescriptor? onlineTruck;
  BitmapDescriptor? onrideTruck;
  BitmapDescriptor? offlineTruck;
  BitmapDescriptor? onlineBike;
  BitmapDescriptor? onrideBike;
  BitmapDescriptor? offlineBike;
  String? choosenCompleteStop;
  String? choosenRide;
  String? sessionToken;
  String? instantRidePrice;
  String? instantRideCurrency;
  String? choosenGoods;
  String goodsSize = 'Loose';
  String? loadImage;
  String? unloadImage;
  String? showLoadImage;
  String? showUnloadImage;
  String? signatureImage;
  String polyString = '';
  String currentLocation = '';
  String acceptedRideFare = '';
  String additionalChargeText = '';
  String additionalChargeAmount = '';
  Timer? currentPosition;
  Timer? waitingTimer;
  Timer? biddingRideTimer;
  Timer? activeTimer;
  Timer? userDetailsTimer;

  int review = 0;
  int choosenCarMenu = 1;
  LatLng? currentLatLng;
  CameraPosition? initialCameraPosition;
  List banners = [];
  List chats = [];
  List rideList = [];
  List oldRides = [];
  List waitingList = [];
  List latlngArray = [];
  List outStationList = [];
  List<CancelReasonData> cancelReasons = [];
  List signaturePoints = [];
  List<GoodsData> goodsList = [];
  List<Marker> markers = [];
  List<AddressData> autoCompleteAddress = [];
  List<VehicleTypeData> subVehicleTypes = [];
  List selectedSubVehicleTypes = [];
  List<Map<String, double>> distanceBetweenList = [];
  static const double _distanceStepInKm = 2.0;
  static const double _kmToMilesFactor = 0.62135;
  String? instantRideType;
  String? etaDistance;
  String? etaDuration;
  String textDirection = 'ltr';
  String? _lastShownRequestId;
  bool isDiagnosticsCheckPage = false;
  bool? isInternetConnected;
  bool? isLocationsEnabled;
  bool? isNotificationsEnabled;
  bool? isSoundsChecked;

  final List<String> diagnosticSteps = ["location", "notification", "sound"];
  int currentDiagnosticStep = 0;

  Widget? animatedWidget;
  LatLng? mapPoint;
  var screenshotImage = GlobalKey();
  ScrollController chatScrollController = ScrollController();
  String fmDistance = '';
  double fmDuration = 0;

  List<GetPreferencesModelData>? preferenceDetailsList;
  List<int> selectedPreferenceDetailsList = [];

  List<int> tempSelectPreference = [];

  HomeBloc() : super(HomeInitialState()) {
    distanceBetweenList = _buildDefaultDistanceList();
    on<UpdateEvent>((event, emit) => emit(UpdateState()));
    on<ShowAcceptRejectEvent>((event, emit) => emit(ShowAcceptRejectState()));
    on<ShowZoneNavigationEvent>((event, emit) => emit(ShowZoneNavigationState(
        zoneName: event.zoneName,
        zoneLatLng: event.zoneLatLng,
        endTimestamp: event.endTimestamp)));
    on<GetDirectionEvent>(getDirection);
    on<GetUserDetailsEvent>(getUserDetails);
    on<ChangeOnlineOfflineEvent>(changeOnlineOffline);
    on<UpdateBottomHeightEvent>(updateValue);
    on<UpdateMarkersEvent>(updateMarkers);
    on<SetMapStyleEvent>(setMapStyle);
    // Location
    on<GetCurrentLocationEvent>(getCurrentLocation);
    on<UpdateLocationEvent>(updateLocation);
    on<AcceptRejectEvent>(respondRequest);
    on<RequestTimerEvent>(rideTimerUpdate);
    on<StreamRequestEvent>(onTripRequest);
    on<RideArrivedEvent>(rideArrived);
    on<RideStartEvent>(rideStart);
    on<WaitingTimeEvent>(waitingTimerEmit);
    on<PolylineEvent>(getPolyline);
    on<PolylineSuccessEvent>(streamPolyline);
    on<RideEndEvent>(rideEnd);
    on<GeocodingLatLngEvent>(getAddressFromLatLng);
    on<PaymentRecievedEvent>(paymentRecieved);
    on<AddReviewEvent>(addReviewFunc);
    on<ReviewUpdateEvent>(changeReview);
    on<UploadReviewEvent>(addRideReview);
    on<OpenAnotherFeatureEvent>(openAnotherFeature);
    on<ShowChatEvent>(showChatFunc);
    on<GetRideChatEvent>(getRideChats);
    on<ChatSeenEvent>(chatSeen);
    on<SendChatEvent>(sendChat);
    on<GetCancelReasonEvent>(getCancelReason);
    on<HideCancelReasonEvent>(cancelReasonChoose);
    on<ChooseCancelReasonEvent>(chooseCancelReason);
    on<CancelRequestEvent>(cancelRequest);
    on<ImageCaptureEvent>(captureImage);
    on<ShowOtpEvent>(showOtpFunc);
    on<ShowImagePickEvent>(showImagePickFunc);
    on<ShowSignatureEvent>(showSignatureFunc);
    on<UpdateSignEvent>(signaturePointUpdate);
    on<BidRideRequestEvent>(bidRequestUpdate);
    on<ShowBiddingPageEvent>(showBiddingPageFunc);
    on<DeclineBidRideEvent>(declineBidRide);
    on<ShowBidRideEvent>(showBidRideFunc);
    on<AcceptBidRideEvent>(acceptBidRide);
    on<RemoveChoosenRideEvent>(removeChoosenRide);
    on<ChangeDistanceEvent>(updateDistanceBetween);
    on<ShowGetDropAddressEvent>(showGetDropAddressFunc);
    on<GetAutoCompleteAddressEvent>(getAutoCompleteAddress);
    on<ClearAutoCompleteEvent>(clearAutoComplete);
    on<GeocodingAddressEvent>(getLatLngFromAddress);
    on<GetEtaRequestEvent>(etaRequest);
    on<CreateInstantRideEvent>(createInstantRequest);
    on<GetGoodsTypeEvent>(getGoodsType);
    on<ChangeGoodsEvent>(changeGoods);
    on<UploadProofEvent>(uploadProof);
    on<ShowChooseStopEvent>(showCompleteStop);
    on<CompleteStopEvent>(stopComplete);
    on<ShowCarMenuEvent>(showCarMenuFunc);
    on<ChooseCarMenuEvent>(chooseCarMenuFunc);
    on<ChangeMenuEvent>(changeMenuFunc);
    on<EnableBubbleEvent>(enableBubbleFunc);
    on<UpdatePricePerDistanceEvent>(updatePricePerDistance);
    on<UpdateReducedTimeEvent>(getWaitingTime);
    on<UpdateOnlineTimeEvent>(updateActiveUserTiming);
    on<NavigationTypeEvent>(navigationTypeFunc);
    on<BiddingIncreaseOrDecreaseEvent>(biddingFareIncreaseDecrease);
    on<ShowoutsationpageEvent>(showOutstationPage);
    on<OutstationSuccessEvent>(outStationSuccess);
    on<GetSubVehicleTypesEvent>(getSubVehicleTypes);
    on<UpdateSubVehiclesTypeEvent>(updateSubVehicleTypes);
    on<TripMarkersAddEvent>(tripMarkersAdd);
    on<DiagnosticCheckEvent>(diagnosticFeaturesCheck);
    on<CheckInternet>(_onCheckInternet);
    on<CheckLocation>(_onCheckLocation);
    on<CheckNotification>(_onCheckNotification);
    on<CheckSound>(_onCheckSound);
    on<DiagnosticCompleteEvent>(openDiagnosticFinalDialogue);
    on<AdditionalChargeEvent>(openAdditionalChargeBottomSheet);
    on<AdditionalChargeOnTapEvent>(tapAdditionalChargeEvent);
    on<StopVerifyOtpEvent>(stopVerifyOtp);
    on<GetPeakZoneEvent>(loadPeakZones);
    on<SelectedPreferenceEvent>(selectPreferenceEvent);
    on<GetPreferencesDetailsEvent>(getPreferencesDetails);
    on<UpdatePreferencesEvent>(updatePreferences);
    on<ConfirmPreferenceEvent>(confirmPreferenceSelection);
    on<ClearTempPreferenceEvent>(clearTempPreferenceEvent);
    on<ToggleAcceptSharedRidesEvent>(toggleAcceptSharedRides);
    on<SelectOnTripRideEvent>(_selectOnTripRide);
    on<EnsureOnTripSelectionEvent>(_ensureOnTripSelection);
  }

  Future<void> _syncDistanceBetweenOptions(Emitter<HomeState> emit) async {
    final double? backendMax = userData?.biddingRideMaximumDistance;
    final double? savedDistance =
        distanceBetween ?? await AppSharedPreference.getDistanceBetween();

    if (backendMax != null && backendMax > 0) {
      distanceBetweenList = _buildDistanceList(backendMax);
    } else if (distanceBetweenList.isEmpty) {
      distanceBetweenList = _buildDefaultDistanceList();
    }

    final matchedOption = _matchDistanceOption(savedDistance);
    distanceBetween = matchedOption['dist'];
    await AppSharedPreference.setDistanceBetween(distanceBetween!);
    emit(DistanceUpdateState());
  }

  Map<String, double> _matchDistanceOption(double? distance) {
    if (distanceBetweenList.isEmpty) {
      distanceBetweenList = _buildDefaultDistanceList();
    }
    if (distance == null || distance <= 0) {
      return distanceBetweenList.first;
    }

    for (final option in distanceBetweenList) {
      if ((option['dist']! - distance).abs() < 0.01) {
        return option;
      }
    }
    return distanceBetweenList.last;
  }

  double _geoRadiusValueFor(double distance) {
    if (distanceBetweenList.isEmpty) {
      distanceBetweenList = _buildDefaultDistanceList();
    }
    final option = _matchDistanceOption(distance);
    return option['value']!;
  }

  List<Map<String, double>> _buildDefaultDistanceList() {
    return _buildDistanceList(_distanceStepInKm * 4);
  }

  List<Map<String, double>> _buildDistanceList(double maxDistanceKm) {
    final double sanitizedMax = max<double>(
        _distanceStepInKm * 2, maxDistanceKm.isFinite ? maxDistanceKm : 0);
    final double finalMax = max<double>(sanitizedMax, _distanceStepInKm * 2);
    final List<Map<String, double>> options = [];
    double current = _distanceStepInKm;

    while (current < finalMax) {
      options.add(_distanceEntry(current));
      current += _distanceStepInKm;
    }

    if (options.isEmpty || (finalMax - options.last['dist']!).abs() > 0.01) {
      options.add(_distanceEntry(finalMax));
    } else {
      options[options.length - 1] = _distanceEntry(finalMax);
    }

    return options;
  }

  Map<String, double> _distanceEntry(double km) {
    final double kmRounded = double.parse(km.toStringAsFixed(2));
    final double miles =
        double.parse((kmRounded * _kmToMilesFactor).toStringAsFixed(5));
    return {
      'name': kmRounded,
      'dist': kmRounded,
      'value': miles,
    };
  }

  FutureOr<void> toggleAcceptSharedRides(
      ToggleAcceptSharedRidesEvent event, Emitter<HomeState> emit) async {
    acceptSharedRides = event.accept;

    // Manage request stream based on preference
    if (acceptSharedRides) {
      if (requestStream == null) {
        streamRequest();
      }
    } else {
      if (onTripSearchNewRide == false) {
        requestStream?.cancel();
        requestStream = null;
      }
    }

    // Persist preference to Firebase regardless of current trip/shared status
    if (userData != null) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/driver_${userData!.id}')
          .update({'shared_ride': acceptSharedRides});
    }

    emit(UpdateState());
  }

  FutureOr<void> _selectOnTripRide(
      SelectOnTripRideEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeDataLoadingStartState());
      Response resp = await AccApi()
          .getHistoryApi('request_number=${event.requestId}', pageNo: '1');
      List dataList = (resp.data is Map && resp.data['data'] is List)
          ? resp.data['data']
          : [];

      if (dataList.isEmpty) {
        resp = await AccApi()
            .getHistoryApi('request_id=${event.requestId}', pageNo: '1');
        dataList = (resp.data is Map && resp.data['data'] is List)
            ? resp.data['data']
            : [];
      }

      if (dataList.isEmpty) {
        // Fallback: pull current on-trip list and find by number or id
        final respAll = await AccApi().getHistoryApi('on_trip=1', pageNo: '1');
        final all = (respAll.data is Map && respAll.data['data'] is List)
            ? respAll.data['data']
            : [];

        dataList = all.where((e) {
          final m = Map<String, dynamic>.from(e);
          final rn = m['request_number']?.toString();
          final rid = m['id']?.toString();
          final matches = rn == event.requestId || rid == event.requestId;
          return matches;
        }).toList();

        if (dataList.isEmpty) {
          emit(HomeDataLoadingStopState());
          return;
        }
      }

      if (dataList.isNotEmpty) {
        // Find the ride that matches our requestId
        final targetRide = dataList.firstWhere(
          (ride) {
            final requestNumber = ride['request_number']?.toString();
            final rideId = ride['id']?.toString();
            final matches =
                requestNumber == event.requestId || rideId == event.requestId;
            return matches;
          },
          orElse: () {
            return null;
          },
        );

        final raw = targetRide != null
            ? Map<String, dynamic>.from(targetRide)
            : Map<String, dynamic>.from(dataList.first);

        // Normalize numeric fields to double and ensure nested shapes
        double? nPickLat = (raw['pick_lat'] != null)
            ? double.tryParse(raw['pick_lat'].toString())
            : null;
        double? nPickLng = (raw['pick_lng'] != null)
            ? double.tryParse(raw['pick_lng'].toString())
            : null;
        double? nDropLat = (raw['drop_lat'] != null)
            ? double.tryParse(raw['drop_lat'].toString())
            : null;
        double? nDropLng = (raw['drop_lng'] != null)
            ? double.tryParse(raw['drop_lng'].toString())
            : null;

        // Ensure requestStops is in {data: [...]} format
        dynamic reqStops = raw['requestStops'];
        if (reqStops is List) {
          raw['requestStops'] = {'data': reqStops};
        } else if (reqStops == null) {
          raw['requestStops'] = {'data': []};
        }

        // Coerce some fields if missing
        raw['pick_lat'] = nPickLat ?? 0.0;
        raw['pick_lng'] = nPickLng ?? 0.0;
        raw['drop_lat'] = nDropLat;
        raw['drop_lng'] = nDropLng;
        raw['is_rental'] = raw['is_rental'] ?? false;
        raw['transport_type'] = raw['transport_type'] ?? '';
        raw['requested_currency_symbol'] =
            raw['requested_currency_symbol'] ?? (raw['currency_symbol'] ?? '');
        raw['payment_type_string'] =
            raw['payment_type_string'] ?? raw['payment_type'] ?? '';
        raw['poly_line'] = raw['poly_line'] ?? raw['polyline'] ?? '';
        raw['userDetail'] = raw['userDetail'] ?? {'data': {}};

        final onTrip = OnTripData.fromJson(raw);
        userData!.onTripRequest = onTrip;
        // Store the selected ride ID for future API calls
        _lastShownRequestId = onTrip.id;

        // Reset overlays
        polyline.clear();
        polygons.clear();
        fmpoly.clear();
        markers.removeWhere((m) => m.markerId != const MarkerId('my_loc'));

        // Route decision
        final arrived =
            (onTrip.arrivedAt != null && onTrip.arrivedAt!.isNotEmpty);

        if (!arrived) {
          if (currentLatLng != null) {
            add(PolylineEvent(
              pickLat: currentLatLng!.latitude,
              pickLng: currentLatLng!.longitude,
              dropLat: onTrip.pickLat,
              dropLng: onTrip.pickLng,
              stops: const [],
              packageName: AppConstants.packageName,
              signKey: AppConstants.signKey,
              pickAddress: currentLocation,
              dropAddress: onTrip.pickAddress,
              isTripEndCall: false,
            ));
          }
        } else if (onTrip.dropLat != null &&
            onTrip.dropLng != null &&
            (onTrip.dropAddress ?? '').isNotEmpty) {
          add(PolylineEvent(
            pickLat: onTrip.pickLat,
            pickLng: onTrip.pickLng,
            dropLat: onTrip.dropLat!,
            dropLng: onTrip.dropLng!,
            stops: onTrip.requestStops,
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: onTrip.pickAddress,
            dropAddress: onTrip.dropAddress ?? '',
            isTripEndCall: false,
          ));
        }

        // Kick off chat and any listeners relying on this
        add(GetRideChatEvent());
        emit(UpdateState());
        try {
          String? requestIdToSend;

          if (event.requestId.isNotEmpty) {
            requestIdToSend = event.requestId;
          } else if (userData?.onTripRequest?.id != null) {
            requestIdToSend = userData!.onTripRequest!.id;
          } else {}

          if (requestIdToSend != null) {
            await serviceLocator<HomeUsecase>()
                .userDetails(requestId: requestIdToSend);
          } else {
            await serviceLocator<HomeUsecase>().userDetails();
          }
        } catch (e) {}
      }
      emit(HomeDataLoadingStopState());
    } catch (e) {
      emit(HomeDataLoadingStopState());
    }
  }

  FutureOr<void> _ensureOnTripSelection(
      EnsureOnTripSelectionEvent event, Emitter<HomeState> emit) async {
    try {
      if (userData == null) {
        return;
      }

      emit(HomeDataLoadingStopState());
      return;
    } catch (e) {
      emit(HomeDataLoadingStopState());
    }
  }

  FutureOr<void> diagnosticFeaturesCheck(
      DiagnosticCheckEvent event, Emitter<HomeState> emit) {
    isDiagnosticsCheckPage = event.isDiagnosticsCheckPage;
    emit(DiagnosticPageCheckState());
  }

  FutureOr<void> openDiagnosticFinalDialogue(
      DiagnosticCompleteEvent event, Emitter<HomeState> emit) {
    emit(DiagnosticCompleteState());
  }

  FutureOr<void> _onCheckInternet(
      CheckInternet event, Emitter<HomeState> emit) async {
    bool isConnected = await checkInternetConnectivity();
    isInternetConnected = isConnected;
    emit(CheckInternetState(isConnected: isConnected));
  }

  FutureOr<void> _onCheckLocation(
      CheckLocation event, Emitter<HomeState> emit) async {
    bool isLocationEnabled = await checkLocationPermission();
    isLocationsEnabled = isLocationEnabled;
    emit(CheckLocationState(
      isLocationEnabled: isLocationEnabled,
    ));
  }

  FutureOr<void> _onCheckNotification(
      CheckNotification event, Emitter<HomeState> emit) async {
    bool isNotificationEnabled = await checkNotificationPermission();
    isNotificationsEnabled = isNotificationEnabled;
    emit(CheckNotificationState(isNotificationEnabled: isNotificationEnabled));
  }

  FutureOr<void> _onCheckSound(
      CheckSound event, Emitter<HomeState> emit) async {
    bool isSoundEnabled = await checkSoundStatus();
    isSoundsChecked = isSoundEnabled;
    emit(CheckSoundState(isSoundEnabled: isSoundEnabled));
  }

  Future<bool> checkInternetConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final Dio dio = Dio();
      final stopwatch = Stopwatch()..start();
      // Ping a reliable server (Google)
      await dio.get("https://www.google.com",
          options: Options(
            receiveTimeout: const Duration(seconds: 5), // Set timeout
          ));
      stopwatch.stop();
      stopwatch.elapsedMilliseconds;
      return true;
    } on DioException catch (_) {
      return false; // No internet
    } catch (e) {
      return false; // Error in checking
    }
  }

  Future<bool> checkLocationPermission() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkNotificationPermission() async {
    final data = await serviceLocator<HomeUsecase>().getDiagnostiNotification();
    return data.fold(
      (error) {
        showToast(message: error.message!);
        return false;
      },
      (success) {
        if (userData != null) {
          userData!.approve = success.data.approve == 1 ? true : false;
          userData!.available = success.data.available == 1 ? true : false;
        }
        return success.success;
      },
    );
  }

  Future<bool> checkSoundStatus() async {
    await audioPlayer.play(AssetSource(AppAudios.requestSound));
    return true; // Replace with real check
  }

  FutureOr<void> getWaitingTime(
      UpdateReducedTimeEvent event, Emitter<HomeState> emit) {
    emit(UpdateReducedTimeState(
        reducedTimeInMinutes: event.reducedTimeInMinutes));
  }

  FutureOr<void> showOutstationPage(
      ShowoutsationpageEvent event, Emitter<HomeState> emit) {
    visibleOutStation = event.isVisible;
    emit(ShowoutsationpageState(isVisible: event.isVisible));
    add(UpdateEvent());
  }

  FutureOr<void> outStationSuccess(
      OutstationSuccessEvent event, Emitter<HomeState> emit) {
    emit(OutstationSuccessState());
  }

  FutureOr<void> getSubVehicleTypes(
      GetSubVehicleTypesEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<HomeUsecase>().getSubVehicleTypes(
        serviceLocationId: event.serviceLocationId,
        vehicleType: event.vehicleType);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        emit(HomeDataLoadingStopState());
        subVehicleTypes = success.data;
        if (subVehicleTypes.isNotEmpty) {
          emit(ShowSubVehicleTypesState());
        } else {
          showToast(message: 'Services Not Available');
        }
      },
    );
  }

  FutureOr<void> updateSubVehicleTypes(
      UpdateSubVehiclesTypeEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<HomeUsecase>()
        .updateVehicleTypesApi(subTypes: event.subTypes);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        emit(HomeDataLoadingStopState());
        showToast(message: 'added successfully');
        final data = UserDetail.fromJson(success["data"]);
        userData = data;
        updateFirebaseData();
      },
    );
  }

  Future<void> startBubbleHead() async {
    try {
      if (Platform.isAndroid) {
        final service = FlutterBackgroundService();
        service.startService();
        // updateBgLocation(10);
        if (showBubbleIcon) {
          await NativeService().startService();
        } else {}
      }
    } on PlatformException {}
  }

  Future<void> stopBubbleHead() async {
    try {
      if (Platform.isAndroid) {
        final service = FlutterBackgroundService();
        service.invoke("stopService");
        if (showBubbleIcon) {
          await NativeService().stopService();
        }
      }
    } catch (e) {}
  }

  Future<void> getDirection(
      GetDirectionEvent event, Emitter<HomeState> emit) async {
    vsync = event.vsync;
    lightMapString = await rootBundle.loadString('assets/light-theme.json');
    darkMapString = await rootBundle.loadString('assets/dark-theme.json');
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      add(GetCurrentLocationEvent());
    }
    mapType = await AppSharedPreference.getMapType();
    languageCode = await AppSharedPreference.getSelectedLanguageCode();
    textDirection = await AppSharedPreference.getLanguageDirection();
    if (Platform.isAndroid) {
      NativeService().initService(
          chatHeadIcon: '@drawable/logo',
          notificationIcon: "@drawable/logo",
          notificationCircleHexColor: AppColors.primaryValue,
          screenHeight: 120);
    }
    minHeight = -(MediaQuery.sizeOf(navigatorKey.currentContext!).height * 0.8);
    if (bottomSize == 0.0) {
      bottomSize =
          -(MediaQuery.sizeOf(navigatorKey.currentContext!).height * 0.8);
      add(UpdateBottomHeightEvent(bottomHeight: bottomSize));
    }
    emit(HomeDataSuccessState());
  }

  Future<void> setMapStyle(
      SetMapStyleEvent event, Emitter<HomeState> emit) async {
    if (Theme.of(event.context).brightness == Brightness.dark) {
      if (googleMapController != null) {
        if (event.context.mounted) {
          googleMapController!.setMapStyle(darkMapString);
        }
      }
    } else {
      if (googleMapController != null) {
        if (event.context.mounted) {
          googleMapController!.setMapStyle(lightMapString);
        }
      }
    }
    emit(UpdateState());
  }

  Future<void> showCompleteStop(
      ShowChooseStopEvent event, Emitter<HomeState> emit) async {
    choosenCompleteStop = null;
    emit(ShowChooseStopsState());
  }

  Future<void> changeMenuFunc(
      ChangeMenuEvent event, Emitter<HomeState> emit) async {
    choosenMenu = event.menu;
    showPeakZones = false;
    polygons.removeWhere(
        (element) => element.polygonId.value.contains('peakzone_'));
    polyline.removeWhere(
        (element) => element.polylineId.value.contains('peakzone_'));
    zoneStreamRemove?.cancel();
    zoneStreamRemove = null;
    if (choosenMenu == 0) {
      lightMapString = await rootBundle.loadString('assets/light-theme.json');
      darkMapString = await rootBundle.loadString('assets/dark-theme.json');
      googleMapController = null;
    }
    emit(ChangedMenuState());
    emit(UpdateState());
  }

  Future<void> enableBubbleFunc(
      EnableBubbleEvent event, Emitter<HomeState> emit) async {
    if (Platform.isAndroid) {
      final perm = await NativeService().checkPermission();
      if (perm) {
        showBubbleIcon = event.isEnabled;
      } else {
        await NativeService().askPermission();
        final perm1 = await NativeService().checkPermission();
        if (perm1) {
          showBubbleIcon = event.isEnabled;
        } else {
          showBubbleIcon = false;
        }
      }

      AppSharedPreference.setBubbleSettingStatus(event.isEnabled);
      emit(EnableBubbleSettingsState());
    }
  }

  Future<void> showCarMenuFunc(
      ShowCarMenuEvent event, Emitter<HomeState> emit) async {
    if (showCarMenu) {
      showCarMenu = false;
    } else {
      showCarMenu = true;
    }
    emit(ShowCarMenuState());
  }

  Future<void> chooseCarMenuFunc(
      ChooseCarMenuEvent event, Emitter<HomeState> emit) async {
    choosenCarMenu = event.menu;
    showCarMenu = false;
    streamOwnersDriver();
    emit(ShowCarMenuState());
  }

  Future<void> clearAutoComplete(
      ClearAutoCompleteEvent event, Emitter<HomeState> emit) async {
    autoSuggestionSearching = false;
    autoCompleteAddress.clear();
    dropAddressController.clear();
    sessionToken = null;
    emit(StateChangedState());
    emit(UpdateState());
  }

  Future<void> changeGoods(
      ChangeGoodsEvent event, Emitter<HomeState> emit) async {
    choosenGoods = event.id;
    emit(StateChangedState());
    emit(UpdateState());
  }

  Future<void> showBidRideFunc(
      ShowBidRideEvent event, Emitter<HomeState> emit) async {
    choosenRide = event.id;
    bidRideAmount.clear();
    outstationRideAmount.clear();
    isBiddingIncreaseLimitReach = false;
    isBiddingDecreaseLimitReach = false;
    isOutstationRide = event.isOutstationRide;
    isNormalBidRide = event.isNormalBidRide;
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }
    markers.add(Marker(
      markerId: const MarkerId("pick"),
      position: LatLng(event.pickLat, event.pickLng),
      rotation: 0.0,
      icon: await Image.asset(
        AppImages.pickupIcon,
        height: 30,
        width: 30,
        fit: BoxFit.contain,
      ).toBitmapDescriptor(
        logicalSize: const Size(30, 30),
        imageSize: const Size(200, 200),
      ),
    ));
    if (event.stops.isEmpty && event.dropAddress != '') {
      markers.add(Marker(
        markerId: const MarkerId("drop"),
        position: LatLng(event.dropLat, event.dropLng),
        rotation: 0.0,
        icon: await const Directionality(
            textDirection: TextDirection.ltr,
            child: Icon(
              Icons.location_on,
              color: Colors.red,
            )).toBitmapDescriptor(
          logicalSize: const Size(30, 30),
          imageSize: const Size(200, 200),
        ),
      ));
    } else if (event.stops.isNotEmpty) {
      for (var i = 0; i < event.stops.length; i++) {
        markers.add(Marker(
          markerId: MarkerId("drop$i"),
          position:
              LatLng(event.stops[i]['latitude'], event.stops[i]['longitude']),
          rotation: 0.0,
          icon: (i == event.stops.length - 1)
              ? await const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  )).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200),
                )
              : await Image.asset(
                  (i == 0)
                      ? AppImages.stopOne
                      : (i == 1)
                          ? AppImages.stopTwo
                          : (i == 2)
                              ? AppImages.stopThree
                              : AppImages.stopFour,
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                ).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200),
                ),
        ));
      }
    }
    if (mapType == 'google_map') {
      if (userData!.metaRequest != null ||
          (userData!.onTripRequest != null &&
              userData!.onTripRequest!.arrivedAt != null) ||
          (userData!.metaRequest == null &&
              userData!.onTripRequest == null &&
              choosenRide != null) ||
          (userData!.metaRequest == null &&
              userData!.onTripRequest == null &&
              showGetDropAddress)) {
        mapBound(event.pickLat, event.pickLng, event.dropLat, event.dropLng,
            event.stops);
      } else {
        mapBound(currentLatLng!.latitude, currentLatLng!.longitude,
            event.pickLat, event.pickLng, event.stops);
      }

      decodeEncodedPolyline(event.polyString);
    } else {
      mapBound(currentLatLng!.latitude, currentLatLng!.longitude, event.pickLat,
          event.pickLng, event.stops);

      decodeEncodedPolyline(event.polyString);
      double lat = (event.pickLat + event.dropLat) / 2;
      double lon = (event.pickLng + event.dropLng) / 2;
      var val = LatLng(lat, lon);
      fmController.move(fmlt.LatLng(val.latitude, val.longitude), 13);
      add(PolylineSuccessEvent());
    }
    await addDistanceMarker(
        LatLng(event.dropLat, event.dropLng), double.parse(event.distance),
        time: double.parse(event.duration));
    add(ShowoutsationpageEvent(isVisible: false));
    acceptedRideFare = event.acceptedRideFare;
    emit(ShowBiddingPageState());
  }

  Future<void> removeChoosenRide(
      RemoveChoosenRideEvent event, Emitter<HomeState> emit) async {
    polyline.clear();
    polygons.clear();
    fmpoly.clear();
    markers
        .removeWhere((element) => element.markerId != const MarkerId('my_loc'));
    choosenRide = null;
    emit(ShowBiddingPageState());
  }

  Future<void> declineBidRide(
      DeclineBidRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    await FirebaseDatabase.instance
        .ref('bid-meta')
        .child('${event.id}/drivers/driver_${userData!.id}')
        .update({
      'driver_id': userData!.id,
      'driver_name': userData!.name,
      'driver_img': userData!.profilePicture,
      'bid_time': ServerValue.timestamp,
      'is_rejected': 'by_driver'
    });
    if (outStationList.isNotEmpty) {
      fmpoly.clear();
      polyline.clear();
      polygons.clear();
      outStationList
          .removeWhere((element) => element["request_id"] == event.id);
      if (outStationList.isEmpty) {
        showOutstationWidget = false;
      }
      emit(UpdateState());
    }
    emit(UpdateState());
    emit(HomeDataLoadingStopState());
  }

  Future<void> acceptBidRide(
      AcceptBidRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    await FirebaseDatabase.instance
        .ref('bid-meta')
        .child('${event.id}/drivers/driver_${userData!.id}')
        .update({
      'driver_id': userData!.id,
      'price': bidRideAmount.text.toString().replaceAll(
          (rideList.isNotEmpty)
              ? rideList
                  .firstWhere((e) => e['request_id'] == event.id)['currency']
              : (outStationList.isNotEmpty)
                  ? outStationList.firstWhere(
                      (e) => e['request_id'] == event.id)['currency']
                  : rideList.firstWhere(
                      (e) => e['request_id'] == event.id)['currency'],
          ''),
      'driver_name': userData!.name,
      'driver_img': userData!.profilePicture,
      'bid_time': ServerValue.timestamp,
      'is_rejected': 'none',
      'vehicle_make': userData!.carMake,
      'vehicle_model': userData!.carModel,
      'vehicle_number': userData!.carNumber,
      'lat': currentLatLng!.latitude,
      'lng': currentLatLng!.longitude,
      'rating': userData!.rating.toString(),
      'mobile': userData!.mobile
    });
    emit(HomeDataLoadingStopState());
    if (showOutstationWidget == true) {
      if (outStationList.isNotEmpty) {
        fmpoly.clear();
        polyline.clear();
        polygons.clear();
        outStationList
            .removeWhere((element) => element["request_id"] == event.id);
        if (outStationList.isEmpty) {
          showOutstationWidget = false;
        }
        emit(UpdateState());
      }
      if (outStationList.isEmpty) {
        showOutstationWidget = false;
      }
      emit(UpdateState());
      emit(OutstationSuccessState());
    }
  }

  Future<void> addReviewFunc(
      AddReviewEvent event, Emitter<HomeState> emit) async {
    if (addReview) {
      addReview = false;
    } else {
      reviewController.clear();
      review = 0;
      addReview = true;
    }
    emit(AddReviewState());
  }

  Future<void> showGetDropAddressFunc(
      ShowGetDropAddressEvent event, Emitter<HomeState> emit) async {
    if (showGetDropAddress) {
      pickAddress = '';
      dropAddress = '';
      pickLatLng = null;
      dropLatLng = null;
      markers.removeWhere(
          (element) => element.markerId != const MarkerId('my_loc'));
      polyline.clear();
      polygons.clear();
      fmpoly.clear();
      if (userData!.transportType == 'both') {
        instantRideType = 'taxi';
      } else {
        instantRideType = null;
      }

      showGetDropAddress = false;
      autoCompleteAddress.clear();
      emit(StateChangedState());
    } else {
      pickAddress = '';
      dropAddress = '';
      add(GeocodingLatLngEvent(
          lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
    }
  }

  Future<void> showBiddingPageFunc(
      ShowBiddingPageEvent event, Emitter<HomeState> emit) async {
    if (showBiddingPage) {
      showBiddingPage = false;
    } else {
      showBiddingPage = true;
      showOutstationWidget = false;
    }
    emit(ShowBiddingPageState());
  }

  Future<void> showOtpFunc(ShowOtpEvent event, Emitter<HomeState> emit) async {
    rideOtp.clear();
    if (showOtp) {
      showOtp = false;
    } else {
      showOtp = true;
    }
    emit(ShowOtpState());
  }

  Future<void> showImagePickFunc(
      ShowImagePickEvent event, Emitter<HomeState> emit) async {
    loadImage = null;
    unloadImage = null;
    showLoadImage = null;
    showUnloadImage = null;
    if (showImagePick) {
      showImagePick = false;
    } else {
      showImagePick = true;
    }

    emit(ShowImagePickState());
  }

  Future<void> showSignatureFunc(
      ShowSignatureEvent event, Emitter<HomeState> emit) async {
    signaturePoints.clear();
    if (showSignature) {
      showSignature = false;
    } else {
      showSignature = true;
    }
    emit(ShowSignatureState());
  }

  Future<void> signaturePointUpdate(
      UpdateSignEvent event, Emitter<HomeState> emit) async {
    if (event.points == null) {
      signaturePoints.clear();
    } else {
      signaturePoints.add(event.points);
    }
    emit(UpdateSignatureState());
  }

  Future<void> captureImage(
      ImageCaptureEvent event, Emitter<HomeState> emit) async {
    try {
      ImagePicker image = ImagePicker();
      XFile? imageFile = await image.pickImage(source: ImageSource.camera);

      if (imageFile != null) {
        if (userData!.onTripRequest == null ||
            userData!.onTripRequest!.isTripStart == 0) {
          loadImage = imageFile.path;
          showLoadImage = imageFile.path;
        } else {
          unloadImage = imageFile.path;
          showUnloadImage = imageFile.path;
        }
        emit(ImageCaptureSuccessState());
      } else {
        emit(ImageCaptureFailureState());
      }
    } catch (e) {
      emit(ImageCaptureFailureState());
    }
  }

  Future<void> chooseCancelReason(
      ChooseCancelReasonEvent event, Emitter<HomeState> emit) async {
    choosenCancelReason = event.choosen;
    cancelReasonText.clear();
    emit(ChoosenCancelReasonState());
  }

  Future<void> cancelReasonChoose(
      HideCancelReasonEvent event, Emitter<HomeState> emit) async {
    if (showCancelReason) {
      showCancelReason = false;
    }
    emit(CancelReasonSuccessState());
  }

  Future<void> showChatFunc(
      ShowChatEvent event, Emitter<HomeState> emit) async {
    if (showChat) {
      showChat = false;
      emit(UpdateState());
    } else {
      showChat = true;
      emit(ShowChatState());
    }
  }

  Future<void> updateDistanceBetween(
      ChangeDistanceEvent event, Emitter<HomeState> emit) async {
    final matchedOption = _matchDistanceOption(event.distance);
    distanceBetween = matchedOption['dist'];
    emit(DistanceUpdateState());
    await AppSharedPreference.setDistanceBetween(distanceBetween!);
    streamBidRequest();
  }

  Future<void> changeReview(
      ReviewUpdateEvent event, Emitter<HomeState> emit) async {
    review = event.star;
    emit(ReviewUpdateState());
  }

  // UserDetails
  FutureOr<void> getUserDetails(
      GetUserDetailsEvent event, Emitter<HomeState> emit) async {
    if (Platform.isAndroid) {
      final overlayPermission = await NativeService().checkPermission();
      final wake = await WakelockPlus.enabled;

      if (overlayPermission && Platform.isAndroid) {
        if (!wake) {
          WakelockPlus.enable();
        }
      }
    }
    final data = await serviceLocator<HomeUsecase>().userDetails(
      requestId: _lastShownRequestId,
    );
    await data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          stopUserDetailsTimer();
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
        if (event.loading == 1) {
          emit(HomeDataLoadingStopState());
        }
      },
      (success) async {
        if (!isAppMapChange) {
          mapType = success.data.mapType;
          await AppSharedPreference.setMapType(mapType);
        }

        if (userData == null) {
          var val = await AppSharedPreference.getBidSettingStatus();
          isBiddingEnabled = val;
          var bubble = await AppSharedPreference.getBubbleSettingStatus();
          showBubbleIcon = bubble;
          var subscription =
              await AppSharedPreference.getSubscriptionSkipStatus();
          subscriptionSkip = subscription;
        }
        userData = success.data;
        await _syncDistanceBetweenOptions(emit);
        selectedSubVehicleTypes = userData!.vehicleTypes!;

        // Start the automatic user details refresh timer
        // startUserDetailsTimer();

        // Ensure request stream is active to auto-trigger GetUserDetailsEvent on new rides
        if (userData!.onTripRequest != null &&
            (acceptSharedRides || userData!.enableSecondRideForDriver == '1')) {
          if (requestStream == null) {
            streamRequest();
          }
        }

        if (userData!.onTripRequest != null &&
            userData!.enableSecondRideForDriver == '1' &&
            userData!.hasWaitingRide) {
          requestStream?.cancel();
          requestStream = null;
          onTripSearchNewRide = false;
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userData!.id}')
              .update({
            'is_available': false,
          });
        }

        if (userData!.onTripRequest == null) {
          if (userData!.onTripRequest == null &&
              userData!.metaRequest == null) {
            addReview = false;
            showSignature = false;
          }
          if (choosenCompleteStop != null) {
            choosenCompleteStop = null;
          }
          if (showChat) {
            showChat = false;
          }
          if (chats.isNotEmpty) {
            chats.clear();
          }
          if (showOtp) {
            showOtp = false;
          }
          if (showImagePick) {
            showImagePick = false;
          }
          if (showSignature) {
            showSignature = false;
          }
          waitingTimeBeforeStart = 0;
          waitingTimeAfterStart = 0;
          tripDistance = 0.0;
          if (waitingTimer != null) {
            waitingTimer?.cancel();
            waitingTimer = null;
          }
          if (showCancelReason) {
            showCancelReason = false;
          }
          if (rideStream != null) {
            rideAddStream?.cancel();
            rideAddStream = null;
            rideStream?.cancel();
            rideStream = null;
          }
          if (ownersDriver == null &&
              userData!.role == 'owner' &&
              userData!.isDeletedAt == '') {
            streamOwnersDriver();
          }
          emit(UpdateState());
        }

        if (positionSubscription == null &&
            userData!.role == 'driver' &&
            userData!.active &&
            userData!.isDeletedAt == '') {
          streamLocation();
        }

        if (event.isRideEnd != null && event.isRideEnd!) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userData!.id}')
              .update({
            'total_rides_taken': userData!.totalRidesTaken,
            'total_kms': userData!.totalKms,
            'total_active_hrs': userData!.totalMinutesOnline
          });
        }
        if (userData!.isDeletedAt.isNotEmpty && userData!.active) {
          FirebaseDatabase.instance
              .ref()
              .child('drivers/driver_${userData!.id}')
              .update({
            'is_active': 0,
            'is_available': false,
          });
        }

        if (userData != null && userData!.isDeletedAt == '') {
          if (userData!.serviceLocationId != null &&
              userData!.uploadedDocument == true &&
              userData!.approve == true) {
            addReview = false;
            if (userData!.metaRequest != null && searchTimer == null) {
              timer = userData!.acceptDuration;
              rideSearchTimer();
            } else if (userData!.metaRequest == null && searchTimer != null) {
              searchTimer?.cancel();
              searchTimer = null;
            }
            if (userData!.metaRequest != null && choosenMenu != 0) {
              choosenMenu = 0;
            }
            if (userData!.metaRequest != null) {
              add(StreamRequestEvent());
            }
            if (userData!.metaRequest == null &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.arrivedAt != null &&
                waitingTimer == null &&
                userData!.onTripRequest!.isBidRide == "0") {
              waitingTime();
            } else if (userData!.metaRequest == null &&
                userData!.onTripRequest != null) {
              var val = await FirebaseDatabase.instance
                  .ref('requests/${userData!.onTripRequest!.id}')
                  .get();

              if (val.child('trip_distance').value != null) {
                tripDistance =
                    double.parse(val.child('trip_distance').value.toString());
              }
              if (val.child('driver_tips').value != null) {
                driverTips =
                    double.parse(val.child('driver_tips').value.toString());
              }
              if (val.child('is_user_paid').value != null) {
                isUserPaidPayment =
                    (val.child('is_user_paid').value as bool?) ?? false;
                rideRepository.updatePaymentReceived(isUserPaidPayment);
              } else {
                isUserPaidPayment =
                    userData!.onTripRequest!.isPaid == 1 ? true : false;
                rideRepository.updatePaymentReceived(isUserPaidPayment);
              }
              if (val.child('payment_method').value != null) {
                paymentChanged = (val.child('payment_method').value.toString());
                rideRepository.updatePaymentChange(paymentChanged);
              } else {
                paymentChanged = userData!.onTripRequest!.paymentType;
                rideRepository.updatePaymentChange(paymentChanged);
              }
            }
            if (userData!.metaRequest == null &&
                userData!.onTripRequest != null &&
                rideStream == null) {
              streamRide();
              if (userData!.onTripRequest!.isCompleted != 1) {
                var val = await FirebaseDatabase.instance
                    .ref('requests/${userData!.onTripRequest!.id}')
                    .get();
                if (val.child('lat_lng_array').value != null) {
                  latlngArray =
                      jsonDecode(jsonEncode(val.child('lat_lng_array').value));
                  if (currentLatLng != null) {
                    latlngArray.add({
                      "lat": currentLatLng!.latitude,
                      'lng': currentLatLng!.longitude
                    });
                  }
                }
              }
            }
            if ((userData!.metaRequest == null &&
                    userData!.onTripRequest == null) &&
                (polyline.isNotEmpty ||
                    fmpoly.isNotEmpty ||
                    markers
                        .where((element) =>
                            element.markerId != const MarkerId('my_loc'))
                        .isNotEmpty)) {
              polyline.clear();
              polygons.clear();
              fmpoly.clear();
              markers.removeWhere(
                  (element) => element.markerId != const MarkerId('my_loc'));
            }
            if (userData!.active == true &&
                userData!.available == true &&
                userData!.metaRequest == null &&
                userData!.onTripRequest == null) {
              if (requestStream == null) {
                streamRequest();
              }
              if (bidRequestStream == null &&
                  (userData!.enableBidding == true ||
                      userData!.enableBidOnFare == true)) {
                isBiddingEnabled = true;
                AppSharedPreference.setBidSettingStatus(true);
                streamBidRequest();
              } else if (userData!.enableBidding == false &&
                  userData!.enableBidOnFare == false) {
                bidRequestStream = null;
                bidRequestStream?.cancel();
                isBiddingEnabled = false;
                AppSharedPreference.setBidSettingStatus(false);
              }
              updateFirebaseData();
            } else if ((userData!.active == false ||
                    userData!.available == false) &&
                onTripSearchNewRide == false) {
              if (requestStream != null) {
                requestStream!.cancel();
                requestStream = null;
              }
              if (bidRequestStream != null) {
                bidRequestStream!.cancel();
                bidRequestStream = null;
              }
              updateFirebaseData();
            }
            if (userData!.onTripRequest != null && showBiddingPage == true) {
              showBiddingPage = false;
            }

            if ((userData!.onTripRequest != null ||
                    userData!.metaRequest != null) &&
                (polyline.isEmpty ||
                    (userData!.hasWaitingRide == false &&
                        onTripSearchNewRide)) &&
                (userData!.onTripRequest == null ||
                    userData!.onTripRequest!.isCompleted == 0)) {
              showPeakZones = false;
              polygons.removeWhere(
                  (element) => element.polygonId.value.contains('peakzone_'));
              polyline.removeWhere(
                  (element) => element.polylineId.value.contains('peakzone_'));
              add(TripMarkersAddEvent()); // Markers Add
            } else if (userData!.metaRequest == null &&
                userData!.onTripRequest != null &&
                (userData!.onTripRequest!.arrivedAt == null ||
                    userData!.onTripRequest!.arrivedAt == "") &&
                userData!.onTripRequest!.isBidRide == '1') {
              add(PolylineEvent(
                  pickLat: currentLatLng!.latitude,
                  pickLng: currentLatLng!.longitude,
                  dropLat: userData!.onTripRequest!.pickLat,
                  dropLng: userData!.onTripRequest!.pickLng,
                  stops: [],
                  packageName: AppConstants.packageName,
                  signKey: AppConstants.signKey,
                  pickAddress: userData!.onTripRequest!.pickAddress,
                  dropAddress: userData!.onTripRequest!.dropAddress ?? '',
                  isTripEndCall: false));
            }
          } else {
            vehicleNotUpdated = true;
            emit(VehicleNotUpdatedState());
            userData!.active = false;
            userData!.available = false;
            FirebaseDatabase.instance
                .ref()
                .child('drivers/driver_${userData!.id}')
                .update({
              'approve': 0,
              'is_active': 0,
              'is_available': false,
            });
            if (Platform.isAndroid) {
              WakelockPlus.disable();
              showBubbleIcon = false;
            }
            if (activeTimer != null) {
              activeTimer!.cancel();
              activeTimer = null;
            }
            if (requestStream != null) {
              requestStream?.cancel();
              requestStream = null;
            }
            if (bidRequestStream != null) {
              bidRequestStream?.cancel();
              bidRequestStream = null;
            }
            if (positionSubscription != null) {
              positionSubscription?.cancel();
              positionSubscription = null;
            }
          }
        } else {
          if (bidRequestStream != null) {
            bidRequestStream?.cancel();
            bidRequestStream = null;
          }
          if (requestStream != null) {
            requestStream?.cancel();
            requestStream = null;
          }
          if (rideStream != null) {
            rideStream?.cancel();
            rideStream = null;
          }
          if (currentPosition != null) {
            currentPosition?.cancel();
            currentPosition = null;
          }
        }
        emit(UserDetailsSuccessState());

        // Ensure peak zones refresh when returning to the map page without movement
        if (userData != null &&
            userData!.role == 'driver' &&
            userData!.active &&
            userData!.available &&
            userData!.metaRequest == null &&
            userData!.onTripRequest == null &&
            showPeakZoneButton) {
          showPeakZones = true;
          if (zoneStreamRemove == null) {
            add(GetPeakZoneEvent());
          } else {
            add(UpdateEvent());
          }
        }
        if (event.loading == 1) {
          emit(HomeDataLoadingStopState());
        }
      },
    );
  }

  FutureOr<void> tripMarkersAdd(
      TripMarkersAddEvent event, Emitter<HomeState> emit) async {
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }
    // Meta Request =================================================>
    if (userData!.metaRequest != null &&
        (polyline.isEmpty ||
            (userData!.hasWaitingRide == false && onTripSearchNewRide)) &&
        userData!.metaRequest!.dropAddress != null) {
      if (userData!.metaRequest!.polyline != null &&
          userData!.metaRequest!.polyline!.isNotEmpty) {
        markers.removeWhere(
            (element) => element.markerId != const MarkerId('my_loc'));
        markers.add(Marker(
          markerId: const MarkerId("pick"),
          position: LatLng(
              userData!.metaRequest!.pickLat, userData!.metaRequest!.pickLng),
          rotation: 0.0,
          icon: await Image.asset(
            AppImages.pickupIcon,
            height: 30,
            width: 30,
            fit: BoxFit.contain,
          ).toBitmapDescriptor(
            logicalSize: const Size(30, 30),
            imageSize: const Size(200, 200),
          ),
        ));
        if (userData!.metaRequest!.requestStops.isEmpty &&
            (userData!.metaRequest!.dropAddress != null &&
                userData!.metaRequest!.dropAddress != "")) {
          markers.add(Marker(
            markerId: const MarkerId("drop"),
            position: LatLng(userData!.metaRequest!.dropLat!,
                userData!.metaRequest!.dropLng!),
            rotation: 0.0,
            icon: await const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                )).toBitmapDescriptor(
              logicalSize: const Size(30, 30),
              imageSize: const Size(200, 200),
            ),
          ));
        } else if (userData!.metaRequest!.requestStops.isNotEmpty) {
          for (var i = 0; i < userData!.metaRequest!.requestStops.length; i++) {
            markers.add(Marker(
              markerId: MarkerId("drop$i"),
              position: LatLng(
                  userData!.metaRequest!.requestStops[i]['latitude'],
                  userData!.metaRequest!.requestStops[i]['longitude']),
              rotation: 0.0,
              icon: (i == userData!.metaRequest!.requestStops.length - 1)
                  ? await const Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      )).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    )
                  : await Image.asset(
                      (i == 0)
                          ? AppImages.stopOne
                          : (i == 1)
                              ? AppImages.stopTwo
                              : (i == 2)
                                  ? AppImages.stopThree
                                  : AppImages.stopFour,
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
                    ).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    ),
            ));
          }
        }
        if (userData!.metaRequest!.dropLat != null &&
            userData!.metaRequest!.dropLng != null) {
          await addDistanceMarker(
              LatLng(userData!.metaRequest!.dropLat!,
                  userData!.metaRequest!.dropLng!),
              (userData!.distanceUnit == 'mi'
                  ? ((double.parse(userData!.metaRequest!.totalDistance) *
                          1.60934) *
                      1000)
                  : double.parse(userData!.metaRequest!.totalDistance) * 1000),
              time: double.parse(userData!.metaRequest!.totalTime.toString()));
        }
        mapBound(
            userData!.metaRequest!.pickLat,
            userData!.metaRequest!.pickLng,
            userData!.metaRequest!.dropLat!,
            userData!.metaRequest!.dropLng!,
            userData!.metaRequest!.requestStops);
        decodeEncodedPolyline(userData!.metaRequest!.polyline!);
      } else {
        add(PolylineEvent(
            pickLat: userData!.metaRequest!.pickLat,
            pickLng: userData!.metaRequest!.pickLng,
            dropLat: userData!.metaRequest!.dropLat!,
            dropLng: userData!.metaRequest!.dropLng!,
            stops: userData!.metaRequest!.requestStops,
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: userData!.metaRequest!.pickAddress,
            dropAddress: userData!.metaRequest!.dropAddress ?? '',
            isTripEndCall: false));
      }
      // OnTrip Request =================================================>
    } else if (polyline.isEmpty &&
        userData!.onTripRequest != null &&
        (userData!.onTripRequest!.dropAddress != null ||
            (userData!.onTripRequest!.isRental &&
                (userData!.onTripRequest!.arrivedAt == null ||
                    userData!.onTripRequest!.arrivedAt == "")))) {
      add(GetRideChatEvent());
      if (userData!.onTripRequest!.polyline != null &&
          userData!.onTripRequest!.polyline!.isNotEmpty &&
          (userData!.onTripRequest!.arrivedAt != null &&
              userData!.onTripRequest!.arrivedAt != "")) {
        mapBound(
            userData!.onTripRequest!.pickLat,
            userData!.onTripRequest!.pickLng,
            userData!.onTripRequest!.dropLat!,
            userData!.onTripRequest!.dropLng!,
            userData!.onTripRequest!.requestStops);
        decodeEncodedPolyline(userData!.onTripRequest!.polyline!);
        markers.removeWhere(
            (element) => element.markerId != const MarkerId('my_loc'));
        markers.add(Marker(
          markerId: const MarkerId("pick"),
          position: LatLng(userData!.onTripRequest!.pickLat,
              userData!.onTripRequest!.pickLng),
          rotation: 0.0,
          icon: await Image.asset(
            AppImages.pickupIcon,
            height: 30,
            width: 30,
            fit: BoxFit.contain,
          ).toBitmapDescriptor(
            logicalSize: const Size(30, 30),
            imageSize: const Size(200, 200),
          ),
        ));
        if (userData!.onTripRequest!.requestStops.isEmpty &&
            (userData!.onTripRequest!.dropAddress != null &&
                userData!.onTripRequest!.dropAddress != "")) {
          markers.add(Marker(
            markerId: const MarkerId("drop"),
            position: LatLng(userData!.onTripRequest!.dropLat!,
                userData!.onTripRequest!.dropLng!),
            rotation: 0.0,
            icon: await const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                )).toBitmapDescriptor(
              logicalSize: const Size(30, 30),
              imageSize: const Size(200, 200),
            ),
          ));
        } else if (userData!.onTripRequest!.requestStops.isNotEmpty) {
          for (var i = 0;
              i < userData!.onTripRequest!.requestStops.length;
              i++) {
            markers.add(Marker(
              markerId: MarkerId("drop$i"),
              position: LatLng(
                  userData!.onTripRequest!.requestStops[i]['latitude'],
                  userData!.onTripRequest!.requestStops[i]['longitude']),
              rotation: 0.0,
              icon: (i == userData!.onTripRequest!.requestStops.length - 1)
                  ? await const Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      )).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    )
                  : await Image.asset(
                      (i == 0)
                          ? AppImages.stopOne
                          : (i == 1)
                              ? AppImages.stopTwo
                              : (i == 2)
                                  ? AppImages.stopThree
                                  : AppImages.stopFour,
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
                    ).toBitmapDescriptor(
                      logicalSize: const Size(30, 30),
                      imageSize: const Size(200, 200),
                    ),
            ));
          }
        }
        if (userData!.onTripRequest != null &&
            (userData!.onTripRequest!.arrivedAt != null &&
                userData!.onTripRequest!.arrivedAt != "")) {
          if (userData!.onTripRequest!.isTripStart != 1 ||
              (userData!.onTripRequest!.isTripStart == 1 &&
                  destinationChanged)) {
            destinationChanged = false;
            FirebaseDatabase.instance
                .ref('requests')
                .child(userData!.onTripRequest!.id)
                .update({
              'polyline': userData!.onTripRequest!.polyline,
              'distance': (userData!.distanceUnit == 'mi'
                  ? ((double.parse(userData!.onTripRequest!.totalDistance) *
                          1.60934) *
                      1000)
                  : double.parse(userData!.onTripRequest!.totalDistance) *
                      1000),
              'duration': userData!.onTripRequest!.totalTime,
            });
            await addDistanceMarker(
                LatLng(userData!.onTripRequest!.dropLat!,
                    userData!.onTripRequest!.dropLng!),
                (userData!.distanceUnit == 'mi'
                    ? ((double.parse(userData!.onTripRequest!.totalDistance) *
                            1.60934) *
                        1000)
                    : double.parse(userData!.onTripRequest!.totalDistance) *
                        1000),
                time: double.parse(
                    userData!.onTripRequest!.totalTime.toString()));
          } else {
            double minPerDistance =
                double.parse(userData!.onTripRequest!.totalTime.toString()) /
                    double.parse(userData!.onTripRequest!.totalDistance);
            double dist = calculateDistance(
              lat1: currentLatLng!.latitude,
              lon1: currentLatLng!.longitude,
              lat2: userData!.onTripRequest!.dropLat!,
              lon2: userData!.onTripRequest!.dropLng!,
              unit: userData?.distanceUnit ?? 'km',
            );
            final dist1 = calculateDistance(
              lat1: userData!.onTripRequest!.pickLat,
              lon1: userData!.onTripRequest!.pickLng,
              lat2: currentLatLng!.latitude,
              lon2: currentLatLng!.longitude,
              unit: userData?.distanceUnit ?? 'km',
            );
            final calDuration =
                double.parse(userData!.onTripRequest!.totalTime.toString()) -
                    ((dist1) * minPerDistance);
            FirebaseDatabase.instance
                .ref('requests')
                .child(userData!.onTripRequest!.id)
                .update({
              'distance': (userData!.distanceUnit == 'mi'
                  ? ((dist * 1.60934) * 1000)
                  : dist * 1000),
              'duration': calDuration
            });
            await addDistanceMarker(
                LatLng(userData!.onTripRequest!.dropLat!,
                    userData!.onTripRequest!.dropLng!),
                (userData!.distanceUnit == 'mi'
                    ? ((dist * 1.60934) * 1000)
                    : dist * 1000),
                time: calDuration);
          }
          add(UpdateEvent());
        }
      } else if (userData!.onTripRequest!.arrivedAt == null ||
          userData!.onTripRequest!.arrivedAt == "") {
        add(PolylineEvent(
            pickLat: currentLatLng!.latitude,
            pickLng: currentLatLng!.longitude,
            dropLat: userData!.onTripRequest!.pickLat,
            dropLng: userData!.onTripRequest!.pickLng,
            stops: [],
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: userData!.onTripRequest!.pickAddress,
            dropAddress: userData!.onTripRequest!.dropAddress ?? '',
            isTripEndCall: false));
      } else {
        add(PolylineEvent(
            pickLat: userData!.onTripRequest!.pickLat,
            pickLng: userData!.onTripRequest!.pickLng,
            dropLat: userData!.onTripRequest!.dropLat!,
            dropLng: userData!.onTripRequest!.dropLng!,
            stops: userData!.onTripRequest!.requestStops,
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: userData!.onTripRequest!.pickAddress,
            dropAddress: userData!.onTripRequest!.dropAddress ?? '',
            isTripEndCall: false));
      }
      // RideWithout Destination =======================================>
    } else if (userData!.onTripRequest != null &&
        userData!.onTripRequest!.isRental &&
        userData!.onTripRequest!.arrivedAt != null &&
        userData!.onTripRequest!.arrivedAt != "") {
      markers.removeWhere(
          (element) => element.markerId != const MarkerId('my_loc'));
      FirebaseDatabase.instance
          .ref('requests')
          .child(userData!.onTripRequest!.id)
          .update({'polyline': '', 'distance': 0.0, 'duration': 0.0});
    } else if (((userData!.onTripRequest != null &&
                userData!.onTripRequest!.dropAddress == null) ||
            (userData!.metaRequest != null &&
                polyline.isEmpty &&
                userData!.metaRequest!.dropAddress == null)) &&
        markers.where((e) => e.markerId == const MarkerId("pick")).isEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId("pick"),
          position: (userData!.onTripRequest != null)
              ? LatLng(userData!.onTripRequest!.pickLat,
                  userData!.onTripRequest!.pickLng)
              : LatLng(userData!.metaRequest!.pickLat,
                  userData!.metaRequest!.pickLng),
          rotation: 0.0,
          icon: await Image.asset(
            AppImages.pickupIcon,
            height: 30,
            width: 30,
            fit: BoxFit.contain,
          ).toBitmapDescriptor(
            logicalSize: const Size(30, 30),
            imageSize: const Size(200, 200),
          ),
        ),
      );

      googleMapController!.animateCamera(CameraUpdate.newLatLng(
          (userData!.onTripRequest != null)
              ? LatLng(userData!.onTripRequest!.pickLat,
                  userData!.onTripRequest!.pickLng)
              : LatLng(userData!.metaRequest!.pickLat,
                  userData!.metaRequest!.pickLng)));
    }
    emit(UpdateState());
  }

  // Accept reject
  FutureOr<void> uploadProof(
      UploadProofEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    searchTimer?.cancel();
    searchTimer = null;

    final data = await serviceLocator<RideUsecases>().uploadProof(
        proofImage: event.image, isBefore: event.isBefore, id: event.id);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        }
        timer = userData!.acceptDuration;
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (signatureImage != null) {
          if (userData!.onTripRequest!.requestStops.isNotEmpty &&
              userData!.onTripRequest!.requestStops
                      .where((e) => e['completed_at'] == null)
                      .length >
                  1) {
            signatureImage = null;
            showSignature = false;
            showImagePick = false;
            showOtp = false;
            add(CompleteStopEvent(id: choosenCompleteStop!));
          } else {
            add(GeocodingLatLngEvent(
                lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
            signatureImage = null;
          }
        } else if (unloadImage != null) {
          if (userData!.onTripRequest!.enableDigitalSignature == '1') {
            add(ShowSignatureEvent());
          } else {
            emit(HomeDataLoadingStopState());
            if (userData!.onTripRequest!.requestStops.isNotEmpty &&
                userData!.onTripRequest!.requestStops
                        .where((e) => e['completed_at'] == null)
                        .length >
                    1) {
              showImagePick = false;
              showOtp = false;
              add(CompleteStopEvent(id: choosenCompleteStop!));
            } else {
              add(GeocodingLatLngEvent(
                  lat: currentLatLng!.latitude, lng: currentLatLng!.longitude));
            }
          }
          unloadImage = null;
          showUnloadImage = null;
        } else if (loadImage != null) {
          if (userData!.onTripRequest!.isTripStart == 0) {
            add(RideStartEvent(
                requestId: userData!.onTripRequest!.id,
                otp: rideOtp.text,
                pickLat: currentLatLng!.latitude,
                pickLng: currentLatLng!.longitude));
          }
          showImagePick = false;
          loadImage = null;
          showLoadImage = null;
        }
      },
    );
    emit(HomeDataLoadingStopState());
  }

  // Accept reject
  FutureOr<void> stopComplete(
      CompleteStopEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().stopComplete(
      id: event.id,
    );
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) {
        userData!.onTripRequest!.requestStops.firstWhere((e) =>
                e['id'].toString() == choosenCompleteStop)['completed_at'] =
            DateTime.now().toString();
        choosenCompleteStop = null;
        emit(HomeDataLoadingStopState());
      },
    );
  }

  // Accept reject
  FutureOr<void> respondRequest(
      AcceptRejectEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    if (event.status == 1) {
      isAcceptLoading = true;
    } else {
      isRejectLoading = true;
    }

    searchTimer?.cancel();
    searchTimer = null;
    emit(UpdateState());

    final data = await serviceLocator<RideUsecases>()
        .respondRequest(requestId: event.requestId, status: event.status);

    data.fold(
      (error) {
        timer = userData!.acceptDuration;
        if (error.statusCode == 500 ||
            error.message == "request already cancelled") {
          userData!.metaRequest = null;
          polyline.clear();
          polygons.clear();
          fmpoly.clear();
          latlngArray.clear();
          tripDistance = 0.0;
          waitingTimeBeforeStart = 0;
          waitingTimeAfterStart = 0;
          updateFirebaseData();
          add(GetUserDetailsEvent());
        }
        isAcceptLoading = false;
        isRejectLoading = false;
        isLoading = false;
        emit(UpdateState());
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (event.status == 1) {
          userData!.onTripRequest = success.data;
          userData!.metaRequest = null;
          polyline.clear();
          polygons.clear();
          fmpoly.clear();
          latlngArray.clear();
          tripDistance = 0.0;
          waitingTimeBeforeStart = 0;
          waitingTimeAfterStart = 0;
          updateFirebaseData();
          // Reset tracking when request is accepted so next new request can be shown
          _lastShownRequestId = null;
          isLoading = false;
        } else {
          userData!.metaRequest = null;
          polyline.clear();
          polygons.clear();
          fmpoly.clear();
          isLoading = false;
          // Reset tracking when request is rejected so next new request can be shown
          _lastShownRequestId = null;
          emit(UpdateState());
        }
        isAcceptLoading = false;
        isRejectLoading = false;
        emit(UpdateState());
        add(GetUserDetailsEvent());
      },
    );
  }

  // ride arrived
  FutureOr<void> rideArrived(
      RideArrivedEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    emit(LoadingStartState());
    emit(UpdateState());

    final data = await serviceLocator<RideUsecases>().rideArrived(
      requestId: event.requestId,
    );

    data.fold(
      (error) {
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) async {
        FirebaseDatabase.instance.ref('requests').child(event.requestId).update(
            {'trip_arrived': '1', 'modified_by_driver': ServerValue.timestamp});
        polyline.clear();
        polygons.clear();
        fmpoly.clear();
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());
        add(GetUserDetailsEvent());
        if (userData!.onTripRequest!.isBidRide == "0") {
          waitingTime();
        }
      },
    );
  }

  // ride arrived
  FutureOr<void> cancelRequest(
      CancelRequestEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().cancelRequest(
        requestId: userData!.onTripRequest!.id,
        reason: (cancelReasonText.text.isNotEmpty) ? cancelReasonText.text : '',
        choosenReason: (cancelReasonText.text.isNotEmpty)
            ? ''
            : cancelReasons[choosenCancelReason!].id);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(HomeDataLoadingStopState());
      },
      (success) async {
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({'cancelled_by_driver': true, 'is_cancelled': true});
        add(HideCancelReasonEvent());
        add(GetUserDetailsEvent(loading: 1));
      },
    );
  }

  // get ride chats
  FutureOr<void> getRideChats(
      GetRideChatEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().getRideChat(
      requestId: userData!.onTripRequest!.id,
    );
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        chats = success.chats;
        emit(RideChatSuccessState());
      },
    );
  }

  // get cancel reason
  FutureOr<void> getCancelReason(
      GetCancelReasonEvent event, Emitter<HomeState> emit) async {
    cancelReasons.clear();
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>().getCancelReason(
        requestId: userData!.onTripRequest!.id,
        arrived:
            userData!.onTripRequest!.arrivedAt == null ? 'before' : 'after');
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        choosenCancelReason = null;
        cancelReasons = success.data;
        showCancelReason = true;

        emit(CancelReasonSuccessState());
      },
    );
    emit(HomeDataLoadingStopState());
  }

  // chats seen
  FutureOr<void> chatSeen(ChatSeenEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().chatSeen(
      requestId: userData!.onTripRequest!.id,
    );
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        chats.where((e) => e['seen'] == 0).forEach((v) {
          v['seen'] = 1;
        });

        emit(RideChatSuccessState());
      },
    );
  }

  // send chat
  FutureOr<void> sendChat(SendChatEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().sendChat(
        requestId: userData!.onTripRequest!.id, message: event.message);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({'message_by_driver': chats.length + 1});
        add(GetRideChatEvent());
        emit(RideChatSuccessState());
      },
    );
  }

  // ride start
  FutureOr<void> getGoodsType(
      GetGoodsTypeEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    if (goodsList.isEmpty) {
      final data = await serviceLocator<RideUsecases>().getGoodsType();
      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) {
          goodsList = success.goods;
        },
      );
    }
    goodsSizeText.clear();
    goodsSize = 'Loose';
    choosenGoods = null;
    emit(HomeDataLoadingStopState());
    emit(GetGoodsSuccessState());
  }

  // ride start
  FutureOr<void> rideStart(
      RideStartEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    emit(LoadingStartState());
    emit(UpdateState());

    final data = await serviceLocator<RideUsecases>().rideStart(
        requestId: event.requestId,
        otp: event.otp,
        pickLat: event.pickLat,
        pickLng: event.pickLng);

    data.fold(
      (error) {
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());

        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          emit(LoadingStopState());
          emit(UpdateState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        isLoading = false;
        showOtp = false;
        showImagePick = false;
        audioPlayer.play(AssetSource(AppAudios.started));
        FirebaseDatabase.instance.ref('requests').child(event.requestId).update(
            {'trip_start': '1', 'modified_by_driver': ServerValue.timestamp});
        emit(LoadingStopState());
        emit(UpdateState());
        emit(RideStartSuccessState());
        add(GetUserDetailsEvent());
      },
    );
  }

  // ride end
  FutureOr<void> rideEnd(RideEndEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    emit(LoadingStartState());
    emit(UpdateState());
    final data = await serviceLocator<RideUsecases>().rideEnd(
      requestId: userData!.onTripRequest!.id,
      distance: double.parse((tripDistance).toStringAsFixed(2)),
      dropLat: event.isAfterGeoCodeEnd
          ? dropLatLng!.latitude
          : (userData!.onTripRequest!.isRental == false &&
                  userData!.onTripRequest!.isOutstation != 1 &&
                  userData!.onTripRequest!.dropAddress != null)
              ? userData!.onTripRequest!.dropLat!
              : currentLatLng!.latitude,
      dropLng: event.isAfterGeoCodeEnd
          ? dropLatLng!.longitude
          : (userData!.onTripRequest!.isRental == false &&
                  userData!.onTripRequest!.isOutstation != 1 &&
                  userData!.onTripRequest!.dropAddress != null)
              ? userData!.onTripRequest!.dropLng!
              : currentLatLng!.longitude,
      dropAddress: event.isAfterGeoCodeEnd
          ? dropAddress
          : (userData!.onTripRequest!.isRental == false &&
                  userData!.onTripRequest!.isOutstation != 1 &&
                  userData!.onTripRequest!.dropAddress != null)
              ? userData!.onTripRequest!.dropAddress!
              : dropAddress,
      beforeTripStartWaitingTime:
          (int.parse((waitingTimeBeforeStart / 60).toStringAsFixed(0)) >
                  userData!.onTripRequest!.freeWaitingTimeBeforeStart)
              ? int.parse((waitingTimeBeforeStart / 60).toStringAsFixed(0)) -
                  userData!.onTripRequest!.freeWaitingTimeBeforeStart
              : 0,
      afterTripStartWaitingTime:
          (int.parse((waitingTimeAfterStart / 60).toStringAsFixed(0)) >
                  userData!.onTripRequest!.freeWaitingTimeAfterStart)
              ? int.parse((waitingTimeAfterStart / 60).toStringAsFixed(0)) -
                  userData!.onTripRequest!.freeWaitingTimeAfterStart
              : 0,
      polyString: (userData!.onTripRequest!.polyline != null)
          ? userData!.onTripRequest!.polyline!
          : polyString,
    );
    data.fold(
      (error) {
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        printWrapped('text 777777777777 --------- ');
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());
        audioPlayer.play(AssetSource(AppAudios.ended));
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          'is_completed':
              userData!.onTripRequest!.isCompleted == 0 ? false : true,
          'modified_by_driver': ServerValue.timestamp
        });
        onTripSearchNewRide = false;
        addReview = false;
        dropAddress = '';
        dropLatLng = null;
        additionalChargeAmount = '';
        additionalChargeText = '';
        userData!.onTripRequest = success.data;
        // paymentChanged = '';
        add(UpdateEvent());
        add(GetUserDetailsEvent(isRideEnd: true));
        printWrapped('text 888888888888888 --------- ');
      },
    );
  }

//  Locations
  Future<void> getCurrentLocation(
      GetCurrentLocationEvent event, Emitter<HomeState> emit) async {
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double long = position.longitude;
      currentLatLng = LatLng(lat, long);
      if (!isClosed) {
        add(UpdateLocationEvent(latLng: LatLng(lat, long)));
      }

      if (currentPosition == null) {
        currentPositionUpdate();
      }
    } else {
      showToast(
          message: AppLocalizations.of(navigatorKey.currentContext!)!
              .getYourCurrentLocation);
      emit(GetLocationPermissionState());
    }
  }

  Future<void> updateLocation(
      UpdateLocationEvent event, Emitter<HomeState> emit) async {
    currentLatLng = event.latLng;
    initialCameraPosition = CameraPosition(target: currentLatLng!, zoom: 15);

    if (userData != null && userData!.role == 'driver') {
      final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.bikeOffline);

      final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.car);

      final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.auto);

      final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.truck);

      final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.ehcv);

      final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.hatchBack);

      final BitmapDescriptor hcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.hcv);

      final BitmapDescriptor lcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.lcv);

      final BitmapDescriptor mcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.mcv);

      final BitmapDescriptor luxury = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.luxury);

      final BitmapDescriptor premium = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.premium);

      final BitmapDescriptor suv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.suv);

      vehicleMarker = (userData!.vehicleTypeIcon == 'truck')
          ? truckMarker
          : (userData!.vehicleTypeIcon == 'motor_bike')
              ? bikeMarker
              : (userData!.vehicleTypeIcon == 'auto')
                  ? autoMarker
                  : (userData!.vehicleTypeIcon == 'lcv')
                      ? lcv
                      : (userData!.vehicleTypeIcon == 'ehcv')
                          ? ehcv
                          : (userData!.vehicleTypeIcon == 'hatchback')
                              ? hatchBack
                              : (userData!.vehicleTypeIcon == 'hcv')
                                  ? hcv
                                  : (userData!.vehicleTypeIcon == 'mcv')
                                      ? mcv
                                      : (userData!.vehicleTypeIcon == 'luxury')
                                          ? luxury
                                          : (userData!.vehicleTypeIcon ==
                                                  'premium')
                                              ? premium
                                              : (userData!.vehicleTypeIcon ==
                                                      'suv')
                                                  ? suv
                                                  : carMarker;

      // Remove previous marker if exists
      markers.removeWhere(
          (element) => element.markerId == const MarkerId('my_loc'));
      markers.add(Marker(
          markerId: const MarkerId('my_loc'),
          rotation: 0.0,
          position: currentLatLng!,
          icon: vehicleMarker!,
          anchor: const Offset(0.5, 0.5)));
      add(UpdateEvent());
    }

    // You can also animate the camera to the new position
    if (googleMapController != null) {
      googleMapController
          ?.animateCamera(CameraUpdate.newLatLng(currentLatLng!));
    }

    emit(UpdateLocationState());
  }

  currentPositionUpdate() async {
    currentPosition?.cancel();
    LatLng? recentLocs;
    DateTime? updateTime;
    currentPosition = Timer.periodic(const Duration(seconds: 10), (val) {
      if (userData != null &&
          userData!.active == true &&
          (userData!.available == true || userData!.available == false)) {
        if (currentLatLng != null && currentLatLng! != recentLocs) {
          recentLocs = currentLatLng!;
          updateTime = DateTime.now();
          updateFirebaseData();
        } else {
          if (updateTime != null &&
              // DateTime.now().difference(updateTime!).inSeconds > 30) {
              DateTime.now().difference(updateTime!).inMinutes > 5) {
            updateTime = DateTime.now();
            updateFirebaseData();
          }
        }
      }
    });
  }

  waitingTime() async {
    waitingTimer?.cancel();
    LatLng? lastLatLng;
    var val = await FirebaseDatabase.instance
        .ref('requests/${userData!.onTripRequest!.id}')
        .get();
    if (val.child('waiting_time_before_start').value != null) {
      waitingTimeBeforeStart =
          int.parse(val.child('waiting_time_before_start').value.toString());
    }
    if (val.child('trip_distance').value != null) {
      tripDistance = double.parse(val.child('trip_distance').value.toString());
    }
    if (val.child('waiting_time_after_start').value != null) {
      waitingTimeAfterStart =
          int.parse(val.child('waiting_time_after_start').value.toString());
    }
    if (val.child('lat_lng_array').value != null) {
      latlngArray = jsonDecode(jsonEncode(val.child('lat_lng_array').value));
      if (currentLatLng != null) {
        latlngArray.add(
            {"lat": currentLatLng!.latitude, 'lng': currentLatLng!.longitude});
      }
    }
    add(WaitingTimeEvent());
    waitingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (userData!.onTripRequest != null &&
          userData!.onTripRequest!.isTripStart == 0) {
        waitingTimeBeforeStart += 60;
        updateFirebaseData();
        add(WaitingTimeEvent());
      } else {
        if (lastLatLng == null && currentLatLng != null) {
          lastLatLng = currentLatLng;
        } else if (currentLatLng == lastLatLng && currentLatLng != null) {
          waitingTimeAfterStart += 60;
          updateFirebaseData();
          add(WaitingTimeEvent());
        } else if (currentLatLng != null) {
          lastLatLng = currentLatLng;
        }
      }
    });
  }

  FutureOr<void> waitingTimerEmit(
      WaitingTimeEvent event, Emitter<HomeState> emit) async {
    emit(RideUpdateState());
  }

  audioPlay() {
    audioPlayer.play(AssetSource(AppAudios.requestSound));
  }

  rideTimerUpdate(RequestTimerEvent event, Emitter<HomeState> emit) async {
    emit(SearchTimerUpdateStatus());
  }

  rideSearchTimer() async {
    searchTimer?.cancel();
    if (waitingList.isEmpty) {
      searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        timer--;
        if (audioPlayer.state != PlayerState.playing) {
          audioPlay();
        }
        add(RequestTimerEvent());
      });
    } else {
      searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (waitingList.isNotEmpty && !showOutstationWidget) {
          var val = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(waitingList[0]
                  ['drivers']['driver_${userData!.id}']['bid_time']))
              .inSeconds;
          if (int.parse(val.toString()) >=
              int.parse(userData!.maximumTimeForFindDriversForBittingRide)) {
            searchTimer?.cancel();
            searchTimer = null;
            Future.delayed(const Duration(seconds: 2), () {
              if (userData!.onTripRequest == null) {
                FirebaseDatabase.instance
                    .ref()
                    .child(
                        'bid-meta/${waitingList[0]["request_id"]}/drivers/driver_${userData!.id}')
                    .update({"is_rejected": 'by_user'});
              }
            });
            waitingList.clear();
          }
          add(RequestTimerEvent());
        }
      });
    }
  }

  updateFirebaseData() async {
    if (userData != null) {
      FirebaseDatabase.instance
          .ref()
          .child('drivers/driver_${userData!.id}')
          .update({
        'bearing': 0,
        'date': DateTime.now().toString(),
        'id': userData!.id,
        if (currentLatLng != null)
          'g': geo.encode(currentLatLng!.longitude, currentLatLng!.latitude),
        'is_active': userData!.active == true ? 1 : 0,
        'profile_picture': userData!.profilePicture,
        'rating': userData!.rating,
        if (onTripSearchNewRide == false)
          'is_available': userData!.available == true ? true : false,
        if (currentLatLng != null)
          'l': {'0': currentLatLng!.latitude, '1': currentLatLng!.longitude},
        'mobile': userData!.mobile,
        'name': userData!.name,
        'vehicle_type_icon': userData!.vehicleTypeIcon,
        'updated_at': ServerValue.timestamp,
        'vehicle_number': userData!.carNumber,
        'vehicle_type_name': userData!.carMake,
        'vehicle_types': userData!.vehicleTypes,
        'ownerid': userData!.ownerId,
        'service_location_id': userData!.serviceLocationId,
        'transport_type': userData!.transportType,
        'preferences': selectedPreferenceDetailsList,
        'shared_ride': (userData!.onTripRequest != null &&
                userData!.onTripRequest!.sharedRide == true)
            ? 1
            : 0,
      });
      if (userData!.onTripRequest != null &&
          userData!.onTripRequest!.isCompleted == 0) {
        if (userData!.onTripRequest!.tripStartTime != null) {
          if (latlngArray.isNotEmpty &&
              (currentLatLng!.latitude !=
                      latlngArray[latlngArray.length - 1]['lat'] ||
                  currentLatLng!.longitude !=
                      latlngArray[latlngArray.length - 1]['lng'])) {
            var dist = calculateDistance(
              lat1: latlngArray[latlngArray.length - 1]['lat'],
              lon1: latlngArray[latlngArray.length - 1]['lng'],
              lat2: currentLatLng!.latitude,
              lon2: currentLatLng!.longitude,
              unit: userData?.distanceUnit ?? 'km',
            );
            latlngArray.add({
              "lat": currentLatLng!.latitude,
              'lng': currentLatLng!.longitude
            });
            tripDistance = tripDistance + dist;
          } else if (latlngArray.isEmpty && currentLatLng != null) {
            latlngArray.add({
              "lat": currentLatLng!.latitude,
              'lng': currentLatLng!.longitude
            });
          }
        }

        if (userData!.onTripRequest != null) {
          FirebaseDatabase.instance
              .ref()
              .child('requests/${userData!.onTripRequest!.id}')
              .update({
            'trip_distance': tripDistance,
            'driver_id': userData!.id,
            if (currentLatLng != null) 'lat': currentLatLng!.latitude,
            if (currentLatLng != null) 'lng': currentLatLng!.longitude,
            'name': userData!.name,
            'profile_picture': userData!.profilePicture,
            'rating': userData!.rating,
            'lat_lng_array': latlngArray,
            'request_id': userData!.onTripRequest!.id,
            'vehicle_type_icon': userData!.vehicleTypeIcon,
            'transport_type': userData!.transportType,
            'waiting_time_before_start': waitingTimeBeforeStart,
            'waiting_time_after_start': waitingTimeAfterStart
          });
        }
      }
      // add(UpdateEvent());
    }

    var val = await FirebaseDatabase.instance.ref('peak-zones').get();
    if (val.exists) {
      showPeakZoneButton = true;

      if (userData != null &&
          userData!.role == 'driver' &&
          userData!.metaRequest == null &&
          userData!.onTripRequest == null &&
          userData!.active &&
          userData!.available) {
        showPeakZones = true;
        add(GetPeakZoneEvent());
      }
      add(UpdateEvent());
    } else {
      showPeakZoneButton = false;
      showPeakZones = false;
      zoneStreamRemove?.cancel();
      zoneStreamRemove = null;
      polygons.removeWhere(
          (element) => element.polygonId.value.contains('peakzone_'));
      polyline.removeWhere(
          (element) => element.polylineId.value.contains('peakzone_'));
      add(UpdateEvent());
    }
  }

  // ride arrived
  FutureOr<void> getAddressFromLatLng(
      GeocodingLatLngEvent event, Emitter<HomeState> emit) async {
    dropAddress = '';
    emit(HomeDataLoadingStartState());
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }

    if (event.lat != 0.0 && event.lng != 0.0) {
      final data = await serviceLocator<RideUsecases>().getGeocodingAddress(
          lat: event.lat,
          lng: event.lng,
          packageName: AppConstants.packageName,
          signKey: AppConstants.signKey);
      data.fold((error) {
        emit(HomeDataLoadingStopState());
      }, (success) {
        final data = success.address.toString().split(',');
        if (data.length > 1) {
          if (data[0].contains('+')) {
            final plusCode = data[0];
            data.removeAt(0);
            final val = plusCode.split(' ');
            if (val.length > 1 && !val[1].contains('+')) {
              dropAddress = '${val[1]} ${data.join(',')}';
            } else {
              dropAddress = data.join(',');
            }
          } else {
            dropAddress = data.join(',');
          }
        } else {
          dropAddress = success.address;
        }
        dropLatLng = LatLng(event.lat, event.lng);
        if (userData!.onTripRequest != null) {
          printWrapped('text 99999999999990 --------- ');
          add(RideEndEvent(
              isAfterGeoCodeEnd: true, isAfterRoutesDistanceCall: false));
        } else {
          if (pickAddress == '') {
            pickAddress = dropAddress;
            pickLatLng = LatLng(event.lat, event.lng);
          }
          showGetDropAddress = true;
          emit(StateChangedState());
        }
        emit(UpdateState());
        emit(HomeDataLoadingStopState());
      });
    } else {
      emit(HomeDataLoadingStopState());
    }
  }

  Future<void> getLatLngFromAddress(
      GeocodingAddressEvent event, Emitter<HomeState> emit) async {
    if (mapType == 'google_map') {
      emit(HomeDataLoadingStartState());
      final cachedPosition = await db.getCachedGeocoding(event.placeId);

      if (cachedPosition != null) {
        dropLatLng = cachedPosition;
        dropAddress = event.address;
        googleMapController!.moveCamera(CameraUpdate.newLatLng(dropLatLng!));
        dropAddressController.clear();
        emit(StateChangedState());
        emit(HomeDataLoadingStopState());
        return;
      }
      // Call the geocoding API if no cache is found
      if (AppConstants.packageName.isEmpty || AppConstants.signKey.isEmpty) {
        final val = await PackageInfo.fromPlatform();
        AppConstants.packageName = val.packageName;
        AppConstants.signKey = val.buildSignature;
      }

      final data = await serviceLocator<RideUsecases>().getGeocodingLatLng(
        sessionToken: sessionToken!,
        placeId: event.placeId,
        packageName: AppConstants.packageName,
        signKey: AppConstants.signKey,
      );

      await data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(HomeDataLoadingStopState());
            emit(UserUnauthenticatedState());
          } else {
            emit(ShowErrorState(message: error.message.toString()));
            emit(HomeDataLoadingStopState());
          }
        },
        (success) async {
          emit(HomeDataLoadingStopState());
          final position = success.position;
          await db.cacheGeocodingResult(event.placeId, position);

          // Update the UI with the new position
          dropLatLng = position;
          dropAddress = event.address;
          if (googleMapController != null) {
            googleMapController!
                .moveCamera(CameraUpdate.newLatLng(dropLatLng!));
          }
          dropAddressController.clear();
        },
      );
    } else {
      emit(HomeDataLoadingStartState());
      dropLatLng = event.position;
      dropAddress = event.address;
      fmController.move(
          fmlt.LatLng(event.position!.latitude, event.position!.longitude), 13);
      add(ClearAutoCompleteEvent());
      emit(HomeDataLoadingStopState());
    }
  }

  Future<void> getAutoCompleteAddress(
      GetAutoCompleteAddressEvent event, Emitter<HomeState> emit) async {
    autoSuggestionSearching = true;
    emit(StateChangedState());
    sessionToken ??= const Uuid().v4();
    if (mapType == 'google_map') {
      final cachedPlaces = await db.getAllCachedAddresses();
      final matchingCachedPlaces = cachedPlaces
          .where((element) => element.address!
              .toLowerCase()
              .contains(event.searchText.toLowerCase()))
          .toList();
      if (matchingCachedPlaces.isNotEmpty) {
        autoCompleteAddress.clear();
        autoCompleteAddress.addAll(matchingCachedPlaces
            .map((e) => AddressData(
                  placeId: e.placeId,
                  address: e.address,
                  lat: e.lat,
                  lon: e.lon,
                  displayName: e.displayName,
                ))
            .toList());
        autoSuggestionSearching = false;
        emit(StateChangedState());
        return;
      }
    }
    final data = await serviceLocator<RideUsecases>().getAutoCompleteAddress(
      lat: currentLatLng!.latitude.toString(),
      lng: currentLatLng!.longitude.toString(),
      packageName: AppConstants.packageName,
      signKey: AppConstants.signKey,
      sessionToken: sessionToken!,
      input: event.searchText,
    );
    await data.fold(
      (error) async {
        autoCompleteAddress.clear();
        emit(StateChangedState());
      },
      (success) async {
        autoCompleteAddress.clear();
        autoCompleteAddress = success.predictions;
        if (mapType == 'google_map') {
          for (var address in autoCompleteAddress) {
            await db.insertCachedAddress(
              SearchPlace(
                placeId: address.placeId,
                address: address.address,
                lat: address.lat,
                lon: address.lon,
                displayName: address.displayName,
              ),
            );
          }
        }

        emit(StateChangedState());
      },
    );
    autoSuggestionSearching = false;
    emit(StateChangedState());
  }

  FutureOr<void> createInstantRequest(
      CreateInstantRideEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());

    final data = await serviceLocator<RideUsecases>().createInstantRequest(
        pickLat: pickLatLng!.latitude.toString(),
        pickLng: pickLatLng!.longitude.toString(),
        dropLat: dropLatLng!.latitude.toString(),
        dropLng: dropLatLng!.longitude.toString(),
        rideType: '1',
        pickAddress: pickAddress,
        dropAddress: dropAddress,
        name: instantUserName.text,
        mobile: instantUserMobile.text,
        price: instantRidePrice!,
        goodsTypeId: choosenGoods,
        distance: etaDistance ?? '0',
        duration: etaDuration ?? '0',
        goodsTypeQuantity: goodsSize);

    await data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        showGetDropAddress = false;
        userData!.onTripRequest = success.ontripData;
        emit(HomeDataLoadingStopState());
        emit(InstantRideSuccessState());
        if ((userData!.onTripRequest != null) &&
            polyline.isEmpty &&
            (userData!.onTripRequest == null ||
                userData!.onTripRequest!.isCompleted == 0)) {
          if (AppConstants.packageName == '' || AppConstants.signKey == '') {
            var val = await PackageInfo.fromPlatform();
            AppConstants.packageName = val.packageName;
            AppConstants.signKey = val.buildSignature;
          }
          if (polyline.isEmpty &&
              userData!.onTripRequest != null &&
              userData!.onTripRequest!.dropAddress != null) {
            add(GetRideChatEvent());
            add(PolylineEvent(
                pickLat: userData!.onTripRequest!.pickLat,
                pickLng: userData!.onTripRequest!.pickLng,
                dropLat: userData!.onTripRequest!.dropLat!,
                dropLng: userData!.onTripRequest!.dropLng!,
                stops: userData!.onTripRequest!.requestStops,
                packageName: AppConstants.packageName,
                signKey: AppConstants.signKey,
                pickAddress: userData!.onTripRequest!.pickAddress,
                dropAddress: userData!.onTripRequest!.dropAddress ?? '',
                isInstantRide: true,
                isTripEndCall: false));
          }
        } else if (polyline.isNotEmpty && userData!.onTripRequest != null) {
          double dist = double.parse((etaDistance ?? '0').toString());
          double time = double.parse((etaDuration ?? '0').toString());
          await addDistanceMarker(
              LatLng(userData!.onTripRequest!.dropLat!,
                  userData!.onTripRequest!.dropLng!),
              dist,
              time: time);
        }
        if (userData!.onTripRequest != null && rideStream == null) {
          streamRide();
        }
        if (userData!.onTripRequest != null &&
            userData!.onTripRequest!.arrivedAt != null &&
            waitingTimer == null &&
            userData!.onTripRequest!.isBidRide == "0") {
          waitingTime();
        }

        if (userData!.onTripRequest!.enableShipmentLoad == '1') {
          add(UploadProofEvent(
            image: loadImage!,
            isBefore: true,
            id: userData!.onTripRequest!.id,
          ));
        }
        emit(UpdateState());
      },
    );
  }

  Future addDistanceMarker(LatLng position, double distanceMeter,
      {double? time}) async {
    markers.removeWhere(
        (element) => element.markerId == const MarkerId('distance'));
    double duration;
    String totalDistance;
    String unitLabel;
    bool isMiles = userData?.distanceUnit == 'mi';

    double convertedDistance =
        isMiles ? ((distanceMeter / 1000) * 0.621371) : (distanceMeter / 1000);

    unitLabel = isMiles ? 'MI' : 'KM';

    if (convertedDistance < 0.5) {
      totalDistance = '0.5';
      duration = 1;
      fmDistance = '0.5';
      fmDuration = 1;
      add(UpdateEvent());
    } else {
      totalDistance = convertedDistance.toStringAsFixed(1);
      duration = (time != null)
          ? (time > 0 ? time : 2)
          : (convertedDistance * 1.5).roundToDouble();
      fmDistance = convertedDistance.toStringAsFixed(1);
      fmDuration = (time != null)
          ? (time > 0 ? time : 2)
          : (convertedDistance * 1.5).roundToDouble();
      add(UpdateEvent());
    }

    markers.add(Marker(
      anchor: const Offset(0.5, 0.0),
      markerId: const MarkerId("distance"),
      position: position,
      rotation: 0.0,
      icon: await Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            height: 40,
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.primary, width: 1)),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                      color: AppColors.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        text: totalDistance,
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                      MyText(
                        text: unitLabel,
                        textStyle: AppTextStyle.normalStyle().copyWith(
                            color: ThemeData.light().scaffoldBackgroundColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        color: ThemeData.light().scaffoldBackgroundColor),
                    child: MyText(
                      text: ((duration) > 60)
                          ? '${(duration / 60).toStringAsFixed(1)} hrs'
                          : '${duration.toStringAsFixed(0)} mins',
                      textStyle: AppTextStyle.normalStyle()
                          .copyWith(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          )).toBitmapDescriptor(
        logicalSize: const Size(100, 30),
        imageSize: const Size(100, 30),
      ),
    ));
    // add(UpdateEvent());
    add(UpdateMarkersEvent(markers: markers));
  }

  FutureOr<void> etaRequest(
      GetEtaRequestEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    if (AppConstants.packageName == '' || AppConstants.signKey == '') {
      var val = await PackageInfo.fromPlatform();
      AppConstants.packageName = val.packageName;
      AppConstants.signKey = val.buildSignature;
    }
    await getPolyline(
        PolylineEvent(
            pickLat: pickLatLng!.latitude,
            pickLng: pickLatLng!.longitude,
            dropLat: dropLatLng!.latitude,
            dropLng: dropLatLng!.longitude,
            stops: [],
            packageName: AppConstants.packageName,
            signKey: AppConstants.signKey,
            pickAddress: pickAddress,
            dropAddress: dropAddress,
            isTripEndCall: false),
        emit);
    final data = await serviceLocator<RideUsecases>().etaRequest(
        pickLat: pickLatLng!.latitude.toString(),
        pickLng: pickLatLng!.longitude.toString(),
        dropLat: dropLatLng!.latitude.toString(),
        dropLng: dropLatLng!.longitude.toString(),
        rideType: '1',
        distance: etaDistance ?? '0',
        duration: etaDuration ?? '0');
    await data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(HomeDataLoadingStopState());
          emit(ServiceNotAvailableState(message: error.message!));
        }
      },
      (success) async {
        instantRidePrice = success.price;
        instantRideCurrency = success.currency;
        instantUserMobile.clear();
        instantUserName.clear();
        goodsSizeText.clear();
        choosenGoods = null;
        goodsSize = 'Loose';
        if (userData!.transportType == 'both') {
          instantRideType = 'taxi';
        } else {
          instantRideType = null;
        }
        autoSuggestionSearching = false;
        emit(HomeDataLoadingStopState());
        emit(InstantEtaSuccessState());
      },
    );
  }

  // ride arrived
  FutureOr<void> getPolyline(
      PolylineEvent event, Emitter<HomeState> emit) async {
    polyline.clear();
    polygons.clear();
    fmpoly.clear();
    List<dynamic> stops = [];
    if (event.isFromAnimate == null) {
      markers.removeWhere(
          (element) => element.markerId != const MarkerId('my_loc'));
      stops = event.stops;
    } else {
      if (event.stops.isNotEmpty) {
        for (var i = 0; i < event.stops.length; i++) {
          if (event.stops[i]['completed_at'] == null) {
            stops.add(event.stops[i]);
          }
        }
      }
    }
    final data = await serviceLocator<RideUsecases>().getPolyline(
      pickLat: event.pickLat,
      pickLng: event.pickLng,
      dropLat: event.dropLat,
      dropLng: event.dropLng,
      // stops: event.stops,
      stops: stops,
      packageName: event.packageName,
      signKey: event.signKey,
      map: mapType,
    );
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        etaDistance =
            (success.distance == 'null') ? null : success.distance.toString();
        if (success.duration.contains('.')) {
          etaDuration = double.parse(success.duration).toStringAsFixed(1);
        } else {
          etaDuration = success.duration.toString();
        }
        etaDuration = success.duration.toString();
        polyString = success.polyString;
        if (event.isTripEndCall) {
          printWrapped('text 44444444444 --------- ');
          add(RideEndEvent(
              isAfterGeoCodeEnd: false, isAfterRoutesDistanceCall: true));
        } else {
          printWrapped('text 5555555555555 --------- ');
          if (userData!.onTripRequest != null) {
            FirebaseDatabase.instance
                .ref('requests')
                .child(userData!.onTripRequest!.id)
                .update({
              'polyline': success.polyString,
              'distance': etaDistance,
              'duration': etaDuration
            });
          }
          if (event.isFromAnimate == null) {
            markers.add(Marker(
              markerId: const MarkerId("pick"),
              position: LatLng(event.pickLat, event.pickLng),
              rotation: 0.0,
              icon: await Image.asset(
                AppImages.pickupIcon,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ).toBitmapDescriptor(
                logicalSize: const Size(30, 30),
                imageSize: const Size(200, 200),
              ),
            ));
            if (event.stops.isEmpty && event.dropAddress != '') {
              markers.add(Marker(
                markerId: const MarkerId("drop"),
                position: LatLng(event.dropLat, event.dropLng),
                rotation: 0.0,
                icon: await const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    )).toBitmapDescriptor(
                  logicalSize: const Size(30, 30),
                  imageSize: const Size(200, 200),
                ),
              ));
            } else if (event.stops.isNotEmpty) {
              for (var i = 0; i < event.stops.length; i++) {
                markers.add(Marker(
                  markerId: MarkerId("drop$i"),
                  position: LatLng(
                      event.stops[i]['latitude'], event.stops[i]['longitude']),
                  rotation: 0.0,
                  icon: (i == event.stops.length - 1)
                      ? await const Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                          )).toBitmapDescriptor(
                          logicalSize: const Size(30, 30),
                          imageSize: const Size(200, 200),
                        )
                      : await Image.asset(
                          (i == 0)
                              ? AppImages.stopOne
                              : (i == 1)
                                  ? AppImages.stopTwo
                                  : (i == 2)
                                      ? AppImages.stopThree
                                      : AppImages.stopFour,
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ).toBitmapDescriptor(
                          logicalSize: const Size(30, 30),
                          imageSize: const Size(200, 200),
                        ),
                ));
              }
            }
          }

          if ((userData!.onTripRequest != null &&
                  (userData!.onTripRequest!.arrivedAt == null ||
                      userData!.onTripRequest!.arrivedAt == "")) ||
              (event.isInstantRide != null && event.isInstantRide!) ||
              (event.isFromAnimate != null && event.isFromAnimate!)) {
            final dist = double.parse(etaDistance ?? '1');
            final time = double.parse(etaDuration ?? '1');
            await addDistanceMarker(LatLng(event.dropLat, event.dropLng), dist,
                time: time);
            add(UpdateEvent());
          }
          if (mapType == 'google_map') {
            if (userData!.metaRequest != null ||
                (userData!.onTripRequest != null &&
                    userData!.onTripRequest!.arrivedAt != null) ||
                (userData!.metaRequest == null &&
                    userData!.onTripRequest == null &&
                    choosenRide != null) ||
                (userData!.metaRequest == null &&
                    userData!.onTripRequest == null &&
                    showGetDropAddress)) {
              mapBound(event.pickLat, event.pickLng, event.dropLat,
                  event.dropLng, event.stops);
            } else {
              mapBound(currentLatLng!.latitude, currentLatLng!.longitude,
                  event.pickLat, event.pickLng, event.stops);
            }

            decodeEncodedPolyline(success.polyString);
          } else {
            mapBound(currentLatLng!.latitude, currentLatLng!.longitude,
                event.pickLat, event.pickLng, event.stops);

            decodeEncodedPolyline(success.polyString);
            double lat = (event.pickLat + event.dropLat) / 2;
            double lon = (event.pickLng + event.dropLng) / 2;
            var val = LatLng(lat, lon);
            fmController.move(fmlt.LatLng(val.latitude, val.longitude), 13);
            add(PolylineSuccessEvent());
          }
        }
      },
    );
  }

  LatLngBounds? bound;

  mapBound(pickLat, pickLng, dropLat, dropLng, stops,
      {bool? isInitCall, bool? isRentalRide}) {
    List points = [LatLng(pickLat, pickLng), LatLng(dropLat, dropLng)];
    if (userData!.onTripRequest == null ||
        userData!.onTripRequest!.arrivedAt != null) {
      stops.forEach((e) {
        points.add(LatLng(e['latitude'], e['longitude']));
      });
    }

    double southWestLat =
        points.map((m) => m.latitude).reduce((a, b) => a < b ? a : b);
    double southWestLng =
        points.map((m) => m.longitude).reduce((a, b) => a < b ? a : b);
    double northEastLat =
        points.map((m) => m.latitude).reduce((a, b) => a > b ? a : b);
    double northEastLng =
        points.map((m) => m.longitude).reduce((a, b) => a > b ? a : b);

    bound = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  List<LatLng> polylist = [];
  List<fmlt.LatLng> fmpoly = [];
  Future<List<PointLatLng>> decodeEncodedPolyline(String encoded) async {
    polylist.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    polyline.clear();
    polygons.clear();
    fmpoly.clear();

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      if (mapType == 'google_map') {
        polylist.add(p);
      } else {
        fmpoly.add(fmlt.LatLng(p.latitude, p.longitude));
      }
    }
    if (mapType == 'google_map') {
      polyline.add(
        Polyline(
            polylineId: const PolylineId('1'),
            color: AppColors.blue,
            visible: true,
            width: 4,
            points: polylist),
      );

      if (mapType == 'google_map') {
        googleMapController
            ?.animateCamera(CameraUpdate.newLatLngBounds(bound!, 50));
      } else {
        fmController.move(
            fmlt.LatLng(bound!.northeast.latitude, bound!.northeast.longitude),
            13);
      }
      add(PolylineSuccessEvent());
    }
    return poly;
  }

  Future<void> streamPolyline(
      PolylineSuccessEvent event, Emitter<HomeState> emit) async {
    emit(PolylineSuccessState());
  }

  Future<void> openAnotherFeature(
      OpenAnotherFeatureEvent event, Emitter<HomeState> emit) async {
    if (await launchUrl(Uri.parse(event.value))) {
      await launchUrl(Uri.parse(event.value));
    } else {
      throw 'Could not launch ${event.value}';
    }
  }

  streamLocation() async {
    if (userData != null && userData!.role == 'driver') {
      final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.bikeOffline);

      final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.car);

      final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.auto);

      final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.truck);

      final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.ehcv);

      final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.hatchBack);

      final BitmapDescriptor hcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.hcv);

      final BitmapDescriptor lcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.lcv);

      final BitmapDescriptor mcv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.mcv);

      final BitmapDescriptor luxury = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.luxury);

      final BitmapDescriptor premium = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.premium);

      final BitmapDescriptor suv = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(23, 34)), AppImages.suv);

      vehicleMarker = (userData!.vehicleTypeIcon == 'truck')
          ? truckMarker
          : (userData!.vehicleTypeIcon == 'motor_bike')
              ? bikeMarker
              : (userData!.vehicleTypeIcon == 'auto')
                  ? autoMarker
                  : (userData!.vehicleTypeIcon == 'lcv')
                      ? lcv
                      : (userData!.vehicleTypeIcon == 'ehcv')
                          ? ehcv
                          : (userData!.vehicleTypeIcon == 'hatchback')
                              ? hatchBack
                              : (userData!.vehicleTypeIcon == 'hcv')
                                  ? hcv
                                  : (userData!.vehicleTypeIcon == 'mcv')
                                      ? mcv
                                      : (userData!.vehicleTypeIcon == 'luxury')
                                          ? luxury
                                          : (userData!.vehicleTypeIcon ==
                                                  'premium')
                                              ? premium
                                              : (userData!.vehicleTypeIcon ==
                                                      'suv')
                                                  ? suv
                                                  : carMarker;

      // Remove previous marker if exists
      if (currentLatLng != null) {
        markers.removeWhere(
            (element) => element.markerId == const MarkerId('my_loc'));
        markers.add(Marker(
            markerId: const MarkerId('my_loc'),
            position: currentLatLng!,
            rotation: 0.0,
            icon: vehicleMarker!,
            anchor: const Offset(0.5, 0.5)));
        add(UpdateMarkersEvent(markers: markers));
      }
    }
    positionSubscription?.cancel();
    positionSubscription = positionStream.handleError((onError) {
      positionSubscription?.cancel();
    }).listen((Position? position) async {
      if (position != null) {
        if (vsync != null && currentLatLng != null && vehicleMarker != null) {
          if (markers
              .where((element) => element.markerId == const MarkerId('my_loc'))
              .isNotEmpty) {
            animationController = AnimationController(
                vsync: vsync, duration: const Duration(milliseconds: 1500));
            animateCar(
                currentLatLng!.latitude,
                currentLatLng!.longitude,
                position.latitude,
                position.longitude,
                vsync,
                (mapType == 'google_map') ? googleMapController : fmController,
                'my_loc',
                vehicleMarker!,
                mapType);
            currentLatLng = LatLng(position.latitude, position.longitude);
            add(UpdateEvent());
          } else {
            markers.add(Marker(
                markerId: const MarkerId('my_loc'),
                position: currentLatLng!,
                rotation: 0.0,
                icon: vehicleMarker!,
                anchor: const Offset(0.5, 0.5)));
            currentLatLng = LatLng(position.latitude, position.longitude);
            add(UpdateEvent());
          }
        } else {
          currentLatLng = LatLng(position.latitude, position.longitude);
          add(UpdateEvent());
        }

        if (userData!.onTripRequest != null &&
            userData!.onTripRequest!.arrivedAt != null &&
            userData!.onTripRequest!.dropLat != null &&
            userData!.onTripRequest!.dropLng != null) {
          markers.removeWhere(
              (element) => element.markerId == const MarkerId('distance'));
          double minPerDistance =
              double.parse(userData!.onTripRequest!.totalTime.toString()) /
                  double.parse(userData!.onTripRequest!.totalDistance);
          double dist = calculateDistance(
            lat1: currentLatLng!.latitude,
            lon1: currentLatLng!.longitude,
            lat2: userData!.onTripRequest!.dropLat!,
            lon2: userData!.onTripRequest!.dropLng!,
            unit: userData?.distanceUnit ?? 'km',
          );
          final dist1 = calculateDistance(
            lat1: userData!.onTripRequest!.pickLat,
            lon1: userData!.onTripRequest!.pickLng,
            lat2: currentLatLng!.latitude,
            lon2: currentLatLng!.longitude,
            unit: userData?.distanceUnit ?? 'km',
          );
          final calDuration =
              double.parse(userData!.onTripRequest!.totalTime.toString()) -
                  ((dist1) * minPerDistance);
          if (userData != null && userData!.enableSecondRideForDriver == '1') {
            if (dist <= double.parse(userData!.distanceForSecondRide) &&
                (userData != null && userData!.hasWaitingRide == false)) {
              FirebaseDatabase.instance
                  .ref()
                  .child('drivers/driver_${userData!.id}')
                  .update({
                'is_available': true,
              });
              userData!.available = true;
              onTripSearchNewRide = true;
              streamRequest();
            } else if (userData != null &&
                userData!.hasWaitingRide == true &&
                onTripSearchNewRide) {
              requestStream?.cancel();
              requestStream = null;
              onTripSearchNewRide = false;
              FirebaseDatabase.instance
                  .ref()
                  .child('drivers/driver_${userData!.id}')
                  .update({
                'is_available': false,
              });
            }
          }
          FirebaseDatabase.instance
              .ref('requests')
              .child(userData!.onTripRequest!.id)
              .update({
            'distance': (userData!.distanceUnit == 'mi'
                ? ((dist * 1.60934) * 1000)
                : dist * 1000),
            'duration': calDuration
          });
          await addDistanceMarker(
              LatLng(userData!.onTripRequest!.dropLat!,
                  userData!.onTripRequest!.dropLng!),
              (userData!.distanceUnit == 'mi'
                  ? ((dist * 1.60934) * 1000)
                  : dist * 1000),
              time: calDuration);
        }
        updateFirebaseData();
        add(UpdateEvent());
      } else {
        positionSubscription?.cancel();
      }
    });
  }

  Future<void> updatePricePerDistance(
      UpdatePricePerDistanceEvent event, Emitter<HomeState> emit) async {
    onlineLoader = true;
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<HomeUsecase>()
        .updatePricePerDistance(price: event.price);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          onlineLoader = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.pricePerDistance = event.price;
      },
    );
    emit(HomeDataLoadingStopState());
  }

  Future<void> navigationTypeFunc(
      NavigationTypeEvent event, Emitter<HomeState> emit) async {
    if (event.isMapNavigation) {
      if (navigationType) {
        navigationType = false;
      } else {
        navigationType = true;
      }
    } else {
      if (navigationType1) {
        navigationType1 = false;
      } else {
        navigationType1 = true;
      }
    }
    emit(NavigationTypeState());
  }

  Future<void> changeOnlineOffline(
      ChangeOnlineOfflineEvent event, Emitter<HomeState> emit) async {
    onlineLoader = true;
    var bubble = await AppSharedPreference.getBubbleSettingStatus();
    emit(OnlineOfflineLoadingState());
    bool status = await WakelockPlus.enabled;
    bool overlayPermission = false;
    if (Platform.isAndroid) {
      overlayPermission = await NativeService().checkPermission();
    }
    final data = await serviceLocator<HomeUsecase>().onlineOffline();
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          onlineLoader = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.active = success.isOnline;
        userData!.available = success.isOnline;
        updateFirebaseData();
        if (success.isOnline == true) {
          if (Platform.isAndroid) {
            if (!overlayPermission) {
              emit(GetOverlayPermissionState());
            } else {
              AppSharedPreference.setBubbleSettingStatus(true);
              showBubbleIcon = true;
              WakelockPlus.enable();
            }
          }

          if (activeTimer == null || !activeTimer!.isActive) {
            activeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
              userData!.totalMinutesOnline =
                  (int.parse(userData!.totalMinutesOnline!) + 1).toString();
              add(UpdateOnlineTimeEvent(
                  minutes: int.parse(userData!.totalMinutesOnline!)));
            });
          }
          add(GetUserDetailsEvent());
        } else {
          showPeakZones = false;
          polygons.removeWhere(
              (element) => element.polygonId.value.contains('peakzone_'));
          polyline.removeWhere(
              (element) => element.polylineId.value.contains('peakzone_'));
          if (Platform.isAndroid) {
            if (status) {
              WakelockPlus.disable();
            }
            if (bubble) {
              showBubbleIcon = false;
            }
          }
          if (activeTimer != null) {
            activeTimer!.cancel();
            activeTimer = null;
          }
          if (requestStream != null) {
            requestStream?.cancel();
            requestStream = null;
          }
          if (bidRequestStream != null) {
            bidRequestStream?.cancel();
            bidRequestStream = null;
          }
          if (positionSubscription != null) {
            positionSubscription?.cancel();
            positionSubscription = null;
          }
        }

        onlineLoader = false;
        emit(OnlineOfflineSuccessState());
        emit(UpdateState());
      },
    );
  }

  Future<void> updateValue(
      UpdateBottomHeightEvent event, Emitter<HomeState> emit) async {
    bottomSize = event.bottomHeight;
    emit(UpdateState());
  }

  Future<void> updateMarkers(
      UpdateMarkersEvent event, Emitter<HomeState> emit) async {
    markers = event.markers;
    emit(UpdateState());
  }

  FutureOr updateActiveUserTiming(
      UpdateOnlineTimeEvent event, Emitter<HomeState> emit) async {
    emit(UpdateOnlineTimeState(minutes: event.minutes));
  }

  Future<void> paymentRecieved(
      PaymentRecievedEvent event, Emitter<HomeState> emit) async {
    emit(HomeDataLoadingStartState());
    final data = await serviceLocator<RideUsecases>()
        .paymentRecieved(requestId: userData!.onTripRequest!.id);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        userData!.onTripRequest!.isPaid = 1;
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          'is_payment_received': true,
          'modified_by_driver': ServerValue.timestamp,
        });
      },
    );
    emit(HomeDataLoadingStopState());
  }

  Future<void> addRideReview(
      UploadReviewEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    emit(LoadingStartState());
    emit(UpdateState());
    final data = await serviceLocator<RideUsecases>().addReview(
        requestId: userData!.onTripRequest!.id,
        rating: review,
        comment: reviewController.text);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          emit(LoadingStopState());
          emit(UpdateState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        isLoading = false;
        emit(LoadingStopState());
        emit(UpdateState());
        emit(AddReviewSuccessState());

        add(GetUserDetailsEvent());
      },
    );
  }

  void sendUserDetailsWithNullRequestId() {
    _lastShownRequestId = null;
    add(GetUserDetailsEvent());
  }

  void resetLastShownRequestId() {
    _lastShownRequestId = null;
  }

  FutureOr<void> onTripRequest(
      StreamRequestEvent event, Emitter<HomeState> emit) async {
    emit(RideUpdateState());
    emit(UpdateState());

    // Check if shared rides are enabled and there are multiple rides
    if (acceptSharedRides && rideList.length > 1) {
      // Get the current request ID to check if it's a new request
      String? currentRequestId;
      if (rideList.isNotEmpty && rideList.first is Map) {
        final firstRide = rideList.first as Map;
        currentRequestId =
            firstRide['id']?.toString() ?? firstRide['request_id']?.toString();
      }

      // Show AcceptRejectWidget for new requests, even during active trips
      // This allows showing accept/reject screen for second ride when already on a trip
      if (currentRequestId != null && currentRequestId != _lastShownRequestId) {
        _lastShownRequestId = currentRequestId;
        // Automatically show AcceptRejectWidget when conditions are met
        emit(ShowAcceptRejectState());
      }
    }
  }

  streamRequest() {
    requestStream?.cancel();
    requestStream = FirebaseDatabase.instance
        .ref('request-meta')
        .orderByChild('driver_id')
        .equalTo(userData!.id)
        .onValue
        .listen((onData) {
      if (onData.snapshot.value != null) {
        add(GetUserDetailsEvent());
        Future.delayed(const Duration(milliseconds: 150), () {
          add(StreamRequestEvent());
        });
      }
    }, onError: (error) {
      Future.delayed(const Duration(seconds: 1), () => streamRequest());
    });
  }

  bidRequestUpdate(BidRideRequestEvent event, Emitter<HomeState> emit) async {
    emit(BidRideRequestState());
  }

  streamBidRequest() async {
    bidRequestStream?.cancel();
    if (distanceBetween == null) {
      var val = await AppSharedPreference.getDistanceBetween();
      distanceBetween = (val != null) ? val : distanceBetweenList.last['dist'];
    }
    if (currentLatLng != null) {
      final double radiusValue = _geoRadiusValueFor(distanceBetween!);
      bidRequestStream = FirebaseDatabase.instance
          .ref('bid-meta')
          .orderByChild('g')
          .startAt(geo.encode(currentLatLng!.longitude - (lon * radiusValue),
              currentLatLng!.latitude - (lat * radiusValue)))
          .endAt(geo.encode(currentLatLng!.longitude + (lon * radiusValue),
              currentLatLng!.latitude + (lat * radiusValue)))
          .onValue
          .handleError((onError) {
        bidRequestStream?.cancel();
        bidRequestStream = null;
      }).listen((DatabaseEvent event) {
        rideList.clear();
        outStationList.clear();
        List waitingData = [];
        if (event.snapshot.value != null) {
          Map list = jsonDecode(jsonEncode(event.snapshot.value));

          list.forEach((key, value) {
            if (value['drivers'] != null &&
                (userData!.vehicleTypeId == value['vehicle_type'] ||
                    userData!.vehicleTypes!.contains(value['vehicle_type']))) {
              if (value['drivers']['driver_${userData!.id}'] != null) {
                if (value['drivers']['driver_${userData!.id}']["is_rejected"] ==
                    'none') {
                  if (value['is_out_station'] == false) {
                    rideList.add(value);
                    waitingData.add(value);
                  }
                } else if (value['drivers']['driver_${userData!.id}']
                        ["is_rejected"] !=
                    'by_driver') {
                  if (value['is_out_station'] == false) {
                    rideList.add(value);
                  } else if (value['is_out_station'] == true
                      // &&
                      //     userData!.showOutstationRideFeature == '1'
                      ) {
                    showOutstationWidget = true;
                    showBiddingPage = false;
                    outStationList.add(value);
                  }
                  if ((waitingData.isEmpty)) {
                    if (oldRides.contains(value['request_id']) == false &&
                        isBiddingEnabled &&
                        value['is_out_station'] == false) {
                      audioPlayer.play(AssetSource(AppAudios.requestSound));
                      oldRides.add(value['request_id']);
                      if (showBiddingPage == false &&
                          value['is_out_station'] == false) {
                        showBiddingPage = true;
                        showOutstationWidget = false;
                        add(UpdateEvent());
                      }
                    }
                  }
                }
                add(UpdateEvent());
              } else {
                if (value['is_out_station'] == false) {
                  rideList.add(value);
                } else if (value['is_out_station'] == true
                    // &&
                    //     userData!.showOutstationRideFeature == '1'
                    ) {
                  outStationList.add(value);
                  showOutstationWidget = true;
                  showBiddingPage = false;
                }
                add(UpdateEvent());
              }
              add(UpdateEvent());
            } else if (userData!.vehicleTypeId == value['vehicle_type'] ||
                userData!.vehicleTypes!.contains(value['vehicle_type'])) {
              if (value['is_out_station'] == false) {
                rideList.add(value);
              }

              if ((waitingData.isEmpty)) {
                if (oldRides.contains(value['request_id']) == false &&
                    isBiddingEnabled &&
                    value['is_out_station'] == false) {
                  audioPlayer.play(AssetSource(AppAudios.requestSound));
                  oldRides.add(value['request_id']);
                  if (showBiddingPage == false &&
                      value['is_out_station'] == false &&
                      showOutstationWidget == false &&
                      choosenRide == null) {
                    showBiddingPage = true;
                    showOutstationWidget = false;
                    add(UpdateEvent());
                  }
                }
                if (value['is_out_station'] == true &&
                    // userData!.showOutstationRideFeature == '1' &&
                    outStationList.contains(value['request_id']) == false &&
                    choosenRide == null &&
                    showBiddingPage == false) {
                  audioPlayer.play(AssetSource(AppAudios.requestSound));
                  showOutstationWidget = true;
                  showBiddingPage = false;
                  visibleOutStation = true;
                  choosenRide = value[
                      'request_id']; // Set choosenRide for outstation rides
                  outStationList.add(value);
                  add(UpdateEvent());
                }
              }
              add(UpdateEvent());
            }
          });
          if (rideList.isNotEmpty) {
            rideList.sort((a, b) => b['updated_at'].compareTo(a["updated_at"]));
          }
          add(UpdateEvent());
        }
        if (waitingData.isNotEmpty && searchTimer == null) {
          waitingList = waitingData;
          rideSearchTimer();
        } else if (searchTimer != null &&
            waitingList.isNotEmpty &&
            waitingData.isEmpty) {
          searchTimer?.cancel();
          searchTimer = null;
          if (rideList
              .where((e) => waitingList[0]['request_id'] == e['request_id'])
              .isEmpty) {
            choosenRide = null;

            add(GetUserDetailsEvent());
          } else {
            bidDeclined = true;
          }
          waitingList = waitingData;
        }
        if (choosenRide != null &&
            rideList.where((e) => e['request_id'] == choosenRide).isEmpty) {
          polyline.clear();
          polygons.clear();
          fmpoly.clear();
          markers.removeWhere(
              (element) => element.markerId != const MarkerId('my_loc'));
          choosenRide = null;
          add(UpdateEvent());
        } else {}
        add(BidRideRequestEvent());
        add(UpdateEvent());
      });
    }
  }

  streamRide() {
    requestStream?.cancel();
    requestStream = null;
    bidRequestStream?.cancel();
    bidRequestStream = null;
    rideStream?.cancel();
    rideAddStream?.cancel();
    rideStream = FirebaseDatabase.instance
        .ref('requests')
        .child(userData!.onTripRequest!.id)
        .onChildChanged
        .listen((data) async {
      if (data.snapshot.key == 'cancelled_by_user') {
        isUserCancelled = true;
        rideStream?.cancel();
        rideStream = null;
        rideAddStream?.cancel();
        rideAddStream = null;
        FirebaseDatabase.instance
            .ref()
            .child('requests/${userData!.onTripRequest!.id}')
            .remove();
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'modified_by_user') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'message_by_user') {
        add(GetRideChatEvent());
      } else if (data.snapshot.key == 'is_paid') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'lat_lng_array' &&
          data.snapshot.child('lat_lng_array').value != null) {
        latlngArray =
            jsonDecode(jsonEncode(data.snapshot.child('lat_lng_array').value));
        add(UpdateEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'driver_tips') {
        add(UpdateEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'is_user_paid') {
        isUserPaidPayment =
            (data.snapshot.child('is_user_paid').value as bool?) ?? false;
        rideRepository.updatePaymentReceived(isUserPaidPayment);
        add(UpdateEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'payment_method') {
        paymentChanged =
            (data.snapshot.child('payment_method').value.toString());
        rideRepository.updatePaymentChange(paymentChanged);
        add(UpdateEvent());
      } else if (data.snapshot.key == 'destination_change') {
        polyline = {};
        destinationChanged = true;
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      }
    });

    rideAddStream = FirebaseDatabase.instance
        .ref('requests')
        .child(userData!.onTripRequest!.id)
        .onChildAdded
        .listen((data) {
      if (data.snapshot.key == 'cancelled_by_user') {
        isUserCancelled = true;
        rideStream?.cancel();
        rideStream = null;
        rideAddStream?.cancel();
        rideAddStream = null;
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'modified_by_user') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'destination_change') {
        polyline = {};
        destinationChanged = true;
        add(UpdateEvent());
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'message_by_user') {
        add(GetRideChatEvent());
      } else if (data.snapshot.key == 'is_paid') {
        add(GetUserDetailsEvent());
      } else if (data.snapshot.key == 'driver_tips') {
        driverTips =
            double.parse(data.snapshot.child('driver_tips').value.toString());
        add(UpdateEvent());
      } else if (data.snapshot.key == 'is_user_paid') {
        isUserPaidPayment =
            (data.snapshot.child('is_user_paid').value as bool?) ?? false;
        rideRepository.updatePaymentReceived(isUserPaidPayment);
        add(UpdateEvent());
      } else if (data.snapshot.value != null &&
          data.snapshot.key == 'payment_method') {
        paymentChanged =
            (data.snapshot.child('payment_method').value.toString());
        rideRepository.updatePaymentChange(paymentChanged);
        add(UpdateEvent());
      }
    });
  }

  streamOwnersDriver() async {
    ownersDriver?.cancel();
    onlineCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOnline);

    offlineCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOffline);

    onrideCar ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.carOnride);

    onlineTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOnline);

    offlineTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOffline);

    onrideTruck ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.deliveryOnride);

    onlineBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOnline);

    offlineBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOffline);

    onrideBike ??= await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(25, 50)), // Replace with your image size
        AppImages.bikeOnride);

    markers.removeWhere(
        (element) => element.markerId.toString().contains('owner_'));
    ownersDriver = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('ownerid')
        .equalTo(userData!.id.toString())
        .onValue
        .listen((data) {
      if (data.snapshot.exists) {
        Map<String, dynamic> datas =
            jsonDecode(jsonEncode(data.snapshot.value));

        datas.forEach((k, v) {
          if (choosenCarMenu == 0 ||
              (choosenCarMenu == 1 &&
                  v['is_active'] == 1 &&
                  v['is_available'] == true) ||
              (choosenCarMenu == 3 &&
                  v['is_active'] == 1 &&
                  v['is_available'] == false) ||
              (choosenCarMenu == 2 && v['is_active'] == 0)) {
            if (v['vehicle_types'] != null) {
              if (markers
                  .where((element) =>
                      element.markerId.toString().contains('owner_${v['id']}'))
                  .isEmpty) {
                markers.add(Marker(
                    markerId: (v['is_active'] == 1 && v['is_available'] == true)
                        ? MarkerId('owner_${v['id']}_1')
                        : (v['is_active'] == 1 && v['is_available'] == false)
                            ? MarkerId('owner_${v['id']}_3')
                            : MarkerId('owner_${v['id']}_2'),
                    position: LatLng(v['l'][0], v['l'][1]),
                    rotation: 0.0,
                    icon: (v['vehicle_type_icon'] == 'car')
                        ? (v['is_active'] == 1 && v['is_available'] == true)
                            ? onlineCar!
                            : (v['is_active'] == 1 &&
                                    v['is_available'] == false)
                                ? onrideCar!
                                : offlineCar!
                        : (v['vehicle_type_icon'] == 'motor_bike')
                            ? (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineBike!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideBike!
                                    : offlineBike!
                            : (v['is_active'] == 1 && v['is_available'] == true)
                                ? onlineTruck!
                                : (v['is_active'] == 1 &&
                                        v['is_available'] == false)
                                    ? onrideTruck!
                                    : offlineTruck!,
                    anchor: const Offset(0.5, 0.5)));
              } else if ((v['is_active'] == 1 &&
                      v['is_available'] == true &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_1'))
                          .isNotEmpty) ||
                  (v['is_active'] == 1 &&
                      v['is_available'] == false &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_3'))
                          .isNotEmpty) ||
                  (v['is_active'] == 0 &&
                      markers
                          .where((element) =>
                              element.markerId !=
                              MarkerId('owner_${v['id']}_2'))
                          .isNotEmpty)) {
                markers.removeWhere((element) =>
                    element.markerId.toString().contains('owner_${v['id']}'));
                if (v['is_active'] != 0) {
                  markers.add(Marker(
                      markerId: (v['is_active'] == 1 &&
                              v['is_available'] == true)
                          ? MarkerId('owner_${v['id']}_1')
                          : (v['is_active'] == 1 && v['is_available'] == false)
                              ? MarkerId('owner_${v['id']}_3')
                              : MarkerId('owner_${v['id']}_2'),
                      position: LatLng(v['l'][0], v['l'][1]),
                      rotation: 0.0,
                      icon: (v['vehicle_type_icon'] == 'car')
                          ? (v['is_active'] == 1 && v['is_available'] == true)
                              ? onlineCar!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == false)
                                  ? onrideCar!
                                  : offlineCar!
                          : (v['vehicle_type_icon'] == 'motor_bike')
                              ? (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineBike!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideBike!
                                      : offlineBike!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineTruck!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideTruck!
                                      : offlineTruck!,
                      anchor: const Offset(0.5, 0.5)));
                }
              } else {
                if (vsync != null) {
                  animationController = AnimationController(
                      vsync: vsync,
                      duration: const Duration(milliseconds: 1500));
                  animateCar(
                      currentLatLng!.latitude,
                      currentLatLng!.longitude,
                      v['l'][0],
                      v['l'][1],
                      vsync,
                      (mapType == 'google_map')
                          ? googleMapController
                          : fmController,
                      (v['is_active'] == 1 && v['is_available'] == true)
                          ? 'owner_${v['id']}_1'
                          : (v['is_active'] == 1 && v['is_available'] == false)
                              ? 'owner_${v['id']}_3'
                              : 'owner_${v['id']}_2',
                      (v['vehicle_type_icon'] == 'car')
                          ? (v['is_active'] == 1 && v['is_available'] == true)
                              ? onlineCar!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == false)
                                  ? onrideCar!
                                  : offlineCar!
                          : (v['vehicle_type_icon'] == 'motor_bike')
                              ? (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineBike!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideBike!
                                      : offlineBike!
                              : (v['is_active'] == 1 &&
                                      v['is_available'] == true)
                                  ? onlineTruck!
                                  : (v['is_active'] == 1 &&
                                          v['is_available'] == false)
                                      ? onrideTruck!
                                      : offlineTruck!,
                      mapType);
                }
              }
            }
          } else if ((choosenCarMenu == 2 &&
              v['is_active'] == 1 &&
              (v['is_available'] == true || v['is_available'] == false))) {
            markers.removeWhere((element) =>
                element.markerId.toString().contains('owner_${v['id']}'));
          } else if ((choosenCarMenu == 1 &&
              (v['is_active'] == 1 || v['is_active'] == 0) &&
              v['is_available'] == false)) {
            markers.removeWhere((element) =>
                element.markerId.toString().contains('owner_${v['id']}'));
          } else if ((choosenCarMenu == 3 &&
              (v['is_active'] == 1 || v['is_active'] == 0) &&
              (v['is_available'] == true || v['is_available'] == false))) {
            markers.removeWhere((element) =>
                element.markerId.toString().contains('owner_${v['id']}'));
          }
        });
        add(UpdateEvent());
      } else {
        markers.removeWhere(
            (element) => element.markerId.toString().contains('owner_'));

        add(UpdateEvent());
      }
    });
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (lat != 0 && lat != 0.0 && lng != 0 && lng != 0.0) {
      if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
        return vector.degrees(atan(lng / lat));
      } else if (begin.latitude >= end.latitude &&
          begin.longitude < end.longitude) {
        return (90 - vector.degrees(atan(lng / lat))) + 90;
      } else if (begin.latitude >= end.latitude &&
          begin.longitude >= end.longitude) {
        return vector.degrees(atan(lng / lat)) + 180;
      } else if (begin.latitude < end.latitude &&
          begin.longitude >= end.longitude) {
        return (90 - vector.degrees(atan(lng / lat))) + 270;
      }
    }

    return 0.0;
  }

  animateCar(
    double fromLat, //Starting latitude

    double fromLong, //Starting longitude

    double toLat, //Ending latitude

    double toLong, //Ending longitude

    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation

    dynamic controller, //Google map controller of our widget

    markerid,
    icon,
    map,
  ) async {
    double? bearing;
    dynamic carMarker;

    carMarker = Marker(
        markerId: MarkerId(markerid),
        position: LatLng(fromLat, fromLong),
        icon: icon,
        rotation: 0.0,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false);

    Tween<double> tween = Tween(begin: 0, end: 1);
    List<LatLng> polyList = [];

    _animation = tween.animate(animationController!)
      ..addListener(() async {
        markers.removeWhere(
            (element) => element.markerId == MarkerId(markerid.toString()));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location
        if (polyline.isNotEmpty) {
          polyList = polyline
              .firstWhere((e) => e.mapsId == const PolylineId('1'))
              .points;
          List polys = [];
          dynamic nearestLat;
          dynamic pol;

          bool isOffRoute = false;
          if (polyList.isNotEmpty) {
            final dist = calculateDistance(
              lat1: toLat,
              lon1: toLong,
              lat2: polyList[1].latitude,
              lon2: polyList[1].longitude,
              unit: 'km',
            );
            if (dist > 0.5) {
              // above 500 meters distance
              isOffRoute = true;
            }
          }

          if (!isOffRoute) {
            for (var e in polyList) {
              var dist = calculateDistance(
                lat1: newPos.latitude,
                lon1: newPos.longitude,
                lat2: e.latitude,
                lon2: e.longitude,
                unit: userData?.distanceUnit ?? 'km',
              );
              if (pol == null) {
                polys.add(dist);
                pol = dist;
                nearestLat = e;
              } else {
                if (dist < pol) {
                  polys.add(dist);
                  pol = dist;
                  nearestLat = e;
                }
              }
            }
            int currentNumber =
                polyList.indexWhere((element) => element == nearestLat);
            for (var i = 0; i < currentNumber; i++) {
              polyList.removeAt(0);
            }
            polyline.clear();
            polyline.add(
              Polyline(
                  polylineId: const PolylineId('1'),
                  color: AppColors.blue,
                  visible: true,
                  width: 4,
                  points: polyList),
            );
          } else {
            // Call Polyline Route
            polyline.clear();
            add(PolylineEvent(
                pickLat: toLat,
                pickLng: toLong,
                dropLat: userData!.onTripRequest!.dropLat!,
                dropLng: userData!.onTripRequest!.dropLng!,
                stops: userData!.onTripRequest!.requestStops,
                packageName: AppConstants.packageName,
                signKey: AppConstants.signKey,
                pickAddress: userData!.onTripRequest!.pickAddress,
                dropAddress: userData!.onTripRequest!.dropAddress ?? '',
                isTripEndCall: false,
                isFromAnimate: true));
          }
        }
        bearing = getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));
        carMarker = Marker(
            markerId: MarkerId(markerid),
            position: newPos,
            icon: icon,
            rotation: bearing ?? 0.0,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            draggable: false);

        markers.add(carMarker);
        add(UpdateMarkersEvent(markers: markers));
        add(UpdateEvent());
      });

    //Starting the animation
    await animationController!.forward();
    if (userData!.onTripRequest != null) {
      if (map == 'google_map') {
        if (controller != null) {
          controller.getVisibleRegion().then((value) {
            if (value.contains(markers
                    .firstWhere(
                        (element) => element.markerId == MarkerId(markerid))
                    .position) ==
                false) {
              controller.animateCamera(CameraUpdate.newLatLngZoom(
                  markers
                      .firstWhere(
                          (element) => element.markerId == MarkerId(markerid))
                      .position,
                  14));
              add(UpdateEvent());
            } else {
              add(UpdateEvent());
            }
          });
        }
      } else {
        final latLng = markers
            .firstWhere((element) => element.markerId == MarkerId(markerid))
            .position;
        controller!.move(
            fmlt.LatLng(
                latLng.latitude.toDouble(), latLng.longitude.toDouble()),
            13);
        add(UpdateEvent());
      }
    }

    if (userData!.onTripRequest != null &&
        (((userData!.onTripRequest!.arrivedAt != null &&
                    userData!.onTripRequest!.arrivedAt != "") &&
                userData!.onTripRequest!.dropLat != null &&
                userData!.onTripRequest!.dropLng != null) ||
            (userData!.onTripRequest!.arrivedAt == null ||
                userData!.onTripRequest!.arrivedAt == ""))) {
      if (userData!.onTripRequest!.isTripStart != 1 &&
          (userData!.onTripRequest!.arrivedAt == null ||
              userData!.onTripRequest!.arrivedAt == "")) {
        double minPerDistance = double.parse((etaDuration ?? '1').toString()) /
            double.parse((etaDistance ?? '1').toString());
        final newDistance = calculateDistance(
          lat1: toLat,
          lon1: toLong,
          lat2: userData!.onTripRequest!.pickLat,
          lon2: userData!.onTripRequest!.pickLng,
          unit: userData?.distanceUnit ?? 'km',
        );
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          if (polyList.isNotEmpty) 'polyline': encodePolyline(polyList),
          'distance': (userData!.distanceUnit == 'mi'
              ? ((newDistance * 1.60934) * 1000)
              : newDistance * 1000),
          'duration':
              (double.parse((newDistance).toStringAsFixed(0)) * minPerDistance)
                  .toStringAsFixed(0)
        });
        await addDistanceMarker(
            LatLng(
                (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt != "")
                    ? userData!.onTripRequest!.dropLat!
                    : userData!.onTripRequest!.pickLat,
                (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt != "")
                    ? userData!.onTripRequest!.dropLng!
                    : userData!.onTripRequest!.pickLng),
            (userData!.distanceUnit == 'mi'
                ? ((newDistance * 1.60934) * 1000)
                : newDistance * 1000),
            time: (double.parse((newDistance).toStringAsFixed(0)) *
                    minPerDistance)
                .roundToDouble());
      } else if (userData!.onTripRequest!.isTripStart == 1 &&
          (userData!.onTripRequest!.arrivedAt != null &&
              userData!.onTripRequest!.arrivedAt != "")) {
        double minPerDistance =
            double.parse(userData!.onTripRequest!.totalTime.toString()) /
                double.parse(userData!.onTripRequest!.totalDistance);
        double dist = calculateDistance(
          lat1: toLat,
          lon1: toLong,
          lat2: userData!.onTripRequest!.dropLat!,
          lon2: userData!.onTripRequest!.dropLng!,
          unit: userData?.distanceUnit ?? 'km',
        );
        final dist1 = calculateDistance(
          lat1: userData!.onTripRequest!.pickLat,
          lon1: userData!.onTripRequest!.pickLng,
          lat2: toLat,
          lon2: toLong,
          unit: userData?.distanceUnit ?? 'km',
        );
        final calDuration =
            double.parse(userData!.onTripRequest!.totalTime.toString()) -
                ((dist1) * minPerDistance);
        FirebaseDatabase.instance
            .ref('requests')
            .child(userData!.onTripRequest!.id)
            .update({
          if (polyList.isNotEmpty) 'polyline': encodePolyline(polyList),
          'distance': (userData!.distanceUnit == 'mi'
              ? ((dist * 1.60934) * 1000)
              : dist * 1000),
          'duration': calDuration
        });
        await addDistanceMarker(
            LatLng(userData!.onTripRequest!.dropLat!,
                userData!.onTripRequest!.dropLng!),
            (userData!.distanceUnit == 'mi'
                ? ((dist * 1.60934) * 1000)
                : dist * 1000),
            time: calDuration);
      }
    }

    animationController = null;
    add(UpdateEvent());
  }

  String encodePolyline(List<LatLng> polyline) {
    StringBuffer encoded = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (LatLng point in polyline) {
      int lat = (point.latitude * 1E5).round();
      int lng = (point.longitude * 1E5).round();

      // Encode the difference in latitude and longitude
      encoded.write(encodeValue(lat - prevLat));
      encoded.write(encodeValue(lng - prevLng));

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  String encodeValue(int value) {
    int encode = value < 0 ? ~(value << 1) : value << 1;
    StringBuffer result = StringBuffer();

    while (encode >= 0x20) {
      result.writeCharCode((0x20 | (encode & 0x1f)) + 63);
      encode >>= 5;
    }
    result.writeCharCode(encode + 63);

    return result.toString();
  }

  Future<void> biddingFareIncreaseDecrease(
      BiddingIncreaseOrDecreaseEvent event, Emitter<HomeState> emit) async {
    if (event.isIncrease) {
      if ((double.parse(bidRideAmount.text.toString()) +
              (double.parse(
                  userData!.biddingAmountIncreaseOrDecrease.toString()))) <=
          (double.parse(acceptedRideFare) +
              ((double.parse(userData!.biddingHighPercentage) / 100) *
                  double.parse(acceptedRideFare)))) {
        isBiddingIncreaseLimitReach = false;
        isBiddingDecreaseLimitReach = false;
        bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) +
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString())))
            .toStringAsFixed(2);
        if (!((double.parse(bidRideAmount.text.toString()) +
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString()))) <=
            (double.parse(acceptedRideFare) +
                ((double.parse(userData!.biddingHighPercentage) / 100) *
                    double.parse(acceptedRideFare))))) {
          bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) +
                  (double.parse(
                      userData!.biddingAmountIncreaseOrDecrease.toString())))
              .toStringAsFixed(2);
          isBiddingIncreaseLimitReach = true;
          isBiddingDecreaseLimitReach = false;
        }
      } else {
        isBiddingIncreaseLimitReach = true;
        isBiddingDecreaseLimitReach = false;
      }
      emit(UpdateState());
    } else {
      if (bidRideAmount.text.isNotEmpty &&
          double.parse(bidRideAmount.text.toString()) >
              double.parse(acceptedRideFare) &&
          ((userData!.biddingLowPercentage == "0") ||
              (double.parse(bidRideAmount.text.toString()) -
                      double.parse(
                          userData!.biddingAmountIncreaseOrDecrease)) >=
                  (double.parse(acceptedRideFare) -
                      ((double.parse(userData!.biddingLowPercentage) / 100) *
                          double.parse(acceptedRideFare))))) {
        isBiddingDecreaseLimitReach = false;
        isBiddingIncreaseLimitReach = false;
        bidRideAmount.text = (double.parse(bidRideAmount.text.toString()) -
                (double.parse(
                    userData!.biddingAmountIncreaseOrDecrease.toString())))
            .toStringAsFixed(2);
        if (double.parse(bidRideAmount.text.toString()) ==
            double.parse(acceptedRideFare)) {
          isBiddingDecreaseLimitReach = true;
          isBiddingIncreaseLimitReach = false;
        }
      } else {
        isBiddingDecreaseLimitReach = true;
        isBiddingIncreaseLimitReach = false;
      }
      emit(UpdateState());
    }
  }

  FutureOr<void> openAdditionalChargeBottomSheet(
      AdditionalChargeEvent event, Emitter<HomeState> emit) {
    additionalChargeAmountText.text = additionalChargeAmount;
    additionalChargeDetailText.text = additionalChargeText;
    emit(AdditionalChargeState());
  }

  FutureOr<void> tapAdditionalChargeEvent(
      AdditionalChargeOnTapEvent event, Emitter<HomeState> emit) async {
    additionalChargeAmount = event.amount;
    additionalChargeText = event.chargeDetails;
    final data = await serviceLocator<RideUsecases>().additionalChargeApi(
        price: additionalChargeAmount,
        reason: additionalChargeText,
        requestId: event.requestId);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        showToast(message: success.message);
      },
    );
    emit(UpdateState());
  }

  FutureOr<void> stopVerifyOtp(
      StopVerifyOtpEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<RideUsecases>().stopOtpVerify(
        stopId: event.stopId, requestId: event.requestId, otp: event.otp);
    data.fold(
      (error) {
        if (error.message != null) {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        showOtp = false;
        if (showImagePick == false) {
          add(ShowImagePickEvent());
        }
      },
    );
    emit(UpdateState());
  }

  Future<List<Map<String, dynamic>>> fetchPeakZones() async {
    final ref = FirebaseDatabase.instance.ref("peak-zones");
    final snapshot = await ref.get();

    List<Map<String, dynamic>> zones = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        final zone = value as Map<dynamic, dynamic>;
        final name = zone['name'] ?? 'Zone';
        final active = zone['active'] ?? '0';
        final endTime = zone['end_time_timestamp'] ?? '0';

        final List<dynamic>? coordsList = zone['coordinates'];

        if (coordsList != null && coordsList.isNotEmpty) {
          List<LatLng> coords = coordsList.map((e) {
            final coord = e as Map<dynamic, dynamic>;
            final lat = coord['latitude']?.toDouble() ?? 0.0;
            final lng = coord['longitude']?.toDouble() ?? 0.0;
            return LatLng(lat, lng);
          }).toList();

          zones.add({
            'id': key,
            'name': name,
            'active': active,
            'end_time': endTime,
            'coordinates': coords,
          });
        }
      });
    }

    return zones;
  }

  bool peakZoneZoomedOut = false;

  Future<void> loadPeakZones(
      GetPeakZoneEvent event, Emitter<HomeState> emit) async {
    zoneStreamRemove?.cancel();
    final zones = await fetchPeakZones();

    for (var zone in zones) {
      final name = zone['name'];
      final coords = zone['coordinates'] as List<LatLng>;
      final zoneId = zone['id'] as String;
      final zoneActive = zone['active'].toString();
      final endTimestamp = zone['end_time'] as int;

      if (zoneActive == '1') {
        polygons.add(
          Polygon(
            polygonId: PolygonId('peakzone_$zoneId'),
            points: coords,
            strokeColor: Colors.red,
            strokeWidth: 3,
            fillColor: Colors.red.withAlpha((0.2 * 255).toInt()),
            consumeTapEvents: true,
            onTap: () => onZoneTapped(coords, zoneId, name, endTimestamp),
          ),
        );

        polyline.add(
          Polyline(
            polylineId: PolylineId('peakzone_$zoneId'),
            points: coords,
            color: Colors.red.withAlpha((0.5 * 255).toInt()),
            width: 2,
          ),
        );
      } else {
        polygons.removeWhere(
            (element) => element.polygonId.value.contains('peakzone_$zoneId'));
        polyline.removeWhere(
            (element) => element.polylineId.value.contains('peakzone_$zoneId'));
        polyline.removeWhere((element) =>
            element.polylineId.value.contains('peakzone_route_$zoneId'));
      }
    }

    zoneStreamRemove = FirebaseDatabase.instance
        .ref("peak-zones")
        .onValue
        .listen((event) async {
      // Clear existing peak zone drawings
      showDemandArea = false;
      polygons.removeWhere(
          (element) => element.polygonId.value.contains('peakzone_'));
      polyline.removeWhere(
          (element) => element.polylineId.value.contains('peakzone_'));
      polyline.removeWhere(
          (element) => element.polylineId.value.contains('peakzone_route_'));

      // Re-fetch and draw
      final updatedZones = await fetchPeakZones();
      for (var zone in updatedZones) {
        final name = zone['name'];
        final coords = zone['coordinates'] as List<LatLng>;
        final zoneId = zone['id'] as String;
        final zoneActive = zone['active'].toString();
        final endTimestamp = zone['end_time'] as int;

        if (zoneActive == '1') {
          polygons.add(
            Polygon(
              polygonId: PolygonId('peakzone_$zoneId'),
              points: coords,
              strokeColor: Colors.red,
              strokeWidth: 3,
              fillColor: Colors.red.withAlpha((0.2 * 255).toInt()),
              consumeTapEvents: true,
              onTap: () => onZoneTapped(coords, zoneId, name, endTimestamp),
            ),
          );

          polyline.add(
            Polyline(
              polylineId: PolylineId('peakzone_$zoneId'),
              points: coords,
              color: Colors.red.withAlpha((0.5 * 255).toInt()),
              width: 2,
            ),
          );
        }
      }

      add(UpdateEvent());
    });

    // Only zoom out once when peak zones are first enabled
    if (!peakZoneZoomedOut && showPeakZones) {
      if (mapType == 'google_map') {
        googleMapController?.animateCamera(CameraUpdate.zoomOut());
      } else {
        fmController.move(
            fmlt.LatLng(bound!.northeast.latitude, bound!.northeast.longitude),
            13);
      }
      peakZoneZoomedOut = true;
    }

    emit(UpdateState());
  }

  Future<void> onZoneTapped(List<LatLng> zonePoints, String zoneId,
      String zoneName, int endTimestamp) async {
    LatLng target = getNearestPoint(zonePoints, currentLatLng!);
    List<LatLng> arcPath = generateArcPoints(target, currentLatLng!);
    polyline = {
      Polyline(
        polylineId: PolylineId("peakzone_route_$zoneId"),
        points: arcPath,
        width: 3,
        color: Colors.blue,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        patterns: [
          PatternItem.gap(3),
          PatternItem.dash(15),
          PatternItem.gap(3)
        ],
      )
    };
    showDemandArea = true;
    add(UpdateEvent());
    add(ShowZoneNavigationEvent(
        zoneName: zoneName, zoneLatLng: target, endTimestamp: endTimestamp));
  }

  List<LatLng> generateArcPoints(LatLng start, LatLng end, {int count = 60}) {
    List<LatLng> path = [];

    double deltaLat = end.latitude - start.latitude;
    double deltaLng = end.longitude - start.longitude;

    // control point (this creates the "bulge"/arc effect)
    double controlLat =
        start.latitude + deltaLat / 2 + 0.017; // adjust height for arc
    double controlLng =
        start.longitude + deltaLng / 2 - 0.00003; // offset sideways

    for (int i = 0; i <= count; i++) {
      double t = i / count;
      double lat = (1 - t) * (1 - t) * start.latitude +
          2 * (1 - t) * t * controlLat +
          t * t * end.latitude;
      double lng = (1 - t) * (1 - t) * start.longitude +
          2 * (1 - t) * t * controlLng +
          t * t * end.longitude;

      path.add(LatLng(lat, lng));
    }

    return path;
  }

  LatLng getNearestPoint(List<LatLng> points, LatLng current) {
    LatLng nearest = points.first;
    double minDistance = calculateDistance(
        lat1: current.latitude,
        lon1: current.longitude,
        lat2: nearest.latitude,
        lon2: nearest.longitude);

    for (LatLng point in points) {
      double dist = calculateDistance(
          lat1: current.latitude,
          lon1: current.longitude,
          lat2: point.latitude,
          lon2: point.longitude);

      if (dist < minDistance) {
        minDistance = dist;
        nearest = point;
      }
    }

    return nearest;
  }

  @override
  Future<void> close() {
    animationController?.dispose();
    positionSubscription?.cancel();
    rideRepository.dispose();
    return super.close();
  }

  //GET PREFERENCES DETAILS LIST
  FutureOr<void> getPreferencesDetails(
      GetPreferencesDetailsEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<HomeUsecase>().getPreferencesDetails();
    await data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) async {
        preferenceDetailsList = success.data;
        for (var i = 0; i < preferenceDetailsList!.length; i++) {
          if (preferenceDetailsList![i].driverSelected) {
            selectedPreferenceDetailsList.add(preferenceDetailsList![i].id);
          }
        }
      },
    );
  }

//UPDATE PREFERENCES
  FutureOr<void> updatePreferences(
      UpdatePreferencesEvent event, Emitter<HomeState> emit) async {
    final data =
        await serviceLocator<HomeUsecase>().updatePreferences(id: event.id);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        showToast(message: 'added successfully');
        updateFirebaseData();
      },
    );
  }

  Future<void> selectPreferenceEvent(
    SelectedPreferenceEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.isSelected) {
      if (!tempSelectPreference.contains(event.prefId)) {
        tempSelectPreference.add(event.prefId);
      }
    } else {
      tempSelectPreference.remove(event.prefId);
    }
    emit(UpdateState());
  }

  Future<void> confirmPreferenceSelection(
    ConfirmPreferenceEvent event,
    Emitter<HomeState> emit,
  ) async {
    selectedPreferenceDetailsList
      ..clear()
      ..addAll(tempSelectPreference);
    add(UpdatePreferencesEvent(id: tempSelectPreference));
  }

  Future<void> clearTempPreferenceEvent(
    ClearTempPreferenceEvent event,
    Emitter<HomeState> emit,
  ) async {
    tempSelectPreference
      ..clear()
      ..addAll(selectedPreferenceDetailsList); // reset to saved preferences
    // add(UpdatePreferencesEvent(id: selectedPreferenceDetailsList));
    add(UpdateEvent());
  }

// Timer management for automatic user details API calls
// void startUserDetailsTimer() {
//   stopUserDetailsTimer(); // Cancel any existing timer

//   userDetailsTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
//     add(GetUserDetailsEvent());
//     print('object GetUserDetailsEvent 212121 ----- ');
//   });
// }

  void stopUserDetailsTimer() {
    if (userDetailsTimer != null && userDetailsTimer!.isActive) {
      userDetailsTimer!.cancel();
      userDetailsTimer = null;
    }
  }
}

class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}
