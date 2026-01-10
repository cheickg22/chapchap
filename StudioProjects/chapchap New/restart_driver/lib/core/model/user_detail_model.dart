import 'dart:convert';

UserDetailResponseModel userDetailResponseModelFromJson(String str) =>
    UserDetailResponseModel.fromJson(json.decode(str));

UserDetail? userData;

class UserDetailResponseModel {
  bool success;
  UserDetail data;

  UserDetailResponseModel({
    required this.success,
    required this.data,
  });

  factory UserDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      UserDetailResponseModel(
        success: json["success"],
        data: UserDetail.fromJson(json["data"]),
      );
}

class UserDetail {
  dynamic id;
  dynamic userId;
  String name;
  String role;
  String gender;
  String lastName;
  String username;
  String email;
  String mobile;
  String profilePicture;
  bool active;
  bool available;
  bool approve;
  bool uploadedDocument;
  String? declinedReason;
  dynamic ownerId;
  int emailConfirmed;
  int mobileConfirmed;
  String lastKnownIp;
  String lastLoginAt;
  String rating;
  int noOfRatings;
  String refferalCode;
  String driverMode;
  String currencyCode;
  String currencySymbol;
  String countryCode;
  bool showRentalRide;
  bool showRideLaterFeature;
  String authorizationCode;
  String enableModulesForApplications;
  String contactUsMobile1;
  String contactUsMobile2;
  String contactUsLink;
  String showWalletMoneyTransferFeatureOnMobileApp;
  String showBankInfoFeatureOnMobileApp;
  String showInstantRideFeatureForMobileApp;
  String showIncentiveFeatureForDriver;
  String showWalletFeatureOnMobileApp;
  String biddingLowPercentage;
  String biddingHighPercentage;
  int notificationsCount;
  String referralComissionString;
  List<SubVehicleType>? subVehicleType;
  String enableSubVehicleFeature;
  String userCanMakeARideAfterXMiniutes;
  int maximumTimeForFindDriversForRegularRide;
  String maximumTimeForFindDriversForBittingRide;
  dynamic enableDriverPreferenceForUser;
  String enablePetPreferenceForUser;
  String enableLuggagePreferenceForUser;
  String biddingAmountIncreaseOrDecrease;
  String showRideWithoutDestination;
  String enableCountryRestrictOnMap;
  String chatId;
  String mapType;
  bool hasOngoingRide;
  String showOutstationRideFeature;
  SOS? sos;
  dynamic bannerImage;
  Wallet? wallet;
  Subscription? subscription;
  LoyaltyPoints? loyaltyPoints;
  OnTripData? onTripRequest;
  MetaData? metaRequest;
  Map laterMetaRequest;
  String? serviceLocationId;
  String? serviceLocationName;
  String? vehicleTypeId;
  dynamic vehicleTypeName;
  dynamic vehicleTypeIcon;
  dynamic carMake;
  dynamic carModel;
  String? carColor;
  String? carNumber;
  List? vehicleTypes;
  String transportType;
  int acceptDuration;
  bool? enableBidding;
  bool? enableBidOnFare;
  String? companyName;
  String? companyAddress;
  String? companyPostalCode;
  String? companyCity;
  String? companyTaxNumber;
  String? totalEarnings;
  String? totalKms;
  String? totalMinutesOnline;
  String? totalRidesTaken;
  bool? hasSubscription;
  bool? isExpired;
  bool? isSubscribed;
  bool? showDriverLevel;
  String? pricePerDistance;
  String? availableIncentive;
  String enableSupportTicketFeature;
  String enableMapAppearanceChange;
  bool enableLeaderboardFeature;
  bool lowBalance;
  String enableWazeMap;
  String isDeletedAt;
  String distanceUnit;
  bool hasLater;
  String androidApp;
  String iosApp;
  bool enablePeakZoneFeature;
  bool hasWaitingRide;
  String enableSecondRideForDriver;
  String distanceForSecondRide;
  String myRouteAddress;
  String enableMyRouteBooking;
  String enableMyRouteFeature;
  bool? sharedRide;
  String? occupiedSeats;
  String? maximumDistance;
  double? biddingRideMaximumDistance;

  UserDetail({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.gender,
    required this.lastName,
    required this.username,
    required this.email,
    required this.mobile,
    required this.profilePicture,
    required this.active,
    required this.available,
    required this.approve,
    required this.uploadedDocument,
    required this.declinedReason,
    required this.ownerId,
    required this.emailConfirmed,
    required this.mobileConfirmed,
    required this.lastKnownIp,
    required this.lastLoginAt,
    required this.rating,
    required this.noOfRatings,
    required this.refferalCode,
    required this.driverMode,
    required this.currencyCode,
    required this.currencySymbol,
    required this.countryCode,
    required this.showRentalRide,
    required this.showRideLaterFeature,
    required this.authorizationCode,
    required this.enableModulesForApplications,
    required this.contactUsMobile1,
    required this.contactUsMobile2,
    required this.contactUsLink,
    required this.showWalletMoneyTransferFeatureOnMobileApp,
    required this.showBankInfoFeatureOnMobileApp,
    required this.showInstantRideFeatureForMobileApp,
    required this.showIncentiveFeatureForDriver,
    required this.showWalletFeatureOnMobileApp,
    required this.notificationsCount,
    required this.referralComissionString,
    required this.subVehicleType,
    required this.enableSubVehicleFeature,
    required this.userCanMakeARideAfterXMiniutes,
    required this.maximumTimeForFindDriversForRegularRide,
    required this.maximumTimeForFindDriversForBittingRide,
    required this.biddingLowPercentage,
    required this.biddingHighPercentage,
    required this.enableDriverPreferenceForUser,
    required this.enablePetPreferenceForUser,
    required this.enableLuggagePreferenceForUser,
    required this.biddingAmountIncreaseOrDecrease,
    required this.showRideWithoutDestination,
    required this.enableCountryRestrictOnMap,
    required this.chatId,
    required this.mapType,
    required this.hasOngoingRide,
    required this.showOutstationRideFeature,
    required this.sos,
    required this.bannerImage,
    required this.wallet,
    required this.subscription,
    required this.loyaltyPoints,
    required this.onTripRequest,
    required this.metaRequest,
    required this.laterMetaRequest,
    required this.serviceLocationId,
    required this.serviceLocationName,
    required this.enableSupportTicketFeature,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.vehicleTypeIcon,
    required this.carMake,
    required this.carModel,
    required this.carColor,
    required this.carNumber,
    required this.vehicleTypes,
    required this.transportType,
    required this.acceptDuration,
    required this.enableBidding,
    required this.enableBidOnFare,
    required this.companyName,
    required this.companyAddress,
    required this.companyPostalCode,
    required this.companyCity,
    required this.companyTaxNumber,
    required this.totalEarnings,
    required this.totalKms,
    required this.totalMinutesOnline,
    required this.totalRidesTaken,
    required this.hasSubscription,
    required this.isExpired,
    required this.isSubscribed,
    required this.showDriverLevel,
    required this.pricePerDistance,
    required this.lowBalance,
    required this.availableIncentive,
    required this.enableWazeMap,
    required this.isDeletedAt,
    required this.distanceUnit,
    required this.hasLater,
    required this.enableLeaderboardFeature,
    required this.enableMapAppearanceChange,
    required this.androidApp,
    required this.iosApp,
    required this.enablePeakZoneFeature,
    required this.hasWaitingRide,
    required this.distanceForSecondRide,
    required this.enableSecondRideForDriver,
    required this.myRouteAddress,
    required this.enableMyRouteBooking,
    required this.enableMyRouteFeature,
    required this.occupiedSeats,
    required this.maximumDistance,
    required this.biddingRideMaximumDistance,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      name: json["name"] ?? '',
      role: json['role'] ?? '',
      gender: json["gender"] ?? '',
      lastName: json["last_name"] ?? '',
      username: json["username"] ?? '',
      email: json["email"] ?? '',
      mobile: json["mobile"] ?? '',
      profilePicture: json["profile_picture"] ?? '',
      active: json["active"] ?? false,
      available: json["available"] ?? false,
      approve: json['approve'] ?? false,
      uploadedDocument: json['uploaded_document'] ?? false,
      declinedReason: json["declined_reason"] ?? '',
      ownerId: json["owner_id"] ?? '',
      emailConfirmed: json["email_confirmed"] ?? 0,
      mobileConfirmed: json["mobile_confirmed"] ?? 0,
      lastKnownIp: json["last_known_ip"] ?? '',
      lastLoginAt: json["last_login_at"] ?? '',
      rating: json["rating"].toString(),
      noOfRatings: json["no_of_ratings"] ?? 0,
      refferalCode: json["refferal_code"] ?? '',
      driverMode: json['driver_mode'] ?? '',
      currencyCode: json["currency_code"] ?? '',
      currencySymbol: json["currency_symbol"] ?? '',
      countryCode: json["country_code"] ?? '',
      showRentalRide: json["show_rental_ride"] ?? false,
      showRideLaterFeature: json["show_ride_later_feature"] ?? false,
      authorizationCode: json["authorization_code"] ?? '',
      enableModulesForApplications:
          json["enable_modules_for_applications"] ?? '',
      maximumDistance: json["maximum_distance"] ?? '',
      biddingRideMaximumDistance: (json["bidding_ride_maximum_distance"] !=
              null)
          ? double.tryParse(json["bidding_ride_maximum_distance"].toString())
          : null,
      contactUsMobile1: json["contact_us_mobile1"] ?? '',
      contactUsMobile2: json["contact_us_mobile2"] ?? '',
      contactUsLink: json["contact_us_link"] ?? '',
      showWalletMoneyTransferFeatureOnMobileApp:
          json["show_wallet_money_transfer_feature_on_mobile_app"] ?? '',
      showBankInfoFeatureOnMobileApp:
          json["show_bank_info_feature_on_mobile_app"] ?? '',
      showInstantRideFeatureForMobileApp:
          json["show_instant_ride_feature_on_mobile_app"] ?? '',
      showIncentiveFeatureForDriver:
          json["show_incentive_feature_for_driver"] ?? '',
      showWalletFeatureOnMobileApp:
          json["show_wallet_feature_on_mobile_app"] ?? '',
      notificationsCount: json["notifications_count"] ?? 0,
      referralComissionString: json["referral_comission_string"] ?? '',
      subVehicleType: (json["sub_vehicle_type"] != null)
          ? List<SubVehicleType>.from(
              json["sub_vehicle_type"].map((x) => SubVehicleType.fromJson(x)))
          : null,
      enableSubVehicleFeature: json["enable_sub_vehicle_feature"] ?? '0',
      userCanMakeARideAfterXMiniutes:
          json["user_can_make_a_ride_after_x_miniutes"] ?? '',
      maximumTimeForFindDriversForRegularRide:
          json["maximum_time_for_find_drivers_for_regular_ride"] ?? 0,
      maximumTimeForFindDriversForBittingRide:
          json["maximum_time_for_find_drivers_for_bitting_ride"] ?? '',
      enableDriverPreferenceForUser:
          json["enable_driver_preference_for_user"] ?? '',
      enablePetPreferenceForUser: json["enable_pet_preference_for_user"] ?? '',
      enableLuggagePreferenceForUser:
          json["enable_luggage_preference_for_user"] ?? '',
      biddingAmountIncreaseOrDecrease:
          json["bidding_amount_increase_or_decrease"] ?? '',
      showRideWithoutDestination: json["show_ride_without_destination"] ?? '',
      enableCountryRestrictOnMap: json["enable_country_restrict_on_map"] ?? '',
      chatId: json["conversation_id"] ?? '',
      mapType: json["map_type"] ?? '',
      hasOngoingRide: json["has_ongoing_ride"] ?? false,
      showOutstationRideFeature: json["show_outstation_ride_feature"] ?? '',
      sos: json["sos"] != null ? SOS.fromJson(json["sos"]) : null,
      bannerImage: json["bannerImage"] ?? '',
      wallet: (json["wallet"] != null) ? Wallet.fromJson(json["wallet"]) : null,
      subscription: json["subscription"] != null
          ? Subscription.fromJson(json["subscription"])
          : json["subscription"],
      loyaltyPoints: json["loyaltyPoint"] != null
          ? LoyaltyPoints.fromJson(json["loyaltyPoint"])
          : json["loyaltyPoint"],
      onTripRequest: (json["onTripRequest"] != null)
          ? OnTripData.fromJson(json["onTripRequest"]["data"])
          : null,
      metaRequest: (json["metaRequest"] != null)
          ? MetaData.fromJson(json["metaRequest"]["data"])
          : null,
      laterMetaRequest: json["laterMetaRequest"] ?? {},
      serviceLocationId: json["service_location_id"] ?? '',
      serviceLocationName: json["service_location_name"] ?? '',
      vehicleTypeId: json["vehicle_type_id"] ?? '',
      vehicleTypeName: json["vehicle_type_name"] ?? '',
      vehicleTypeIcon: json["vehicle_type_icon_for"] ?? '',
      carMake: json["car_make_name"] ?? '',
      carModel: json["car_model_name"] ?? '',
      carColor: json["car_color"] ?? '',
      carNumber: json["car_number"] ?? '',
      vehicleTypes: json["vehicle_types"] ?? [],
      transportType: json["transport_type"] ?? '',
      biddingLowPercentage: json["bidding_low_percentage"] ?? '',
      biddingHighPercentage: json["bidding_high_percentage"] ?? '',
      acceptDuration: json["trip_accept_reject_duration_for_driver"] != null
          ? int.parse(
              json["trip_accept_reject_duration_for_driver"].toString(),
            )
          : 0,
      enableSupportTicketFeature:
          json['enable_support_ticket_feature'].toString(),
      enableBidding: json['enable_bidding'] ?? false,
      enableBidOnFare: json['enable_bid_on_fare'] ?? false,
      companyName: json['company_name'] ?? '',
      companyAddress: json['address'] ?? '',
      companyPostalCode: json['postal_code'].toString(),
      companyCity: json['city'] ?? '',
      companyTaxNumber: json['tax_number'] ?? '',
      totalEarnings: json['total_earnings'].toString(),
      totalKms: json['total_trip_kms'].toString(),
      totalMinutesOnline: json['total_minutes_online'].toString(),
      totalRidesTaken: json['total_trips'].toString(),
      hasSubscription: json['has_subsription'] ?? false,
      isExpired: json['is_expired'] ?? false,
      isSubscribed: json['is_subscribed'] ?? false,
      showDriverLevel: json['show_driver_level_feature'] ?? false,
      pricePerDistance: (json['price_per_distance'] != null)
          ? json['price_per_distance'].toString()
          : '0',
      availableIncentive: json['available_incentive'].toString(),
      lowBalance: json['low_balance'] ?? false,
      enableWazeMap: json['enable_vase_map'] ?? '',
      isDeletedAt: json['is_deleted_at'] ?? '',
      distanceUnit: json["distance_unit"] ?? '',
      hasLater: json["has_later"] ?? false,
      enableLeaderboardFeature: json["enable_leaderboard_feature"] ?? false,
      enableMapAppearanceChange:
          json['enable_map_appearance_change_on_mobile_app'].toString(),
      androidApp: json["android_app"] ?? '',
      iosApp: json["ios_app"] ?? '',
      enablePeakZoneFeature: json["enable_peak_zone_feature"] ?? false,
      hasWaitingRide: json["has_waiting_ride"] ?? false,
      distanceForSecondRide:
          json["distance_for_second_ride"]?.toString() ?? '0',
      enableSecondRideForDriver:
          json["enable_second_ride_for_driver"]?.toString() ?? '0',
      myRouteAddress: json["my_route_address"] ?? '',
      enableMyRouteBooking: json["enable_my_route_booking"]?.toString() ?? '0',
      occupiedSeats: json["occupied_seats"]?.toString(),
      enableMyRouteFeature:
          json["enable_my_route_booking_feature"]?.toString() ?? '0',
    );
  }
}

class MetaData {
  String id;
  String requestNumber;
  bool isLater;
  String? tripStartTime;
  String paymentOpt;
  double requestEtaAmount;
  String vehicleType;
  String vehicleTypeImage;
  double pickLat;
  double pickLng;
  double? dropLat;
  double? dropLng;
  String pickAddress;
  String? dropAddress;
  String? pickPocName;
  String? pickPocMobile;
  String? pickPocInstruction;
  String? dropPocName;
  String? dropPocMobile;
  String? dropPocInstruction;
  String currencySymbol;
  bool isRental;
  int? rentalPackageId;
  int isOutstation;
  String? returnTime;
  String rentalPackageName;
  String goodsType;
  String? goodsQuantity;
  String? polyline;
  int isPetAvailable;
  int isLuggageAvailable;
  bool laterRide;
  String paymentType;
  String transportType;
  List requestStops;
  String? userName;
  String? userEmail;
  String userImage;
  String? userGender;
  String userMobile;
  bool showRequestEtaAmount;
  int userCompletedRideCount;
  double userRatings;
  double totalTime;
  String totalDistance;
  dynamic isPreferenceList;
  bool shareRide;
  String? convertedTripStartTime;
  MetaData(
      {required this.id,
      required this.requestNumber,
      required this.isLater,
      this.tripStartTime,
      required this.paymentOpt,
      required this.requestEtaAmount,
      required this.vehicleType,
      required this.vehicleTypeImage,
      required this.pickLat,
      required this.pickLng,
      required this.dropLat,
      required this.dropLng,
      required this.pickAddress,
      required this.dropAddress,
      required this.pickPocName,
      required this.pickPocMobile,
      required this.pickPocInstruction,
      required this.dropPocName,
      required this.dropPocMobile,
      required this.dropPocInstruction,
      required this.currencySymbol,
      required this.isRental,
      required this.rentalPackageId,
      required this.isOutstation,
      required this.returnTime,
      required this.rentalPackageName,
      required this.goodsType,
      required this.goodsQuantity,
      required this.polyline,
      required this.isPetAvailable,
      required this.isLuggageAvailable,
      required this.laterRide,
      required this.paymentType,
      required this.transportType,
      required this.requestStops,
      required this.userName,
      required this.userEmail,
      required this.userImage,
      required this.userGender,
      required this.userMobile,
      required this.showRequestEtaAmount,
      required this.userCompletedRideCount,
      required this.userRatings,
      required this.totalDistance,
      required this.totalTime,
      required this.isPreferenceList,
      required this.shareRide,
      required this.convertedTripStartTime});

  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        id: json["id"],
        requestNumber: json["request_number"],
        isLater: json["is_later"],
        tripStartTime: json["cv_trip_start_time"],
        paymentOpt: json["payment_opt"],
        requestEtaAmount: json["request_eta_amount"].toDouble(),
        vehicleType: json["vehicle_type_name"],
        vehicleTypeImage: json["vehicle_type_image"],
        pickLat: json["pick_lat"],
        pickLng: json["pick_lng"],
        dropLat: json["drop_lat"],
        dropLng: json["drop_lng"],
        pickAddress: json["pick_address"],
        dropAddress: json["drop_address"],
        pickPocName: json["pickup_poc_name"],
        pickPocMobile: json["pickup_poc_mobile"],
        pickPocInstruction: json["pickup_poc_instruction"],
        dropPocName: json["drop_poc_name"],
        dropPocMobile: json["drop_poc_mobile"],
        dropPocInstruction: json["drop_poc_instruction"],
        currencySymbol: json["requested_currency_symbol"],
        isRental: json["is_rental"],
        rentalPackageId: json["rental_package_id"],
        isOutstation: json["is_out_station"],
        returnTime: json["return_time"],
        rentalPackageName: json["rental_package_name"],
        goodsType: json["goods_type"],
        goodsQuantity: json["goods_type_quantity"],
        polyline: json["poly_line"],
        isPetAvailable: json["is_pet_available"],
        isLuggageAvailable: json["is_luggage_available"],
        laterRide: json["later_ride"],
        paymentType: json["payment_type_string"],
        transportType: json["transport_type"],
        requestStops: json["requestStops"]["data"],
        userName: json["userDetail"] != null
            ? json["userDetail"]["data"]["name"] ?? ''
            : "",
        userEmail: json["userDetail"] != null
            ? json["userDetail"]["data"]["email"] ?? ''
            : "",
        userImage: json["userDetail"] != null
            ? json["userDetail"]["data"]["profile_picture"] ?? ''
            : "",
        userGender: json["userDetail"] != null
            ? json["userDetail"]["data"]["gender"] ?? ''
            : "",
        userMobile: json["userDetail"] != null
            ? json["userDetail"]["data"]["mobile"] ?? ''
            : '',
        showRequestEtaAmount: json["show_request_eta_amount"],
        userCompletedRideCount: json["userDetail"] != null
            ? json["userDetail"]["data"]["completed_ride_count"] ?? ''
            : "",
        userRatings: json["userDetail"] != null
            ? json["userDetail"]["data"]["rating"]?.toDouble() ?? ''
            : "",
        totalTime: json["total_time"]?.toDouble() ?? 0.0,
        totalDistance: json["total_distance"] ?? '0',
        isPreferenceList: (json["requestPreferences"] != null)
            ? RequestPreferencesList.fromJson(json["requestPreferences"])
            : null,
        shareRide: json['shared_ride'] ?? false,
        convertedTripStartTime: json['converted_trip_start_time'],
      );
}

class RequestPreferencesList {
  List<RequestPreferencesListData> data;

  RequestPreferencesList({
    required this.data,
  });

  factory RequestPreferencesList.fromJson(Map<String, dynamic> json) =>
      RequestPreferencesList(
        data: List<RequestPreferencesListData>.from(
            json["data"].map((x) => RequestPreferencesListData.fromJson(x))),
      );
}

class RequestPreferencesListData {
  int id;
  int preferencePriceId;
  int preferenceId;
  String name;
  String icon;
  int price;

  RequestPreferencesListData({
    required this.id,
    required this.preferencePriceId,
    required this.preferenceId,
    required this.name,
    required this.icon,
    required this.price,
  });

  factory RequestPreferencesListData.fromJson(Map<String, dynamic> json) =>
      RequestPreferencesListData(
        id: json["id"],
        preferencePriceId: json["preference_price_id"],
        preferenceId: json["preference_id"],
        name: json["name"],
        icon: json["icon"],
        price: json["price"],
      );
}

class SOS {
  List<SOSDatum> data;

  SOS({
    required this.data,
  });

  factory SOS.fromJson(Map<String, dynamic> json) => SOS(
        data: json["data"] != []
            ? List<SOSDatum>.from(json["data"].map((x) => SOSDatum.fromJson(x)))
            : [],
      );
}

class SOSDatum {
  String? id;
  String? name;
  String? number;
  String? userType;
  bool? status;

  SOSDatum({
    this.id,
    this.name,
    this.number,
    this.userType,
    this.status,
  });

  factory SOSDatum.fromJson(Map<String, dynamic> json) => SOSDatum(
        id: json["id"] ?? '',
        name: json["name"] ?? '',
        number: json["number"] ?? '',
        userType: json["user_type"] ?? '',
        status: json["status"] ?? '',
      );
}

class OnTripData {
  int showAdditionalChargeFeature;
  String id;
  String requestNumber;
  bool isLater;
  String? tripStartTime;
  String paymentOpt;
  dynamic requestEtaAmount;
  String vehicleType;
  String vehicleTypeImage;
  double pickLat;
  double pickLng;
  double? dropLat;
  double? dropLng;
  String pickAddress;
  String? dropAddress;
  String? pickPocName;
  String? pickPocMobile;
  String? pickPocInstruction;
  String? dropPocName;
  String? dropPocMobile;
  String? dropPocInstruction;
  String currencySymbol;
  bool isRental;
  int? rentalPackageId;
  int isOutstation;
  String? returnTime;
  String rentalPackageName;
  String goodsType;
  String? goodsQuantity;
  String? polyline;
  int isPetAvailable;
  int isLuggageAvailable;
  bool laterRide;
  dynamic discountedTotal;
  String paymentType;
  String transportType;
  List requestStops;
  String userName;
  String userEmail;
  String userImage;
  String userGender;
  String userMobile;
  String? arrivedAt;
  String? acceptedAt;
  String? completedAt;
  int isTripStart;
  int isCompleted;
  int isCancelled;
  bool showRequestEtaAmount;
  bool showOtpFeature;
  double waitingCharge;
  int freeWaitingTimeBeforeStart;
  int freeWaitingTimeAfterStart;
  double totalTime;
  String totalDistance;
  String unit;
  RequestBill? requestBill;
  int isPaid;
  String? enableShipmentLoad;
  String? enableShipmentUnload;
  String? enableDigitalSignature;
  String enableDriverTipsFeature;
  dynamic acceptedRideFare;
  String isBidRide;
  int completedRideCount;
  double ratings;
  String paidAt;
  dynamic requestPreferences;
  bool? sharedRide;
  String? seatsTaken;

  OnTripData({
    required this.showAdditionalChargeFeature,
    required this.id,
    required this.requestNumber,
    required this.isLater,
    required this.tripStartTime,
    required this.paymentOpt,
    required this.requestEtaAmount,
    required this.vehicleType,
    required this.vehicleTypeImage,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
    required this.pickAddress,
    required this.dropAddress,
    required this.pickPocName,
    required this.pickPocMobile,
    required this.pickPocInstruction,
    required this.dropPocName,
    required this.dropPocMobile,
    required this.dropPocInstruction,
    required this.currencySymbol,
    required this.isRental,
    required this.rentalPackageId,
    required this.isOutstation,
    required this.returnTime,
    required this.rentalPackageName,
    required this.goodsType,
    required this.goodsQuantity,
    required this.polyline,
    required this.isPetAvailable,
    required this.isLuggageAvailable,
    required this.laterRide,
    required this.discountedTotal,
    required this.paymentType,
    required this.transportType,
    required this.requestStops,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    required this.userGender,
    required this.userMobile,
    required this.arrivedAt,
    required this.acceptedAt,
    required this.completedAt,
    required this.isTripStart,
    required this.isCompleted,
    required this.isCancelled,
    required this.showRequestEtaAmount,
    required this.showOtpFeature,
    required this.waitingCharge,
    required this.freeWaitingTimeBeforeStart,
    required this.freeWaitingTimeAfterStart,
    required this.totalTime,
    required this.totalDistance,
    required this.unit,
    required this.requestBill,
    required this.isPaid,
    required this.enableShipmentLoad,
    required this.enableShipmentUnload,
    required this.enableDigitalSignature,
    required this.acceptedRideFare,
    required this.enableDriverTipsFeature,
    required this.isBidRide,
    required this.completedRideCount,
    required this.ratings,
    required this.paidAt,
    required this.requestPreferences,
    this.sharedRide,
    this.seatsTaken,
  });

  factory OnTripData.fromJson(Map<String, dynamic> json) => OnTripData(
        showAdditionalChargeFeature:
            int.tryParse('${json["show_additional_charge_feature"]}') ?? 0,
        id: json["id"],
        requestNumber: json["request_number"],
        isLater: json["is_later"],
        tripStartTime: json["trip_start_time"],
        paymentOpt: json["payment_opt"]?.toString() ?? '1',
        requestEtaAmount: json["request_eta_amount"],
        vehicleType: json["vehicle_type_name"],
        vehicleTypeImage: json["vehicle_type_image"],
        pickLat: json["pick_lat"],
        pickLng: json["pick_lng"],
        dropLat: json["drop_lat"],
        dropLng: json["drop_lng"],
        pickAddress: json["pick_address"],
        dropAddress: json["drop_address"],
        pickPocName: json["pickup_poc_name"],
        pickPocMobile: json["pickup_poc_mobile"],
        pickPocInstruction: json["pickup_poc_instruction"],
        dropPocName: json["drop_poc_name"],
        dropPocMobile: json["drop_poc_mobile"],
        dropPocInstruction: json["drop_poc_instruction"],
        currencySymbol: json["requested_currency_symbol"],
        isRental: json["is_rental"],
        rentalPackageId: json["rental_package_id"],
        isOutstation: json["is_out_station"] ?? 0,
        returnTime: json["return_time"],
        rentalPackageName: json["rental_package_name"],
        goodsType: json["goods_type"],
        goodsQuantity: json["goods_type_quantity"],
        polyline: json["poly_line"],
        isPetAvailable: json["is_pet_available"],
        isLuggageAvailable: json["is_luggage_available"],
        laterRide: json["later_ride"],
        paymentType: json["payment_type_string"],
        discountedTotal: json["discounted_total"] ?? '',
        transportType: json["transport_type"],
        requestStops: json["requestStops"]["data"],
        userName: json["userDetail"] != null
            ? json["userDetail"]["data"]["name"] ?? ''
            : "",
        userEmail: json["userDetail"] != null
            ? json["userDetail"]["data"]["email"] ?? ''
            : "",
        userImage: json["userDetail"] != null
            ? json["userDetail"]["data"]["profile_picture"] ?? ''
            : "",
        userGender: json["userDetail"] != null
            ? json["userDetail"]["data"]["gender"] ?? ''
            : "",
        userMobile: json["userDetail"] != null
            ? json["userDetail"]["data"]["mobile"] ?? ''
            : "",
        showRequestEtaAmount: json["show_request_eta_amount"],
        arrivedAt: json["arrived_at"],
        acceptedAt: json["accepted_at"],
        completedAt: json["completed_at"],
        isTripStart:
            (json["is_trip_start"] == true) ? 1 : json["is_trip_start"],
        isCancelled: json["is_cancelled"] ?? 0,
        isCompleted: json["is_completed"] ?? 0,
        showOtpFeature: json["show_otp_feature"],
        waitingCharge: json["waiting_charge"].toDouble(),
        freeWaitingTimeAfterStart:
            json["free_waiting_time_in_mins_after_trip_start"],
        freeWaitingTimeBeforeStart:
            json["free_waiting_time_in_mins_before_trip_start"],
        totalTime: json["total_time"]?.toDouble() ?? 0,
        totalDistance: json["total_distance"] ?? '0',
        unit: json["unit"],
        requestBill: (json["requestBill"] != null)
            ? RequestBill.fromJson(json["requestBill"]["data"])
            : null,
        isPaid: json["is_paid"] ?? 0,
        enableShipmentLoad: json['enable_shipment_load_feature'] ?? '0',
        enableShipmentUnload: json['enable_shipment_unload_feature'] ?? '0',
        enableDigitalSignature: json['enable_digital_signature'] ?? '0',
        acceptedRideFare: json['accepted_ride_fare'],
        enableDriverTipsFeature: json['enable_driver_tips_feature'] ?? '0',
        isBidRide: json['is_bid_ride'].toString(),
        completedRideCount: json["userDetail"] != null
            ? json["userDetail"]["data"]["completed_ride_count"] ?? 0
            : 0,
        ratings: json["userDetail"] != null
            ? json["userDetail"]["data"]["rating"]?.toDouble() ?? 0.0
            : 0.0,
        paidAt: json["paid_at"] ?? '',
        seatsTaken: json['occupied_seats'] ?? '0',
        requestPreferences: (json["requestPreferences"] != null)
            ? RequestPreferences.fromJson(json["requestPreferences"])
            : null,
        sharedRide: (() {
          final v = json['shared_ride'];
          if (v is bool) return v;
          if (v is int) return v == 1;
          if (v is String) {
            final s = v.toLowerCase();
            return s == '1' || s == 'true';
          }
          return false;
        })(),
      );
}

class RequestPreferences {
  List<RequestPreferencesData> data;

  RequestPreferences({
    required this.data,
  });

  factory RequestPreferences.fromJson(Map<String, dynamic> json) =>
      RequestPreferences(
        data: List<RequestPreferencesData>.from(
            json["data"].map((x) => RequestPreferencesData.fromJson(x))),
      );
}

class RequestPreferencesData {
  int id;
  int preferencePriceId;
  int preferenceId;
  String name;
  String icon;
  int price;

  RequestPreferencesData({
    required this.id,
    required this.preferencePriceId,
    required this.preferenceId,
    required this.name,
    required this.icon,
    required this.price,
  });

  factory RequestPreferencesData.fromJson(Map<String, dynamic> json) =>
      RequestPreferencesData(
        id: json["id"],
        preferencePriceId: json["preference_price_id"],
        preferenceId: json["preference_id"],
        name: json["name"],
        icon: json["icon"],
        price: json["price"],
      );
}

class RequestBill {
  int id;
  double basePrice;
  double baseDistance;
  double pricePerDistance;
  double distancePrice;
  double pricePerTime;
  double timePrice;
  double waitingCharge;
  double cancellationFee;
  double airportSurgeFee;
  double serviceTax;
  double serviceTaxPercentage;
  double promoDiscount;
  double adminCommission;
  double driverCommision;
  double totalAmount;
  String requestedCurrencyCode;
  String currencySymbol;
  double adminCommisionWithTax;
  String driverTips;
  int calculatedWaitingTime;
  double waitingChargePerMin;
  double adminCommisionFromDriver;
  double additionalChargesAmount;
  String? additionalChargesReason;
  String calculatedDistance;
  String totalTime;
  String unit;
  double preferencePriceTotal;

  RequestBill(
      {required this.id,
      required this.basePrice,
      required this.baseDistance,
      required this.pricePerDistance,
      required this.distancePrice,
      required this.pricePerTime,
      required this.timePrice,
      required this.waitingCharge,
      required this.cancellationFee,
      required this.airportSurgeFee,
      required this.serviceTax,
      required this.serviceTaxPercentage,
      required this.promoDiscount,
      required this.adminCommission,
      required this.driverCommision,
      required this.totalAmount,
      required this.requestedCurrencyCode,
      required this.currencySymbol,
      required this.adminCommisionWithTax,
      required this.driverTips,
      required this.calculatedWaitingTime,
      required this.waitingChargePerMin,
      required this.adminCommisionFromDriver,
      required this.additionalChargesAmount,
      required this.additionalChargesReason,
      required this.calculatedDistance,
      required this.totalTime,
      required this.unit,
      required this.preferencePriceTotal});

  factory RequestBill.fromJson(Map<String, dynamic> json) => RequestBill(
        id: json["id"],
        basePrice: json["base_price"]?.toDouble(),
        baseDistance: json["base_distance"]?.toDouble(),
        pricePerDistance: json["price_per_distance"]?.toDouble(),
        distancePrice: json["distance_price"]?.toDouble(),
        pricePerTime: json["price_per_time"]?.toDouble(),
        timePrice: json["time_price"]?.toDouble(),
        waitingCharge: json["waiting_charge"]?.toDouble(),
        cancellationFee: json["cancellation_fee"]?.toDouble(),
        airportSurgeFee: json["airport_surge_fee"]?.toDouble(),
        serviceTax: json["service_tax"]?.toDouble(),
        serviceTaxPercentage: json["service_tax_percentage"]?.toDouble(),
        promoDiscount: json["promo_discount"]?.toDouble(),
        adminCommission: json["admin_commision"]?.toDouble(),
        driverCommision: json["driver_commision"]?.toDouble(),
        driverTips: json["driver_tips"]?.toString() ?? '0',
        totalAmount: json["total_amount"]?.toDouble(),
        requestedCurrencyCode: json["requested_currency_code"],
        currencySymbol: json["requested_currency_symbol"],
        adminCommisionWithTax: json["admin_commision_with_tax"]?.toDouble(),
        calculatedWaitingTime: json["calculated_waiting_time"],
        waitingChargePerMin: json["waiting_charge_per_min"]?.toDouble(),
        adminCommisionFromDriver:
            json["admin_commision_from_driver"]?.toDouble(),
        additionalChargesAmount: json["additional_charges_amount"]?.toDouble(),
        additionalChargesReason: json["additional_charges_reason"],
        calculatedDistance: json["calculated_distance"].toString(),
        totalTime: json["total_time"].toString(),
        unit: json["unit"] ?? '',
        preferencePriceTotal: json['preference_price_total']?.toDouble() ?? 0,
      );
}

class Wallet {
  WalletData data;

  Wallet({
    required this.data,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        data: WalletData.fromJson(json["data"]),
      );
}

class WalletData {
  String id;
  int userId;
  dynamic amountAdded;
  dynamic amountBalance;
  dynamic amountSpent;
  String currencySymbol;
  String currencyCode;
  String createdAt;
  String updatedAt;

  WalletData({
    required this.id,
    required this.userId,
    required this.amountAdded,
    required this.amountBalance,
    required this.amountSpent,
    required this.currencySymbol,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        id: json["id"] ?? '',
        userId: json["user_id"] is int
            ? json["user_id"]
            : int.tryParse(json["user_id"] ?? '0') ?? 0,
        amountAdded: json["amount_added"]?.toDouble() ?? 0.0,
        amountBalance: json["amount_balance"]?.toDouble() ?? 0.0,
        amountSpent: json["amount_spent"]?.toDouble() ?? 0.0,
        currencySymbol: json["currency_symbol"] ?? '',
        currencyCode: json["currency_code"] ?? '',
        createdAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
      );
}

class Subscription {
  SubscriptionDatas data;

  Subscription({
    required this.data,
  });

  // Factory constructor to create a Subscription object from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        data: SubscriptionDatas.fromJson(json["data"]),
      );
}

class SubscriptionDatas {
  String id;
  int subscriptionId;
  String subscriptionName;
  String transactionId;
  int paidAmount;
  String expiredAt;
  String startedAt;
  int subscriptionType;

  SubscriptionDatas({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.transactionId,
    required this.paidAmount,
    required this.expiredAt,
    required this.startedAt,
    required this.subscriptionType,
  });

  // Factory constructor to create a SubscriptionData object from JSON
  factory SubscriptionDatas.fromJson(Map<String, dynamic> json) =>
      SubscriptionDatas(
        id: json["id"] ?? '',
        subscriptionId: json["subscription_id"] ?? 0,
        subscriptionName: json["subscription_name"] ?? '',
        transactionId: json["transaction_id"] ?? '',
        paidAmount: json["paid_amount"] ?? 0,
        expiredAt: json["expired_at"] ?? '',
        startedAt: json["started_at"] ?? '',
        subscriptionType: json["subscription_type"] ?? 0,
      );
}

class LoyaltyPoints {
  LoyaltyPointsDatas data;

  LoyaltyPoints({
    required this.data,
  });
  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) => LoyaltyPoints(
        data: LoyaltyPointsDatas.fromJson(json["data"]),
      );
}

class LoyaltyPointsDatas {
  String id;
  int userId;
  double pointsAdded;
  double balanceRewardPoints;
  String enableRewardConversation;
  double minimumRewardPoints;
  double pointsSpent;
  double conversionQuotient;
  String startedAt;
  String updatedAt;
  double totalRewardPointsCollected;

  LoyaltyPointsDatas({
    required this.id,
    required this.userId,
    required this.pointsAdded,
    required this.balanceRewardPoints,
    required this.enableRewardConversation,
    required this.minimumRewardPoints,
    required this.pointsSpent,
    required this.conversionQuotient,
    required this.startedAt,
    required this.updatedAt,
    required this.totalRewardPointsCollected,
  });

  // Factory constructor to create a SubscriptionData object from JSON
  factory LoyaltyPointsDatas.fromJson(Map<String, dynamic> json) =>
      LoyaltyPointsDatas(
        id: json["id"] ?? '',
        userId: json["user_id"] ?? 0,
        pointsAdded: json["points_added"]?.toDouble() ?? '',
        balanceRewardPoints: json["balance_reward_points"]?.toDouble() ?? 0.0,
        enableRewardConversation: json["enable_reward_conversion"].toString(),
        minimumRewardPoints: json['minimun_reward_point']?.toDouble(),
        pointsSpent: json["points_spent"]?.toDouble() ?? 0.0,
        conversionQuotient: json['conversion_quotient']?.toDouble(),
        startedAt: json["created_at"] ?? '',
        updatedAt: json["updated_at"] ?? '',
        totalRewardPointsCollected:
            json["total_reward_points_collected"]?.toDouble() ?? 0.0,
      );
}

class SubVehicleType {
  String name;
  String vehicleType;

  SubVehicleType({
    required this.name,
    required this.vehicleType,
  });

  factory SubVehicleType.fromJson(Map<String, dynamic> json) => SubVehicleType(
        name: json["name"],
        vehicleType: json["vehicle_type"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "vehicle_type": vehicleType,
      };
}
