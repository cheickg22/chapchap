part of 'acc_bloc.dart';

abstract class AccEvent {}

class AccGetUserDetailsEvent extends AccEvent {}

class AccGetDirectionEvent extends AccEvent {}

class AddHistoryMarkerEvent extends AccEvent {
  final List? stops;
  final String pickLat;
  final String pickLng;
  final String? dropLat;
  final String? dropLng;
  final String? polyline;

  AddHistoryMarkerEvent(
      {this.stops,
      required this.pickLat,
      required this.pickLng,
      this.dropLat,
      this.dropLng,
      this.polyline});
}

class SosInitEvent extends AccEvent {
  final SOSPageArguments arg;

  SosInitEvent({required this.arg});
}

class OnTapChangeEvent extends AccEvent {}

class IsEditPage extends AccEvent {}

class NavigateToEditPageEvent extends AccEvent {}

// class GetUserProfileDetailsEvent extends AccEvent {}

class GetWithdrawDataEvent extends AccEvent {
  final int pageIndex;

  GetWithdrawDataEvent({required this.pageIndex});
}

class GetWithdrawInitEvent extends AccEvent {}

class RequestWithdrawEvent extends AccEvent {
  final String amount;

  RequestWithdrawEvent({required this.amount});
}

class UpdateControllerWithDetailsEvent extends AccEvent {
  final UpdateDetailsArguments args;

  UpdateControllerWithDetailsEvent({required this.args});
}

class GetFleetDashboardEvent extends AccEvent {
  final String fleetId;

  GetFleetDashboardEvent({required this.fleetId});
}

class GetDriverPerformanceEvent extends AccEvent {
  final String driverId;

  GetDriverPerformanceEvent({required this.driverId});
}

class UpdateDetailsEvent extends AccEvent {
  final String? name;
  final String? mail;

  UpdateDetailsEvent({
    required this.name,
    required this.mail,
  });
}

class UpdateTextFieldEvent extends AccEvent {
  final String text;
  final UpdateDetailsArguments arg;

  UpdateTextFieldEvent({required this.text, required this.arg});
}

class UpdateUserNameEvent extends AccEvent {
  final String name;

  UpdateUserNameEvent({required this.name});
}

class UpdateUserEmailEvent extends AccEvent {
  final String email;

  UpdateUserEmailEvent({required this.email});
}

class UpdateUserGenderEvent extends AccEvent {
  final String gender;

  UpdateUserGenderEvent({required this.gender});
}

class UserDetailsPageInitEvent extends AccEvent {
  final AccountPageArguments arg;

  UserDetailsPageInitEvent({required this.arg});
}

class NotificationGetEvent extends AccEvent {
  final int? pageNumber;

  NotificationGetEvent({this.pageNumber});
}

class ComplaintEvent extends AccEvent {
  final String? complaintType;

  ComplaintEvent({this.complaintType});
}

class NotificationLoading extends AccEvent {}

class GetBankDetails extends AccEvent {}

class DeleteNotificationEvent extends AccEvent {
  final String id;

  DeleteNotificationEvent({required this.id});
}

class ClearAllNotificationsEvent extends AccEvent {}

class HistoryGetEvent extends AccEvent {
  final String historyFilter;
  final int? pageNumber;
  final int? typeIndex;
  final int? historyIndex;
  final bool? isFrom;

  HistoryGetEvent(
      {required this.historyFilter,
      this.pageNumber,
      this.typeIndex,
      this.historyIndex,
      this.isFrom});
}

class AddBankEvent extends AccEvent {
  final int? choosen;

  AddBankEvent({
    required this.choosen,
  });
}

class EditBankEvent extends AccEvent {
  final int? choosen;

  EditBankEvent({
    required this.choosen,
  });
}

class UpdateBankDetailsEvent extends AccEvent {
  final dynamic body;

  UpdateBankDetailsEvent({required this.body});
}

class OutstationReadyToPickupEvent extends AccEvent {
  final String requestId;

  OutstationReadyToPickupEvent({required this.requestId});
}

class DriverLevelnitEvent extends AccEvent {}

class DriverLevelGetEvent extends AccEvent {
  final int pageNo;

  DriverLevelGetEvent({required this.pageNo});
}

class LogoutEvent extends AccEvent {}

class GetFaqListEvent extends AccEvent {}

class FaqOnTapEvent extends AccEvent {
  final int selectedFaqIndex;

  FaqOnTapEvent({required this.selectedFaqIndex});
}

class UpdateUserDetailsEvent extends AccEvent {
  final String name;
  final String email;
  final String gender;
  final String profileImage;
  final String? mapType;
  final String? mobile;
  final String? country;

  UpdateUserDetailsEvent(
      {required this.name,
      required this.email,
      required this.gender,
      required this.profileImage,
      this.mapType,
      this.mobile,
      this.country});
}

class GenderSelectedEvent extends AccEvent {
  final String selectedGender;

  GenderSelectedEvent({required this.selectedGender});
}

class ChooseMapOnTapEvent extends AccEvent {
  final int chooseMapIndex;

  ChooseMapOnTapEvent({required this.chooseMapIndex});
}

class ComplaintButtonEvent extends AccEvent {
  final String complaintTitleId;
  final String complaintText;
  final String requestId;

  ComplaintButtonEvent(
      {required this.complaintTitleId,
      required this.complaintText,
      required this.requestId});
}

class DeleteAccountEvent extends AccEvent {}

class ReferalHistoryEvent extends AccEvent {}

class ReferralTabChangeEvent extends AccEvent {
  final bool showReferralHistory;

  ReferralTabChangeEvent({required this.showReferralHistory});
}

class HistoryTypeChangeEvent extends AccEvent {
  final int historyTypeIndex;

  HistoryTypeChangeEvent({required this.historyTypeIndex});
}

class GetWalletHistoryListEvent extends AccEvent {
  final int pageIndex;

  GetWalletHistoryListEvent({required this.pageIndex});
}

class GetSubscriptionListEvent extends AccEvent {}

class SubscribeToPlanEvent extends AccEvent {
  final int paymentOpt;
  final int amount;
  final int planId;

  SubscribeToPlanEvent(
      {required this.paymentOpt, required this.amount, required this.planId});
}

class SubscriptionOnTapEvent extends AccEvent {
  final int selectedPlanIndex;

  SubscriptionOnTapEvent({required this.selectedPlanIndex});
}

class SubscriptionPaymentOnTapEvent extends AccEvent {
  final int selectedPayIndex;

  SubscriptionPaymentOnTapEvent({required this.selectedPayIndex});
}

class ChoosePlanEvent extends AccEvent {
  final bool isPlansChoosed;

  ChoosePlanEvent({required this.isPlansChoosed});
}

class WalletEmptyEvent extends AccEvent {}

class GetWalletInitEvent extends AccEvent {}

class TransferMoneySelectedEvent extends AccEvent {
  final String selectedTransferAmountMenuItem;

  TransferMoneySelectedEvent({required this.selectedTransferAmountMenuItem});
}

class MoneyTransferedEvent extends AccEvent {
  final String transferMobile;
  final String role;
  final String transferAmount;

  MoneyTransferedEvent(
      {required this.transferMobile,
      required this.role,
      required this.transferAmount});
}

class DeleteContactEvent extends AccEvent {
  final String? id;

  DeleteContactEvent({required this.id});
}

class SelectContactDetailsEvent extends AccEvent {}

class AddContactEvent extends AccEvent {
  final String name;
  final String number;

  AddContactEvent({required this.name, required this.number});
}

class UpdateEvent extends AccEvent {}

class DeleteFavAddressEvent extends AccEvent {
  final String? id;

  DeleteFavAddressEvent({required this.id});
}

class GetFavListEvent extends AccEvent {}

class FavPageInitEvent extends AccEvent {}

class SelectFromFavAddressEvent extends AccEvent {
  final String addressType;

  SelectFromFavAddressEvent({required this.addressType});
}

class AddFavAddressEvent extends AccEvent {
  final String address;
  final String name;
  final String lat;
  final String lng;

  AddFavAddressEvent(
      {required this.address,
      required this.name,
      required this.lat,
      required this.lng});
}

class UserDetailEditEvent extends AccEvent {
  final String header;
  final String text;

  UserDetailEditEvent({required this.header, required this.text});
}

class UserDetailEvent extends AccEvent {}

class SendAdminMessageEvent extends AccEvent {
  final String newChat;
  final String message;
  final String chatId;

  SendAdminMessageEvent(
      {required this.newChat, required this.message, required this.chatId});
}

class GetAdminChatHistoryListEvent extends AccEvent {}

class PickImageFromGalleryEvent extends AccEvent {}

class PickImageFromCameraEvent extends AccEvent {}

class AdminMessageSeenEvent extends AccEvent {
  final String? chatId;

  AdminMessageSeenEvent({required this.chatId});
}

class GetOwnerDashboardEvent extends AccEvent {}

class UpdateImageEvent extends AccEvent {
  final String name;
  final String email;
  final String gender;
  final ImageSource source;

  UpdateImageEvent({
    required this.name,
    required this.email,
    required this.gender,
    required this.source,
  });
}

class GetLeaderBoardEvent extends AccEvent {
  final int type;

  GetLeaderBoardEvent({required this.type});
}

class LanguageGetEvent extends AccEvent {}

class FavLocateMeEvent extends AccEvent {}

class PaymentOnTapEvent extends AccEvent {
  final int selectedPaymentIndex;

  PaymentOnTapEvent({required this.selectedPaymentIndex});
}

class RideLaterCancelRequestEvent extends AccEvent {
  final String requestId;

  RideLaterCancelRequestEvent({
    required this.requestId,
  });
}

class UserDataInitEvent extends AccEvent {
  final UserDetail? userDetails;

  UserDataInitEvent({required this.userDetails});
}

class AddMoneyWebViewUrlEvent extends AccEvent {
  dynamic from;
  dynamic url;
  dynamic userId;
  dynamic requestId;
  dynamic currencySymbol;
  dynamic money;
  dynamic planId;
  BuildContext context;

  AddMoneyWebViewUrlEvent(
      {this.url,
      this.from,
      this.userId,
      this.requestId,
      this.currencySymbol,
      this.money,
      this.planId,
      required this.context});
}

class AddDriverEvent extends AccEvent {}

class GetVehiclesEvent extends AccEvent {}

class GetUserDetailsEvent extends AccEvent {}

class ChangeEarningsWeekEvent extends AccEvent {
  final int week;

  ChangeEarningsWeekEvent({required this.week});
}

class GetDailyEarningsEvent extends AccEvent {
  final String date;

  GetDailyEarningsEvent({required this.date});
}

class GetEarningsEvent extends AccEvent {}

class GetDriverEvent extends AccEvent {
  int from;
  String? fleetId;

  GetDriverEvent({required this.from, this.fleetId});
}

class DeleteDriverEvent extends AccEvent {
  String driverId;

  DeleteDriverEvent({required this.driverId});
}

class AssignDriverEvent extends AccEvent {
  String driverId;
  String fleetId;

  AssignDriverEvent({required this.driverId, required this.fleetId});
}

class SosLoadingEvent extends AccEvent {}

class NotificationLoadingEvent extends AccEvent {}

class WalletPageReUpdateEvent extends AccEvent {
  String from;
  String url;
  String userId;
  String requestId;
  String currencySymbol;
  String money;
  String planId;

  WalletPageReUpdateEvent({
    required this.from,
    required this.url,
    required this.userId,
    required this.requestId,
    required this.currencySymbol,
    required this.money,
    required this.planId,
  });
}

class GetIncentiveEvent extends AccEvent {
  final int type;

  GetIncentiveEvent({
    required this.type,
  });
}

class SelectIncentiveDateEvent extends AccEvent {
  final String selectedDate;
  final bool isSelected;
  final int choosenIndex;

  SelectIncentiveDateEvent(
      {required this.selectedDate,
      required this.isSelected,
      required this.choosenIndex});
}

class DriverLevelPopupEvent extends AccEvent {
  final LevelDetails driverLevelList;

  DriverLevelPopupEvent({required this.driverLevelList});
}

class DriverRewardGetEvent extends AccEvent {
  final int pageNo;

  DriverRewardGetEvent({required this.pageNo});
}

class DriverGetInitEvent extends AccEvent {}

class DriverRewardInitEvent extends AccEvent {}

class DriverRewardPointsEvent extends AccEvent {}

class RedeemPointsEvent extends AccEvent {
  final String amount;

  RedeemPointsEvent({required this.amount});
}

class ReportSubmitEvent extends AccEvent {
  final String fromDate;
  final String toDate;

  ReportSubmitEvent({required this.fromDate, required this.toDate});
}

class ReportClearEvent extends AccEvent {}

class HowItWorksEvent extends AccEvent {}

class UpdateRedeemedAmountEvent extends AccEvent {
  final double? redeemedAmount;

  UpdateRedeemedAmountEvent({required this.redeemedAmount});
}

class ChooseDateEvent extends AccEvent {
  final BuildContext context;
  final bool isFromDate;

  ChooseDateEvent({required this.context, required this.isFromDate});
}

class AddCardDetailsEvent extends AccEvent {
  BuildContext context;

  AddCardDetailsEvent({
    required this.context,
  });
}

class CardListEvent extends AccEvent {}

class DeleteCardEvent extends AccEvent {
  final String cardId;

  DeleteCardEvent({required this.cardId});
}

class PaymentAuthenticationEvent extends AccEvent {
  final PaymentMethodArguments arg;

  PaymentAuthenticationEvent({required this.arg});
}

class ShowPaymentGatewayEvent extends AccEvent {}

class AddMoneyFromCardEvent extends AccEvent {
  final String amount;
  final String cardToken;
  final String? planId;

  AddMoneyFromCardEvent(
      {required this.amount, required this.cardToken, this.planId});
}

class CreateSupportTicketEvent extends AccEvent {
  final bool isFromRequest;
  final String requestId;
  final int? index;
  final int? pageNumber;

  CreateSupportTicketEvent({
    required this.isFromRequest,
    required this.requestId,
    this.index,
    this.pageNumber,
  });
}

class MakeTicketSubmitEvent extends AccEvent {
  final String titleId;
  final String description;
  final List<File> attachement;
  final String requestId;
  final bool isFromRequest;
  final int? index;
  final int? pageNumber;

  MakeTicketSubmitEvent(
      {required this.titleId,
      required this.description,
      required this.attachement,
      required this.requestId,
      required this.isFromRequest,
      this.index,
      this.pageNumber});
}

class TicketTitleChangeEvent extends AccEvent {
  final String changedTitle;
  final String id;

  TicketTitleChangeEvent({required this.changedTitle, required this.id});
}

class GetTicketListEvent extends AccEvent {
  final bool isFromAcc;

  GetTicketListEvent({required this.isFromAcc});
}

class ViewTicketEvent extends AccEvent {
  final String id;

  ViewTicketEvent({required this.id});
}

class AddAttachmentTicketEvent extends AccEvent {
  final BuildContext context;

  AddAttachmentTicketEvent({required this.context});
}

class ClearAttachmentEvent extends AccEvent {}

class TicketReplyMessageEvent extends AccEvent {
  final BuildContext context;
  final String messageText;
  final String id;

  TicketReplyMessageEvent(
      {required this.messageText, required this.id, required this.context});
}

class TripSummaryHistoryDataEvent extends AccEvent {
  final HistoryData tripHistoryData;

  TripSummaryHistoryDataEvent({required this.tripHistoryData});
}

class DownloadInvoiceEvent extends AccEvent {
  final String requestId;

  DownloadInvoiceEvent({required this.requestId});
}

class AccDataLoaderShowEvent extends AccEvent {
  final bool showLoader;

  AccDataLoaderShowEvent({required this.showLoader});
}

class GetHtmlStringEvent extends AccEvent {
  final bool isPrivacy;

  GetHtmlStringEvent({required this.isPrivacy});
}

class ToggleSearchVisibilityEvent extends AccEvent {
  final bool showSearch;

  ToggleSearchVisibilityEvent(this.showSearch);
}

//my route address update

class MyRouteAddressUpdateEvent extends AccEvent {
  final double myRouteLat;
  final double myRouteLng;
  final String myRouteAddress;

  MyRouteAddressUpdateEvent({
    required this.myRouteLat,
    required this.myRouteLng,
    required this.myRouteAddress,
  });
}

class EnableMyRouteBookingEvent extends AccEvent {
  final bool isEnable;
  final double currentLat;
  final double currentLng;
  final String currentLatLng;

  EnableMyRouteBookingEvent({
    required this.isEnable,
    required this.currentLat,
    required this.currentLng,
    required this.currentLatLng,
  });
}

class AccGeocodingLatLngEvent extends AccEvent {
  final double lat;
  final double lng;
  final bool? isFromRoutePage;
  AccGeocodingLatLngEvent(
      {required this.lat, required this.lng, this.isFromRoutePage});
}

class AccGeocodingAddressEvent extends AccEvent {
  final String placeId;
  final String address;
  final LatLng? position;
  AccGeocodingAddressEvent(
      {required this.placeId, required this.address, this.position});
}

class AccClearAutoCompleteEvent extends AccEvent {}

class AccGetCurrentLocationEvent extends AccEvent {
  final bool? isFromRoutePage;

  AccGetCurrentLocationEvent({this.isFromRoutePage});
}

class AccGetAutoCompleteAddressEvent extends AccEvent {
  final String searchText;

  AccGetAutoCompleteAddressEvent({required this.searchText});
}

class RouteBookingInitEvent extends AccEvent {
  final String address;

  RouteBookingInitEvent({required this.address});
}

//referal response
class ReferralResponseEvent extends AccEvent {}
