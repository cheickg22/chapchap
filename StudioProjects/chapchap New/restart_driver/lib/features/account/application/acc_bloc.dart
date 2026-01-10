// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use, library_prefixes

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/tobitmap.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_performance_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_rewards_model.dart';
import 'package:restart_tagxi/features/account/domain/models/fleet_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/leader_board_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_dashboard_model.dart';
import 'package:restart_tagxi/features/account/domain/models/report_section_model.dart';
import 'package:restart_tagxi/features/account/domain/models/route_address_update_model.dart';
import 'package:restart_tagxi/features/account/domain/models/subcription_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/features/account/domain/models/view_ticket_model.dart';
import 'package:restart_tagxi/features/account/domain/models/withdraw_model.dart';
import 'package:restart_tagxi/features/account/domain/models/referalhistory_model.dart'
    as historyModel;
import 'package:restart_tagxi/features/account/domain/models/referal_response_model.dart'
    as referralModel;
import 'package:restart_tagxi/features/driverprofile/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/application/usecase/ride_usecases.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/account/application/usecase/acc_usecases.dart';
import 'package:restart_tagxi/features/account/domain/models/contact_model.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_data_model.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/features/account/domain/models/faq_model.dart';
import 'package:restart_tagxi/features/account/domain/models/owner_vehicle_model.dart';
import '../../../common/common.dart';
import '../../../common/debouncer.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_text.dart';
import '../../../di/locator.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/usecase/home_usecases.dart';
import '../../home/domain/models/address_auto_complete_model.dart';
import '../domain/models/admin_chat_history_model.dart';
import '../domain/models/admin_chat_model.dart';
import '../domain/models/card_list_model.dart';
import '../domain/models/history_model.dart';
import '../domain/models/incentive_model.dart';
import '../domain/models/makecomplaint_model.dart';
import '../domain/models/notifications_model.dart';
import '../domain/models/outstation_model.dart';
import '../domain/models/payment_method_model.dart';
import '../domain/models/walletpage_model.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:url_launcher/url_launcher.dart';

part 'acc_event.dart';

part 'acc_state.dart';

class AccBloc extends Bloc<AccEvent, AccState> {
  final formKey = GlobalKey<FormState>();
  final paymentKey = GlobalKey();
  bool _isEdit = false;
  ImagePicker picker = ImagePicker();

  List<NotificationData> notificationDatas = [];
  List<HistoryData> history = [];
  List<OutstationResponse> outstation = [];
  List<ComplaintList> complaintList = [];
  List<historyModel.Referral> referralHistory = [];
  referralModel.ReferralResponseData? referralResponse;

  // UserDetails
  TextEditingController updateController = TextEditingController();
  TextEditingController complaintController = TextEditingController();
  String profilePicture = '';
  String name = '';
  String mobile = '';
  String email = '';
  String gender = '';
  String profileImage = '';

  List<String> genderOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];
  String selectedGender = '';
  bool isLoading = false;
  bool isWithdrawLoading = false;
  bool isSosLoading = false;
  bool showReferralHistory = false;
  HistoryData? historyData;
  List<DriverData> driverData = [];

  //fav address
  TextEditingController newAddressController = TextEditingController();

  List<FaqData> faqDataList = [];
  int choosenFaqIndex = 0;

  int choosenMapIndex = 0;
  final fm.MapController fmController = fm.MapController();
  int selectedHistoryType = 0;
  List withdrawData = [];
  List bankDetails = [];
  List choosenBankList = [];
  List<WalletHistoryData> walletHistoryList = [];
  List<SubscriptionData> subscriptionList = [];
  List<DriverLevelsData> driverLevelsList = [];
  List<DriverRewardsData> driverRewardsList = [];
  WalletResponseModel? walletResponse;
  WithdrawModel? withdrawResponse;
  SubscriptionListModel? subscriptionResponse;
  SubscriptionSuccessData? subscriptionSuccessData;
  IncentiveModel? incentiveData;
  List<UpcomingIncentive> incentiveRideCount = [];
  List<IncentiveHistory> incentiveHistory = [];
  List<IncentiveDates> incentiveDates = [];
  IncentiveDates? selectedIncentiveHistory;
  TextEditingController walletAmountController = TextEditingController();
  TextEditingController rewardAmountController = TextEditingController();
  TextEditingController withdrawAmountController = TextEditingController();
  ScrollController scrollController = ScrollController();
  ScrollController earningScrollController = ScrollController();
  ScrollController incentiveScrollController = ScrollController();
  ScrollController rewardsScrollController = ScrollController();
  ScrollController levelsScrollController = ScrollController();

  List<PaymentGateway> walletPaymentGatways = [];
  TextEditingController transferPhonenumber = TextEditingController();
  TextEditingController transferAmount = TextEditingController();
  dynamic addMoney;
  dynamic addRewardMoney;
  dynamic addMoneySubscription;
  WalletPagination? walletPaginations;
  RewardsPagination? rewardsPagination;
  LevelsPagination? levelsPagination;
  ReportData? reportsData;
  int? choosenPaymentIndex = 0;
  int choosenPlanindex = 0;
  double redeemedAmount = 0.0;
  int? choosenSubscriptionPayIndex = 0;
  List<SOSDatum> sosdata = [];
  List<ContactsModel> contactsList = [];
  ContactsModel selectedContact = ContactsModel(name: '', number: '');
  TextEditingController addSosNameController = TextEditingController();
  TextEditingController addSosMobileController = TextEditingController();

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
          value: "user",
          child: MyText(
              text: AppLocalizations.of(navigatorKey.currentContext!)!.user)),
      DropdownMenuItem(
          value: "driver",
          child: MyText(
              text: AppLocalizations.of(navigatorKey.currentContext!)!.driver)),
    ];
    return menuItems;
  }

  void _onReferralTabChange(
      ReferralTabChangeEvent event, Emitter<AccState> emit) {
    showReferralHistory = event.showReferralHistory;
    emit(UpdateState());
  }

  String dropdownValue = 'user';

  StreamSubscription<DatabaseEvent>? chatStream;
  String unSeenChatCount = '0';
  String? paymentUrl;
  String? requestId;

  TextEditingController adminchatText = TextEditingController();
  List<ChatData> adminChatList = [];
  dynamic isNewChat = 1;
  String chatId = '';
  List<Conversation> adminChatHistory = [];
  ScrollController scroolController = ScrollController();
  NotificationPagination? notificationPaginations;
  GoogleMapController? googleMapController;
  LatLng? currentLatLng;

  bool showSearch = false;
  String currentLocation = '';
  bool isCameraMoved = false;
  List<AddressData> autoCompleteAddress = [];

  HistoryPagination? historyPaginations;
  TextEditingController searchController = TextEditingController();
  TextEditingController bankAccountName = TextEditingController();
  TextEditingController bankIfsc = TextEditingController();
  TextEditingController upiText = TextEditingController();
  TextEditingController paymentMethodId = TextEditingController();
  TextEditingController paymentFieldId = TextEditingController();
  TextEditingController paymentValue = TextEditingController();
  TextEditingController fromDateText = TextEditingController();
  TextEditingController toDateText = TextEditingController();

  bool editBank = false;
  String webViewUrl = '';
  int currentPageDates = 0;
  int dateitemsPerPage = 7;

  int startIndex = 0;
  int endIndex = 0;
  int totalPages = 0;
  bool addBankInfo = false;
  bool isSelected = false;
  int? choosenBankMethod;
  PageController earningsController = PageController();
  List<Marker> markers = [];
  Set<Polyline> polyline = {};

  DashboardData? fleetData;
  FleetData? fleetDashboardData;
  DriverPerformanceDatas? driverPerformanceData;
  List<FleetEarningsData>? fleetEarnings;
  List<FleetDriverData>? fleetDriverData;

  bool isArrow = true;
  bool paymentProcessComplete = false;
  bool paymentSuccess = false;
  bool firstLoad = true;
  bool firstLoadReward = true;
  bool firstWithdrawLoad = true;
  bool firstLoadLevel = true;
  bool loadMore = false;
  bool loadWithdrawMore = false;
  bool loadMoreReward = false;
  bool loadMoreLevel = false;
  bool isDarkTheme = false;
  WebViewController? webController;
  InAppWebViewController? inAppWebViewController;
  bool isPlansChooseds = false;
  String? selectedDate;
  String? selectedDateInit;
  String darkMapString = '';
  String lightMapString = '';
  String textDirection = 'ltr';
  String? htmlString;

  int? choosenEarningsWeeks;
  List<NotificationData> dataum = [];

  List<UserDetailData> userDetailData = [];

  List<EarningsData> earningsList = [];
  DailyEarningsModel? dailyEarningsList;
  List<LeaderBoardData>? leaderBoardData;

  int choosenLeaderboardData = 0;
  int choosenIncentiveData = 0;

  TextEditingController driverNameController = TextEditingController();
  TextEditingController driverMobileController = TextEditingController();
  TextEditingController driverEmailController = TextEditingController();
  TextEditingController driverAddressController = TextEditingController();
  TextEditingController supportMessageReplyController = TextEditingController();
  TextEditingController supportDescriptionController = TextEditingController();
  String choosenEarningsDate = '';
  String? choosenDriverForDelete;
  int? choosenDriverToVehicle;
  String? choosenFleetToAssign;
  List<VehicleData> vehicleData = [];
  String? earningCurrency;
  PaymentAuthData? paymentAuthData;
  CardFormEditController? cardFormEditController;
  CardFieldInputDetails? cardDetails;
  List<SavedCardDetails> savedCardsList = [];
  List<TicketData> ticketList = [];
  SupportTicket? supportTicketData;
  List<ReplyMessage> replyMessages = [];
  String? selectedTicketTitle;
  String? selectedTicketTitleId;
  bool isTicketSheetOpened = false;
  List<TicketNamesList> ticketNamesList = [];
  List<ServiceLocationData> serviceLocations = [];
  List<File> ticketAttachments = [];
  List<Attachment> viewAttachments = [];
  bool showRefresh = false;

  String? sessionToken;
  String selectedMyRouteAddress = '';
  LatLng? selectedMyRouteLatLng;
  bool showGetDropAddress = false;
  bool confirmPinAddress = false;
  LatLng? mapPoint;
  CameraPosition? initialCameraPosition;
  bool autoSuggestionSearching = false;
  final debouncer = Debouncer(milliseconds: 1000);

  AccBloc() : super(AccInitialState()) {
    on<UpdateEvent>((event, emit) => emit(UpdateState()));
    on<AccGetDirectionEvent>(getDirection);
    on<OnTapChangeEvent>(_onTapChange);
    on<AccDataLoaderShowEvent>(showLoader);

    //isEditPage
    on<IsEditPage>(_isEditPage);
    on<UpdateControllerWithDetailsEvent>(_updateControllerWithDetails);
    on<UserDetailsPageInitEvent>(_updateUserDetails);

    //Notification
    on<NotificationGetEvent>(_getNotificationList);
    on<ClearAllNotificationsEvent>(_clearAllNotifications);
    on<DeleteNotificationEvent>(_deleteNotification);
    on<NotificationLoadingEvent>(notificationUpdateLoading);

    on<GetFaqListEvent>(_getFaqList);
    on<FaqOnTapEvent>(_selectedFaqIndex);
    on<ChooseMapOnTapEvent>(_selectedMapIndex);

    // History
    on<HistoryGetEvent>(_getHistoryList);
    on<HistoryTypeChangeEvent>(_historyTypeChange);

    //Outstation
    on<OutstationReadyToPickupEvent>(readyToPickup);

    //Logout event
    on<LogoutEvent>(_logout);

    //Delete Account
    on<DeleteAccountEvent>(_deleteAccount);
    on<ReferalHistoryEvent>(_referalHistory);
    on<ReferralResponseEvent>(_referralResponse);
    on<ReferralTabChangeEvent>(_onReferralTabChange);

    //Complaint page
    on<ComplaintEvent>(_getComplaints);
    on<ComplaintButtonEvent>(_complaintButton);
    //wallet
    on<GetWalletHistoryListEvent>(_getWalletHistoryList);
    on<TransferMoneySelectedEvent>(_onTransferMoneySelected);
    on<MoneyTransferedEvent>(moneyTransfered);
    on<WalletPageReUpdateEvent>(walletPageReUpdate);
    on<GetWalletInitEvent>(walletInitEvent);
    on<PaymentAuthenticationEvent>(paymentAuth);
    on<CardListEvent>(getCardList);
    on<DeleteCardEvent>(deleteCard);
    on<ShowPaymentGatewayEvent>(showPaymentGateways);
    on<AddCardDetailsEvent>(addCardDetails);
    on<AddMoneyFromCardEvent>(addMoneyFromCard);

    //Subscription page
    on<GetSubscriptionListEvent>(_getSubscriptionDataList);
    on<SubscribeToPlanEvent>(subscriptionToPlan);
    on<SubscriptionOnTapEvent>(selectedPlanIndex);
    on<SubscriptionPaymentOnTapEvent>(selectedPayIndex);
    on<ChoosePlanEvent>(choosePlansFunction);
    on<WalletEmptyEvent>(walletEmptyFunction);

    //gender list
    on<GenderSelectedEvent>(_onGenderSelected);
    on<DeleteContactEvent>(_deletesos);
    on<AccGetUserDetailsEvent>(getUserDetails);
    on<SelectContactDetailsEvent>(selectContactDetails);
    on<AddContactEvent>(addContactDetails);
    on<SosLoadingEvent>(changeBoolSos);
    on<SosInitEvent>(sosPageInit);

    // update details
    on<UpdateUserDetailsEvent>(_updateTextField);
    on<UserDetailEditEvent>(userDetailEdit);
    on<UserDetailEvent>(userDetails);
    on<SendAdminMessageEvent>(sendAdminChat);
    on<GetAdminChatHistoryListEvent>(_getAdminChatHistoryList);
    on<AdminMessageSeenEvent>(_adminMessageSeenDetail);

    //update profile
    on<UpdateImageEvent>(_getProfileImage);
    //payment
    on<PaymentOnTapEvent>(_selectedPaymentIndex);
    on<RideLaterCancelRequestEvent>(cancelRequest);
    on<UserDataInitEvent>(userDataInit);
    on<AddMoneyWebViewUrlEvent>(addMoneyWebViewUrl);

    //Driver Details
    on<AddDriverEvent>(_addDrivers);
    on<GetDriverEvent>(_getDrivers);
    on<GetVehiclesEvent>(_getVehicles);
    on<AssignDriverEvent>(_assignDriver);
    on<DeleteDriverEvent>(_deleteDrivers);
    //earnings
    on<GetEarningsEvent>(getEarnings);
    on<GetDailyEarningsEvent>(getDailyEarnings);
    on<ChangeEarningsWeekEvent>(changeEarningsWeek);
    //Dashboard
    on<GetOwnerDashboardEvent>(getOwnerDashboard);
    on<GetFleetDashboardEvent>(getFleetDashboard);
    on<GetLeaderBoardEvent>(getLeaderboard);
    on<GetDriverPerformanceEvent>(getDriverPerformance);
    //incentive
    on<GetIncentiveEvent>(getIncentives);
    on<SelectIncentiveDateEvent>(getUpcomingIncentiveData);

    //bankDatas
    on<GetBankDetails>(getBankDetails);
    on<GetWithdrawDataEvent>(getWithdrawData);
    on<GetWithdrawInitEvent>(withdrawInitEvent);
    on<RequestWithdrawEvent>(requestWithdraw);
    on<AddBankEvent>(addBankFunc);
    on<EditBankEvent>(editBankFunc);
    on<UpdateBankDetailsEvent>(updateBankDetails);
    on<AddHistoryMarkerEvent>(addHistoryMarker);
    //Rewards and Levels
    on<DriverLevelGetEvent>(getDriverLevelData);
    on<DriverRewardGetEvent>(getDriverRewardData);
    on<RedeemPointsEvent>(postRedeemPoints);
    on<DriverLevelPopupEvent>(getDriverLevelPopup);
    on<DriverRewardPointsEvent>(showRewardsPointsPopup);
    on<HowItWorksEvent>(showHowitWorksPopup);
    on<DriverRewardInitEvent>(rewardInitEvent);
    on<DriverLevelnitEvent>(levelInitEvent);
    on<UpdateRedeemedAmountEvent>(updateRedeemValues);
    on<ReportSubmitEvent>(_getReportNotification);
    on<ReportClearEvent>(reportClearEvent);
    on<ChooseDateEvent>(pickDate);
    //Support Ticket
    on<CreateSupportTicketEvent>(createSupportTicket);
    on<MakeTicketSubmitEvent>(makeTicketSubmit);
    on<GetTicketListEvent>(getTicketList);
    on<ViewTicketEvent>(viewTicketData);
    on<AddAttachmentTicketEvent>(addAttachment);
    on<ClearAttachmentEvent>(clearAttachment);
    on<TicketReplyMessageEvent>(ticketMessageReply);
    on<TicketTitleChangeEvent>(assignSelectedTicketValue);
    on<TripSummaryHistoryDataEvent>(tripSummaryHistoryDataGet);
    on<DownloadInvoiceEvent>(downloadInvoice);
    on<GetHtmlStringEvent>(getHtmlString);

    ///routebooking
    on<RouteBookingInitEvent>(routeBookingInit);
    on<ToggleSearchVisibilityEvent>(_onToggleSearch);

    on<MyRouteAddressUpdateEvent>(_onMyRouteAddressUpdate);
    on<EnableMyRouteBookingEvent>(_onEnableMyRouteBooking);
    on<AccGeocodingLatLngEvent>(getAddressFromLatLng);
    on<AccGeocodingAddressEvent>(getLatLngFromAddress);
    on<AccGetCurrentLocationEvent>(getCurrentLocation);
    on<AccGetAutoCompleteAddressEvent>(getAutoCompleteAddress);
    on<AccClearAutoCompleteEvent>(clearAutoComplete);
  }

  Future<void> getDirection(AccEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    textDirection = await AppSharedPreference.getLanguageDirection();
    mapType = await AppSharedPreference.getMapType();
    isDarkTheme = await AppSharedPreference.getDarkThemeStatus();
    lightMapString = await rootBundle.loadString('assets/light-theme.json');
    darkMapString = await rootBundle.loadString('assets/dark-theme.json');
    if (mapType == 'google_map') {
      choosenMapIndex = 0;
    } else {
      choosenMapIndex = 1;
    }
    emit(AccDataLoadingStopState());
  }

  Future<void> showLoader(
      AccDataLoaderShowEvent event, Emitter<AccState> emit) async {
    if (event.showLoader) {
      isLoading = event.showLoader;
      emit(AccDataLoadingStartState());
    } else {
      if (isLoading) {
        emit(AccDataLoadingStopState());
      }
      isLoading = event.showLoader;
    }
  }

  FutureOr<void> pickDate(ChooseDateEvent event, Emitter<AccState> emit) async {
    DateTime? picker;

    if (event.isFromDate) {
      picker = await showDatePicker(
        context: event.context,
        initialDate: fromDateText.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(fromDateText.text.split('-').reversed.join('-')),
        firstDate: DateTime(2023),
        lastDate: toDateText.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(toDateText.text.split('-').reversed.join('-')),
      );

      if (picker != null) {
        fromDateText.text = formatDate(picker); // <-- FIXED
      }
    } else {
      picker = await showDatePicker(
        context: event.context,
        initialDate: toDateText.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(toDateText.text.split('-').reversed.join('-')),
        firstDate: fromDateText.text.isEmpty
            ? DateTime(2023)
            : DateTime.parse(fromDateText.text.split('-').reversed.join('-')),
        lastDate: DateTime.now(),
      );

      if (picker != null) {
        toDateText.text = formatDate(picker); // <-- FIXED
      }
    }

    emit(UpdateState());
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  FutureOr<void> walletPageReUpdate(
      WalletPageReUpdateEvent event, Emitter<AccState> emit) async {
    emit(WalletPageReUpdateState(
      currencySymbol: event.currencySymbol,
      money: event.money,
      requestId: event.requestId,
      url: event.url,
      planId: event.planId,
      userId: event.userId,
    ));
  }

  FutureOr<void> addHistoryMarker(
      AddHistoryMarkerEvent event, Emitter<AccState> emit) async {
    if (mapType == 'google_map') {
      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId("pick"),
        position:
            LatLng(double.parse(event.pickLat), double.parse(event.pickLng)),
        icon: await Image.asset(
          AppImages.pickupIcon,
          height: 30,
          fit: BoxFit.contain,
        ).toBitmapDescriptor(
            logicalSize: const Size(20, 20), imageSize: const Size(200, 200)),
      ));
      if ((event.stops == null || event.stops!.isEmpty) &&
          event.dropLat != '') {
        markers.add(Marker(
          markerId: const MarkerId("drop"),
          position: LatLng(
              double.parse(event.dropLat!), double.parse(event.dropLng!)),
          icon: await Image.asset(
            AppImages.dropIcon,
            height: 30,
            fit: BoxFit.contain,
          ).toBitmapDescriptor(
              logicalSize: const Size(20, 20), imageSize: const Size(200, 200)),
        ));
      } else if (event.stops != null) {
        for (var i = 0; i < event.stops!.length; i++) {
          markers.add(Marker(
            markerId: MarkerId("drop$i"),
            position: LatLng(
                event.stops![i]['latitude'], event.stops![i]['longitude']),
            icon: await Image.asset(
              AppImages.dropIcon,
              height: 30,
              fit: BoxFit.contain,
            ).toBitmapDescriptor(
                logicalSize: const Size(20, 20),
                imageSize: const Size(200, 200)),
          ));
        }
      }
    }
    if (mapType == 'google_map') {
      if (event.dropLat != null) {
        mapBound(double.parse(event.pickLat), double.parse(event.pickLng),
            double.parse(event.dropLat!), double.parse(event.dropLng!));
      } else {
        googleMapController
            ?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(
                  double.parse(event.pickLat),
                  double.parse(event.pickLng),
                ),
                zoom: 15)));
      }

      if (event.polyline != '') {
        await decodeEncodedPolyline(event.polyline!);
      }
    } else {
      if (event.polyline != '') {
        await decodeEncodedPolyline(event.polyline!);
      }
      if (event.dropLat != null) {
        fmController.fitCamera(fm.CameraFit.coordinates(coordinates: [
          fmlt.LatLng(double.parse(event.pickLat), double.parse(event.pickLng)),
          fmlt.LatLng(
              double.parse(event.dropLat!), double.parse(event.dropLng!))
        ]));
        fmController.move(
            fmlt.LatLng(
                double.parse(event.pickLat), double.parse(event.pickLng)),
            10);
      } else {
        fmController.move(
            fmlt.LatLng(
                double.parse(event.pickLat), double.parse(event.pickLng)),
            10);
      }
    }

    emit(DataChangedState());
  }

  List<LatLng> polylist = [];

  List<fmlt.LatLng> fmpoly = [];

  Future<List<PointLatLng>> decodeEncodedPolyline(String encoded) async {
    polylist.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    polyline.clear();
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
            color: AppColors.primary,
            visible: true,
            width: 4,
            points: polylist),
      );
    }
    return poly;
  }

  LatLngBounds? bound;

  mapBound(pickLat, pickLng, dropLat, dropLng) {
    dynamic pick = LatLng(pickLat, pickLng);
    dynamic drop = LatLng(dropLat, dropLng);
    if (pick.latitude > drop.latitude && pick.longitude > drop.longitude) {
      bound = LatLngBounds(southwest: drop, northeast: pick);
    } else if (pick.longitude > drop.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(pick.latitude, drop.longitude),
          northeast: LatLng(drop.latitude, pick.longitude));
    } else if (pick.latitude > drop.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(drop.latitude, pick.longitude),
          northeast: LatLng(pick.latitude, drop.longitude));
    } else {
      bound = LatLngBounds(southwest: pick, northeast: drop);
    }
    if (mapType == 'google_map') {
      googleMapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bound!, 50));
    }
  }

  void getListGetIndex() {
    final totalItems = incentiveHistory.length;
    totalPages = (totalItems / dateitemsPerPage).ceil();

    startIndex = currentPageDates * dateitemsPerPage;
    endIndex = (startIndex + dateitemsPerPage > totalItems)
        ? totalItems
        : startIndex + dateitemsPerPage;
  }

  //ontap event
  Future<void> _onTapChange(
      OnTapChangeEvent event, Emitter<AccState> emit) async {}

  //ontap event
  Future<void> addBankFunc(AddBankEvent event, Emitter<AccState> emit) async {
    if (addBankInfo) {
      addBankInfo = false;
    } else {
      if (event.choosen != null) {
        choosenBankMethod = event.choosen;
      }
      choosenBankList = bankDetails[choosenBankMethod!]['fields']['data'];
      bankDetailsText.clear();
      // ignore: unused_local_variable
      for (var e in choosenBankList) {
        bankDetailsText.add(TextEditingController());
      }
      if (bankDetails[choosenBankMethod!]['driver_bank_info']['data'] != null &&
          bankDetails[choosenBankMethod!]["driver_bank_info"]['data']
                  .toString() !=
              '[]') {
        if (bankDetails[choosenBankMethod!]['method_name'] == 'bank account') {
          bankAccountName.text = bankDetails[choosenBankMethod!]
              ['driver_bank_info']['data']['account_number'];
          bankIfsc.text = bankDetails[choosenBankMethod!]['driver_bank_info']
              ['data']['branch_identification_code'];
        } else {
          upiText.text = bankDetails[choosenBankMethod!]['driver_bank_info']
                  ['data']['upi']
              .toString();
        }
      } else {
        // editBank = true;
        editBank = false;
      }
      addBankInfo = true;
    }
    emit(UpdateState());
  }

  List bankDetailsText = [];

  //ontap event
  Future<void> editBankFunc(EditBankEvent event, Emitter<AccState> emit) async {
    if (editBank) {
      editBank = false;
    } else {
      if (event.choosen != null) {
        choosenBankMethod = event.choosen;
      }
      choosenBankList = bankDetails[choosenBankMethod!]['fields']['data'];
      bankDetailsText.clear();
      // ignore: unused_local_variable
      for (var e in choosenBankList) {
        bankDetailsText.add(TextEditingController(
            text: bankDetails[choosenBankMethod!]['driver_bank_info']['data'][0]
                ['value']));
      }
      editBank = true;
    }
    emit(UpdateState());
  }

  void _isEditPage(IsEditPage event, Emitter<AccState> emit) {
    _isEdit = !_isEdit;
  }

  //Update userDetails controller
  Future<void> _updateControllerWithDetails(
      UpdateControllerWithDetailsEvent event, Emitter<AccState> emit) async {
    userData = event.args.userData;
    updateController.text = event.args.text;
    emit(AccDataSuccessState());
  }

  //Update User Details
  Future<void> _updateUserDetails(
      UserDetailsPageInitEvent event, Emitter<AccState> emit) async {
    userData = event.arg.userData;
    sosdata = event.arg.userData.sos!.data;
    if (userData != null) {
      name = userData!.name;
      mobile = userData!.mobile;
      email = userData!.email;
      gender = userData!.gender;
      profilePicture = userData!.profilePicture;
    }
    emit(UserDetailsSuccessState(userData: userData));
  }

  Future<void> reportClearEvent(
      ReportClearEvent event, Emitter<AccState> emit) async {
    reportsData = null;
    fromDateText.clear();
    toDateText.clear();
    emit(UpdateState());
  }

  Future<void> _getReportNotification(
      ReportSubmitEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(ReportLoadingState());
    try {
      final data = await serviceLocator<AccUsecase>()
          .getReportSection(fromDate: event.fromDate, toDate: event.toDate);
      data.fold((error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          emit(NotificationFailure(errorMessage: error.message ?? ""));
          emit(ShowErrorState(message: error.message.toString()));
        }
        emit(ReportSubmitState());
      }, (success) {
        isLoading = false;
        reportsData = success.data;
        emit(ReportSubmitState());
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Get Notifications
  Future<void> _getNotificationList(
      NotificationGetEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    try {
      final data = await serviceLocator<AccUsecase>()
          .notificationDetails(pageNo: event.pageNumber.toString());
      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            isLoading = false;
            emit(NotificationFailure(errorMessage: error.message ?? ""));
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) {
          isLoading = false;
          for (var i = 0; i < success.data.length; i++) {
            notificationDatas.add(success.data[i]);
          }
          notificationPaginations = success.meta;
          emit(NotificationSuccess(notificationDatas: notificationDatas));
        },
      );
    } catch (e) {
      emit(
        NotificationFailure(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // History
  Future<void> _getHistoryList(
      HistoryGetEvent event, Emitter<AccState> emit) async {
    if (event.typeIndex != null) {
      selectedHistoryType = event.typeIndex!;
      emit(UpdateState());
    }
    isLoading = true;
    final data = await serviceLocator<AccUsecase>().historyDetails(
        event.historyFilter,
        pageNo: event.pageNumber.toString());
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          emit(HistoryFailure(errorMessage: error.message ?? ""));
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        isLoading = false;
        if (event.pageNumber != null && event.pageNumber == 1) {
          history = success.data;
        } else {
          history.addAll(success.data);
          List<HistoryData> historySetData = history.toSet().toList();
          history = historySetData;
        }
        historyPaginations = success.meta;
        if (event.historyIndex != null) {
          historyData = history[event.historyIndex!];
        }
        emit(HistorySuccess(
          history: history,
        ));
      },
    );
  }

  // Outstation

  Future<void> readyToPickup(
      OutstationReadyToPickupEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<AccUsecase>()
        .readyToPickup(requestId: event.requestId);
    data.fold(
      (error) {
        emit(AccDataLoadingStopState());
        showToast(message: error.message ?? '');
        emit(OutstationFailure(errorMessage: error.message ?? ""));
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        emit(AccDataLoadingStopState());
        emit(OutstationReadyToPickupState());
      },
    );
  }

//driver levelpopup
  FutureOr getDriverLevelPopup(
      DriverLevelPopupEvent event, Emitter<AccState> emit) async {
    emit(DriverLevelPopupState(driverLevelList: event.driverLevelList));
  }

  //LEVEL PAGE SCROLL FUNCTIONS
  void levelsPageScrollListener() {
    handleScrollListener(
      controller: levelsScrollController,
      pagination: levelsPagination,
      onPageFetch: (pageNo) {
        add(DriverLevelGetEvent(pageNo: pageNo));
      },
      onUpdate: () {
        add(UpdateEvent());
      },
      isLoading: loadMoreLevel,
      setLoading: (loading) {
        loadMoreLevel = loading;
      },
    );
  }

//Level Init function
  Future<void> levelInitEvent(
      DriverLevelnitEvent event, Emitter<AccState> emit) async {
    firstLoadLevel = true;
    isLoading = true;
    add(DriverLevelGetEvent(pageNo: 1));
    levelsScrollController.addListener(levelsPageScrollListener);
    emit(UpdateState());
  }

//DRIVER LEVEL Data
  Future<void> getDriverLevelData(
      DriverLevelGetEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    if (firstLoadLevel) {
      emit(DriverLevelLoadingStartState());
    }
    final data =
        await serviceLocator<AccUsecase>().getDriverLevels(event.pageNo);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          firstLoadLevel = false;
          isLoading = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        firstLoadLevel = false;
        isLoading = false;
        loadMoreLevel = false;
        driverLevelsList = success.data;
        levelsPagination = success.meta.pagination;
        add(AccGetUserDetailsEvent());
      },
    );
    emit(DriverLevelLoadingStopState());
  }

//redeem points update
  Future<void> postRedeemPoints(
      RedeemPointsEvent event, Emitter<AccState> emit) async {
    try {
      final data = await serviceLocator<AccUsecase>()
          .rewardPointsPost(amount: event.amount);
      data.fold(
        (error) {
          emit(ShowErrorState(message: error.message.toString()));
        },
        (success) {
          add(DriverRewardGetEvent(pageNo: 1));
        },
      );
    } catch (e) {
      emit(ShowErrorState(message: e.toString()));
    }
  }

//redeem values update
  FutureOr updateRedeemValues(
      UpdateRedeemedAmountEvent event, Emitter<AccState> emit) async {
    redeemedAmount = event.redeemedAmount!;
    emit(UpdateRedeemedAmountState(redeemedAmount: redeemedAmount));
  }

//REWARD PAGE SCROLL FUNCTIONS
  void rewardPageScrollListener() {
    handleScrollListener(
      controller: rewardsScrollController,
      pagination: rewardsPagination,
      onPageFetch: (pageNo) {
        add(DriverRewardGetEvent(pageNo: pageNo));
      },
      onUpdate: () {
        add(UpdateEvent());
      },
      isLoading: loadMoreReward,
      setLoading: (loading) {
        loadMoreReward = loading;
      },
    );
  }

//Reward Init function
  Future<void> rewardInitEvent(
      DriverRewardInitEvent event, Emitter<AccState> emit) async {
    firstLoadReward = true;
    isLoading = true;
    add(DriverRewardGetEvent(pageNo: 1));
    rewardsScrollController.addListener(rewardPageScrollListener);
    emit(UpdateState());
  }

//driver reward data
  Future<void> getDriverRewardData(
      DriverRewardGetEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    if (firstLoadReward) {
      emit(DriverRewardLoadingStartState());
    }
    final data =
        await serviceLocator<AccUsecase>().getDriverRewards(event.pageNo);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          firstLoadReward = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        firstLoadReward = false;
        isLoading = false;
        loadMoreReward = false;
        driverRewardsList = success.data;
        rewardsPagination = success.meta.pagination;
        add(AccGetUserDetailsEvent());
      },
    );
    emit(DriverRewardLoadingStopState());
  }

//reward popup
  FutureOr showRewardsPointsPopup(
      DriverRewardPointsEvent event, Emitter<AccState> emit) async {
    emit(DriverRewardPointsState());
  }

//reward how it works popup
  FutureOr showHowitWorksPopup(
      HowItWorksEvent event, Emitter<AccState> emit) async {
    emit(HowItWorksState());
  }

  // Change History Type
  Future<void> _historyTypeChange(
      HistoryTypeChangeEvent event, Emitter<AccState> emit) async {
    selectedHistoryType = event.historyTypeIndex;
    emit(HistoryTypeChangeState(selectedHistoryType: selectedHistoryType));
  }

  //Clear notification
  Future<void> _clearAllNotifications(
      ClearAllNotificationsEvent event, Emitter<AccState> emit) async {
    try {
      await serviceLocator<AccUsecase>().clearAllNotification();
      notificationDatas.clear();
      emit(NotificationClearedSuccess());
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

  // Delete notification
  Future<void> _deleteNotification(
      DeleteNotificationEvent event, Emitter<AccState> emit) async {
    try {
      await _deleteNotificationById(event.id);
      notificationDatas.removeWhere((value) => value.id == event.id);
      emit(NotificationDeletedSuccess());
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

//delete notification
  Future<void> _deleteNotificationById(String id) async {
    try {
      await serviceLocator<AccUsecase>().deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Logout
  Future<void> _logout(LogoutEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(LogoutLoadingState());
    final data = await serviceLocator<AccUsecase>().logout();
    data.fold(
      (error) {
        emit(LogoutFailureState(errorMessage: error.toString()));
        emit(ShowErrorState(message: error.message.toString()));
        isLoading = false;
      },
      (success) {
        isLoading = false;
        emit(LogoutSuccess());
      },
    );
  }

  // Delete account
  Future<void> _deleteAccount(
      DeleteAccountEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(DeleteAccountLoadingState());
    final deleteResult = await serviceLocator<AccUsecase>().deleteUserAccount();
    deleteResult.fold(
      (error) {
        emit(DeleteAccountFailureState(errorMessage: error.message ?? ""));
        emit(ShowErrorState(message: error.message.toString()));
        isLoading = false;
      },
      (success) {
        FirebaseDatabase.instance
            .ref()
            .child('drivers/driver_${userData!.id}')
            .update({
          'is_active': 0,
          'is_available': false,
        });
        isLoading = false;
        emit(DeleteAccountSuccess());
      },
    );
  }

  // make complaints
  Future<void> _getComplaints(
      ComplaintEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(MakeComplaintLoading());

    try {
      final data = await serviceLocator<AccUsecase>()
          .makeComplaint(complaintType: event.complaintType.toString());
      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            isLoading = false;
            emit(MakeComplaintFailure(errorMessage: error.message ?? ""));
          }
        },
        (success) {
          isLoading = false;
          complaintList = success.data;
          emit(MakeComplaintSuccess(complaintList: complaintList));
        },
      );
    } catch (e) {
      debugPrint('An error occurred: $e');
      emit(MakeComplaintFailure(errorMessage: e.toString()));
    }
  }

// make complaint button
  Future<void> _complaintButton(
      ComplaintButtonEvent event, Emitter<AccState> emit) async {
    final complaintText = complaintController.text.trim();

    if (complaintText.length <= 10) {
      emit(ComplaintButtonFailureState(
          errorMessage: 'Complaint text must be more than 10 characters.'));
      return;
    }

    emit(ComplaintButtonLoadingState());
    final result = await serviceLocator<AccUsecase>().makeComplaintButton(
        event.complaintTitleId, complaintText, event.requestId);

    result.fold(
      (failure) {
        emit(ComplaintButtonFailureState(errorMessage: failure.toString()));
      },
      (success) {
        emit(MakeComplaintButtonSuccess());
        complaintController.clear();
      },
    );
  }

//Gender select event
  Future<void> _onGenderSelected(
      GenderSelectedEvent event, Emitter<AccState> emit) async {
    selectedGender = event.selectedGender;
    emit(GenderSelectedState(selectedGender: selectedGender));
  }

//Faq
  FutureOr<void> _getFaqList(
      GetFaqListEvent event, Emitter<AccState> emit) async {
    emit(FaqLoadingState());
    final data = await serviceLocator<AccUsecase>().getFaqDetail();
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(FaqFailureState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        faqDataList = success.data;
        emit(FaqSuccessState());
      },
    );
  }

  Future<void> _selectedFaqIndex(
      FaqOnTapEvent event, Emitter<AccState> emit) async {
    choosenFaqIndex = event.selectedFaqIndex;
    emit(FaqSelectState(choosenFaqIndex));
  }

//map type update function
  Future<void> _selectedMapIndex(
      ChooseMapOnTapEvent event, Emitter<AccState> emit) async {
    choosenMapIndex = event.chooseMapIndex;
    if (event.chooseMapIndex == 0) {
      mapType = 'google_map';
      await AppSharedPreference.setMapType(mapType);
      add(UpdateUserDetailsEvent(
          name: '',
          email: '',
          gender: '',
          profileImage: '',
          mapType: 'google_map'));
    } else {
      mapType = 'open_street_map';
      await AppSharedPreference.setMapType(mapType);
      add(UpdateUserDetailsEvent(
          name: '',
          email: '',
          gender: '',
          profileImage: '',
          mapType: 'open_street_map'));
    }
    isAppMapChange = true;
    emit(ChooseMApSelectState(choosenMapIndex));
  }

//get wallet init
  Future<void> walletInitEvent(
      GetWalletInitEvent event, Emitter<AccState> emit) async {
    firstLoad = true;
    isLoading = true;
    scrollController.addListener(walletPageScrollListener);
    emit(UpdateState());
  }

//withdraw init
  Future<void> withdrawInitEvent(
      GetWithdrawInitEvent event, Emitter<AccState> emit) async {
    firstWithdrawLoad = true;
    isWithdrawLoading = true;
    addBankInfo = false;

    // Remove existing listener to prevent duplicates
    scrollController.removeListener(walletPageScrollListener);
    scrollController.addListener(walletPageScrollListener);

    // Initialize with first page
    add(GetWithdrawDataEvent(pageIndex: 1));
    add(GetBankDetails());
    emit(UpdateState());
  }

  walletPageScrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading &&
        !loadMore) {
      if (walletPaginations != null &&
          walletPaginations!.pagination.currentPage <
              walletPaginations!.pagination.totalPages) {
        loadMore = true;
        add(UpdateEvent());
        add(GetWalletHistoryListEvent(
            pageIndex: walletPaginations!.pagination.currentPage + 1));
      } else if (walletPaginations!.pagination.currentPage ==
          walletPaginations!.pagination.totalPages) {
        loadMore = false;
        add(UpdateEvent());
      }
    }
  }

  incentiveDateScrollListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incentiveHistoryLength = incentiveHistory.length;
      if (incentiveScrollController.hasClients && incentiveHistoryLength > 0) {
        incentiveScrollController.jumpTo(
          incentiveScrollController.position.maxScrollExtent,
        );
      }
    });
  }

  withdrawPageScrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading &&
        !loadWithdrawMore) {
      if (withdrawResponse != null && withdrawResponse!.pagination != null) {
        if (withdrawResponse!.pagination!.currentPage <
            withdrawResponse!.pagination!.totalPages) {
          loadWithdrawMore = true;
          add(UpdateEvent());
          add(GetWithdrawDataEvent(
              pageIndex: withdrawResponse!.pagination!.currentPage + 1));
        } else if (withdrawResponse!.pagination!.currentPage ==
            withdrawResponse!.pagination!.totalPages) {
          loadWithdrawMore = false;
          add(UpdateEvent());
        }
      }
    }
  }

//get wallet history
  FutureOr<void> _getWalletHistoryList(
      GetWalletHistoryListEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    if (firstLoad) {
      emit(WalletHistoryLoadingState());
    }
    if (event.pageIndex == 1) {
      walletHistoryList.clear();
    }
    final data =
        await serviceLocator<AccUsecase>().getWalletDetail(event.pageIndex);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          firstLoad = false;
          emit(WalletHistoryFailureState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        firstLoad = false;
        isLoading = false;
        loadMore = false;
        walletResponse = success;
        List<WalletHistoryData> listWallet = success.walletHistory.data;
        walletHistoryList.addAll(listWallet);
        walletPaymentGatways = success.paymentGateways;
        walletPaginations = success.walletHistory.meta;
        add(AccGetUserDetailsEvent());
        emit(WalletHistorySuccessState(walletHistoryDatas: walletHistoryList));
      },
    );
  }

  Future<void> paymentAuth(
      PaymentAuthenticationEvent event, Emitter<AccState> emit) async {
    userData = event.arg.userData;
    final data = await serviceLocator<AccUsecase>().stripeSetupIntent();
    data.fold((error) {
      debugPrint(error.toString());
    }, (success) {
      paymentAuthData = success.data;
    });
    emit(UpdateState());
  }

  FutureOr getCardList(CardListEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>().cardList();
    data.fold((error) {
      debugPrint(error.toString());
    }, (success) {
      savedCardsList.clear();
      savedCardsList = success.data;
      emit(UpdateState());
    });
  }

  FutureOr deleteCard(DeleteCardEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data =
        await serviceLocator<AccUsecase>().deleteCard(cardId: event.cardId);
    data.fold((error) {
      debugPrint(error.toString());
      showToast(message: error.message.toString());
      emit(AccDataLoadingStopState());
    }, (success) {
      savedCardsList.removeWhere((element) => element.id == event.cardId);
      emit(AccDataLoadingStopState());
    });
  }

  FutureOr showPaymentGateways(
      ShowPaymentGatewayEvent event, Emitter<AccState> emit) async {
    emit(ShowPaymentGatewayState());
  }

  FutureOr addCardDetails(
      AddCardDetailsEvent event, Emitter<AccState> emit) async {
    try {
      isLoading = true;
      emit(UpdateState());
      final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                  billingDetails: BillingDetails(
                      name: userData!.name, phone: userData!.mobile))));

      final data = await serviceLocator<AccUsecase>().stripSaveCardDetails(
          paymentMethodId: paymentMethod.id,
          last4Number: paymentMethod.card.last4!,
          cardType: paymentMethod.card.brand!,
          validThrough:
              '${paymentMethod.card.expMonth}/${paymentMethod.card.expYear}');
      data.fold((error) {
        printWrapped(error.toString());
        isLoading = false;
      }, (success) {
        if (success['success']) {
          isLoading = false;
          emit(SaveCardSuccessState());
        } else {
          isLoading = false;
          showToast(message: success['message'].toString());
          emit(UpdateState());
        }
      });
    } on StripeException catch (e) {
      isLoading = false;
      emit(UpdateState());
      printWrapped(e.toString());
      showToast(message: e.error.localizedMessage.toString());
    } catch (e) {
      isLoading = false;
      emit(UpdateState());
      printWrapped(e.toString());
      showToast(message: 'Please enter the valid data');
    }
  }

  Future<void> addMoneyFromCard(
      AddMoneyFromCardEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<AccUsecase>().addMoneyToWalletFromCard(
        amount: event.amount, cardToken: event.cardToken, planId: event.planId);
    data.fold((error) {
      printWrapped(error.toString());
      showToast(message: error.message.toString());
      emit(AccDataLoadingStopState());
      emit(PaymentUpdateState(status: false));
    }, (success) {
      emit(AccDataLoadingStopState());
      emit(PaymentUpdateState(status: success['success']));
    });
  }

//Get subscription
  FutureOr<void> _getSubscriptionDataList(
      GetSubscriptionListEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    if (firstLoad) {
      emit(SubscriptionListLoadingState());
    }
    final data = await serviceLocator<AccUsecase>().getSubscriptionList();
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          firstLoad = false;
          emit(SubscriptionListFailureState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        firstLoad = false;
        isLoading = false;
        subscriptionResponse = success;
        subscriptionList = success.data!;
        if (subscriptionList.isNotEmpty) {
          addMoneySubscription = subscriptionList[choosenPlanindex].amount;
        }
        add(AccGetUserDetailsEvent());
        emit(SubscriptionListSuccessState(subscriptionDatas: subscriptionList));
      },
    );
  }

//subsription plan
  FutureOr<void> subscriptionToPlan(
      SubscribeToPlanEvent event, Emitter<AccState> emit) async {
    emit(SubscriptionPayLoadingState());
    final data = await serviceLocator<AccUsecase>().makeSubscriptionPlan(
        amount: event.amount,
        paymentOpt: event.paymentOpt,
        planId: event.planId);
    data.fold(
      (error) {
        emit(SubscriptionPayLoadedState());
      },
      (success) {
        subscriptionSuccessData = success.data;
        emit(SubscriptionPaySuccessState());
      },
    );
  }

// get bank details
  FutureOr<void> getBankDetails(
      GetBankDetails event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>().getBankDetails();
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        bankDetails = success.data;
      },
    );
  }

//update bank details
  FutureOr<void> updateBankDetails(
      UpdateBankDetailsEvent event, Emitter<AccState> emit) async {
    emit(WithdrawDataLoadingStartState());
    final data =
        await serviceLocator<AccUsecase>().updateBankDetails(body: event.body);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        editBank = false;
        addBankInfo = false;
        add(GetBankDetails());
        emit(BankUpdateSuccessState());
      },
    );

    emit(WithdrawDataLoadingStopState());
  }

//get witdraw data
  FutureOr<void> getWithdrawData(
      GetWithdrawDataEvent event, Emitter<AccState> emit) async {
    final data =
        await serviceLocator<AccUsecase>().getWithdrawData(event.pageIndex);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (event.pageIndex == 1) {
          // First page - replace existing data
          withdrawData = List.from(success.data);
        } else {
          // Subsequent pages - append new data
          if (success.data.isNotEmpty) {
            withdrawData.addAll(success.data);
            // Remove duplicates if any
            withdrawData = withdrawData.toSet().toList();
          }
        }

        withdrawResponse = success;
        isWithdrawLoading = false;
        firstWithdrawLoad = false;

        // Emit success state with the updated data

        emit(UpdateState());
        // emit(WalletHistorySuccessState(
        //   walletHistory: withdrawData,
        //   pagination: success.pagination,
        // ));
      },
    );
    emit(UpdateState());
  }

//request withdraw
  FutureOr<void> requestWithdraw(
      RequestWithdrawEvent event, Emitter<AccState> emit) async {
    emit(WithdrawDataLoadingStartState());
    final data = await serviceLocator<AccUsecase>()
        .requestWithdraw(amount: event.amount);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        if (success.success == true) {
          add(GetWithdrawDataEvent(pageIndex: 1));
        }
      },
    );
    emit(WithdrawDataLoadingStopState());
  }

//select plan subscription
  Future<void> selectedPlanIndex(
      SubscriptionOnTapEvent event, Emitter<AccState> emit) async {
    choosenPlanindex = event.selectedPlanIndex;
    if (subscriptionList.isNotEmpty) {
      addMoneySubscription = subscriptionList[choosenPlanindex].amount;
    }
    emit(PlanSelectState(choosenPlanindex));
  }

//choose plans subscription
  Future<void> choosePlansFunction(
      ChoosePlanEvent event, Emitter<AccState> emit) async {
    isPlansChooseds = event.isPlansChoosed;
    emit(SubscriptionPlanChosenState());
  }

//wallet empty function
  Future<void> walletEmptyFunction(
      WalletEmptyEvent event, Emitter<AccState> emit) async {
    emit(WalletEmptyState());
  }

//select pay subsription
  Future<void> selectedPayIndex(
      SubscriptionPaymentOnTapEvent event, Emitter<AccState> emit) async {
    choosenSubscriptionPayIndex = event.selectedPayIndex;
    emit(SubscriptionPaymentSelectState(choosenSubscriptionPayIndex!));
  }

//Transer money selection option
  Future<void> _onTransferMoneySelected(
      TransferMoneySelectedEvent event, Emitter<AccState> emit) async {
    dropdownValue = event.selectedTransferAmountMenuItem;
    emit(TransferMoneySelectedState(
        selectedTransferAmountMenuItem: dropdownValue));
  }

//Money transfered api
  FutureOr<void> moneyTransfered(
      MoneyTransferedEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>().moneyTransfer(
        transferMobile: event.transferMobile,
        role: event.role,
        transferAmount: event.transferAmount);
    data.fold(
      (error) {
        emit(MoneyTransferedFailureState());
        emit(ShowErrorState(message: error.message.toString()));
        showToast(message: error.message.toString());
      },
      (success) {
        add(GetWalletHistoryListEvent(pageIndex: 1));
        emit(MoneyTransferedSuccessState());
      },
    );
  }

//Get user details
  Future<void> getUserDetails(
      AccGetUserDetailsEvent event, Emitter<AccState> emit) async {
    requestId = userData?.onTripRequest?.id;
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<HomeUsecase>().userDetails(
      requestId: requestId,
    );
    data.fold((error) {
      if (error.statusCode == 401) {
        AppSharedPreference.remove('login');
        AppSharedPreference.remove('token');
        emit(UserUnauthenticatedState());
      } else {
        emit(ShowErrorState(message: error.message.toString()));
      }
    }, (success) {
      userData = success.data;
      if (userData!.role == 'driver') {
        sosdata = success.data.sos!.data;
      }
      emit(AccDataSuccessState());
    });
  }

  // Delete sos
  Future<void> _deletesos(
      DeleteContactEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>().deleteSosContact(event.id!);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(SosFailureState());
      },
      (success) {
        add(AccGetUserDetailsEvent());
        emit(SosDeletedSuccessState());
      },
    );
  }

//add contacts
  FutureOr<void> addContactDetails(
      AddContactEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>()
        .addSosContact(name: event.name, number: event.number);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
        emit(AddContactFailureState());
      },
      (success) {
        add(AccGetUserDetailsEvent());
        emit(AddContactSuccessState());
      },
    );
  }

//select contact
  Future<void> selectContactDetails(
      SelectContactDetailsEvent event, Emitter<AccState> emit) async {
    await Permission.contacts.request();
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      emit(AccDataLoadingStartState());
      if (contactsList.isEmpty) {
        if (await FlutterContacts.requestPermission()) {
          isLoading = true;
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
          isLoading = false;
        }
      }
      emit(AccDataSuccessState());
      emit(SelectContactDetailsState());
    } else {
      bool isOpened = await openAppSettings();
      if (isOpened) {
      } else {}
      emit(GetContactPermissionState());
    }
  }

//update user details
  Future<void> _updateTextField(
      UpdateUserDetailsEvent event, Emitter<AccState> emit) async {
    final result = await serviceLocator<AccUsecase>().updateDetailsButton(
      email: event.email,
      name: event.name,
      gender: event.gender,
      profileImage: event.profileImage,
      mapType: mapType,
      mobile: event.mobile,
      country: event.country,
    );
    result.fold(
      (failure) {
        emit(UpdateUserDetailsFailureState());
      },
      (success) {
        emit(UserDetailsUpdatedState(
          name: event.name,
          email: event.email,
          gender: event.gender,
          profileImage: event.profileImage,
        ));

        emit(UserDetailsButtonSuccess());
        add(AccGetUserDetailsEvent());
      },
    );
  }

//get profile
  Future<void> _getProfileImage(
      UpdateImageEvent event, Emitter<AccState> emit) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;
    if (event.source == ImageSource.camera) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else if (event.source == ImageSource.gallery) {
      image = await picker.pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      profileImage = image.path;
      emit(ImageUpdateState(profileImage: profileImage));
      add(UpdateUserDetailsEvent(
        name: event.name,
        email: event.email,
        gender: event.gender,
        profileImage: profileImage,
      ));
    }
  }

//edit user details
  FutureOr<void> userDetailEdit(
      UserDetailEditEvent event, Emitter<AccState> emit) async {
    emit(UserDetailEditState(header: event.header, text: event.text));
  }

//user details
  FutureOr<void> userDetails(
      UserDetailEvent event, Emitter<AccState> emit) async {
    emit(UserDetailState());
  }

//send admin chat
  FutureOr<void> sendAdminChat(
      SendAdminMessageEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<AccUsecase>().sendAdminMessages(
        newChat: event.newChat, message: event.message, chatId: event.chatId);
    data.fold(
      (error) {
        emit(SendAdminMessageFailureState());
      },
      (success) {
        chatId = success.data.conversationId;
        adminChatList.add(ChatData(
            message: success.data.message,
            conversationId: chatId,
            senderId: userData!.id.toString(),
            senderType: success.data.senderType,
            count: success.data.count,
            newChat: success.data.newChat,
            createdAt: success.data.createdAt,
            messageSuccess: success.data.messageSuccess,
            userTimezone: success.data.userTimezone));
        isNewChat = 0;
        if (adminChatList.isNotEmpty && chatStream == null) {
          streamAdminchat();
        }
        unSeenChatCount = '0';
        add(GetAdminChatHistoryListEvent());
        emit(SendAdminMessageSuccessState());
      },
    );
  }

//get admin chat
  FutureOr<void> _getAdminChatHistoryList(
      GetAdminChatHistoryListEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>().getAdminChatHistoryDetail();
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          emit(AdminChatHistoryFailureState());
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        adminChatList.clear();
        isNewChat = success.data.newChat;
        int count = success.data.count;
        for (var i = 0; i < success.data.conversation.length; i++) {
          adminChatList.add(ChatData(
              message: success.data.conversation[i].content,
              conversationId: success.data.conversation[i].conversationId,
              senderId: success.data.conversation[i].senderId.toString(),
              senderType: success.data.conversation[i].senderType.toString(),
              count: count,
              newChat: '0',
              createdAt: success.data.conversation[i].createdAt,
              messageSuccess: 'Data inserted successfully',
              userTimezone: success.data.conversation[i].userTimezone));
        }
        if (adminChatList.isNotEmpty) {
          chatId = success.data.conversationId;
        }

        unSeenChatCount = '0';
        emit(AdminChatHistorySuccessState());
      },
    );
  }

//admin chat stream function
  streamAdminchat() async {
    if (chatStream != null) {
      chatStream?.cancel();
      chatStream = null;
    }
    chatStream = FirebaseDatabase.instance
        .ref()
        .child(
            'conversation/${(adminChatList.length > 2) ? (userData != null) ? userData!.chatId : chatId : chatId}')
        .onValue
        .listen((event) async {
      var value = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(event.snapshot.value)));
      if (userData != null) {
        if ((((adminChatList.isNotEmpty &&
                    adminChatList.last.message !=
                        value['message'].toString())) &&
                value['sender_id'].toString() != userData!.id.toString()) ||
            (value['sender_id'].toString() != userData!.id.toString() &&
                adminChatList.isEmpty)) {
          adminChatList.add(ChatData.fromJson(value));
          add(UpdateEvent());
        }
      }
      value.clear();
      if (adminChatList.isNotEmpty) {
        unSeenChatCount =
            adminChatList[adminChatList.length - 1].count.toString();
        if (unSeenChatCount == 'null') {
          unSeenChatCount = '0';
        }
      }
      add(UpdateEvent());
    });
  }

//message seen admin
  FutureOr<void> _adminMessageSeenDetail(
      AdminMessageSeenEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>()
        .adminMessageSeenDetail(event.chatId!);
    data.fold(
      (error) {
        emit(AdminMessageSeenFailureState());
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        emit(AdminMessageSeenSuccessState());
      },
    );
  }

//choosen payment index -->payments
  Future<void> _selectedPaymentIndex(
      PaymentOnTapEvent event, Emitter<AccState> emit) async {
    choosenPaymentIndex = event.selectedPaymentIndex;
    emit(PaymentSelectState(choosenPaymentIndex!));
  }

//Rider cancel
  FutureOr cancelRequest(
      RideLaterCancelRequestEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<RideUsecases>()
        .cancelRequest(requestId: event.requestId, reason: '');
    data.fold((error) {
      emit(ShowErrorState(message: error.message.toString()));
    }, (success) {
      history.removeWhere((value) => value.id == event.requestId);
      emit(RequestCancelState());
    });
  }

//web routing payment
  FutureOr addMoneyWebViewUrl(
      AddMoneyWebViewUrlEvent event, Emitter<AccState> emit) async {
    if (event.from == '1') {
      paymentUrl =
          '${event.url}?amount=${event.money}&payment_for=request&currency=${event.currencySymbol}&user_id=${event.userId.toString()}&request_id=${event.requestId.toString()}';
    } else if (event.from == '2') {
      paymentUrl =
          '${event.url}?amount=${event.money}&payment_for=subscription&currency=${event.currencySymbol}&user_id=${event.userId.toString()}&plan_id=${event.planId}';
    } else {
      paymentUrl =
          '${event.url}?amount=${event.money}&payment_for=wallet&currency=${event.currencySymbol}&user_id=${event.userId.toString()}';
    }
    final Uri uri = Uri.parse(paymentUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } else {
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        const SnackBar(content: Text("Could not open payment page")),
      );
    }
    emit(UpdateState());
  }

  FutureOr userDataInit(UserDataInitEvent event, Emitter<AccState> emit) async {
    userData = event.userDetails;
    emit(UpdateState());
  }

  // Add drivers
  Future<void> _addDrivers(AddDriverEvent event, Emitter<AccState> emit) async {
    try {
      emit(DriversLoadingStartState());
      final data = await serviceLocator<AccUsecase>().addDrivers(
          name: driverNameController.text,
          email: driverEmailController.text,
          mobile: driverMobileController.text,
          address: driverAddressController.text);
      data.fold(
        (error) {
          emit(DriversLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        },
        (success) {
          driverNameController.clear();
          driverEmailController.clear();
          driverMobileController.clear();
          driverAddressController.clear();
          emit(DriversLoadingStopState());
          add(GetDriverEvent(from: 0));
        },
      );
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

//get drivers
  Future<void> _getDrivers(GetDriverEvent event, Emitter<AccState> emit) async {
    printWrapped('text ${event.from}');
    if (event.from == 1) {
      emit(VehiclesLoadingStartState());
    } else {
      emit(DriversLoadingStartState());
    }
    try {
      final data = await serviceLocator<AccUsecase>().getDrivers();
      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            if (event.from == 1) {
              emit(VehiclesLoadingStopState());
              emit(ShowErrorState(message: error.message.toString()));
            } else {
              emit(DriversLoadingStopState());
              emit(ShowErrorState(message: error.message.toString()));
            }
          }
        },
        (success) {
          choosenDriverForDelete = null;
          if (event.from == 1) {
            choosenDriverToVehicle = null;
            driverData.clear();
            for (var e in success.data!) {
              if (e.approve && e.carNumber == null) {
                driverData.add(e);
              }
              choosenFleetToAssign = event.fleetId;
            }
            emit(VehiclesLoadingStopState());
            emit(ShowAssignDriverState());
          } else {
            driverData = success.data!;
            emit(DriversLoadingStopState());
          }
        },
      );
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
      if (event.from == 1) {
        emit(VehiclesLoadingStopState());
      } else {
        emit(DriversLoadingStopState());
      }
    }
  }

//delete drivers
  Future<void> _deleteDrivers(
      DeleteDriverEvent event, Emitter<AccState> emit) async {
    emit(DriversLoadingStartState());

    try {
      final data = await serviceLocator<AccUsecase>()
          .deleteDrivers(driverId: event.driverId);
      data.fold(
        (error) {
          emit(DriversLoadingStopState());
          emit(ShowErrorState(message: error.message.toString()));
        },
        (success) {
          emit(DriversLoadingStopState());
          driverData.removeWhere((element) => element.id == event.driverId);
          add(GetDriverEvent(from: 0));
        },
      );
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

//get vehicles
  Future<void> _getVehicles(
      GetVehiclesEvent event, Emitter<AccState> emit) async {
    if (userData!.role == 'owner') {
      vehicleData = [];
      emit(VehiclesLoadingStartState());
      try {
        final data = await serviceLocator<AccUsecase>().getVehicles();
        data.fold(
          (error) {
            if (error.statusCode == 401) {
              AppSharedPreference.remove('login');
              AppSharedPreference.remove('token');
              emit(UserUnauthenticatedState());
            } else {
              isLoading = false;
              emit(ShowErrorState(message: error.message.toString()));
            }
          },
          (success) {
            isLoading = false;
            vehicleData = success.data;
          },
        );
      } catch (e) {
        emit(NotificationFailure(errorMessage: e.toString()));
      }
      emit(VehiclesLoadingStopState());
    }
  }

//Assign driver admin
  Future<void> _assignDriver(
      AssignDriverEvent event, Emitter<AccState> emit) async {
    emit(VehiclesLoadingStartState());
    try {
      final data = await serviceLocator<AccUsecase>()
          .assignDriver(fleetId: event.fleetId, driverId: event.driverId);
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
          add(GetVehiclesEvent());
        },
      );
      emit(VehiclesLoadingStopState());
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

//get earnings
  FutureOr<void> getEarnings(
      GetEarningsEvent event, Emitter<AccState> emit) async {
    emit(EarningsLoadingStartState());
    final data = await serviceLocator<AccUsecase>().getEarnings();

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
        earningsList = success.data;
        earningCurrency = success.currency;
        choosenEarningsWeeks = 0;
        // add(GetDailyEarningsEvent(date: 'today'));
        if (!emit.isDone) {
          add(GetDailyEarningsEvent(date: 'today'));
        }
      },
    );
    emit(EarningsLoadingStopState());
  }

//get leaderboard
  FutureOr<void> getLeaderboard(
      GetLeaderBoardEvent event, Emitter<AccState> emit) async {
    choosenLeaderboardData = event.type;
    leaderBoardData = null;
    isLoading = true;
    emit(LeaderBoardLoadingStartState());
    if (currentLatLng == null) {
      PermissionStatus status = await Permission.location.status;
      if (status.isGranted || status.isLimited) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        double long = position.longitude;
        currentLatLng = LatLng(lat, long);
      } else {
        await Permission.location.request();
      }
    }
    if (currentLatLng != null) {
      final data = await serviceLocator<AccUsecase>().getLeaderBoard(
          type: event.type,
          lat: currentLatLng!.latitude.toString(),
          lng: currentLatLng!.longitude.toString());

      data.fold(
        (error) {
          if (error.statusCode == 401) {
            AppSharedPreference.remove('login');
            AppSharedPreference.remove('token');
            emit(UserUnauthenticatedState());
          } else {
            isLoading = false;
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) {
          isLoading = false;
          leaderBoardData = success.data;
        },
      );
    }
    emit(LeaderBoardLoadingStopState());
  }

//get incentives
  Future<void> getIncentives(
      GetIncentiveEvent event, Emitter<AccState> emit) async {
    choosenIncentiveData = event.type;
    incentiveData = null;
    incentiveHistory = [];
    incentiveDates = [];
    isLoading = true;
    emit(IncentiveLoadingStartState());

    final data =
        await serviceLocator<AccUsecase>().getIncentive(type: event.type);
    data.fold(
      (error) {
        if (error.statusCode == 401) {
          AppSharedPreference.remove('login');
          AppSharedPreference.remove('token');
          emit(UserUnauthenticatedState());
        } else {
          isLoading = false;
          emit(ShowErrorState(message: error.message.toString()));
        }
      },
      (success) {
        isLoading = false;
        incentiveData = success;
        incentiveHistory = success.data.incentiveHistory;
        for (var history in incentiveHistory) {
          incentiveDates.addAll(history.dates);
        }
        for (var date in incentiveDates) {
          bool isSelectedDate = choosenIncentiveData == 0
              ? date.isCurrentDate
              : date.isCurrentWeek;
          if (isSelectedDate) {
            selectedDateInit =
                formatDateBasedOnIndex(date.date, choosenIncentiveData);
            selectedDate = selectedDateInit;
            add(
              SelectIncentiveDateEvent(
                selectedDate: selectedDate!,
                isSelected: true,
                choosenIndex: choosenIncentiveData,
              ),
            );
            emit(SelectIncentiveDateState(isSelected: true));
            break;
          }
        }
        incentiveDateScrollListener();
      },
    );
    emit(IncentiveLoadingStopState());
  }

//get incentiveData upcoming
  FutureOr<void> getUpcomingIncentiveData(
    SelectIncentiveDateEvent event,
    Emitter<AccState> emit,
  ) async {
    int choosenIndex = event.choosenIndex;
    bool isMatchFound = false;

    for (var history in incentiveHistory) {
      for (var date in history.dates) {
        String formattedDate = formatDateBasedOnIndex(date.date, choosenIndex);
        if (formattedDate == event.selectedDate) {
          selectedIncentiveHistory = date;
          isMatchFound = true;
          break;
        }
      }
      if (isMatchFound) break;
    }
    if (selectedIncentiveHistory != null) {
      emit(
        ShowUpcomingIncentivesState(
          upcomingIncentives: selectedIncentiveHistory!.upcomingIncentives,
        ),
      );
    } else {
      emit(ShowErrorState(message: "Failed"));
    }
  }

  //date format
  String formatDateBasedOnIndex(String date, int choosenIndexData) {
    List<String> dateParts = date.split('-');
    String day = dateParts[0];
    String month = dateParts[1];
    String year = dateParts[2];
    if (choosenIndexData == 0) {
      final dates = date.split('-')[0];
      return dates;
    } else if (choosenIndexData == 1) {
      int dayInt = int.parse(day);
      int monthInt = _monthToNumber(month);
      int yearInt = int.parse(year);
      DateTime startDate = DateTime(yearInt, monthInt, dayInt);
      DateTime endDate = startDate.add(const Duration(days: 6));
      String endDay = endDate.day.toString().padLeft(2, '0');
      return '$day-$endDay';
    }
    return '';
  }

//get owner dashboard
  FutureOr<void> getOwnerDashboard(
      GetOwnerDashboardEvent event, Emitter<AccState> emit) async {
    emit(DashboardLoadingStartState());
    final data = await serviceLocator<AccUsecase>().getOwnerDashboard();
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
        fleetData = success.data;
        fleetEarnings = success.fleetEarnings;
        fleetDriverData = success.fleetDriverData;
      },
    );
    emit(DashboardLoadingStopState());
  }

//get fleet dashboard
  FutureOr<void> getFleetDashboard(
      GetFleetDashboardEvent event, Emitter<AccState> emit) async {
    fleetDashboardData = null;
    emit(FleetDashboardLoadingStartState());
    final data = await serviceLocator<AccUsecase>()
        .getFleetDashboard(fleetId: event.fleetId);

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
        fleetDashboardData = success.data;
      },
    );
    emit(FleetDashboardLoadingStopState());
  }

//driver performance get
  FutureOr<void> getDriverPerformance(
      GetDriverPerformanceEvent event, Emitter<AccState> emit) async {
    driverPerformanceData = null;
    emit(DriverPerformanceLoadingStartState());
    final data = await serviceLocator<AccUsecase>()
        .getDriverPerformance(driverId: event.driverId);
    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        driverPerformanceData = success.driverData;
      },
    );
    emit(DriverPerformanceLoadingStopState());
  }

//change earnings week
  FutureOr<void> changeEarningsWeek(
      ChangeEarningsWeekEvent event, Emitter<AccState> emit) async {
    choosenEarningsWeeks = event.week;
    emit(DataChangedState());
  }

//Get daily earnings
  FutureOr<void> getDailyEarnings(
      GetDailyEarningsEvent event, Emitter<AccState> emit) async {
    String date = (event.date == 'today')
        ? DateTime.now().toString().split(' ')[0]
        : DateFormat('dd-MMM-yy').parse(event.date).toString().split(' ')[0];
    choosenEarningsDate = (event.date == 'today')
        ? DateFormat('EEE-dd').format(DateTime.now())
        : DateFormat('EEE-dd')
            .format(DateFormat('dd-MMM-yy').parse(event.date));
    emit(EarningsLoadingStartState());

    final data =
        await serviceLocator<AccUsecase>().getDailyEarnings(date: date);

    data.fold(
      (error) {
        emit(ShowErrorState(message: error.message.toString()));
      },
      (success) {
        dailyEarningsList = success;
      },
    );
    emit(EarningsLoadingStopState());
  }

//sos change type
  Future<void> changeBoolSos(AccEvent event, Emitter<AccState> emit) async {
    emit(SosLoadingState());

    await Future.delayed(const Duration(seconds: 2));

    emit(SosLoadedState());
  }

  Future<void> sosPageInit(SosInitEvent event, Emitter<AccState> emit) async {
    isSosLoading = true;
    emit(UpdateState());
    sosdata = event.arg.sosData;
    await Future.delayed(const Duration(seconds: 2));
    isSosLoading = false;
    emit(UpdateState());
  }

//Notification update
  Future<void> notificationUpdateLoading(
      AccEvent event, Emitter<AccState> emit) async {
    emit(NotificationLoadingState());

    await Future.delayed(const Duration(seconds: 2));

    emit(NotificationLoadedState());
  }

  // Helper function to convert month name to month number
  int _monthToNumber(String month) {
    switch (month.toLowerCase()) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
      default:
        return 1;
    }
  }

  //common scrolling function
  void handleScrollListener({
    required ScrollController controller,
    required dynamic pagination,
    required Function(int pageNo) onPageFetch,
    required VoidCallback onUpdate,
    required bool isLoading,
    required void Function(bool) setLoading,
  }) {
    if (controller.position.pixels == controller.position.maxScrollExtent &&
        !isLoading) {
      if (pagination != null &&
          pagination.currentPage < pagination.totalPages) {
        setLoading(true);
        onUpdate();
        Future.delayed(const Duration(seconds: 2), () {
          onPageFetch(pagination.currentPage + 1);
        });
      } else if (pagination != null &&
          pagination.currentPage == pagination.totalPages) {
        setLoading(false);
        onUpdate();
      }
    }
    if (controller.position.pixels == controller.position.minScrollExtent &&
        !isLoading) {
      if (pagination != null && pagination.currentPage > 1) {
        setLoading(true);
        onUpdate();
        Future.delayed(const Duration(seconds: 2), () {
          onPageFetch(pagination.currentPage - 1);
        });
      } else if (pagination != null && pagination.currentPage == 1) {
        setLoading(false);
        onUpdate();
      }
    }
  }

  Future<void> makeTicketSubmit(
      MakeTicketSubmitEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(UpdateState());
    final data = await serviceLocator<AccUsecase>().makeTicket(
        titleId: event.titleId,
        description: event.description,
        attachments: event.attachement,
        requestId: event.requestId);
    data.fold((error) {
      showToast(message: error.message.toString());
      isLoading = false;
    }, (success) {
      showToast(message: success.message.toString());
      isLoading = false;
      if (event.isFromRequest == true) {
        add(HistoryGetEvent(
            historyFilter: 'is_completed=1',
            historyIndex: event.index,
            pageNumber: event.pageNumber));
      } else {
        if (!isClosed) {
          add(GetTicketListEvent(isFromAcc: false));
        }
      }

      emit(UpdateState());
    });
  }

  Future<void> viewTicketData(
      ViewTicketEvent event, Emitter<AccState> emit) async {
    viewAttachments.clear();
    final data =
        await serviceLocator<AccUsecase>().viewTicket(ticketId: event.id);
    data.fold((error) {
      showToast(message: error.message.toString());
    }, (success) {
      supportTicketData = success.supportTicket;
      viewAttachments = success.attachment;
      replyMessages = success.replyMessage;
      emit(UpdateState());
    });
  }

  Future<void> createSupportTicket(
      CreateSupportTicketEvent event, Emitter<AccState> emit) async {
    selectedTicketTitle = '';
    ticketAttachments.clear();
    supportDescriptionController.clear();
    final data = await serviceLocator<AccUsecase>()
        .supportTicketTitles(isFromRequest: event.isFromRequest);
    data.fold((error) {
      debugPrint(error.toString());
    }, (success) {
      ticketNamesList.clear();
      ticketNamesList = success.data;
      emit(UpdateState());
    });
    emit(CreateSupportTicketState(
        ticketNamesList: ticketNamesList,
        requestId: event.requestId,
        isFromRequest: event.isFromRequest,
        historyPageNumber: event.pageNumber,
        historyIndex: event.index));
  }

  FutureOr<void> getTicketList(
      GetTicketListEvent event, Emitter<AccState> emit) async {
    if (event.isFromAcc == true) {
      emit(GetTicketListLoadingState());
    }
    isLoading = true;
    final data = await serviceLocator<AccUsecase>().getTicketList();
    data.fold(
      (error) {
        debugPrint(error.toString());
        isLoading = false;
      },
      (success) {
        ticketList = success.data;
        isLoading = false;
        emit(GetTicketListLoadedState());
      },
    );
  }

  Future<void> assignSelectedTicketValue(
      TicketTitleChangeEvent event, Emitter<AccState> emit) async {
    selectedTicketTitle = event.changedTitle;
    selectedTicketTitleId = event.id;
    emit(UpdateState());
  }

  Future<void> clearAttachment(
      ClearAttachmentEvent event, Emitter<AccState> emit) async {
    ticketAttachments.clear();
    emit(ClearAttachmentState());
  }

  Future<void> addAttachment(
    AddAttachmentTicketEvent event,
    Emitter<AccState> emit,
  ) async {
    if (ticketAttachments.length >= 8) {
      showToast(message: AppLocalizations.of(event.context)!.fileLimitReached);
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'jpeg', 'png'],
      );
      if (result != null) {
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc'];

        final selectedFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        final validFiles = <File>[];
        bool hasInvalidFile = false;

        for (var file in selectedFiles) {
          final extension = file.path.split('.').last.toLowerCase();
          if (allowedExtensions.contains(extension)) {
            validFiles.add(file);
          } else {
            hasInvalidFile = true;
          }
        }
        if (hasInvalidFile) {
          showToast(message: "Some files were not supported and skipped.");
        }

        if (validFiles.isNotEmpty) {
          ticketAttachments =
              [...ticketAttachments, ...validFiles].take(8).toList();
          emit(AddAttachmentTicketState());
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      showToast(message: 'Failed to pick files');
    }
  }

  Future<void> ticketMessageReply(
      TicketReplyMessageEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>()
        .ticketReplyMessage(id: event.id, replyMessage: event.messageText);
    data.fold((error) {
      showToast(message: error.message.toString());
    }, (success) {
      showToast(
          message: AppLocalizations.of(event.context)!.messageSuccessText);
      add(ViewTicketEvent(id: event.id));
      emit(UpdateState());
      supportMessageReplyController.clear();
    });
  }

  Future<void> tripSummaryHistoryDataGet(
      TripSummaryHistoryDataEvent event, Emitter<AccState> emit) async {
    historyData = event.tripHistoryData;
    emit(UpdateState());
  }

  FutureOr<void> downloadInvoice(
      DownloadInvoiceEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(UpdateState());
    final data = await serviceLocator<AccUsecase>()
        .invoiceDownload(requestId: event.requestId);
    data.fold(
      (error) {
        debugPrint(error.toString());
        isLoading = false;
        emit(UpdateState());
      },
      (success) {
        isLoading = false;
        emit(UpdateState());
        if (success["success"]) {
          emit(InvoiceDownloadSuccessState());
        }
      },
    );
  }

  FutureOr<void> getHtmlString(
      GetHtmlStringEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<AccUsecase>()
        .getTermsAndPrivacyHtml(isPrivacyPage: event.isPrivacy);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(AccDataLoadingStopState());
      },
      (success) {
        if (success["success"]) {
          htmlString = success["data"];
        }
        emit(AccDataLoadingStopState());
      },
    );
  }

  void _onToggleSearch(
      ToggleSearchVisibilityEvent event, Emitter<AccState> emit) {
    showSearch = event.showSearch;
    emit(AccSearchVisibilityChanged(showSearch));
  }

  void routeBookingInit(RouteBookingInitEvent event, Emitter<AccState> emit) {
    selectedMyRouteAddress = event.address;
    emit(UpdateState());
  }

  Future<void> _onMyRouteAddressUpdate(
      MyRouteAddressUpdateEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(UpdateState());
    // Call the usecase (make sure serviceLocator is set up for AccUsecase)
    final result = await serviceLocator<AccUsecase>().addressUpdated(
      myRouteLat: event.myRouteLat,
      myRouteLng: event.myRouteLng,
      myRouteAddress: event.myRouteAddress,
    );

    result.fold(
      (failure) {
        isLoading = false;
        showToast(message: failure.message.toString());
        emit(ShowErrorState(message: failure.message.toString()));
      },
      (response) {
        isLoading = false;
        emit(UpdateState());
        showToast(
            message: AppLocalizations.of(navigatorKey.currentState!.context)!
                .detailsUpdateSuccess);
        selectedMyRouteLatLng = LatLng(event.myRouteLat, event.myRouteLng);
        selectedMyRouteAddress = event.myRouteAddress;
        userData!.myRouteAddress = selectedMyRouteAddress;
        emit(MyRouteAddressUpdateState(
          myRouteLat: event.myRouteLat,
          myRouteLng: event.myRouteLng,
          myRouteAddress: event.myRouteAddress,
        ));
      },
    );
  }

  Future<void> _onEnableMyRouteBooking(
    EnableMyRouteBookingEvent event,
    Emitter<AccState> emit,
  ) async {
    isLoading = true;
    emit(UpdateState());
    final result = await serviceLocator<AccUsecase>().enableMyRouteBooking(
      isEnable: event.isEnable,
      currentLat: event.currentLat,
      currentLng: event.currentLng,
      currentAddress: event.currentLatLng,
    );

    result.fold(
      (failure) {
        isLoading = false;
        showToast(message: failure.message.toString());
        emit(ShowErrorState(message: failure.message.toString()));
      },
      (response) {
        isLoading = false;
        emit(UpdateState());
        if (response.success) {
          showToast(
              message: AppLocalizations.of(navigatorKey.currentState!.context)!
                  .myRouteEnabledSuccessfully);
        } else {
          showToast(
              message: AppLocalizations.of(navigatorKey.currentState!.context)!
                  .myrouteDisabledSuccessfully);
        }
        add(AccGetUserDetailsEvent());
        emit(EnableMyRouteBookingSuccessState(
          isEnable: event.isEnable,
          currentLat: event.currentLat,
          currentLng: event.currentLng,
          currentAddress: event.currentLatLng,
        ));
      },
    );
  }

  FutureOr<void> getAddressFromLatLng(
      AccGeocodingLatLngEvent event, Emitter<AccState> emit) async {
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
      data.fold((error) {}, (success) {
        final data = success.address.toString().split(',');
        if (data.length > 1) {
          if (data[0].contains('+')) {
            final plusCode = data[0];
            data.removeAt(0);
            final val = plusCode.split(' ');
            if (val.length > 1 && !val[1].contains('+')) {
              if (event.isFromRoutePage == null) {
                selectedMyRouteAddress = '${val[1]} ${data.join(',')}';
              }
              currentLocation = '${val[1]} ${data.join(',')}';
            } else {
              if (event.isFromRoutePage == null) {
                selectedMyRouteAddress = data.join(',');
              }
              currentLocation = data.join(',');
            }
          } else {
            if (event.isFromRoutePage == null) {
              selectedMyRouteAddress = data.join(',');
            }
            currentLocation = data.join(',');
          }
        } else {
          if (event.isFromRoutePage == null) {
            selectedMyRouteAddress = success.address;
          }
          currentLocation = success.address;
        }
        selectedMyRouteLatLng = LatLng(event.lat, event.lng);

        showGetDropAddress = true;
        emit(UpdateState());
      });
    }
  }

  Future<void> getLatLngFromAddress(
      AccGeocodingAddressEvent event, Emitter<AccState> emit) async {
    if (mapType == 'google_map') {
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
            emit(UserUnauthenticatedState());
          } else {
            emit(ShowErrorState(message: error.message.toString()));
          }
        },
        (success) async {
          final position = success.position;

          // Update the UI with the new position
          selectedMyRouteLatLng = position;
          selectedMyRouteAddress = event.address;
          if (googleMapController != null) {
            googleMapController!
                .moveCamera(CameraUpdate.newLatLng(selectedMyRouteLatLng!));
          }
          searchController.clear();
          add(AccClearAutoCompleteEvent());
        },
      );
    } else {
      selectedMyRouteLatLng = event.position;
      selectedMyRouteAddress = event.address;
      fmController.move(
          fmlt.LatLng(event.position!.latitude, event.position!.longitude), 13);
      add(AccClearAutoCompleteEvent());
    }
  }

  Future<void> clearAutoComplete(
      AccClearAutoCompleteEvent event, Emitter<AccState> emit) async {
    autoSuggestionSearching = false;
    autoCompleteAddress.clear();
    searchController.clear();
    sessionToken = null;
    emit(UpdateState());
  }

  Future<void> getCurrentLocation(
      AccGetCurrentLocationEvent event, Emitter<AccState> emit) async {
    if (event.isFromRoutePage != null && event.isFromRoutePage!) {
      emit(MyRouteLoadingStartState());
    }
    await Permission.location.request();
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double long = position.longitude;
      currentLatLng = LatLng(lat, long);
      selectedMyRouteLatLng = currentLatLng;
      initialCameraPosition = CameraPosition(target: selectedMyRouteLatLng!);
      if (event.isFromRoutePage != null && event.isFromRoutePage!) {
        add(AccGeocodingLatLngEvent(
            lat: lat, lng: long, isFromRoutePage: event.isFromRoutePage));
      }
      if (googleMapController != null) {
        googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: selectedMyRouteLatLng!, zoom: 15)));
      }
      emit(UpdateState());
      if (event.isFromRoutePage != null && event.isFromRoutePage!) {
        emit(MyRouteLoadingStopState());
      }
    } else {
      showToast(
          message: AppLocalizations.of(navigatorKey.currentContext!)!
              .getYourCurrentLocation);
      if (event.isFromRoutePage != null && event.isFromRoutePage!) {
        emit(MyRouteLoadingStopState());
      }
    }
  }

  Future<void> getAutoCompleteAddress(
      AccGetAutoCompleteAddressEvent event, Emitter<AccState> emit) async {
    autoSuggestionSearching = true;
    emit(UpdateState());
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
        emit(UpdateState());
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
        emit(UpdateState());
      },
      (success) async {
        autoCompleteAddress.clear();
        autoCompleteAddress = success.predictions;

        emit(UpdateState());
      },
    );
    autoSuggestionSearching = false;
    emit(UpdateState());
  }

  FutureOr _referalHistory(
      ReferalHistoryEvent event, Emitter<AccState> emit) async {
    emit(ReferalHistoryLoadingState());
    final data = await serviceLocator<AccUsecase>().referalHistory();
    data.fold(
      (error) {
        emit(ReferalHistoryFailureState());
      },
      (success) async {
        if (success is historyModel.ReferralResponse) {
          referralHistory = success.data;
        }
        emit(ReferalHistorySuccessState());
      },
    );
  }

  FutureOr _referralResponse(
      ReferralResponseEvent event, Emitter<AccState> emit) async {
    emit(ReferralResponseLoadingState());
    final data = await serviceLocator<AccUsecase>().referalResponse();
    data.fold(
      (error) {
        emit(ReferralResponseFailureState());
      },
      (success) async {
        if (success is referralModel.ReferralResponseData) {
          referralResponse = success;
        }
        emit(ReferralResponseSuccessState());
      },
    );
  }
}
