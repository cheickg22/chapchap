// To parse this JSON data, do
//
//     final outstationResponseModel = outstationResponseModelFromJson(jsonString);

import 'dart:convert';

OutstationResponseModel outstationResponseModelFromJson(String str) =>
    OutstationResponseModel.fromJson(json.decode(str));

class OutstationResponseModel {
  bool success;
  String message;
  List<OutstationResponse> data;

  OutstationResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OutstationResponseModel.fromJson(Map<String, dynamic> json) =>
      OutstationResponseModel(
        success: json["success"],
        message: json["message"],
        data: List<OutstationResponse>.from(
            json["data"].map((x) => OutstationResponse.fromJson(x))),
      );
}

class OutstationResponse {
  String id;
  String requestNumber;
  int rideOtp;
  int isLater;
  int userId;
  String serviceLocationId;
  String tripStartTime;
  dynamic arrivedAt;
  dynamic acceptedAt;
  dynamic completedAt;
  int isDriverStarted;
  int isDriverArrived;
  String updatedAt;
  int isTripStart;
  String totalDistance;
  int totalTime;
  int isCompleted;
  int isCancelled;
  String cancelMethod;
  String paymentOpt;
  int isPaid;
  int userRated;
  int driverRated;
  String unit;
  String zoneTypeId;
  String vehicleTypeId;
  String vehicleTypeName;
  String vehicleTypeImage;
  String carMakeName;
  String carModelName;
  String carColor;
  String carNumber;
  double pickLat;
  double pickLng;
  double dropLat;
  double dropLng;
  String pickAddress;
  String dropAddress;
  dynamic pickupPocName;
  dynamic pickupPocMobile;
  dynamic dropPocName;
  dynamic dropPocMobile;
  dynamic pickupPocInstruction;
  dynamic dropPocInstruction;
  String requestedCurrencyCode;
  String requestedCurrencySymbol;
  int userCancellationFee;
  bool isRental;
  dynamic rentalPackageId;
  int isOutStation;
  dynamic returnTime;
  dynamic isRoundTrip;
  String rentalPackageName;
  bool showDropLocation;
  double? requestEtaAmount;
  bool showRequestEtaAmount;
  int offerredRideFare;
  int acceptedRideFare;
  int isBidRide;
  int rideUserRating;
  int rideDriverRating;
  bool ifDispatch;
  String goodsType;
  dynamic goodsTypeQuantity;
  String convertedTripStartTime;
  dynamic convertedArrivedAt;
  dynamic convertedAcceptedAt;
  dynamic convertedCompletedAt;
  dynamic convertedCancelledAt;
  String convertedCreatedAt;
  String paymentType;
  dynamic discountedTotal;
  String polyLine;
  int isPetAvailable;
  int isLuggageAvailable;
  bool showOtpFeature;
  bool completedRide;
  bool laterRide;
  bool cancelledRide;
  bool ongoingRide;
  String tripStartTimeWithDate;
  dynamic arrivedAtWithDate;
  dynamic acceptedAtWithDate;
  dynamic completedAtWithDate;
  dynamic cancelledAtWithDate;
  String creatededAtWithDate;
  String biddingLowPercentage;
  String biddingHighPercentage;
  int maximumTimeForFindDriversForRegularRide;
  int freeWaitingTimeInMinsBeforeTripStart;
  int freeWaitingTimeInMinsAfterTripStart;
  int waitingCharge;
  String paymentTypeString;
  String cvTripStartTime;
  dynamic cvCompletedAt;
  String cvCreatedAt;
  String transportType;
  RequestStops requestStops;
  dynamic driverDetail;
  OutstationUserDetail userDetail;

  OutstationResponse({
    required this.id,
    required this.requestNumber,
    required this.rideOtp,
    required this.isLater,
    required this.userId,
    required this.serviceLocationId,
    required this.tripStartTime,
    required this.arrivedAt,
    required this.acceptedAt,
    required this.completedAt,
    required this.isDriverStarted,
    required this.isDriverArrived,
    required this.updatedAt,
    required this.isTripStart,
    required this.totalDistance,
    required this.totalTime,
    required this.isCompleted,
    required this.isCancelled,
    required this.cancelMethod,
    required this.paymentOpt,
    required this.isPaid,
    required this.userRated,
    required this.driverRated,
    required this.unit,
    required this.zoneTypeId,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.vehicleTypeImage,
    required this.carMakeName,
    required this.carModelName,
    required this.carColor,
    required this.carNumber,
    required this.pickLat,
    required this.pickLng,
    required this.dropLat,
    required this.dropLng,
    required this.pickAddress,
    required this.dropAddress,
    required this.pickupPocName,
    required this.pickupPocMobile,
    required this.dropPocName,
    required this.dropPocMobile,
    required this.pickupPocInstruction,
    required this.dropPocInstruction,
    required this.requestedCurrencyCode,
    required this.requestedCurrencySymbol,
    required this.userCancellationFee,
    required this.isRental,
    required this.rentalPackageId,
    required this.isOutStation,
    required this.returnTime,
    required this.isRoundTrip,
    required this.rentalPackageName,
    required this.showDropLocation,
    required this.requestEtaAmount,
    required this.showRequestEtaAmount,
    required this.offerredRideFare,
    required this.acceptedRideFare,
    required this.isBidRide,
    required this.rideUserRating,
    required this.rideDriverRating,
    required this.ifDispatch,
    required this.goodsType,
    required this.goodsTypeQuantity,
    required this.convertedTripStartTime,
    required this.convertedArrivedAt,
    required this.convertedAcceptedAt,
    required this.convertedCompletedAt,
    required this.convertedCancelledAt,
    required this.convertedCreatedAt,
    required this.paymentType,
    required this.discountedTotal,
    required this.polyLine,
    required this.isPetAvailable,
    required this.isLuggageAvailable,
    required this.showOtpFeature,
    required this.completedRide,
    required this.laterRide,
    required this.cancelledRide,
    required this.ongoingRide,
    required this.tripStartTimeWithDate,
    required this.arrivedAtWithDate,
    required this.acceptedAtWithDate,
    required this.completedAtWithDate,
    required this.cancelledAtWithDate,
    required this.creatededAtWithDate,
    required this.biddingLowPercentage,
    required this.biddingHighPercentage,
    required this.maximumTimeForFindDriversForRegularRide,
    required this.freeWaitingTimeInMinsBeforeTripStart,
    required this.freeWaitingTimeInMinsAfterTripStart,
    required this.waitingCharge,
    required this.paymentTypeString,
    required this.cvTripStartTime,
    required this.cvCompletedAt,
    required this.cvCreatedAt,
    required this.transportType,
    required this.requestStops,
    required this.driverDetail,
    required this.userDetail,
  });

  factory OutstationResponse.fromJson(Map<String, dynamic> json) =>
      OutstationResponse(
        id: json["id"],
        requestNumber: json["request_number"],
        rideOtp: json["ride_otp"],
        isLater: json["is_later"],
        userId: json["user_id"],
        serviceLocationId: json["service_location_id"],
        tripStartTime: json["trip_start_time"],
        arrivedAt: json["arrived_at"],
        acceptedAt: json["accepted_at"],
        completedAt: json["completed_at"],
        isDriverStarted: json["is_driver_started"],
        isDriverArrived: json["is_driver_arrived"],
        updatedAt: json["updated_at"],
        isTripStart: json["is_trip_start"],
        totalDistance: json["total_distance"],
        totalTime: json["total_time"],
        isCompleted: json["is_completed"],
        isCancelled: json["is_cancelled"],
        cancelMethod: json["cancel_method"],
        paymentOpt: json["payment_opt"],
        isPaid: json["is_paid"],
        userRated: json["user_rated"],
        driverRated: json["driver_rated"],
        unit: json["unit"],
        zoneTypeId: json["zone_type_id"],
        vehicleTypeId: json["vehicle_type_id"],
        vehicleTypeName: json["vehicle_type_name"],
        vehicleTypeImage: json["vehicle_type_image"],
        carMakeName: json["car_make_name"],
        carModelName: json["car_model_name"],
        carColor: json["car_color"],
        carNumber: json["car_number"],
        pickLat: json["pick_lat"]?.toDouble(),
        pickLng: json["pick_lng"]?.toDouble(),
        dropLat: json["drop_lat"]?.toDouble(),
        dropLng: json["drop_lng"]?.toDouble(),
        pickAddress: json["pick_address"],
        dropAddress: json["drop_address"],
        pickupPocName: json["pickup_poc_name"],
        pickupPocMobile: json["pickup_poc_mobile"],
        dropPocName: json["drop_poc_name"],
        dropPocMobile: json["drop_poc_mobile"],
        pickupPocInstruction: json["pickup_poc_instruction"],
        dropPocInstruction: json["drop_poc_instruction"],
        requestedCurrencyCode: json["requested_currency_code"],
        requestedCurrencySymbol: json["requested_currency_symbol"],
        userCancellationFee: json["user_cancellation_fee"],
        isRental: json["is_rental"],
        rentalPackageId: json["rental_package_id"],
        isOutStation: json["is_out_station"],
        returnTime: json["return_time"],
        isRoundTrip: json["is_round_trip"],
        rentalPackageName: json["rental_package_name"],
        showDropLocation: json["show_drop_location"],
        requestEtaAmount: json["request_eta_amount"].toDouble() ?? 0.0,
        showRequestEtaAmount: json["show_request_eta_amount"],
        offerredRideFare: json["offerred_ride_fare"],
        acceptedRideFare: json["accepted_ride_fare"],
        isBidRide: json["is_bid_ride"],
        rideUserRating: json["ride_user_rating"],
        rideDriverRating: json["ride_driver_rating"],
        ifDispatch: json["if_dispatch"],
        goodsType: json["goods_type"],
        goodsTypeQuantity: json["goods_type_quantity"],
        convertedTripStartTime: json["converted_trip_start_time"],
        convertedArrivedAt: json["converted_arrived_at"],
        convertedAcceptedAt: json["converted_accepted_at"],
        convertedCompletedAt: json["converted_completed_at"],
        convertedCancelledAt: json["converted_cancelled_at"],
        convertedCreatedAt: json["converted_created_at"],
        paymentType: json["payment_type"],
        discountedTotal: json["discounted_total"],
        polyLine: json["poly_line"],
        isPetAvailable: json["is_pet_available"],
        isLuggageAvailable: json["is_luggage_available"],
        showOtpFeature: json["show_otp_feature"],
        completedRide: json["completed_ride"],
        laterRide: json["later_ride"],
        cancelledRide: json["cancelled_ride"],
        ongoingRide: json["ongoing_ride"],
        tripStartTimeWithDate: json["trip_start_time_with_date"],
        arrivedAtWithDate: json["arrived_at__with_date"],
        acceptedAtWithDate: json["accepted_at__with_date"],
        completedAtWithDate: json["completed_at_with_date"],
        cancelledAtWithDate: json["cancelled_at_with_date"],
        creatededAtWithDate: json["createded_at_with_date"],
        biddingLowPercentage: json["bidding_low_percentage"],
        biddingHighPercentage: json["bidding_high_percentage"],
        maximumTimeForFindDriversForRegularRide:
            json["maximum_time_for_find_drivers_for_regular_ride"],
        freeWaitingTimeInMinsBeforeTripStart:
            json["free_waiting_time_in_mins_before_trip_start"],
        freeWaitingTimeInMinsAfterTripStart:
            json["free_waiting_time_in_mins_after_trip_start"],
        waitingCharge: json["waiting_charge"],
        paymentTypeString: json["payment_type_string"],
        cvTripStartTime: json["cv_trip_start_time"],
        cvCompletedAt: json["cv_completed_at"],
        cvCreatedAt: json["cv_created_at"],
        transportType: json["transport_type"],
        requestStops: RequestStops.fromJson(json["requestStops"]),
        driverDetail: json["driverDetail"],
        userDetail: OutstationUserDetail.fromJson(json["userDetail"]),
      );
}

class RequestStops {
  List<RequestStopsDatum> data;

  RequestStops({
    required this.data,
  });

  factory RequestStops.fromJson(Map<String, dynamic> json) => RequestStops(
        data: List<RequestStopsDatum>.from(
            json["data"].map((x) => RequestStopsDatum.fromJson(x))),
      );
}

class RequestStopsDatum {
  String id;
  String name;
  String number;
  String userType;
  bool status;

  RequestStopsDatum({
    required this.id,
    required this.name,
    required this.number,
    required this.userType,
    required this.status,
  });

  factory RequestStopsDatum.fromJson(Map<String, dynamic> json) =>
      RequestStopsDatum(
        id: json["id"],
        name: json["name"],
        number: json["number"],
        userType: json["user_type"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "number": number,
        "user_type": userType,
        "status": status,
      };
}

class OutstationUserDetail {
  UserDetailData data;

  OutstationUserDetail({
    required this.data,
  });

  factory OutstationUserDetail.fromJson(Map<String, dynamic> json) =>
      OutstationUserDetail(
        data: UserDetailData.fromJson(json["data"]),
      );
}

class UserDetailData {
  int id;
  String name;
  String gender;
  dynamic lastName;
  dynamic username;
  String email;
  String mobile;
  String profilePicture;
  int active;
  int emailConfirmed;
  int mobileConfirmed;
  String lastKnownIp;
  DateTime lastLoginAt;
  int rating;
  int noOfRatings;
  String refferalCode;
  String currencyCode;
  String currencySymbol;
  String countryCode;
  bool showRentalRide;
  bool isDeliveryApp;
  bool showRideLaterFeature;
  dynamic authorizationCode;
  String enableModulesForApplications;
  String contactUsMobile1;
  String contactUsMobile2;
  String contactUsLink;
  String showWalletMoneyTransferFeatureOnMobileApp;
  String showBankInfoFeatureOnMobileApp;
  String showIncentiveFeatureForDriver;
  String showWalletFeatureOnMobileApp;
  int notificationsCount;
  String referralComissionString;
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
  RequestStops sos;
  RequestStops bannerImage;
  Wallet wallet;

  UserDetailData({
    required this.id,
    required this.name,
    required this.gender,
    required this.lastName,
    required this.username,
    required this.email,
    required this.mobile,
    required this.profilePicture,
    required this.active,
    required this.emailConfirmed,
    required this.mobileConfirmed,
    required this.lastKnownIp,
    required this.lastLoginAt,
    required this.rating,
    required this.noOfRatings,
    required this.refferalCode,
    required this.currencyCode,
    required this.currencySymbol,
    required this.countryCode,
    required this.showRentalRide,
    required this.isDeliveryApp,
    required this.showRideLaterFeature,
    required this.authorizationCode,
    required this.enableModulesForApplications,
    required this.contactUsMobile1,
    required this.contactUsMobile2,
    required this.contactUsLink,
    required this.showWalletMoneyTransferFeatureOnMobileApp,
    required this.showBankInfoFeatureOnMobileApp,
    required this.showIncentiveFeatureForDriver,
    required this.showWalletFeatureOnMobileApp,
    required this.notificationsCount,
    required this.referralComissionString,
    required this.userCanMakeARideAfterXMiniutes,
    required this.maximumTimeForFindDriversForRegularRide,
    required this.maximumTimeForFindDriversForBittingRide,
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
  });

  factory UserDetailData.fromJson(Map<String, dynamic> json) => UserDetailData(
        id: json["id"],
        name: json["name"],
        gender: json["gender"],
        lastName: json["last_name"],
        username: json["username"],
        email: json["email"],
        mobile: json["mobile"],
        profilePicture: json["profile_picture"],
        active: json["active"],
        emailConfirmed: json["email_confirmed"],
        mobileConfirmed: json["mobile_confirmed"],
        lastKnownIp: json["last_known_ip"],
        lastLoginAt: DateTime.parse(json["last_login_at"]),
        rating: json["rating"],
        noOfRatings: json["no_of_ratings"],
        refferalCode: json["refferal_code"],
        currencyCode: json["currency_code"],
        currencySymbol: json["currency_symbol"],
        countryCode: json["country_code"],
        showRentalRide: json["show_rental_ride"],
        isDeliveryApp: json["is_delivery_app"],
        showRideLaterFeature: json["show_ride_later_feature"],
        authorizationCode: json["authorization_code"],
        enableModulesForApplications: json["enable_modules_for_applications"],
        contactUsMobile1: json["contact_us_mobile1"],
        contactUsMobile2: json["contact_us_mobile2"],
        contactUsLink: json["contact_us_link"],
        showWalletMoneyTransferFeatureOnMobileApp:
            json["show_wallet_money_transfer_feature_on_mobile_app"],
        showBankInfoFeatureOnMobileApp:
            json["show_bank_info_feature_on_mobile_app"],
        showIncentiveFeatureForDriver:
            json["show_incentive_feature_for_driver"] ?? '',
        showWalletFeatureOnMobileApp: json["show_wallet_feature_on_mobile_app"],
        notificationsCount: json["notifications_count"],
        referralComissionString: json["referral_comission_string"],
        userCanMakeARideAfterXMiniutes:
            json["user_can_make_a_ride_after_x_miniutes"],
        maximumTimeForFindDriversForRegularRide:
            json["maximum_time_for_find_drivers_for_regular_ride"],
        maximumTimeForFindDriversForBittingRide:
            json["maximum_time_for_find_drivers_for_bitting_ride"],
        enableDriverPreferenceForUser:
            json["enable_driver_preference_for_user"],
        enablePetPreferenceForUser: json["enable_pet_preference_for_user"],
        enableLuggagePreferenceForUser:
            json["enable_luggage_preference_for_user"],
        biddingAmountIncreaseOrDecrease:
            json["bidding_amount_increase_or_decrease"],
        showRideWithoutDestination: json["show_ride_without_destination"],
        enableCountryRestrictOnMap: json["enable_country_restrict_on_map"],
        chatId: json["conversation_id"],
        mapType: json["map_type"],
        hasOngoingRide: json["has_ongoing_ride"],
        showOutstationRideFeature: json["show_outstation_ride_feature"],
        sos: RequestStops.fromJson(json["sos"]),
        bannerImage: RequestStops.fromJson(json["bannerImage"]),
        wallet: Wallet.fromJson(json["wallet"]),
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
  double? amountAdded;
  double? amountBalance;
  double? amountSpent;
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
        id: json["id"],
        userId: json["user_id"],
        amountAdded: json["amount_added"].toDouble() ?? 0.0,
        amountBalance: json["amount_balance"].toDouble() ?? 0.0,
        amountSpent: json["amount_spent"].toDouble() ?? 0.0,
        currencySymbol: json["currency_symbol"],
        currencyCode: json["currency_code"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );
}
