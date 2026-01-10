// ignore_for_file: use_build_context_synchronously, library_prefixes

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/tobitmap.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/features/account/domain/models/referal_response_model.dart'
    as referralModel;
import 'package:restart_tagxi/features/account/domain/models/referalhistory_model.dart'
    as historyModel;
import 'package:restart_tagxi/features/account/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/features/account/domain/models/view_ticket_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../common/common.dart';
import '../../../core/utils/custom_loader.dart';
import '../../../core/utils/custom_text.dart';
import '../../../core/utils/functions.dart';
import '../../../di/locator.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookingpage/application/usecases/booking_usecase.dart';
import '../../bookingpage/domain/models/point_latlng.dart';
import '../../home/domain/models/contact_model.dart';
import '../../home/application/usecase/home_usecases.dart';
import '../../home/domain/models/stop_address_model.dart';
import '../../home/domain/models/user_details_model.dart';
import '../domain/models/admin_chat_history_model.dart';
import '../domain/models/admin_chat_model.dart';
import '../domain/models/card_list_model.dart';
import '../domain/models/faq_model.dart';
import '../domain/models/history_model.dart';
import '../domain/models/makecomplaint_model.dart';
import '../domain/models/notifications_model.dart';
import '../domain/models/payment_method_model.dart';
import '../domain/models/walletpage_model.dart';
import 'usecase/acc_usecases.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:file_picker/file_picker.dart';
part 'acc_event.dart';

part 'acc_state.dart';

class AccBloc extends Bloc<AccEvent, AccState> {
  final formKey = GlobalKey<FormState>();
  final paymentKey = GlobalKey();

  String textDirection = 'ltr';
  String languageCode = '';
  String profilePicture = '';
  String name = '';
  String mobile = '';
  String email = '';
  String gender = '';
  String profileImage = '';
  String country = '';
  String dialCode = '';
  String darkMapString = '';
  String lightMapString = '';
  String selectedGender = '';
  String chatId = '';
  String dropdownValue = 'user';
  String currentLocation = '';
  String webViewUrl = '';
  String mapType = '';
  String appVersion = '';
  String unSeenChatCount = '0';
  String? paymentUrl;
  String? selectedTicketTitle;
  String? selectedTicketTitleId;
  String? selectedTicketArea;
  String? selectedTicketAreaId;
  String? htmlString;

  Set<Polyline> polyline = {};
  LatLngBounds? bound;
  List<NotificationData> notificationDatas = [];
  List<HistoryData> historyList = [];
  List outstation = [];
  List outStationDriver = [];
  List<ComplaintList> complaintList = [];
  List<Marker> markers = [];
  List<LatLng> polylist = [];
  List<fmlt.LatLng> fmpoly = [];
  List<ReplyMessage> replyMessages = [];
  List<FavoriteLocationData> home = [];
  List<FavoriteLocationData> work = [];
  List<FavoriteLocationData> others = [];
  List<FavoriteLocationData> favAddressList = [];
  List<FaqData> faqDataList = [];
  List<WalletHistoryData> walletHistoryList = [];
  List<PaymentGateway> walletPaymentGatways = [];
  List<SavedCardDetails> savedCardsList = [];
  List<ServiceLocationData> serviceLocations = [];
  List<File> ticketAttachments = [];
  List<Attachment> viewAttachments = [];
  List<TicketNamesList> ticketNamesList = []; //support ticket
  List<TicketData> ticketList = [];
  List<SOSDatum> sosdata = [];
  List<ContactsModel> contactsList = [];
  List<ChatData> adminChatList = [];
  List<Conversation> adminChatHistory = [];
  List<AddressModel> selectedAddress = [];
  List<historyModel.Referral> referralHistory = [];
  referralModel.ReferralResponseData? referralResponse;
  List<String> genderOptions = [
    'Male',
    'Female',
    'Prefer not to say',
  ];
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

  // UserDetails
  TextEditingController updateController = TextEditingController();
  TextEditingController complaintController = TextEditingController();
  TextEditingController supportMessageReplyController = TextEditingController();
  TextEditingController supportDescriptionController = TextEditingController();
  TextEditingController newAddressController =
      TextEditingController(); //fav address
  TextEditingController walletAmountController = TextEditingController();
  TextEditingController transferPhonenumber = TextEditingController();
  TextEditingController transferAmount = TextEditingController();
  TextEditingController addSosNameController = TextEditingController();
  TextEditingController addSosMobileController = TextEditingController();
  TextEditingController adminchatText = TextEditingController();
  TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  bool isContainerClicked = false;
  bool loadMore = false;
  bool isArrow = true;
  bool paymentProcessComplete = false;
  bool paymentSuccess = false;
  bool addCardSuccess = false;
  bool sosInitLoading = false;
  bool isFavLoading = false;
  bool isSosLoading = false;
  bool firstLoad = true;
  bool isDarkTheme = false;
  bool isTicketSheetOpened = false;
  bool showRefresh = false;
  bool showReferralHistory = false;

  UserDetail? userData;
  HistoryData? historyData;
  DriverData? driverData;
  AddressModel? favNewAddress;
  SupportTicket? supportTicketData;
  WalletResponseModel? walletResponse;
  WalletPagination? walletPaginations;
  HistoryPagination? historyPaginations;
  NotificationPagination? notificationPaginations;

  int choosenFaqIndex = 0;
  int choosenMapIndex = 0;
  int selectedHistoryType = 0;
  int? choosenPaymentIndex = 0;
  int? selectedAmount;

  dynamic addMoney;
  dynamic isNewChat = 1;
  ContactsModel selectedContact = ContactsModel(name: '', number: '');
  ScrollController scrollController = ScrollController();
  GoogleMapController? googleMapController;
  final fm.MapController fmController = fm.MapController();

  WebViewController? webController;
  InAppWebViewController? inAppWebViewController;
  StreamSubscription<DatabaseEvent>? chatStream;
  StreamSubscription<DatabaseEvent>? outStationBidStream;

  PaymentAuthData? paymentAuthData;
  CardFormEditController? cardFormEditController;
  CardFieldInputDetails? cardDetails;

  AccBloc() : super(AccInitialState()) {
    on<AccUpdateEvent>((event, emit) => emit(UpdateState()));
    on<AccGetDirectionEvent>(getDirection);
    on<GetAppVersionEvent>(getAppVersion);
    on<ContainerClickedEvent>(_isClickChange);
    on<AccDataLoaderShowEvent>(showLoader);

    on<UpdateControllerWithDetailsEvent>(_updateControllerWithDetails);
    on<UserDetailsPageInitEvent>(_updateUserDetails);
    on<ReferalHistoryEvent>(_referalHistory);
    on<ReferralResponseEvent>(_referralResponse);
    on<ReferralTabChangeEvent>(_onReferralTabChange);

    //Notification
    on<NotificationGetEvent>(_getNotificationList);
    on<ClearAllNotificationsEvent>(_clearAllNotifications);
    on<DeleteNotificationEvent>(_deleteNotification);
    on<NotificationPageInitEvent>(notificationInitEvent);

    on<GetFaqListEvent>(_getFaqList);
    on<FaqOnTapEvent>(_selectedFaqIndex);
    on<ChooseMapOnTapEvent>(_selectedMapIndex);

    // History
    on<HistoryPageInitEvent>(historyInitEvent);
    on<HistoryGetEvent>(_getHistoryList);
    on<HistoryTypeChangeEvent>(_historyTypeChange);
    on<AddHistoryMarkerEvent>(addHistoryMarker);
    on<TripSummaryHistoryDataEvent>(tripSummaryHistoryDataGet);

    //Outstation
    on<OutstationGetEvent>(_getOutstationList);
    on<OutstationAcceptOrDeclineEvent>(outstationAcceptOrDecline);

    //Logout event
    on<LogoutEvent>(_logout);

    //Delete Account
    on<DeleteAccountEvent>(_deleteAccount);

    //Complaint page
    on<ComplaintEvent>(_getComplaints);
    on<ComplaintButtonEvent>(_complaintButton);
    on<SosLoadingEvent>(changeBoolSos);

    // Wallet PAge
    on<WalletPageInitEvent>(walletInitEvent);
    on<GetWalletHistoryListEvent>(_getWalletHistoryList);
    on<TransferMoneySelectedEvent>(_onTransferMoneySelected);
    on<MoneyTransferedEvent>(moneyTransfered);
    on<PaymentAuthenticationEvent>(paymentAuth);
    on<CardListEvent>(getCardList);
    on<DeleteCardEvent>(deleteCard);
    on<ShowPaymentGatewayEvent>(showPaymentGateways);
    on<AddCardDetailsEvent>(addCardDetails);
    on<AddMoneyFromCardEvent>(addMoneyFromCard);

    //gender list
    on<GenderSelectedEvent>(_onGenderSelected);
    on<DeleteContactEvent>(_deletesos);
    on<AccGetUserDetailsEvent>(getUserDetails);
    on<SelectContactDetailsEvent>(selectContactDetails);
    on<AddContactEvent>(addContactDetails);
    on<DeleteFavAddressEvent>(_deleteFavAddress);
    on<GetFavListEvent>(getFavList);
    on<SelectFromFavAddressEvent>(selectFavAddress);
    on<AddFavAddressEvent>(addFavourites);

    // update details
    on<UpdateUserDetailsEvent>(_updateTextField);
    on<UserDetailEditEvent>(userDetailEdit);
    on<SendAdminMessageEvent>(sendAdminChat);
    on<GetAdminChatHistoryListEvent>(_getAdminChatHistoryList);
    on<AdminMessageSeenEvent>(_adminMessageSeenDetail);

    //update profile
    on<UpdateImageEvent>(_getProfileImage);
    on<PaymentOnTapEvent>(_selectedPaymentIndex);
    on<RideLaterCancelRequestEvent>(cancelRequest);
    on<FavNewAddressInitEvent>(newFavAddress);
    on<UserDataInitEvent>(userDataInit);
    on<AddMoneyWebViewUrlEvent>(addMoneyWebViewUrl);

    on<SosInitEvent>(sosPageInit);
    on<AdminChatInitEvent>(adminChatInit);
    on<WalletPageReUpdateEvent>(walletPageReUpdate);
    on<OnlinePaymentDoneUserEvent>(onlinePaymentDoneUser);
    //Support Ticket
    on<CreateSupportTicketEvent>(createSupportTicket);
    on<MakeTicketSubmitEvent>(makeTicketSubmit);
    on<GetTicketListEvent>(getTicketList);
    on<ViewTicketEvent>(viewTicketData);
    on<AddAttachmentTicketEvent>(addAttachment);
    on<ClearAttachmentEvent>(clearAttachment);
    on<TicketReplyMessageEvent>(ticketMessageReply);
    on<TicketTitleChangeEvent>(assignSelectedTicketValue);
    on<TicketAreaChangeEvent>(assignSelectedTicketArea);
    on<GetServiceLocationEvent>(getServiceLocation);
    on<DownloadInvoiceEvent>(downloadInvoice);
    on<GetHtmlStringEvent>(getHtmlString);
  }

  //Get Direction
  Future<void> getDirection(AccEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    languageCode = await AppSharedPreference.getSelectedLanguageCode();
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

  void _onReferralTabChange(
      ReferralTabChangeEvent event, Emitter<AccState> emit) {
    showReferralHistory = event.showReferralHistory;
    emit(UpdateState());
  }

  Future<void> getAppVersion(AccEvent event, Emitter<AccState> emit) async {
    PackageInfo buildKeys = await PackageInfo.fromPlatform();
    appVersion = '${buildKeys.version}+${buildKeys.buildNumber}';
    emit(UpdateState());
  }

  FutureOr<void> walletPageReUpdate(
      WalletPageReUpdateEvent event, Emitter<AccState> emit) async {
    emit(WalletPageReUpdateState(
        currencySymbol: event.currencySymbol,
        money: event.money,
        requestId: event.requestId,
        url: event.url,
        userId: event.userId));
  }

  void _isClickChange(ContainerClickedEvent event, Emitter<AccState> emit) {
    isContainerClicked = !isContainerClicked;
    emit(ContainerClickState(isContainerClicked: isContainerClicked));
  }

//sos change type
  Future<void> changeBoolSos(AccEvent event, Emitter<AccState> emit) async {
    emit(SosLoadingState());

    await Future.delayed(const Duration(seconds: 2));

    emit(SosLoadedState());
  }

  Future<void> onlinePaymentDoneUser(
      OnlinePaymentDoneUserEvent event, Emitter<AccState> emit) async {
    FirebaseDatabase.instance.ref('requests').child(event.requestId).update({
      'is_user_paid': true,
      'modified_by_driver': ServerValue.timestamp,
    });
  }

  //Update userDetails controller
  Future<void> _updateControllerWithDetails(
      UpdateControllerWithDetailsEvent event, Emitter<AccState> emit) async {
    userData = event.args.userData;
    updateController.text = event.args.text;
    emit(UpdateState());
  }

  //Update User Details
  Future<void> _updateUserDetails(
      UserDetailsPageInitEvent event, Emitter<AccState> emit) async {
    userData = event.arg.userData;
    sosdata = event.arg.userData.sos.data;
    favAddressList = event.arg.userData.favouriteLocations.data;
    if (userData != null) {
      name = userData!.name;
      mobile = userData!.mobile;
      email = userData!.email;
      gender = userData!.gender;
      profilePicture = userData!.profilePicture;
    }
    emit(UserDetailsSuccessState(userData: userData));
  }

  Future<void> notificationInitEvent(
      NotificationPageInitEvent event, Emitter<AccState> emit) async {
    add(NotificationGetEvent());
    scrollController.addListener(notificationPageScrollListener);
    emit(UpdateState());
  }

  notificationPageScrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading &&
        !loadMore) {
      if (notificationPaginations != null &&
          notificationPaginations!.pagination != null &&
          notificationPaginations!.pagination.currentPage <
              notificationPaginations!.pagination.totalPages) {
        loadMore = true;
        add(AccUpdateEvent());
        add(NotificationGetEvent());
        add(AccUpdateEvent());
      } else {
        if (notificationPaginations!.pagination.currentPage ==
            notificationPaginations!.pagination.totalPages) {
          loadMore = false;
          add(AccUpdateEvent());
        }
      }
    }
  }

  // Get Notifications
  Future<void> _getNotificationList(
      NotificationGetEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(UpdateState());
    emit(AccDataLoadingStartState());
    try {
      final data = await serviceLocator<AccUsecase>()
          .notificationDetails(pageNo: event.pageNumber.toString());
      data.fold(
        (error) {
          isLoading = false;
          emit(UpdateState());
          emit(NotificationFailure(errorMessage: error.message ?? ""));
        },
        (success) {
          isLoading = false;
          emit(UpdateState());
          for (var i = 0; i < success.data.length; i++) {
            notificationDatas.add(success.data[i]);
          }
          notificationPaginations = success.meta;
          emit(NotificationSuccess(notificationDatas: notificationDatas));
        },
      );
    } catch (e) {
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

//ook
  Future<void> historyInitEvent(
      HistoryPageInitEvent event, Emitter<AccState> emit) async {
    firstLoad = true;
    isLoading = true;
    add(HistoryGetEvent(historyFilter: 'is_completed=1'));
    scrollController.addListener(historyPageScrollListener);
    emit(UpdateState());
  }

  historyPageScrollListener() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading &&
        !loadMore) {
      if (historyPaginations != null &&
          historyPaginations!.pagination != null &&
          historyPaginations!.pagination.currentPage <
              historyPaginations!.pagination.totalPages) {
        loadMore = true;
        add(AccUpdateEvent());
        add(HistoryGetEvent(
            pageNumber: historyPaginations!.pagination.currentPage + 1,
            historyFilter: (selectedHistoryType == 0)
                ? "is_completed=1"
                : (selectedHistoryType == 1)
                    ? "is_later=1"
                    : "is_cancelled=1"));
        // loadMore = false;
        add(AccUpdateEvent());
      } else {
        if (historyPaginations!.pagination.currentPage ==
            historyPaginations!.pagination.totalPages) {
          loadMore = false;
          add(AccUpdateEvent());
        }
      }
    }
  }

  // History
  Future<void> _getHistoryList(
      HistoryGetEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    if (event.pageNumber != null) {
      loadMore = true;
    } else {
      firstLoad = true;
    }
    emit(UpdateState());
    final data = await serviceLocator<AccUsecase>().historyDetails(
        event.historyFilter,
        pageNo: event.pageNumber.toString());
    data.fold(
      (error) {
        isLoading = false;
        emit(UpdateState());
        debugPrint('History Error: ${error.toString()}');
        emit(HistoryFailure(errorMessage: error.message ?? ""));
      },
      (success) {
        isLoading = false;
        loadMore = false;
        firstLoad = false;
        emit(UpdateState());
        if (event.pageNumber == null || event.pageNumber == 1) {
          historyList = success.data;
        } else {
          if (success.data.isNotEmpty) {
            historyList.addAll(success.data);
            List<HistoryData> historySetData = historyList.toSet().toList();
            historyList = historySetData;
          }
        }
        // history = success.data;
        historyPaginations = success.meta;
        if (event.historyIndex != null) {
          historyData = historyList[event.historyIndex!];
        }
        emit(HistorySuccess(history: historyList));
      },
    );
  }

  // Outstation
  Future<void> _getOutstationList(
      OutstationGetEvent event, Emitter<AccState> emit) async {
    if (outStationBidStream != null) {
      outStationBidStream?.cancel();
    }
    outStationBidStream = FirebaseDatabase.instance
        .ref()
        .child('bid-meta/${event.id}')
        .onValue
        .handleError((onError) {
      outStationBidStream?.cancel();
    }).listen(
      (DatabaseEvent event) {
        debugPrint("Outstation Bidding Stream");
        Map rideList = {};
        DataSnapshot snapshots = event.snapshot;
        if (snapshots.value != null) {
          rideList = jsonDecode(jsonEncode(snapshots.value));
          if (rideList['request_id'] != null) {
            if (rideList['drivers'] != null) {
              outstation.clear();
              outStationDriver.clear();
              Map driver = rideList['drivers'];
              driver.forEach((key, value) {
                if (driver[key]['is_rejected'] != 'by_driver' &&
                    driver[key]['is_rejected'] != 'by_user') {
                  outstation.add(value);
                  final dist = calculateDistance(
                    lat1: rideList['pick_lat'],
                    lon1: rideList['pick_lng'],
                    lat2: rideList['drivers'][key]['lat'],
                    lon2: rideList['drivers'][key]['lng'],
                    unit: userData?.distanceUnit ?? 'km',
                  );
                  outStationDriver.add(
                    dist.toStringAsFixed(2),
                  );
                } else {
                  outstation.removeWhere(
                      (element) => element["id"] == driver[key]["id"]);
                }
              });
              add(AccUpdateEvent());
            }
          }
        }
      },
    );
  }

  Future<void> outstationAcceptOrDecline(
      OutstationAcceptOrDeclineEvent event, Emitter<AccState> emit) async {
    if (event.isAccept) {
      final data = await serviceLocator<BookingUsecase>().biddingAccept(
          requestId: event.id,
          driverId: event.driver['driver_id'].toString(),
          acceptRideFare: event.driver['price'].toString(),
          offeredRideFare: event.offeredRideFare);
      await data.fold(
        (error) {
          isLoading = false;
          if (error.message == 'logout') {
            emit(UpdateState());
          } else {
            showToast(message: '${error.message}');
            emit(UpdateState());
          }
        },
        (success) async {
          emit(OutstationAcceptState());
          await FirebaseDatabase.instance
              .ref()
              .child('bid-meta/${event.id}')
              .remove();
        },
      );
    } else {
      await FirebaseDatabase.instance
          .ref()
          .child(
              'bid-meta/${event.id}/drivers/driver_${event.driver["driver_id"]}')
          .update({"is_rejected": 'by_user'});
      outstation.removeWhere(
          (element) => element["driver_id"] == event.driver["driver_id"]);
      emit(UpdateState());
    }
  }

  // Change History Type
  Future<void> _historyTypeChange(
      HistoryTypeChangeEvent event, Emitter<AccState> emit) async {
    selectedHistoryType = event.historyTypeIndex;
    String filter;
    switch (selectedHistoryType) {
      case 0:
        filter = 'is_completed=1';
        break;
      case 1:
        filter = 'is_later=1';
        break;
      case 2:
        filter = 'is_cancelled=1';
        break;
      default:
        filter = '';
    }
    emit(UpdateState());
    add(HistoryGetEvent(historyFilter: filter));
    // emit(HistoryTypeChangeState(selectedHistoryType: selectedHistoryType));
  }

  FutureOr<void> addHistoryMarker(
      AddHistoryMarkerEvent event, Emitter<AccState> emit) async {
    mapType = await AppSharedPreference.getMapType();
    if (mapType == 'google_map') {
      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId("pick"),
        position:
            LatLng(double.parse(event.pickLat), double.parse(event.pickLng)),
        icon: await Image.asset(
          AppImages.pickPin,
          height: 30,
          fit: BoxFit.contain,
        ).toBitmapDescriptor(
            logicalSize: const Size(20, 20), imageSize: const Size(200, 200)),
      ));
      if (event.stops!.isEmpty && event.dropLat != '') {
        markers.add(Marker(
          markerId: const MarkerId("drop"),
          position: LatLng(
              double.parse(event.dropLat!), double.parse(event.dropLng!)),
          icon: await Image.asset(
            AppImages.dropPin,
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
              AppImages.dropPin,
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
        mapBound(
            double.parse(event.pickLat),
            double.parse(event.pickLng),
            double.parse(event.dropLat!),
            double.parse(event.dropLng!),
            mapType);
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
        await decodeEncodedPolyline(event.polyline!, mapType);
      }
    } else {
      if (event.polyline != '') {
        await decodeEncodedPolyline(event.polyline!, mapType);
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

    emit(UpdateState());
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

  Future<void> _deleteNotificationById(String id) async {
    try {
      await serviceLocator<AccUsecase>().deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Logout
  Future<void> _logout(LogoutEvent event, Emitter<AccState> emit) async {
    emit(LogoutLoadingState());
    final data = await serviceLocator<AccUsecase>().logout();
    data.fold(
      (error) {
        debugPrint('Logout error: ${error.toString()}');
        emit(LogoutFailureState(errorMessage: error.toString()));
        emit(LogoutSuccess());
      },
      (success) {
        emit(LogoutSuccess());
      },
    );
  }

  // Delete account
  Future<void> _deleteAccount(
      DeleteAccountEvent event, Emitter<AccState> emit) async {
    emit(DeleteAccountLoadingState());
    final deleteResult = await serviceLocator<AccUsecase>().deleteUserAccount();
    deleteResult.fold(
      (error) {
        debugPrint('Delete Account error: ${error.toString()}');
        emit(DeleteAccountFailureState(errorMessage: error.message ?? ""));
      },
      (success) {
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
          isLoading = false;
          debugPrint('Outstation Error: ${error.toString()}');
          emit(MakeComplaintFailure(errorMessage: error.message ?? ""));
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
        debugPrint('Make Complaint Button error: ${failure.toString()}');
        emit(ComplaintButtonFailureState(errorMessage: failure.toString()));
      },
      (success) {
        emit(MakeComplaintButtonSuccess());
        complaintController.clear();
      },
    );
  }

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
        emit(FaqFailureState());
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

  Future<void> _selectedMapIndex(
      ChooseMapOnTapEvent event, Emitter<AccState> emit) async {
    choosenMapIndex = event.chooseMapIndex;
    final details = userData;
    if (event.chooseMapIndex == 0) {
      await AppSharedPreference.setMapType('google_map');
      if (details != null) {
        add(UpdateUserDetailsEvent(
            name: details.name,
            email: details.email,
            gender: details.gender,
            profileImage: '',
            mapType: 'google_map',
            mobile: details.mobile,
            country: details.countryCode));
      }
    } else {
      await AppSharedPreference.setMapType('open_street_map');
      if (details != null) {
        add(UpdateUserDetailsEvent(
            name: details.name,
            email: details.email,
            gender: details.gender,
            profileImage: '',
            mapType: 'open_street_map',
            mobile: details.mobile,
            country: details.countryCode));
      }
    }
    isAppMapChange = true;
    emit(ChooseMapSelectState(choosenMapIndex));
  }

  FutureOr<void> _getWalletHistoryList(
      GetWalletHistoryListEvent event, Emitter<AccState> emit) async {
    if (firstLoad) {
      emit(WalletHistoryLoadingState());
    }
    final data =
        await serviceLocator<AccUsecase>().getWalletDetail(event.pageIndex);
    data.fold(
      (error) {
        isLoading = false;
        firstLoad = false;
        emit(UpdateState());
        emit(WalletHistoryFailureState());
      },
      (success) {
        isLoading = false;
        loadMore = false;
        firstLoad = false;
        walletResponse = success;

        walletPaymentGatways = success.paymentGateways;
        if (event.pageIndex == 1) {
          walletHistoryList = success.walletHistory.data;
        } else {
          if (success.walletHistory.data.isNotEmpty) {
            walletHistoryList.addAll(success.walletHistory.data);
          }
        }
        walletPaginations = success.walletHistory.meta;
        emit(UpdateState());
        emit(WalletHistorySuccessState(walletHistoryDatas: walletHistoryList));
      },
    );
  }

  Future<void> walletInitEvent(
      WalletPageInitEvent event, Emitter<AccState> emit) async {
    userData = event.arg.userData;
    firstLoad = true;
    isLoading = true;
    transferPhonenumber.clear();
    transferAmount.clear();
    add(GetWalletHistoryListEvent(pageIndex: 1));
    scrollController.addListener(walletPageScrollListener);
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
        add(AccUpdateEvent());
        add(GetWalletHistoryListEvent(
            pageIndex: walletPaginations!.pagination.currentPage + 1));
      } else {
        if (walletPaginations!.pagination.currentPage ==
            walletPaginations!.pagination.totalPages) {
          loadMore = false;
          add(AccUpdateEvent());
        }
      }
    }
  }

  Future<void> _onTransferMoneySelected(
      TransferMoneySelectedEvent event, Emitter<AccState> emit) async {
    dropdownValue = event.selectedTransferAmountMenuItem;
    emit(TransferMoneySelectedState(
        selectedTransferAmountMenuItem: dropdownValue));
  }

  FutureOr<void> moneyTransfered(
      MoneyTransferedEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    isLoading = true;
    final data = await serviceLocator<AccUsecase>().moneyTransfer(
        transferMobile: event.transferMobile,
        role: event.role,
        transferAmount: event.transferAmount);
    data.fold(
      (error) {
        debugPrint(error.toString());
        isLoading = false;
        emit(MoneyTransferedFailureState());
        showToast(message: error.message.toString());
      },
      (success) {
        add(GetWalletHistoryListEvent(
            pageIndex: walletPaginations!.pagination.currentPage));
        isLoading = false;
        emit(MoneyTransferedSuccessState());

        // add(GetWalletHistoryListEvent());
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

  Future<void> getUserDetails(
      AccGetUserDetailsEvent event, Emitter<AccState> emit) async {
    // emit(AccDataLoadingState());
    final data = await serviceLocator<HomeUsecase>().userDetails();
    data.fold((error) {
      debugPrint(error.toString());
    }, (success) {
      if (isClosed) return;
      userData = success.data;
      sosdata = success.data.sos.data;
      favAddressList = success.data.favouriteLocations.data;
      if (!isClosed) {
        add(
          GetFavListEvent(userData: userData!, favAddressList: favAddressList),
        );
      }
      // emit(AccDataSuccessState());
    });
  }

  // Delete sos
  Future<void> _deletesos(
      DeleteContactEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>().deleteSosContact(event.id!);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(SosFailureState());
      },
      (success) {
        add(AccGetUserDetailsEvent());
        emit(SosDeletedSuccessState());
      },
    );
  }

  FutureOr<void> addContactDetails(
      AddContactEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    isLoading = true;
    final data = await serviceLocator<AccUsecase>()
        .addSosContact(name: event.name, number: event.number);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(AddContactFailureState());
      },
      (success) {
        isLoading = false;
        add(AccGetUserDetailsEvent());
        emit(AddContactSuccessState());
      },
    );
  }

  Future<void> selectContactDetails(
      SelectContactDetailsEvent event, Emitter<AccState> emit) async {
    await Permission.contacts.request();
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      emit(AccDataLoadingStartState());
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

      emit(AccDataLoadingStopState());
      emit(SelectContactDetailsState());
    } else {
      debugPrint("Permission Denied");
      bool isOpened = await openAppSettings();
      if (isOpened) {
      } else {}
      emit(GetContactPermissionState());
    }
  }

  Future<void> _updateTextField(
      UpdateUserDetailsEvent event, Emitter<AccState> emit) async {
    final result = await serviceLocator<AccUsecase>().updateDetailsButton(
      email: event.email,
      name: event.name,
      gender: event.gender,
      profileImage: event.profileImage,
      mobile: event.mobile,
      country: event.country,
      mapType: event.mapType,
    );
    result.fold(
      (failure) {
        debugPrint('Update Details: ${failure.toString()}');
        emit(UpdateUserDetailsFailureState());
      },
      (success) {
        emit(UserDetailsUpdatedState(
          name: success["data"]['name'] ?? '', //event.name,
          email: success["data"]['email'] ?? '', //event.email,
          gender: success["data"]['gender'] ?? '', //event.gender,
          profileImage:
              success["data"]['profile_picture'] ?? '', //event.profileImage,
        ));
        emit(UserDetailsButtonSuccess());
        emit(UpdateState());
      },
    );
  }

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
        mobile: mobile,
        country: country,
      ));
    }
  }

  Future<void> _deleteFavAddress(
      DeleteFavAddressEvent event, Emitter<AccState> emit) async {
    final data =
        await serviceLocator<AccUsecase>().deleteFavouritesAddress(event.id!);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(FavFailureState());
      },
      (success) {
        if (event.isHome) {
          home.removeWhere((element) => element.id == event.id);
        } else if (event.isWork) {
          work.removeWhere((element) => element.id == event.id);
        } else if (event.isOthers) {
          others.removeWhere((element) => element.id == event.id);
        }
        if (userData != null) {
          userData!.favouriteLocations.data
              .removeWhere((element) => element.id == event.id);
        }
        emit(FavDeletedSuccessState());
      },
    );
  }

  //Fav loc
  FutureOr<void> getFavList(
      GetFavListEvent event, Emitter<AccState> emit) async {
    userData = event.userData;
    isFavLoading = true;
    emit(FavoriteLoadingState());
    home.clear();
    work.clear();
    others.clear();
    if (event.favAddressList.isNotEmpty) {
      for (var e in event.favAddressList) {
        if (e.addressName == 'Work') {
          work.add(e);
        } else if (e.addressName == 'Home') {
          home.add(e);
        } else {
          others.add(e);
        }
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    isFavLoading = false;
    emit(FavoriteLoadedState());
    // emit(UpdateState());
  }

  FutureOr<void> selectFavAddress(
      SelectFromFavAddressEvent event, Emitter<AccState> emit) async {
    emit(SelectFromFavAddressState(addressType: event.addressType));
  }

  Future addFavourites(AddFavAddressEvent event, Emitter<AccState> emit) async {
    final data = await serviceLocator<AccUsecase>().addFavAddress(
        address: event.address,
        name: event.name,
        lat: event.lat,
        lng: event.lng);
    data.fold(
      (error) {
        debugPrint(error.toString());
        emit(AddFavAddressFailureState());
      },
      (success) {
        if (!event.isOther) {
          add(AccGetUserDetailsEvent());
        }
        emit(UpdateState());
      },
    );
  }

  FutureOr<void> userDetailEdit(
      UserDetailEditEvent event, Emitter<AccState> emit) async {
    emit(UserDetailEditState(header: event.header, text: event.text));
  }

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
        // add(GetAdminChatHistoryListEvent());
        emit(SendAdminMessageSuccessState());
      },
    );
  }

  FutureOr<void> _getAdminChatHistoryList(
      GetAdminChatHistoryListEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>().getAdminChatHistoryDetail();
    data.fold(
      (error) {
        emit(AdminChatHistoryFailureState());
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
        // if (adminChatList.isNotEmpty) {
        chatId = success.data.conversationId;
        // add(AdminMessageSeenEvent(chatId: chatId));
        // }
        if (adminChatList.isNotEmpty && chatStream == null) {
          streamAdminchat();
        }
        unSeenChatCount = '0';
        emit(AdminChatHistorySuccessState());
      },
    );
  }

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
          // adminChatList.add(jsonDecode(jsonEncode(event.snapshot.value)));
          adminChatList.add(ChatData.fromJson(value));
          add(AccUpdateEvent());
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
    });
  }

  FutureOr<void> _adminMessageSeenDetail(
      AdminMessageSeenEvent event, Emitter<AccState> emit) async {
    emit(UserProfileDetailsLoadingState());
    final data = await serviceLocator<AccUsecase>()
        .adminMessageSeenDetail(event.chatId!);
    data.fold(
      (error) {
        emit(AdminMessageSeenFailureState());
      },
      (success) {
        emit(AdminMessageSeenSuccessState());
      },
    );
  }

  Future<void> _selectedPaymentIndex(
      PaymentOnTapEvent event, Emitter<AccState> emit) async {
    choosenPaymentIndex = event.selectedPaymentIndex;
    emit(PaymentSelectState(choosenPaymentIndex!));
  }

  FutureOr cancelRequest(
      RideLaterCancelRequestEvent event, Emitter<AccState> emit) async {
    emit(AccDataLoadingStartState());
    final data = await serviceLocator<BookingUsecase>()
        .cancelRequest(requestId: event.requestId, reason: event.reason);
    data.fold((error) {
      debugPrint(error.toString());
      emit(AccDataLoadingStopState());
    }, (success) {
      emit(AccDataLoadingStopState());
      historyList.removeWhere((value) => value.id == event.requestId);
      emit(RequestCancelState());
    });
  }

  FutureOr newFavAddress(
      FavNewAddressInitEvent event, Emitter<AccState> emit) async {
    favNewAddress = event.arg.selectedAddress;
    userData = event.arg.userData;
    emit(UpdateState());
  }

  FutureOr addMoneyWebViewUrl(
      AddMoneyWebViewUrlEvent event, Emitter<AccState> emit) async {
    if (event.from == '1') {
      paymentUrl =
          '${event.url}?amount=${event.money}&payment_for=request&currency=${event.currencySymbol}&user_id=${event.userId.toString()}&request_id=${event.requestId.toString()}';
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
  }

  Future<void> userDataInit(
      UserDataInitEvent event, Emitter<AccState> emit) async {
    userData = event.userDetails;
    // sosdata = userData!.sos.data;
    // favAddressList = userData!.favouriteLocations.data;
    // add(GetFavListEvent(userData: userData!, favAddressList: favAddressList));
    emit(UpdateState());
  }

  Future<void> sosPageInit(SosInitEvent event, Emitter<AccState> emit) async {
    isSosLoading = true;
    emit(UpdateState());
    sosdata = event.arg.sosData;
    await Future.delayed(const Duration(microseconds: 300));
    isSosLoading = false;
    emit(UpdateState());
  }

  Future<void> adminChatInit(
      AdminChatInitEvent event, Emitter<AccState> emit) async {
    userData = event.arg.userData;
    emit(UpdateState());
    add(GetAdminChatHistoryListEvent());
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
                      name: userData!.username, phone: userData!.mobile))));

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
        amount: event.amount, cardToken: event.cardToken);
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

  Future<List<PointLatLng>> decodeEncodedPolyline(
      String encoded, String mapType) async {
    polylist.clear();
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    polyline.clear();

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

  mapBound(pickLat, pickLng, dropLat, dropLng, mapType) {
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

  Future<void> makeTicketSubmit(
      MakeTicketSubmitEvent event, Emitter<AccState> emit) async {
    isLoading = true;
    emit(UpdateState());
    final data = await serviceLocator<AccUsecase>().makeTicket(
        titleId: event.titleId,
        description: event.description,
        serviceLocationId: event.serviceLocationId,
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

  FutureOr<void> getServiceLocation(
      GetServiceLocationEvent event, Emitter<AccState> emit) async {
    if (serviceLocations.isEmpty) {
      final data = await serviceLocator<AccUsecase>().getServiceLocation();
      data.fold(
        (error) {
          debugPrint(error.toString());
        },
        (success) {
          serviceLocations = success.data;
          emit(UpdateState());
        },
      );
    }
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

  Future<void> assignSelectedTicketArea(
      TicketAreaChangeEvent event, Emitter<AccState> emit) async {
    selectedTicketArea = event.changedArea;
    selectedTicketAreaId = event.id;
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
