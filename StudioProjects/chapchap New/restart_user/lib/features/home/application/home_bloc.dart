// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:restart_tagxi/core/utils/payment_received_stream.dart';
import 'package:restart_tagxi/db/app_database.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:vector_math/vector_math.dart' as vector;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/common.dart';
import '../../../core/utils/custom_debouncer.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../core/utils/functions.dart';
import '../../../core/utils/geohash.dart';
import '../../../di/locator.dart';
import '../../account/application/usecase/acc_usecases.dart';
import '../../account/domain/models/history_model.dart';
import '../domain/models/contact_model.dart';
import '../domain/models/recent_routes_model.dart';
import '../domain/models/ride_modules_model.dart';
import '../domain/models/user_details_model.dart';
import '../domain/models/stop_address_model.dart';
import 'usecase/home_usecases.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  String textDirection = 'ltr';
  String languageCode = '';
  GoogleMapController? googleMapController;
  fm.MapController? fmController;

  FocusNode searchFocus = FocusNode();

  PageController recentRoutesPageController = PageController();
  TextEditingController searchController = TextEditingController();
  TextEditingController pickupAddressController = TextEditingController();
  TextEditingController dropAddressController = TextEditingController();
  TextEditingController stopAddressController = TextEditingController();

  TextEditingController instructionsController = TextEditingController();
  TextEditingController receiverNameController = TextEditingController();
  TextEditingController receiverMobileController = TextEditingController();

  List<GlobalKey> focusNodeKeys = [];

  UserDetail? userData;
  List<String> serviceTypeImages = [
    AppImages.taxi,
    AppImages.delivery,
    AppImages.rental,
    AppImages.outstation,
  ];

  int routesIndex = 0;
  ModulesData? selectedServiceType;
  int choosenTransportType = 0;
  int choosenAddressIndex = 0;
  int bannerIndex = 0;
  int onGoingRideIndex = 0;
  double minChildSize = 0.42;
  double maxChildSize = 0.99;
  double sheetSize = 0.43;
  double midChildSize = 0.68;
  double recentRouteHeight = 0.0;
  double previousScrollOffset = 0.0;
  Map<String, int> bannerIndices = {};
  bool isDriverReceivedPayment = false;
  late RideRepository rideRepository;

  bool isDragging = false;
  bool isCameraMoving = false;
  bool isMyself = false;
  bool ismulitipleride = false;
  bool isPickupSelect = false;
  bool isFavoriteTabSelected = true;
  bool isCameraMoveComplete = false;
  bool isMultipleRide = false;
  bool isLoading = false;
  bool canPop = false;
  bool isSheetAtTop = false;
  bool isOnCurrentLocation = false;
  bool confirmPinAddress = false;
  bool serviceAvailable = true;
  String mapType = 'google_map';
  String currentLocation = '';
  String transportType = '';
  String searchInfoMessage = '';
  String lightMapString = '';
  String darkMapString = '';
  LatLng currentLatLng = const LatLng(0, 0);
  LatLng? pickUpLatLng;
  fmlt.LatLng fmLatLng = const fmlt.LatLng(0, 0);
  CameraPosition? initialCameraPosition;
  final debouncer = Debouncer(milliseconds: 1000);

  ContactsModel selectedContact = ContactsModel(name: '', number: '');
  List<ContactsModel> contactsList = [];
  List markerList = [];
  List banners = [];
  List<FavoriteLocationData> favAddressList = [];
  List<AddressModel> pickupAddressList = [];
  List<AddressModel> stopAddressList = [];
  List<AddressModel> addressList = [];
  List<TextEditingController> addressTextControllerList = [];
  List<AddressModel> recentSearchPlaces = [];
  List<AddressModel> autoSearchPlaces = [];
  List<AddressModel> searchPlaces = [];
  List<HistoryData> onGoingRideList = [];
  List<FocusNode> focusNodeList = [];
  List<RecentRouteData> recentRoutes = [];
  List<ModulesData> rideModules = [];

  Animation<double>? _animation;
  AnimationController? animationController;
  StreamSubscription<DatabaseEvent>? nearByVechileSubscription;
  Map myBearings = {};

  MapType _selectedMapType = MapType.normal;
  MapType get selectedMapType => _selectedMapType;

  HomeBloc() : super(HomeInitialState()) {
    // update
    on<UpdateEvent>((event, emit) => emit(HomeUpdateState()));
    on<GetDirectionEvent>(getDirection);
    // HomePage
    on<GetUserDetailsEvent>(getUserDetails);
    on<GetRideModulesEvent>(getRideModules);
    on<GoogleControllAssignEvent>(assignController);
    on<GetLocationPermissionEvent>(getLocationPermission);
    on<UpdateLocationEvent>(updateLocation);
    on<ServiceTypeChangeEvent>(serviceTypeChage);
    on<DestinationSelectEvent>(destinationUpdate);
    on<LocateMeEvent>(locateMe);
    on<StreamRequestEvent>(streamRequest);
    on<GetOnGoingRidesEvent>(getOngoingRides);
    on<NavigateToOnGoingRidesPageEvent>(navigateToOnGoingRides);
    on<OnGoingRideOnTapEvent>(onGoingRideOnTap);
    on<UpdateScrollPositionEvent>(updateScrollPosition);
    on<RideWithoutDestinationEvent>(rideWithoutDestination);
    on<InitScrollPositionEvent>(initScrollPosition);
    on<ServiceLocationVerifyEvent>(serviceLocationVerify);

    // DestinationPage
    on<DesinationPageInitEvent>(destinationPageInit);
    on<SearchPlacesEvent>(getAutoCompleteSearchPlaces);
    on<RecentSearchPlaceSelectEvent>(recentSearchPlaceSelect);
    on<FavLocationSelectEvent>(favPlaceSelect);
    on<ReceiverContactEvent>(receiverContactDetails);
    on<SelectContactDetailsEvent>(selectContactDetails);
    on<ReorderEvent>(reOrderAddress);
    on<AddStopEvent>(addNewAddressStop);
    on<ConfirmRideAddressEvent>(confirmRideAddress);
    on<RecentRoutesEvent>(getRecentRoutes);
    on<RecentRoutesChangeIndex>(routesChangeIndex);
    on<SavedRecentTabChangeEvent>(savedRecentTabChange);
    on<RecentRouteSelectEvent>(recentRouteSelect);

    // ConfirmLocationPage
    on<ConfirmLocationPageInitEvent>(confirmLocationPageInit);
    on<ConfirmAddressEvent>(confirmAddress);
    on<ConfirmLocationSearchPlaceSelectEvent>(confirmLocationSearchSelectPlace);

    //MapType
    on<UpdateMapTypeEvent>(updateMapType);

    // ConfirmRidePage
    on<SelectFromMapEvent>(selectStopAddress);
    on<AddOrEditStopAddressEvent>(addOrEditStopAddress);

    on<GetCurrentLocationEvent>(getCurrentLocation);

    on<FocusUpdateEvent>(_onFocusUpdate);
    _initializeFocusNodes();

    focusNodeKeys = List.generate(
      addressList.length,
      (index) => GlobalKey(),
    );
  }

  void setDragging(bool dragging) {
    isDragging = dragging;
    add(UpdateEvent());
  }

  void setCameraMoving(bool moving) {
    isCameraMoving = moving;
    add(UpdateEvent());
  }

  Future<void> streamRequest(
      StreamRequestEvent event, Emitter<HomeState> emit) async {
    emit(VechileStreamMarkerState());
  }

  void updateFocusNodeKeys() {
    focusNodeKeys = List.generate(
      addressList.length,
      (index) => GlobalKey(),
    );
  }

  // Define the updateFocusKeys method
  void updateFocusKeys(int index, FocusNode newFocusNode) {
    if (index >= 0 && index < focusNodeList.length) {
      // Update the specific focus node in the list
      focusNodeList[index] = newFocusNode;
    }
  }

  // ===========================VECHILE MARKER ADD======================================>

  nearByVechileCheckStream(BuildContext context, dynamic vsync) async {
    GeoHasher geo = GeoHasher();
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    double lowerLat = 0.0;
    double lowerLon = 0.0;
    double greaterLat = 0.0;
    double greaterLon = 0.0;
    lowerLat = currentLatLng.latitude - (lat * 1.24);
    lowerLon = currentLatLng.longitude - (lon * 1.24);

    greaterLat = currentLatLng.latitude + (lat * 1.24);
    greaterLon = currentLatLng.longitude + (lon * 1.24);

    var lower = geo.encode(lowerLon, lowerLat);
    var higher = geo.encode(greaterLon, greaterLat);

    final BitmapDescriptor bikeMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.bike);

    final BitmapDescriptor carMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.car);

    final BitmapDescriptor autoMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.auto);

    final BitmapDescriptor truckMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.truck);

    final BitmapDescriptor ehcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.ehcv);

    final BitmapDescriptor hatchBack = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.hatchBack);

    final BitmapDescriptor hcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.hcv);

    final BitmapDescriptor lcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.lcv);

    final BitmapDescriptor mcv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.mcv);

    final BitmapDescriptor luxury = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.luxury);

    final BitmapDescriptor premium = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.premium);

    final BitmapDescriptor suv = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 34)), AppImages.suv);

    if (nearByVechileSubscription != null) {
      nearByVechileSubscription?.cancel();
      nearByVechileSubscription = null;
    }
    nearByVechileSubscription = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('g')
        .startAt(lower)
        .endAt(higher)
        .onValue
        .listen((onData) {
      debugPrint('NearByVechiles');
      if (onData.snapshot.exists) {
        List driverData = [];
        for (var element in onData.snapshot.children) {
          driverData.add(element.value);
        }
        for (var element in driverData) {
          if (element['is_active'] == 1 && element['is_available'] == true) {
            if ((choosenTransportType == 0 &&
                    element['transport_type'] == 'taxi') ||
                (choosenTransportType == 1 &&
                    element['transport_type'] == 'delivery') ||
                element['transport_type'] == 'bidding' ||
                element['transport_type'] == 'both') {
              DateTime dt =
                  DateTime.fromMillisecondsSinceEpoch(element['updated_at']);

              if (DateTime.now().difference(dt).inMinutes <= 1) {
                if (markerList
                    .where((e) => e.markerId.toString().contains(
                        'marker#${element['id']}#${element['vehicle_type_icon']}'))
                    .isEmpty) {
                  markerList.add(Marker(
                    markerId: MarkerId(
                        'marker#${element['id']}#${element['vehicle_type_icon']}'),
                    rotation: (myBearings[element['id'].toString()] != null)
                        ? myBearings[element['id'].toString()]
                        : 0.0,
                    position: LatLng(element['l'][0], element['l'][1]),
                    icon: (element['vehicle_type_icon'] == 'truck')
                        ? truckMarker
                        : (element['vehicle_type_icon'] == 'motor_bike')
                            ? bikeMarker
                            : (element['vehicle_type_icon'] == 'auto')
                                ? autoMarker
                                : (element['vehicle_type_icon'] == 'lcv')
                                    ? lcv
                                    : (element['vehicle_type_icon'] == 'ehcv')
                                        ? ehcv
                                        : (element['vehicle_type_icon'] ==
                                                'hatchback')
                                            ? hatchBack
                                            : (element['vehicle_type_icon'] ==
                                                    'hcv')
                                                ? hcv
                                                : (element['vehicle_type_icon'] ==
                                                        'mcv')
                                                    ? mcv
                                                    : (element['vehicle_type_icon'] ==
                                                            'luxury')
                                                        ? luxury
                                                        : (element['vehicle_type_icon'] ==
                                                                'premium')
                                                            ? premium
                                                            : (element['vehicle_type_icon'] ==
                                                                    'suv')
                                                                ? suv
                                                                : carMarker,
                  ));
                } else {
                  if (markerList.isNotEmpty) {
                    final matchingMarker = markerList.firstWhere(
                      (e) => e.markerId.toString().contains(
                          'marker#${element['id']}#${element['vehicle_type_icon']}'),
                      orElse: () => null,
                    );

                    if (matchingMarker != null) {
                      var dist = calculateDistance(
                        lat1: matchingMarker.position.latitude,
                        lon1: matchingMarker.position.longitude,
                        lat2: double.parse(element['l'][0].toString()),
                        lon2: double.parse(element['l'][1].toString()),
                        unit: userData?.distanceUnit ?? 'km',
                      );
                      if ((dist * 1000) > 100) {
                        //KM converted to Meter
                        animationController = AnimationController(
                          animationBehavior: AnimationBehavior.preserve,
                          duration: const Duration(
                              milliseconds:
                                  2000), //Animation duration of marker
                          vsync: vsync, //From the widget
                        );
                        animateCar(
                          markerList
                              .firstWhere((e) => e.markerId.toString().contains(
                                  'marker#${element['id']}#${element['vehicle_type_icon']}'))
                              .position
                              .latitude,
                          markerList
                              .firstWhere((e) => e.markerId.toString().contains(
                                  'marker#${element['id']}#${element['vehicle_type_icon']}'))
                              .position
                              .longitude,
                          element['l'][0],
                          element['l'][1],
                          vsync,
                          googleMapController,
                          'marker#${element['id']}#${element['vehicle_type_icon']}',
                          (element['vehicle_type_icon'] == 'truck')
                              ? truckMarker
                              : (element['vehicle_type_icon'] == 'motor_bike')
                                  ? bikeMarker
                                  : (element['vehicle_type_icon'] == 'auto')
                                      ? autoMarker
                                      : (element['vehicle_type_icon'] == 'lcv')
                                          ? lcv
                                          : (element['vehicle_type_icon'] ==
                                                  'ehcv')
                                              ? ehcv
                                              : (element['vehicle_type_icon'] ==
                                                      'hatchback')
                                                  ? hatchBack
                                                  : (element['vehicle_type_icon'] ==
                                                          'hcv')
                                                      ? hcv
                                                      : (element['vehicle_type_icon'] ==
                                                              'mcv')
                                                          ? mcv
                                                          : (element['vehicle_type_icon'] ==
                                                                  'luxury')
                                                              ? luxury
                                                              : (element['vehicle_type_icon'] ==
                                                                      'premium')
                                                                  ? premium
                                                                  : (element['vehicle_type_icon'] ==
                                                                          'suv')
                                                                      ? suv
                                                                      : carMarker,
                        );
                      }
                    }
                  }
                }
              }
            }
          } else {
            if (markerList
                .where((e) => e.markerId.toString().contains(
                    'marker#${element['id']}#${element['vehicle_type_icon']}'))
                .isNotEmpty) {
              markerList.removeWhere((e) => e.markerId.toString().contains(
                  'marker#${element['id']}#${element['vehicle_type_icon']}'));
            }
          }
        }
        add(UpdateEvent());
      }
    });
  }

  // =======================================================================================>

  Future<void> getDirection(
      GetDirectionEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingStartState());
    languageCode = await AppSharedPreference.getSelectedLanguageCode();
    textDirection = await AppSharedPreference.getLanguageDirection();
    mapType = await AppSharedPreference.getMapType();
    fmController = fm.MapController();
    emit(HomeLoadingStopState());
  }

  // OnGoingRides
  FutureOr<void> getOngoingRides(
      GetOnGoingRidesEvent event, Emitter<HomeState> emit) async {
    isLoading = true;
    final data =
        await serviceLocator<HomeUsecase>().getOnGoingRides(historyFilter: '1');
    data.fold(
      (error) {
        debugPrint(error.toString());
        isLoading = false;
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          emit(OnGoingRidesFailureState());
        }
      },
      (success) {
        debugPrint('OnGoingRides :${success.data}');
        onGoingRideList = success.data;
        isLoading = false;
        emit(OnGoingRidesSuccessState());
      },
    );
  }

  Future<void> navigateToOnGoingRides(
      NavigateToOnGoingRidesPageEvent event, Emitter<HomeState> emit) async {
    emit(NavigateToOnGoingRidesPageState());
  }

  Future<void> onGoingRideOnTap(
      OnGoingRideOnTapEvent event, Emitter<HomeState> emit) async {
    rideRepository = RideRepository();
    if (onGoingRideList[event.selectedIndex].isCompleted == 1) {
      OnTripRequestData tripData = OnTripRequestData.fromJson(
          onGoingRideList[event.selectedIndex].toJson());
      RequestBillData requestBillData = tripData.requestBill.data;
      DriverDetailData driverData = tripData.driverDetail.data;
      rideRepository.updatePaymentReceived(tripData.isPaid == 0 ? false : true);
      emit(UserTripSummaryState(
          requestData: tripData,
          requestBillData: requestBillData,
          driverData: driverData,
          rideRepository: rideRepository));
    } else {
      OnTripRequestData tripData = OnTripRequestData.fromJson(
          onGoingRideList[event.selectedIndex].toJson());
      pickupAddressList.clear();
      pickupAddressList.add(AddressModel(
          orderId: '1',
          address: tripData.pickAddress,
          lat: double.parse(tripData.pickLat),
          lng: double.parse(tripData.pickLng),
          name: tripData.driverDetail.data.name,
          number: tripData.driverDetail.data.mobile,
          isAirportLocation:
              (tripData.pickAddress.toLowerCase().contains('airport'))
                  ? true
                  : false,
          pickup: true));
      if (tripData.requestStops.data.isNotEmpty) {
        for (var i = 0; i < tripData.requestStops.data.length; i++) {
          stopAddressList.add(AddressModel(
            orderId: '${i + 2}',
            address: tripData.requestStops.data[i].address,
            lat: tripData.requestStops.data[i].latitude,
            lng: tripData.requestStops.data[i].longitude,
            name: tripData.requestStops.data[i].pocName,
            number: tripData.requestStops.data[i].pocMobile,
            instructions: tripData.requestStops.data[i].pocInstruction,
            isAirportLocation: (tripData.requestStops.data[i].address
                    .toLowerCase()
                    .contains('airport'))
                ? true
                : false,
            pickup: false,
          ));
        }
      } else {
        if (tripData.dropAddress.isNotEmpty) {
          stopAddressList.add(AddressModel(
            orderId: '2',
            address: tripData.dropAddress,
            lat: double.parse(tripData.dropLat),
            lng: double.parse(tripData.dropLng),
            name: tripData.driverDetail.data.name,
            number: tripData.driverDetail.data.mobile,
            isAirportLocation:
                (tripData.dropAddress.toLowerCase().contains('airport'))
                    ? true
                    : false,
            pickup: false,
          ));
        }
      }
      emit(UserOnTripState(tripData: tripData));
    }
  }

  Future<void> assignController(
      GoogleControllAssignEvent event, Emitter<HomeState> emit) async {
    googleMapController = event.controller;
    lightMapString = await rootBundle.loadString('assets/light-theme.json');
    darkMapString = await rootBundle.loadString('assets/dark-theme.json');
    add(GetLocationPermissionEvent(
        isFromHomePage: event.isFromHomePage,
        isEditAddress: event.isEditAddress));
  }

  Future<void> destinationUpdate(
      DestinationSelectEvent event, Emitter<HomeState> emit) async {
    emit(DestinationSelectState(
      isPickupChange: event.isPickupChange,
      dropAddress: event.dropAddress,
      dropLatLng: event.dropLatLng,
      transportType: event.transportType,
    ));
  }

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
        add(UpdateLocationEvent(
            isFromHomePage: true,
            latLng: currentLatLng,
            mapType: event.mapType));
      }

      // if (currentPosition == null) {
      //   currentPositionUpdate();
      // }
    } else {
      showToast(
          message: 'allow location permission to get your current location');
      emit(GetLocationPermissionState());
    }
  }

  // LocateMe
  Future<void> locateMe(LocateMeEvent event, Emitter<HomeState> emit) async {
    isOnCurrentLocation = true;
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        double lat = position.latitude;
        double long = position.longitude;
        currentLatLng = LatLng(lat, long);
        AppConstants.currentLocations = LatLng(lat, long);
        if (event.mapType == 'google_map') {
          if (googleMapController != null) {
            googleMapController!
                .animateCamera(CameraUpdate.newLatLng(currentLatLng));
          }
        } else {
          if (fmController != null) {
            fmController!.move(fmlt.LatLng(lat, long), 15);
          }
          add(UpdateLocationEvent(
              isFromHomePage: true,
              latLng: currentLatLng,
              mapType: event.mapType));
        }
        add(UpdateLocationEvent(
            isFromHomePage: true,
            latLng: currentLatLng,
            mapType: event.mapType));
      } else {
        add(GetCurrentLocationEvent(mapType: mapType));
      }
    } else {
      showToast(
          message: 'allow location permission to get your current location');
      emit(GetLocationPermissionState());
    }
  }

  // Ride Modules
  FutureOr<void> getRideModules(
      GetRideModulesEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<HomeUsecase>().rideModules();
    await data.fold((error) {
      debugPrint(error.toString());
      if (error.message == 'logout') {
        emit(LogoutState());
      } else {
        emit(HomeLoadingStopState());
      }
    }, (success) async {
      rideModules = success.data;
      if (rideModules.isNotEmpty) {
        for (var i = 0; i < rideModules.length; i++) {
          if (rideModules[i].transportType == 'taxi') {
            selectedServiceType = rideModules[i];
            break;
          }
        }
      }
      emit(HomeUpdateState());
    });
  }

  // UserDetails
  FutureOr<void> getUserDetails(
      GetUserDetailsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingStartState());
    textDirection = await AppSharedPreference.getLanguageDirection();
    final val = await AppSharedPreference.getRecentSearchPlaces();
    if (val.isNotEmpty) {
      List<dynamic> decodedList = jsonDecode(val);
      List<AddressModel> decodedData =
          decodedList.map((item) => AddressModel.fromJson(item)).toList();
      recentSearchPlaces = decodedData;
    }
    final data = await serviceLocator<HomeUsecase>().userDetails();
    await data.fold(
      (error) {
        debugPrint(error.toString());
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          emit(HomeLoadingStopState());
        }
      },
      (success) async {
        userData = success.data;
        if (userData!.zoneTypeId.isEmpty) {
          emit(UpdateZoneLocationState());
        }
        if (!isAppMapChange) {
          mapType = success.data.mapType;
          await AppSharedPreference.setMapType(mapType);
        }
        if ((userData!.onTripRequest == null ||
                userData!.onTripRequest == "") ||
            (userData!.metaRequest == null || userData!.metaRequest == "")) {
          add(LocateMeEvent(mapType: mapType));
        }
        if (userData!.enableModulesForApplications == 'taxi' ||
            userData!.enableModulesForApplications == 'both') {
          choosenTransportType = 0;
        } else if (userData!.enableModulesForApplications == 'delivery') {
          choosenTransportType = 1;
        }

        favAddressList = success.data.favouriteLocations.data;
        if (favAddressList.isNotEmpty) {
          isFavoriteTabSelected = true;
        } else if (recentSearchPlaces.isNotEmpty) {
          isFavoriteTabSelected = false;
        } else {
          isFavoriteTabSelected = true;
        }
        if ((userData!.onTripRequest != null &&
                userData!.onTripRequest != "") ||
            (userData!.metaRequest != null && userData!.metaRequest != "")) {
          OnTripRequestData tripData = userData!.onTripRequest != ""
              ? userData!.onTripRequest.data
              : userData!.metaRequest.data;
          pickupAddressList.clear();
          pickupAddressList.add(AddressModel(
              orderId: '1',
              address: tripData.pickAddress,
              lat: double.parse(tripData.pickLat),
              lng: double.parse(tripData.pickLng),
              name: (tripData.userDetail != null)
                  ? tripData.userDetail!.data.name
                  : '',
              number: (tripData.userDetail != null)
                  ? tripData.userDetail!.data.mobile
                  : '',
              isAirportLocation:
                  (tripData.pickAddress.toLowerCase().contains('airport'))
                      ? true
                      : false,
              pickup: true));
          if (tripData.requestStops.data.isNotEmpty) {
            for (var i = 0; i < tripData.requestStops.data.length; i++) {
              stopAddressList.add(AddressModel(
                orderId: '${i + 2}',
                address: tripData.requestStops.data[i].address,
                lat: tripData.requestStops.data[i].latitude,
                lng: tripData.requestStops.data[i].longitude,
                name: tripData.requestStops.data[i].pocName,
                number: tripData.requestStops.data[i].pocMobile,
                isAirportLocation: (tripData.requestStops.data[i].address
                        .toLowerCase()
                        .contains('airport'))
                    ? true
                    : false,
                instructions: tripData.requestStops.data[i].pocInstruction,
                pickup: false,
              ));
            }
          } else {
            if (tripData.dropLat.isNotEmpty && tripData.dropLng.isNotEmpty) {
              stopAddressList.add(AddressModel(
                orderId: '2',
                address: tripData.dropAddress,
                lat: double.parse(tripData.dropLat),
                lng: double.parse(tripData.dropLng),
                isAirportLocation:
                    (tripData.dropAddress.toLowerCase().contains('airport'))
                        ? true
                        : false,
                name: (tripData.userDetail != null)
                    ? tripData.userDetail!.data.name
                    : '',
                number: (tripData.userDetail != null)
                    ? tripData.userDetail!.data.mobile
                    : '',
                pickup: false,
              ));
            }
          }
          emit(UserOnTripState(tripData: tripData));
        } else if (userData!.hasOngoingRide) {
          isMultipleRide = true;
          add(GetOnGoingRidesEvent());
          emit(HomeLoadingStopState());
        } else {
          emit(HomeLoadingStopState());
        }
        if (success.data.fcmToken.isEmpty) {
          await serviceLocator<AccUsecase>().updateDetailsButton(
            email: userData!.email,
            name: userData!.name,
            gender: userData!.gender,
            profileImage: '',
            mobile: userData!.mobile,
            country: userData!.countryCode,
            updateFcmToken: true,
          );
        }
        emit(HomeUpdateState());
      },
    );
    add(InitScrollPositionEvent());
  }

//  Locations
  Future<void> getLocationPermission(
      GetLocationPermissionEvent event, Emitter<HomeState> emit) async {
    if (event.isEditAddress) {
      if (mapType == 'google_map') {
        if (googleMapController != null) {
          googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: currentLatLng, zoom: 15)));
        }
      } else {
        if (fmController != null) {
          fmController!.move(
              fmlt.LatLng(currentLatLng.latitude, currentLatLng.longitude), 15);
        }
      }
      add(UpdateLocationEvent(
          latLng: currentLatLng,
          isFromHomePage: event.isFromHomePage,
          mapType: mapType));
    } else {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (event.isFromHomePage) {
          Position? position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            double lat = position.latitude;
            double long = position.longitude;
            emit(HomeLoadingStartState());
            currentLatLng = LatLng(lat, long);
            if (mapType == 'google_map') {
              if (googleMapController != null) {
                googleMapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                        CameraPosition(target: currentLatLng, zoom: 15)));
              }
            } else {
              if (fmController != null) {
                fmController!.move(
                    fmlt.LatLng(
                        currentLatLng.latitude, currentLatLng.longitude),
                    15);
              }
            }
          }
          emit(HomeLoadingStopState());
          add(UpdateLocationEvent(
              latLng: currentLatLng,
              isFromHomePage: event.isFromHomePage,
              mapType: mapType));
        } else {
          Position? position = await Geolocator.getLastKnownPosition();
          if (position != null) {
            double lat = position.latitude;
            double long = position.longitude;
            currentLatLng = LatLng(lat, long);
            if (mapType == 'google_map') {
              if (googleMapController != null) {
                googleMapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                        CameraPosition(target: currentLatLng, zoom: 15)));
              }
            } else {
              if (fmController != null) {
                fmController!.move(
                    fmlt.LatLng(
                        currentLatLng.latitude, currentLatLng.longitude),
                    15);
              }
            }
            add(UpdateLocationEvent(
                latLng: LatLng(lat, long),
                isFromHomePage: event.isFromHomePage,
                mapType: mapType));
            // }
          } else {
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            double lat = position.latitude;
            double long = position.longitude;
            if (event.isFromHomePage) {
              emit(HomeLoadingStartState());
              currentLatLng = LatLng(lat, long);
              if (mapType == 'google_map') {
                if (googleMapController != null) {
                  googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                          CameraPosition(target: currentLatLng, zoom: 15)));
                }
              } else {
                if (fmController != null) {
                  fmController!.move(
                      fmlt.LatLng(
                          currentLatLng.latitude, currentLatLng.longitude),
                      15);
                }
              }
              emit(HomeLoadingStopState());
              add(UpdateLocationEvent(
                  latLng: currentLatLng,
                  isFromHomePage: event.isFromHomePage,
                  mapType: mapType));
            }
          }
        }
      } else {
        await Permission.location.request();
        PermissionStatus status = await Permission.location.status;
        if (status.isGranted || status.isLimited) {
          emit(HomeUpdateState());
          add(GetLocationPermissionEvent(
              isEditAddress: event.isEditAddress,
              isFromHomePage: event.isFromHomePage,
              controller: event.controller));
        } else {
          showToast(
              message:
                  'allow location permission to get your current location');
          emit(GetLocationPermissionState());
        }
      }
    }
  }

  Future<void> updateLocation(
      UpdateLocationEvent event, Emitter<HomeState> emit) async {
    if (event.latLng.latitude != 0.0 && event.latLng.longitude != 0.0) {
      final result = await serviceLocator<HomeUsecase>().getAddressFromLatLng(
        lat: event.latLng.latitude,
        lng: event.latLng.longitude,
        mapType: event.mapType,
      );

      result.fold((error) {
        debugPrint('object ---------- $error');
        currentLocation = '';
        pickupAddressController.text = '';
        emit(HomeUpdateState());
      }, (success) {
        final rawAddress = success.toString().trim();
        if (rawAddress.isNotEmpty) {
          List<String> parts =
              rawAddress.split(','); // First try with English comma

          if (parts.length > 1) {
            // Handle possible plus code
            if (parts[0].contains('+')) {
              final plusCode = parts[0];
              parts.removeAt(0);
              final val = plusCode.split(' ');
              if (val.length > 1 && !val[1].contains('+')) {
                currentLocation = '${val[1]} ${parts.join(',')}';
              } else {
                currentLocation = parts.join(',');
              }
            } else {
              currentLocation = parts.join(',');
            }
          } else {
            // Fallback: try Arabic comma
            List<String> arabicParts = rawAddress.split('،');
            if (arabicParts.length > 1) {
              if (arabicParts[0].contains('+')) {
                final plusCode = arabicParts[0];
                arabicParts.removeAt(0);
                final val = plusCode.split(' ');
                if (val.length > 1 && !val[1].contains('+')) {
                  currentLocation = '${val[1]} ${arabicParts.join('،')}';
                } else {
                  currentLocation = arabicParts.join('،');
                }
              } else {
                currentLocation = arabicParts.join('،');
              }
            } else {
              // If neither split works, just use the raw address
              currentLocation = rawAddress;
            }
          }

          // Update controller & list if from home page
          if (event.isFromHomePage) {
            pickupAddressController.text = currentLocation;
            pickupAddressList.removeWhere((element) => element.pickup == true);
            pickupAddressList.add(AddressModel(
              orderId: '1',
              address: currentLocation,
              lat: event.latLng.latitude,
              lng: event.latLng.longitude,
              name: (userData != null) ? userData!.name : '',
              number: (userData != null) ? userData!.mobile : '',
              isAirportLocation:
                  currentLocation.toLowerCase().contains('airport'),
              pickup: true,
            ));

            debugPrint('pickup add');

            add(ServiceLocationVerifyEvent(
              isFromHomePage: event.isFromHomePage,
              rideType: 'taxi',
              address: pickupAddressList,
            ));

            if (nearByVechileSubscription == null) {
              add(StreamRequestEvent());
            }
          }
        } else {
          currentLocation = '';
          pickupAddressController.text = '';
        }
      });
    }

    isCameraMoveComplete = false;
    emit(UpdateLocationState());
  }

  Future<void> serviceTypeChage(
      ServiceTypeChangeEvent event, Emitter<HomeState> emit) async {
    transportType = event.transportType;
    if (event.serviceTypeIndex == 1) {
      emit(DeliverySelectState());
    } else if (event.serviceTypeIndex == 2) {
      emit(RentalSelectState());
    } else if (event.serviceTypeIndex == 3) {
      emit(OutStationSelectState());
    } else {
      // selectedServiceType = event.serviceTypeIndex;
      add(DestinationSelectEvent(isPickupChange: false, transportType: 'taxi'));
    }
  }

  Future<void> destinationPageInit(
      DesinationPageInitEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingStartState());
    transportType = event.arg.transportType;
    userData = event.arg.userData;
    if (event.arg.pickupLatLng != null) {
      pickUpLatLng = event.arg.pickupLatLng!;
      currentLatLng = event.arg.pickupLatLng!;
    } else {
      add(LocateMeEvent(mapType: event.arg.mapType));
    }
    // Pick Address
    if (event.arg.pickupAddress != null && event.arg.pickupLatLng != null) {
      addressList.add(AddressModel(
          orderId: '1',
          address: event.arg.pickupAddress!,
          lat: event.arg.pickupLatLng!.latitude,
          lng: event.arg.pickupLatLng!.longitude,
          name: (userData != null) ? userData!.name : '',
          number: (userData != null) ? userData!.mobile : '',
          isAirportLocation:
              (event.arg.pickupAddress!.toLowerCase().contains('airport'))
                  ? true
                  : false,
          pickup: true));
      addressTextControllerList
          .add(TextEditingController(text: event.arg.pickupAddress));
    } else {
      addressList.add(AddressModel(
          orderId: '1',
          address: '',
          lat: 0,
          lng: 0,
          name: '',
          number: '',
          pickup: true));
      addressTextControllerList.add(TextEditingController(text: ''));
    }

    // Drop Address
    if (event.arg.dropAddress != null && event.arg.dropLatLng != null) {
      addressList.add(AddressModel(
          orderId: '2',
          address: event.arg.dropAddress!,
          lat: event.arg.dropLatLng!.latitude,
          lng: event.arg.dropLatLng!.longitude,
          name: (userData != null) ? userData!.name : '',
          number: (userData != null) ? userData!.mobile : '',
          isAirportLocation:
              (event.arg.dropAddress!.toLowerCase().contains('airport'))
                  ? true
                  : false,
          pickup: false));
      addressTextControllerList
          .add(TextEditingController(text: event.arg.dropAddress));
    } else {
      addressList.add(AddressModel(
          orderId: '2',
          address: '',
          lat: 0,
          lng: 0,
          name: '',
          number: '',
          pickup: false));
      addressTextControllerList.add(TextEditingController(text: ''));
    }
    if (event.arg.pickUpChange) {
      isPickupSelect = true;
      choosenAddressIndex = 0;
    } else {
      isPickupSelect = false;
      choosenAddressIndex = 1;
    }
    final val = await AppSharedPreference.getRecentSearchPlaces();
    if (val.isNotEmpty) {
      List<dynamic> decodedList = jsonDecode(val);
      List<AddressModel> decodedData =
          decodedList.map((item) => AddressModel.fromJson(item)).toList();
      recentSearchPlaces = decodedData;
      add(RecentRoutesEvent());
    }
    emit(HomeLoadingStopState());
  }

  FutureOr<void> getRecentRoutes(
      RecentRoutesEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<HomeUsecase>().getRecentRoutes();
    data.fold(
      (error) {
        debugPrint(error.toString());
      },
      (success) {
        recentRoutes = success.data;
        if (recentRoutes.isNotEmpty) {
          if (recentRoutes.any((element) =>
              element.searchStops.data.isNotEmpty &&
              element.searchStops.data.length == 2)) {
            recentRouteHeight = 0.4;
          } else if (recentRoutes.any((element) =>
              element.searchStops.data.isNotEmpty &&
              element.searchStops.data.length == 1)) {
            recentRouteHeight = 0.3;
          } else {
            recentRouteHeight = 0.22;
          }
        }
        emit(HomeUpdateState());
      },
    );
  }

  FutureOr<void> routesChangeIndex(
      RecentRoutesChangeIndex event, Emitter<HomeState> emit) async {
    routesIndex = event.routesIndex;
    emit(HomeUpdateState());
  }

  FutureOr<void> recentRouteSelect(
      RecentRouteSelectEvent event, Emitter<HomeState> emit) async {
    pickupAddressList.clear();
    pickupAddressList.add(AddressModel(
        orderId: '',
        address: event.selectedRoute.pickAddress,
        lat: event.selectedRoute.pickLat,
        lng: event.selectedRoute.pickLng,
        name: event.selectedRoute.pickupPocName,
        number: event.selectedRoute.pickupPocMobile,
        instructions: event.selectedRoute.pickupPocInstruction,
        pickup: true));
    stopAddressList.clear();
    if (event.selectedRoute.searchStops.data.isNotEmpty) {
      for (var i = 0; i < event.selectedRoute.searchStops.data.length; i++) {
        stopAddressList.add(AddressModel(
            orderId: event.selectedRoute.searchStops.data[i].order.toString(),
            address: event.selectedRoute.searchStops.data[i].address,
            lat: event.selectedRoute.searchStops.data[i].latitude,
            lng: event.selectedRoute.searchStops.data[i].longitude,
            name: event.selectedRoute.searchStops.data[i].pocName,
            number: event.selectedRoute.searchStops.data[i].pocMobile,
            instructions:
                event.selectedRoute.searchStops.data[i].pocInstruction,
            pickup: false));
      }
    }
    stopAddressList.add(AddressModel(
        orderId: '',
        address: event.selectedRoute.dropAddress,
        lat: event.selectedRoute.dropLat,
        lng: event.selectedRoute.dropLng,
        name: event.selectedRoute.dropPocName,
        number: event.selectedRoute.dropPocMobile,
        instructions: event.selectedRoute.dropPocInstruction,
        pickup: false));

    emit(RecentRouteSelectState(selectedRoute: event.selectedRoute));
    final addList = pickupAddressList + stopAddressList;
    // // Check service availability for the route
    add(ServiceLocationVerifyEvent(
        isFromHomePage: false,
        rideType: event.selectedRoute.transportType,
        address: addList));
  }

  FutureOr<void> getAutoCompleteSearchPlaces(
      SearchPlacesEvent event, Emitter<HomeState> emit) async {
    if (event.searchText.length >= 4) {
      searchInfoMessage = AppLocalizations.of(event.context)!.searching;
      emit(SearchOnChangeState());
      final cachedPlaces = await db.getCachedPlaces();
      // Filter cached places
      final matchingCachedPlaces = cachedPlaces
          .where((element) => element.address
              .toLowerCase()
              .contains(event.searchText.toLowerCase()))
          .toList();

      if (matchingCachedPlaces.isNotEmpty && mapType == 'google_map') {
        autoSearchPlaces.clear();
        autoSearchPlaces.addAll(matchingCachedPlaces.map((e) => AddressModel(
              orderId: e.orderId,
              address: e.address,
              lat: e.lat,
              lng: e.lng,
              pickup: e.pickup,
              isAirportLocation: e.isAirportLocation,
            )));
        searchInfoMessage = AppLocalizations.of(event.context)!.searchResult;
        emit(SearchOnChangeState());
        return;
      } else {
        final data = await serviceLocator<HomeUsecase>().getAutoCompletePlaces(
          input: event.searchText,
          mapType: event.mapType,
          countryCode: event.countryCode,
          currentLatLng: event.latLng,
          enbleContryRestrictMap: event.enbleContryRestrictMap,
        );
        data.fold(
          (error) {
            debugPrint(error.toString());
            autoSearchPlaces.clear();
            emit(SearchOnChangeState());
          },
          (success) async {
            autoSearchPlaces.clear();
            searchInfoMessage =
                AppLocalizations.of(event.context)!.searchResult;
            final places = <CachedPlace>[];
            if (event.mapType == 'google_map') {
              for (var element in success) {
                final place = CachedPlace(
                  orderId: element['place_id'],
                  address: element['description'],
                  lat: 0,
                  lng: 0,
                  pickup: false,
                  isAirportLocation:
                      element['description'].toLowerCase().contains('airport'),
                );
                places.add(place);
                autoSearchPlaces.add(AddressModel(
                  orderId: place.orderId,
                  address: place.address,
                  lat: place.lat,
                  lng: place.lng,
                  pickup: place.pickup,
                  isAirportLocation: place.isAirportLocation,
                ));
              }
              for (var place in places) {
                await db.insertCachedPlace(place);
              }
            } else {
              for (var element in success) {
                final place = CachedPlace(
                  orderId: '${element['place_id']}',
                  address: element['display_name'],
                  lat: double.parse(element['lat'].toString()),
                  lng: double.parse(element['lon']),
                  pickup: false,
                  isAirportLocation:
                      element['display_name'].toLowerCase().contains('airport'),
                );
                places.add(place);
                autoSearchPlaces.add(AddressModel(
                  orderId: place.orderId,
                  address: place.address,
                  lat: place.lat,
                  lng: place.lng,
                  pickup: place.pickup,
                  isAirportLocation: place.isAirportLocation,
                ));
              }
            }
          },
        );
        emit(SearchOnChangeState());
      }
    } else if (event.searchText.isNotEmpty && event.searchText.length < 4) {
      searchInfoMessage = AppLocalizations.of(event.context)!
          .minimumSearchLength
          .replaceAll('*', '4');
      autoSearchPlaces.clear();
      emit(SearchOnChangeState());
    } else if (event.searchText.isEmpty) {
      searchInfoMessage = '';
      autoSearchPlaces.clear();
      emit(SearchOnChangeState());
    } else {
      autoSearchPlaces.clear();
      emit(SearchOnChangeState());
    }
  }

  FutureOr<void> recentSearchPlaceSelect(
      RecentSearchPlaceSelectEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingStartState());
    autoSearchPlaces.clear();
    searchInfoMessage = '';
    emit(HomeUpdateState());
    dynamic latLng;
    if ((event.address.lat == 0 || event.address.lat == 0.0) &&
        (event.address.lng == 0 || event.address.lng == 0.0) &&
        mapType == 'google_map') {
      final data = await serviceLocator<HomeUsecase>()
          .getAutoCompletePlaceLatLng(placeId: event.address.orderId);
      data.fold(
        (error) {
          debugPrint(error.toString());
        },
        (success) {
          latLng = success;
        },
      );
    }

    if (recentSearchPlaces.length == 5) {
      recentSearchPlaces.removeAt(0);
    }
    recentSearchPlaces.removeWhere(
        (element) => element.orderId.contains(event.address.orderId));
    recentSearchPlaces.add(AddressModel(
        orderId: event.address.orderId,
        name: event.address.name,
        number: event.address.number,
        address: event.address.address,
        lat: latLng != null ? latLng.latitude : event.address.lat,
        lng: latLng != null ? latLng.longitude : event.address.lng,
        isAirportLocation: event.address.isAirportLocation,
        pickup: false));
    if (mapType == 'google_map') {
      await db.deleteCachedPlaces(event.address.orderId);
      final newPlace = CachedPlace(
        orderId: event.address.orderId,
        address: event.address.address,
        lat: latLng != null ? latLng.latitude : event.address.lat,
        lng: latLng != null ? latLng.longitude : event.address.lng,
        isAirportLocation: event.address.isAirportLocation,
        pickup: false,
      );
      await db.insertCachedPlace(newPlace);
    }
    if (!event.isPickupSelect &&
        event.transportType.toLowerCase() != 'delivery') {
      dropAddressController.text = event.address.address;
      if (stopAddressList
          .any((element) => element.orderId == event.address.orderId)) {
        stopAddressList
            .removeWhere((element) => element.orderId == event.address.orderId);
      }
      stopAddressList.add(AddressModel(
          orderId: event.address.orderId,
          address: event.address.address,
          lat: latLng != null ? latLng.latitude : event.address.lat,
          lng: latLng != null ? latLng.longitude : event.address.lng,
          isAirportLocation: event.address.isAirportLocation,
          name: event.address.name,
          number: event.address.number,
          pickup: false));
      if (pickupAddressList.isEmpty) {
        pickupAddressList = [addressList.first];
      }
    } else if (event.isPickupSelect) {
      currentLocation = event.address.address;
      pickupAddressController.text = event.address.address;
      dropAddressController.text = '';
      pickupAddressList.clear();
      pickupAddressList.add(AddressModel(
          orderId: event.address.orderId,
          address: event.address.address,
          lat: latLng != null ? latLng.latitude : event.address.lat,
          lng: latLng != null ? latLng.longitude : event.address.lng,
          isAirportLocation: event.address.isAirportLocation,
          name: (userData != null) ? userData!.name : '',
          number: (userData != null) ? userData!.mobile : '',
          pickup: true));
    }
    final recent = jsonEncode(
        recentSearchPlaces.map((address) => address.toJson()).toList());
    await AppSharedPreference.setRecentSearchPlaces(recent);

    emit(HomeLoadingStopState());
    emit(RecentSearchPlaceSelectState(
        transportType: event.transportType,
        address: recentSearchPlaces.elementAt(recentSearchPlaces.indexWhere(
            (element) => element.orderId == event.address.orderId))));
  }

  FutureOr<void> favPlaceSelect(
      FavLocationSelectEvent event, Emitter<HomeState> emit) async {
    autoSearchPlaces.clear();
    searchInfoMessage = '';
    final selectedAddress = AddressModel(
        orderId: event.address.id,
        address: event.address.pickAddress,
        lat: double.parse(event.address.pickLat),
        lng: double.parse(event.address.pickLng),
        isAirportLocation:
            (event.address.pickAddress.toLowerCase().contains('airport'))
                ? true
                : false,
        name: (userData != null) ? userData!.name : '',
        number: (userData != null) ? userData!.mobile : '',
        pickup: event.isPickupSelect);

    final favTransportType = selectedServiceType != null
        ? selectedServiceType!.transportType
        : transportType;

    if (!event.isPickupSelect && favTransportType.toLowerCase() != 'delivery') {
      dropAddressController.text = selectedAddress.address;
      if (stopAddressList
          .any((element) => element.orderId == selectedAddress.orderId)) {
        stopAddressList.removeWhere(
            (element) => element.orderId == selectedAddress.orderId);
      }
      stopAddressList.add(AddressModel(
          orderId: selectedAddress.orderId,
          address: selectedAddress.address,
          lat: selectedAddress.lat,
          lng: selectedAddress.lng,
          pickup: false,
          isAirportLocation: selectedAddress.isAirportLocation,
          name: selectedAddress.name,
          number: selectedAddress.number));
      if (pickupAddressList.isEmpty && addressList.isNotEmpty) {
        pickupAddressList = [addressList.first];
      }
    } else if (event.isPickupSelect) {
      currentLocation = selectedAddress.address;
      pickupAddressController.text = selectedAddress.address;
      dropAddressController.text = '';
      pickupAddressList.clear();
      pickupAddressList.add(AddressModel(
          orderId: selectedAddress.orderId,
          address: selectedAddress.address,
          lat: selectedAddress.lat,
          lng: selectedAddress.lng,
          pickup: true,
          isAirportLocation: selectedAddress.isAirportLocation,
          name: selectedAddress.name,
          number: selectedAddress.number));
    }

    emit(RecentSearchPlaceSelectState(
        transportType: favTransportType, address: selectedAddress));
  }

  FutureOr<void> savedRecentTabChange(
      SavedRecentTabChangeEvent event, Emitter<HomeState> emit) async {
    if (isFavoriteTabSelected == event.isFavoriteSelected) return;
    isFavoriteTabSelected = event.isFavoriteSelected;
    emit(HomeUpdateState());
  }

  Future<void> receiverContactDetails(
      ReceiverContactEvent event, Emitter<HomeState> emit) async {
    isMyself = event.isReceiveMyself;
    receiverNameController.text = event.name;
    receiverMobileController.text = event.number;
    emit(HomeUpdateState());
  }

  Future<void> selectContactDetails(
      SelectContactDetailsEvent event, Emitter<HomeState> emit) async {
    await Permission.contacts.request();
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      emit(HomeLoadingStartState());
      if (contactsList.isEmpty) {
        if (await FlutterContacts.requestPermission()) {
          List<Contact> contacts =
              await FlutterContacts.getContacts(withProperties: true);
          for (var contact in contacts) {
            for (var phone in contact.phones) {
              contactsList.add(ContactsModel(
                name: contact.displayName,
                number: phone.number,
              ));
            }
          }
        }
      }
      emit(HomeLoadingStopState());
      emit(SelectContactDetailsState());
    } else {
      debugPrint("Permission Denied");
      bool isOpened = await openAppSettings();
      if (isOpened) {
        debugPrint('App settings opened.');
      } else {
        debugPrint('Failed to open app settings.');
      }
      emit(HomeUpdateState());
    }
  }

  // ConfirmLocationPage
  Future<void> confirmLocationPageInit(
      ConfirmLocationPageInitEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingStartState());
    transportType = event.arg.transportType;
    mapType = event.arg.mapType;
    if (event.arg.mapType != 'google_map') {
      fmController = fm.MapController();
    }
    if (event.arg.latlng != null &&
        event.arg.latlng != const LatLng(0.0, 0.0)) {
      currentLatLng = event.arg.latlng!;
    } else {
      add(LocateMeEvent(mapType: event.arg.mapType));
    }
    final val = await AppSharedPreference.getRecentSearchPlaces();
    if (val.isNotEmpty) {
      List<dynamic> decodedList = jsonDecode(val);
      List<AddressModel> decodedData =
          decodedList.map((item) => AddressModel.fromJson(item)).toList();
      recentSearchPlaces = decodedData;
    }
    emit(HomeLoadingStopState());
  }

  FutureOr<void> confirmAddress(
      ConfirmAddressEvent event, Emitter<HomeState> emit) async {
    emit(ConfirmAddressState(
        isDelivery: event.isDelivery,
        isEditAddress: event.isEditAddress,
        isPickUpEdit: event.isPickUpEdit,
        address: AddressModel(
            orderId: '1',
            address: currentLocation,
            lat: currentLatLng.latitude,
            lng: currentLatLng.longitude,
            isAirportLocation:
                (currentLocation.toLowerCase().toString().contains('airport'))
                    ? true
                    : false,
            name: (userData != null) ? userData!.name : '',
            number: (userData != null) ? userData!.mobile : '',
            pickup: event.isPickUpEdit)));
  }

  FutureOr<void> confirmLocationSearchSelectPlace(
      ConfirmLocationSearchPlaceSelectEvent event,
      Emitter<HomeState> emit) async {
    dynamic latLng;
    if ((event.address.lat == 0 || event.address.lat == 0.0) &&
        (event.address.lng == 0 || event.address.lng == 0.0)) {
      final data = await serviceLocator<HomeUsecase>()
          .getAutoCompletePlaceLatLng(placeId: event.address.orderId);
      data.fold(
        (error) {
          debugPrint(error.toString());
        },
        (success) {
          latLng = success;
        },
      );
    }

    searchInfoMessage = '';
    autoSearchPlaces.clear();
    searchController.clear();

    currentLocation = event.address.address;
    currentLatLng = latLng != null
        ? LatLng(latLng.latitude, latLng.longitude)
        : LatLng(event.address.lat, event.address.lng);
    recentSearchPlaces.removeWhere(
        (element) => element.orderId.contains(event.address.orderId));
    if (recentSearchPlaces.length == 4) {
      recentSearchPlaces.removeAt(0);
    }
    recentSearchPlaces.add(AddressModel(
        orderId: event.address.orderId,
        address: event.address.address,
        lat: latLng != null ? latLng.latitude : event.address.lat,
        lng: latLng != null ? latLng.longitude : event.address.lng,
        isAirportLocation: event.address.isAirportLocation,
        name: (userData != null) ? userData!.name : '',
        number: (userData != null) ? userData!.mobile : '',
        pickup: false));
    if (event.mapType == 'google_map') {
      if (googleMapController != null) {
        googleMapController!.animateCamera(CameraUpdate.newLatLng(
            LatLng(currentLatLng.latitude, currentLatLng.longitude)));
      }
    } else {
      if (fmController != null) {
        fmController!.move(
            fmlt.LatLng(currentLatLng.latitude, currentLatLng.longitude), 15);
      }
    }
    final recent = jsonEncode(
        recentSearchPlaces.map((address) => address.toJson()).toList());
    await AppSharedPreference.setRecentSearchPlaces(recent);
    emit(HomeUpdateState());
  }

  FutureOr<void> selectStopAddress(
      SelectFromMapEvent event, Emitter<HomeState> emit) async {
    emit(SelectFromMapState(
      isPickUpEdit: event.isPickUpEdit,
    ));
  }

  FutureOr<void> addOrEditStopAddress(
      AddOrEditStopAddressEvent event, Emitter<HomeState> emit) async {
    addressList[event.choosenAddressIndex] = event.newAddress;
    addressTextControllerList[event.choosenAddressIndex].text =
        event.newAddress.address;

    emit(AddOrEditAddressState());
    emit(HomeUpdateState());
  }

  Future<void> reOrderAddress(
      ReorderEvent event, Emitter<HomeState> emit) async {
    if (event.oldIndex < event.newIndex) {
      event.newIndex -= 1;
    }
    final item = addressList.removeAt(event.oldIndex);
    final itemController = addressTextControllerList.removeAt(event.oldIndex);
    addressList.insert(event.newIndex, item);
    addressTextControllerList.insert(event.newIndex, itemController);
    add(UpdateEvent());
  }

  FutureOr<void> initScrollPosition(
      InitScrollPositionEvent event, Emitter<HomeState> emit) {
    if (isMultipleRide ||
        (recentSearchPlaces.isNotEmpty && recentSearchPlaces.length > 1)) {
      sheetSize = maxChildSize;
      isSheetAtTop = true;
    }
    bannerIndex = 0;
    emit(UpdateScrollPositionState(sheetSize));
  }

  FutureOr<void> updateScrollPosition(
      UpdateScrollPositionEvent event, Emitter<HomeState> emit) {
    double newSize = event.position;
    if (newSize < minChildSize) {
      newSize = minChildSize;
    } else if (newSize > maxChildSize) {
      newSize = maxChildSize;
    }
    sheetSize = newSize;
    isSheetAtTop = sheetSize == maxChildSize;
    bannerIndex = 0;
    emit(UpdateScrollPositionState(sheetSize));
  }

  FutureOr<void> rideWithoutDestination(
      RideWithoutDestinationEvent event, Emitter<HomeState> emit) {
    emit(RideWithoutDestinationState());
  }

  FutureOr<void> updateTopScrollPositionEvent(
      UpdateScrollTopEvent event, Emitter<HomeState> emit) {}

  Future<void> addNewAddressStop(
      AddStopEvent event, Emitter<HomeState> emit) async {
    addressList.add(AddressModel(
        orderId: '',
        address: '',
        lat: 0,
        lng: 0,
        name: '',
        number: '',
        pickup: false));
    addressTextControllerList.add(TextEditingController(text: ''));
    emit(HomeUpdateState());
  }

  Future<void> confirmRideAddress(
      ConfirmRideAddressEvent event, Emitter<HomeState> emit) async {
    pickupAddressList.clear();
    stopAddressList.clear();
    pickupAddressList.add(event.addressList.first);
    for (var i = 0; i < event.addressList.length; i++) {
      if (i != 0) {
        stopAddressList.add(event.addressList[i]);
      }
    }
    add(ServiceLocationVerifyEvent(
        address: event.addressList, rideType: event.rideType));
    emit(HomeUpdateState());
  }

  FutureOr<void> serviceLocationVerify(
      ServiceLocationVerifyEvent event, Emitter<HomeState> emit) async {
    final data = await serviceLocator<HomeUsecase>().serviceLocationVerify(
        rideType: event.rideType, address: event.address);
    data.fold(
      (error) {
        debugPrint(error.toString());
        if (error.message == 'logout') {
          emit(LogoutState());
        } else {
          emit(HomeUpdateState());
        }
      },
      (success) {
        if (success["success"] == false) {
          if (event.isFromHomePage != null && event.isFromHomePage!) {
            serviceAvailable = false;
            emit(HomeUpdateState());
          } else {
            emit(ServiceNotAvailableState(message: success["message"]));
          }
        } else {
          if (event.isFromHomePage != null && event.isFromHomePage!) {
            serviceAvailable = true;
            emit(HomeUpdateState());
          }
          if (!addressList.any((element) => element.address.isEmpty)) {
            emit(ConfirmRideAddressState());
          }
        }
      },
    );
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(math.atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(math.atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(math.atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(math.atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
    double fromLat, //Starting latitude

    double fromLong, //Starting longitude

    double toLat, //Ending latitude

    double toLong, //Ending longitude

    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation

    GoogleMapController? controller, //Google map controller of our widget

    markerid,
    icon,
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    dynamic carMarker;
    // if (name == '' && number == '') {
    carMarker = Marker(
        markerId: MarkerId(markerid),
        position: LatLng(fromLat, fromLong),
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false);

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController!)
      ..addListener(() async {
        markerList
            .removeWhere((element) => element.markerId == MarkerId(markerid));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        carMarker = Marker(
            markerId: MarkerId(markerid),
            position: newPos,
            icon: icon,
            rotation: bearing,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            draggable: false);

        //Adding new marker to our list and updating the google map UI.

        markerList.add(carMarker);

        add(UpdateEvent());
      });

    //Starting the animation

    await animationController!.forward();
    if (controller != null &&
        userData != null &&
        userData!.onTripRequest != "" &&
        userData!.onTripRequest != null) {
      controller.getVisibleRegion().then((value) {
        if (value.contains(markerList
                .firstWhere((element) => element.markerId == MarkerId(markerid))
                .position) ==
            false) {
          debugPrint('Animating correctly');
          controller.animateCamera(CameraUpdate.newLatLng(markerList
              .firstWhere((element) => element.markerId == MarkerId(markerid))
              .position));
        } else {
          debugPrint('Animating wrongly');
        }
      });
    }

    animationController = null;
  }

  int calculateResponsiveFlex(double screenWidth) {
    if (screenWidth < 360) {
      return 5;
    } else if (screenWidth >= 360 && screenWidth < 720) {
      return 8;
    } else if (screenWidth >= 720 && screenWidth < 1080) {
      return 10;
    } else {
      return 12;
    }
  }

  double calculateResponsiveBottom(double screenHeight) {
    if (screenHeight < 600) {
      return 150;
    } else if (screenHeight >= 600 && screenHeight < 800) {
      return 200;
    } else if (screenHeight >= 800 && screenHeight < 1000) {
      return 380;
    } else {
      return 385;
    }
  }

  void _initializeFocusNodes() {
    focusNodeList = List.generate(addressList.length, (index) => FocusNode());
  }

  void _onFocusUpdate(FocusUpdateEvent event, Emitter<HomeState> emit) {
    if (focusNodeList.isNotEmpty && event.focusIndex < focusNodeList.length) {
      focusNodeList[event.focusIndex].requestFocus();
    }
  }

  void updateBannerIndex(
      CarouselIndexUpdateEvent event, Emitter<HomeState> emit) {
    bannerIndices[event.carouselId] = event.index;
    emit(CarouselUpdateState(carouselIndices: Map.of(bannerIndices)));
  }

  int getBannerIndex(String carouselId) {
    return bannerIndices[carouselId] ?? 0;
  }

  Future<void> updateMapType(
      UpdateMapTypeEvent event, Emitter<HomeState> emit) async {
    _selectedMapType = event.mapType;
    emit(HomeUpdateState());
  }
}
