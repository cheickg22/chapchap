class ApiEndpoints {
  static String languageList = 'api/v1/translation/list';
  //  static String exceptionCheck = 'api/v1/test-exception?';
  static String updateLanguage = 'api/v1/user/update-my-lang';
  static String countryList = 'api/v1/countries';
  // Onboarding
  static String onBoarding = 'api/v1/on-boarding-driver';
  static String onBoardingOwner = 'api/v1/on-boarding-owner';
  static String reportApi = 'api/v1/driver/earnings-report/fromDate/toDate';

  // Authentication
  static String verifyUser = 'api/v1/driver/validate-mobile-for-login';
  static String userLogin = 'api/v1/driver/login';
  static String commonModule = 'api/v1/common/modules';
  static String sendMobileOtp = 'api/v1/mobile-otp';
  static String verifyMobileOtp = 'api/v1/validate-otp';
  static String sendEmailOtp = 'api/v1/send-mail-otp';
  static String verifyEmailOtp = 'api/v1/validate-email-otp';
  static String registerUser = 'api/v1/driver/register';
  static String referral = 'api/v1/update/driver/referral';
  static String referralResponse =
      'api/v1/common/referral/driver-referral-condition';
  static String ownerRegister = 'api/v1/owner/register';

  //driver register
  static String getServiceLocation = 'api/v1/servicelocation';
  static String getVehicleTypes =
      'api/v1/types/service?transport_type=vehilceType';
  static String getVehicleMake =
      'api/v1/common/car/makes?transport_type=vehicleType&vehicle_type=iconFor';
  static String getVehicleModel = 'api/v1/common/car/models/make';
  static String updateVehicle = 'api/v1/user/driver-profile';
  static String neededDocuments = 'api/v1/driver/documents/needed';
  static String uploadDocument = 'api/v1/driver/upload/documents';

  // Home
  static String userDetails = 'api/v1/user';
  static String onlineOffline = 'api/v1/driver/online-offline';
  static String updatePricePerDistance = 'api/v1/driver/update-price';
  static String subVehiclesTypes = 'api/v1/types/sub-vehicle';
  static String diagnosticNotification = 'api/v1/driver/diagnostic';

  //Ride
  static String respondRequest = 'api/v1/request/respond';
  static String rideArrived = 'api/v1/request/arrived';
  static String rideStart = 'api/v1/request/started';
  static String rideEnd = 'api/v1/request/end';
  static String paymentRecieved = 'api/v1/request/payment-confirm';
  static String addReview = 'api/v1/request/rating';
  static String getRideChats = 'api/v1/request/chat-history';
  static String chatsSeen = 'api/v1/request/seen';
  static String sendChat = 'api/v1/request/send';
  static String cancelReason = 'api/v1/common/cancallation/reasons';
  static String cancelRequest = 'api/v1/request/cancel/by-driver';
  static String openMap = 'https://www.google.com/maps/search/?api=1&query=';
  static String uploadProof = 'api/v1/request/upload-proof';
  static String stopComplete = 'api/v1/request/stop-complete';
  static String additionalCharge = 'api/v1/request/additional-charge';
  static String stopOtpVerify = 'api/v1/request/stop-otp-verify';

  //withdraw
  static String getWithdrawData = 'api/v1/payment/wallet/withdrawal-requests';
  static String requestWithdraw =
      'api/v1/payment/wallet/request-for-withdrawal';

  //Map Apis
  static String getPolyline =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  static String getAddressFromLatLng =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=addlat,addlng&key=mapkey';
  static String updateLocation = 'api/v1/user/update-location';

  static String getOpenstreetPolyline =
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/pick;drop?overview=false&geometries=polyline&steps=true';
  static String getAddressFromLatLngOpenstreet =
      'https://nominatim.openstreetmap.org/reverse?lat=addlat&lon=addlng&format=json';

  // Booking eta
  static String etaDetails = 'api/v1/request/eta';
  static String rentalEtaDetails = 'api/v1/request/list-packages';
  static String updatePassword = 'api/v1/driver/update-password';
  static String createInstantRide = 'api/v1/request/create-instant-ride';
  static String getGoods = 'api/v1/common/goods-types';
  static String createDeliverInstantRide =
      'api/v1/request/create-delivery-instant-ride';

  //history
  static String history = 'api/v1/request/history';
  static String downloadInvoice = 'api/v1/request/invoice/';

  //Outstation
  static String readyToPickup = 'api/v1/request/ready-to-pickup';

  //logout
  static String logout = 'api/v1/logout';

  //delete account
  static String deleteAccount = 'api/v1/user/delete-user-account';

  //earnings
  static String getEarnings = 'api/v1/driver/new-earnings';
  static String getDailyEarnings = 'api/v1/driver/earnings-by-date';

  // make complaint
  static String makeComplaint = 'api/v1/common/complaint-titles';
  static String makeComplaintButton = 'api/v1/common/make-complaint';

  //update Details button
  static String updateUserDetailsButton = 'api/v1/user/driver-profile';

  //Faq
  static String faqData = 'api/v1/common/faq/list';

  //Subscription
  static String subscriptionList = 'api/v1/driver/list_of_plans';
  static String makeSubscription = 'api/v1/driver/subscribe';

  //Incentives
  static String weeklyIncentive = '/api/v1/driver/week-incentives';
  static String todayIncentive = '/api/v1/driver/new-incentives';

  //reward and levels
  static String driverLevel = "/api/v1/driver/loyalty/history";
  static String driverRewards = "/api/v1/driver/rewards/history";
  static String rewardsPointsPost =
      "/api/v1/payment/wallet/convert-point-to-wallet";

  //wallet
  static String walletHistory = 'api/v1/payment/wallet/history';
  static String transferMoney =
      'api/v1/payment/wallet/transfer-money-from-wallet';
  static String stripCreate = 'api/v1/payment/stripe/create-setup-intent';
  static String stripSavedCardsDetail = 'api/v1/payment/stripe/save-card';
  static String savedCardList = 'api/v1/payment/cards/list';
  static String deleteCardsDetail = 'api/v1/payment/cards/delete/';
  static String stripAddMoneyToWallet =
      'api/v1/payment/stripe/add-money-to-wallet';

  //sos
  static String addSosContact = 'api/v1/common/sos/store';
  static String deleteSosContact = 'api/v1/common/sos/delete';

  //admin chat
  static String sendAdminMessage = 'api/v1/request/user-send-message';
  static String adminChatHistory = 'api/v1/request/user-chat-history';
  static String adminMessageSeen = 'api/v1/request/update-notification-count';

  //notifications
  static String notification = 'api/v1/notifications/get-notification';
  static String deleteNotification = 'api/v1/notifications/delete-notification';
  static String clearAllNotification =
      'api/v1/notifications/delete-all-notification';

  static String getBankInfo = 'api/v1/driver/list/bankinfo';
  static String updateBankInfo = 'api/v1/driver/update/bankinfo';

  //owner
  static String getDrivers = 'api/v1/owner/list-drivers';
  static String addDrivers = 'api/v1/owner/add-drivers';
  static String deleteDriver = 'api/v1/owner/delete-driver/driverId';
  static String addVehicle = 'api/v1/owner/add-fleet';
  static String getVehicles = 'api/v1/owner/list-fleets';
  static String assignDriver = 'api/v1/owner/assign-driver/fleetId';
  static String fleetDocumentNeeded =
      'api/v1/owner/fleet/documents/needed?fleet_id=fleetId';
  static String ownerDashboard = 'api/v1/owner/dashboard';
  static String leaderBoardEarnings = 'api/v1/driver/leader-board/earnings';
  static String leaderBoardTrips = 'api/v1/driver/leader-board/trips';
  static String fleetDashboard = 'api/v1/owner/fleet-dashboard';
  static String driverPerformance = 'api/v1/owner/fleet-driver-dashboard';

//support ticket
  static String ticketTitles = 'api/v1/common/ticket-titles';
  static String makeTicket = 'api/v1/common/make-ticket';
  static String replyTicket = 'api/v1/common/reply-message';
  static String viewTicket = 'api/v1/common/view-ticket';
  static String ticketList = 'api/v1/common/list';

  // privacy && terms
  static String termsAndPrivacyHtml = 'api/v1/common/mobile/';
  //my route booking
  static String addressUpdated = 'api/v1/driver/add-my-route-address';

  static String enableMyRouteBooking = 'api/v1/driver/enable-my-route-booking';

  //preferences
  static String getPreferences = 'api/v1/common/preferences';
  static String updatePreferences = 'api/v1/common/preferences/store';
  static String referalHistory = 'api/v1/common/referral/history';
}
