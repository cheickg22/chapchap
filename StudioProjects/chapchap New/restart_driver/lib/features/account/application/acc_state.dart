part of 'acc_bloc.dart';

abstract class AccState {}

class AccInitialState extends AccState {}

class AccDataSuccessState extends AccState {}

class AccDataLoadingStartState extends AccState {}

class AccDataLoadingStopState extends AccState {}

class UserProfileDetailsLoadingState extends AccState {}

class IsEditPageState extends AccState {
  final bool isEditPage;

  IsEditPageState({required this.isEditPage});
}

class GenderSelectedState extends AccState {
  final String selectedGender;

  GenderSelectedState({required this.selectedGender});
}

class UserDetailsUpdatedState extends AccState {
  final String name;
  final String email;
  final String gender;
  final String profileImage;

  UserDetailsUpdatedState(
      {required this.name,
      required this.email,
      required this.gender,
      required this.profileImage});
}

class UserDetailsSuccessState extends AccState {
  final UserDetail? userData;

  UserDetailsSuccessState({this.userData});
}

class NotificationFailure extends AccState {
  final String errorMessage;

  NotificationFailure({required this.errorMessage});
}

class WithdrawDataLoadingStartState extends AccState {}

class WithdrawDataLoadingStopState extends AccState {}

class PermissionDeniedState extends AccState {
  final String message;

  PermissionDeniedState({required this.message});
}

class UpdateDetailsFailureState extends AccState {
  final String errorMessage;

  UpdateDetailsFailureState({required this.errorMessage});
}

class HistoryFailure extends AccState {
  final String errorMessage;

  HistoryFailure({required this.errorMessage});
}

class LogoutFailure extends AccState {
  final String errorMessage;

  LogoutFailure({required this.errorMessage});
}

class OutstationFailure extends AccState {
  final String errorMessage;

  OutstationFailure({required this.errorMessage});
}

class MakeComplaintFailure extends AccState {
  final String errorMessage;

  MakeComplaintFailure({required this.errorMessage});
}

class ComplaintButtonFailureState extends AccState {
  final String errorMessage;

  ComplaintButtonFailureState({required this.errorMessage});
}

class UpdateUserDetailsButtonFailureState extends AccState {
  final String errorMessage;

  UpdateUserDetailsButtonFailureState({required this.errorMessage});
}

class NotificationSuccess extends AccState {
  final List<NotificationData>? notificationDatas;

  NotificationSuccess({required this.notificationDatas});
}

class HistorySuccess extends AccState {
  final List<HistoryData>? history;

  HistorySuccess({required this.history});
}

class UpdatedUserDetailsState extends AccState {
  final UserDetail updatedUserData;

  UpdatedUserDetailsState({required this.updatedUserData});
}

class LogoutSuccess extends AccState {}

class ImageUpdateState extends AccState {
  final String profileImage;

  ImageUpdateState({required this.profileImage});
}

class MakeComplaintButtonSuccess extends AccState {}

class ImageUpdateFailureState extends AccState {}

class ShowErrorState extends AccState {
  final String message;
  ShowErrorState({required this.message});
}

class BankUpdateSuccessState extends AccState {}

class UserDetailsButtonSuccess extends AccState {}

class DeleteAccountSuccess extends AccState {}

class UpdateUserDetailsSuccessState extends AccState {}

class UpdateUserDetailsFailureState extends AccState {}

class OutstationSuccess extends AccState {}

class OutstationReadyToPickupState extends AccState {}

class MakeComplaintSuccess extends AccState {
  final List<ComplaintList>? complaintList;

  MakeComplaintSuccess({required this.complaintList});
}

class MarkerSuccessState extends AccState {}

class NotificationClearedSuccess extends AccState {}

class NotificationDeletedSuccess extends AccState {}

class LogoutLoadingState extends AccState {}

class ComplaintButtonLoadingState extends AccState {}

class UpdateUserDetailsLoadingState extends AccState {}

class DeleteAccountLoadingState extends AccState {}

class LogoutFailureState extends AccState {
  final String errorMessage;

  LogoutFailureState({required this.errorMessage});
}

final class ChooseMApSelectState extends AccState {
  final int selectedMapIndex;

  ChooseMApSelectState(this.selectedMapIndex);

  List<Object> get props => [selectedMapIndex];
}

class MakeComplaintFailureState extends AccState {
  final String errorMessage;

  MakeComplaintFailureState({required this.errorMessage});
}

class DeleteAccountFailureState extends AccState {
  final String errorMessage;

  DeleteAccountFailureState({required this.errorMessage});
}

class HistoryTypeChangeState extends AccState {
  final int selectedHistoryType;

  HistoryTypeChangeState({required this.selectedHistoryType});
}

final class FaqSuccessState extends AccState {}

final class FaqFailureState extends AccState {}

final class FaqLoadingState extends AccState {}

final class FaqSelectState extends AccState {
  final int selectedIndex;

  FaqSelectState(this.selectedIndex);

  List<Object> get props => [selectedIndex];
}

final class UserProfileDetailsFailureState extends AccState {}

class WalletHistorySuccessState extends AccState {
  final List<WalletHistoryData>? walletHistoryDatas;

  WalletHistorySuccessState({required this.walletHistoryDatas});
}

final class WalletHistoryFailureState extends AccState {}

final class WalletHistoryLoadingState extends AccState {}

class TransferMoneySelectedState extends AccState {
  final String selectedTransferAmountMenuItem;

  TransferMoneySelectedState({required this.selectedTransferAmountMenuItem});
}

final class MoneyTransferedSuccessState extends AccState {}

final class MoneyTransferedFailureState extends AccState {}

final class MoneyTransferedLoadingState extends AccState {}

class SosDeletedSuccessState extends AccState {}

class SosFailureState extends AccState {}

final class GetContactPermissionState extends AccState {}

final class SelectContactDetailsState extends AccState {}

final class AddContactSuccessState extends AccState {}

final class AddContactFailureState extends AccState {}

final class AddContactLoadingState extends AccState {}

final class UpdateState extends AccState {}

class FavDeletedSuccessState extends AccState {}

class FavFailureState extends AccState {}

final class SelectFromFavAddressState extends AccState {
  final String addressType;

  SelectFromFavAddressState({required this.addressType});
}

final class AddFavAddressSuccessState extends AccState {}

final class AddFavAddressFailureState extends AccState {}

final class AddFavAddressLoadingState extends AccState {}

final class UserDetailEditState extends AccState {
  final String header;
  final String text;

  UserDetailEditState({required this.header, required this.text});
}

final class UserDetailState extends AccState {}

final class SendAdminMessageSuccessState extends AccState {}

final class SendAdminMessageFailureState extends AccState {}

final class SendAdminMessageLoadingState extends AccState {}

final class AdminChatHistorySuccessState extends AccState {}

final class AdminChatHistoryFailureState extends AccState {}

final class AdminChatHistoryLoadingState extends AccState {}

class ImagePickedState extends AccState {
  final String imagePath;

  ImagePickedState({required this.imagePath});
}

final class AdminMessageSeenSuccessState extends AccState {}

final class AdminMessageSeenFailureState extends AccState {}

final class LanguageInitialState extends AccState {}

final class LanguageLoadingState extends AccState {}

final class LanguageFailureState extends AccState {}

final class LanguageSuccessState extends AccState {}

final class LanguageUpdateState extends AccState {}

final class EarningsLoadingStartState extends AccState {}

final class EarningsLoadingStopState extends AccState {}

final class DataChangedState extends AccState {}

class DriversLoadingStopState extends AccState {}

class DriversLoadingStartState extends AccState {}

class ShowAssignDriverState extends AccState {}

class MakeComplaintLoading extends AccState {}

final class RequestCancelState extends AccState {}

class VehiclesLoadingStopState extends AccState {}

class VehiclesLoadingStartState extends AccState {}

class PaymentSuccessState extends AccState {}

class GetUrlSuccessState extends AccState {}

class PaymentFailureState extends AccState {}

final class AddMoneyWebViewUrlState extends AccState {
  dynamic from;
  dynamic url;
  dynamic userId;
  dynamic requestId;
  dynamic currencySymbol;
  dynamic money;

  AddMoneyWebViewUrlState(
      {this.url,
      this.from,
      this.userId,
      this.requestId,
      this.currencySymbol,
      this.money});
}

class HistoryDataSuccessState extends AccState {}

class HistoryDataLoadingState extends AccState {}

final class FavLocateMeState extends AccState {}

final class PaymentSelectState extends AccState {
  final int selectedIndex;

  PaymentSelectState(this.selectedIndex);
}

class WalletPageReUpdateState extends AccState {
  String url;
  String userId;
  String requestId;
  String currencySymbol;
  String money;
  String planId;

  WalletPageReUpdateState({
    required this.url,
    required this.userId,
    required this.requestId,
    required this.currencySymbol,
    required this.money,
    required this.planId,
  });
}

final class DashboardLoadingStartState extends AccState {}

final class DashboardLoadingStopState extends AccState {}

final class FleetDashboardLoadingStartState extends AccState {}

final class FleetDashboardLoadingStopState extends AccState {}

final class DriverPerformanceLoadingStartState extends AccState {}

final class DriverPerformanceLoadingStopState extends AccState {}

final class LeaderBoardLoadingStartState extends AccState {}

final class UserUnauthenticatedState extends AccState {}

final class LeaderBoardLoadingStopState extends AccState {}

class SosLoadingState extends AccState {}

class SosLoadedState extends AccState {}

class NotificationLoadingState extends AccState {}

class NotificationLoadedState extends AccState {}

final class PlanSelectState extends AccState {
  final int selectedIndex;
  PlanSelectState(this.selectedIndex);
}

final class SubscriptionPaymentSelectState extends AccState {
  final int selectedIndex;
  SubscriptionPaymentSelectState(this.selectedIndex);
}

class SubscriptionListSuccessState extends AccState {
  final List<SubscriptionData>? subscriptionDatas;
  SubscriptionListSuccessState({required this.subscriptionDatas});
}

class SubscriptionPlanChosenState extends AccState {}

final class SubscriptionListFailureState extends AccState {}

final class SubscriptionListLoadingState extends AccState {}

final class SubscriptionPayFailedState extends AccState {}

final class SubscriptionPaySuccessState extends AccState {}

final class SubscriptionPayLoadingState extends AccState {}

final class SubscriptionPayLoadedState extends AccState {}

final class WalletEmptyState extends AccState {}

final class IncentiveLoadingStartState extends AccState {}

final class IncentiveLoadingStopState extends AccState {}

class ShowUpcomingIncentivesState extends AccState {
  final List<UpcomingIncentive> upcomingIncentives;
  ShowUpcomingIncentivesState({required this.upcomingIncentives});
}

class SelectIncentiveDateState extends AccState {
  final bool isSelected;
  SelectIncentiveDateState({required this.isSelected});
}

final class DriverLevelLoadingStartState extends AccState {}

final class DriverLevelLoadingStopState extends AccState {}

class DriverLevelPopupState extends AccState {
  final LevelDetails driverLevelList;
  DriverLevelPopupState({required this.driverLevelList});
}

final class DriverRewardLoadingStartState extends AccState {}

final class DriverRewardLoadingStopState extends AccState {}

class DriverRewardPointsState extends AccState {}

class HowItWorksState extends AccState {}

class UpdateRedeemedAmountState extends AccState {
  final double? redeemedAmount;
  UpdateRedeemedAmountState({required this.redeemedAmount});
}

class ReportLoadingState extends AccState {}

class ReportSubmitState extends AccState {}

class SaveCardSuccessState extends AccState {}

class ShowPaymentGatewayState extends AccState {}

class PaymentUpdateState extends AccState {
  final bool status;

  PaymentUpdateState({required this.status});
}

class CreateSupportTicketState extends AccState {
  final List<TicketNamesList> ticketNamesList;
  final String requestId;
  final bool isFromRequest;
  final int? historyIndex;
  final int? historyPageNumber;

  CreateSupportTicketState(
      {required this.ticketNamesList,
      required this.requestId,
      required this.isFromRequest,
      this.historyIndex,
      this.historyPageNumber});
}

class MakeTicketSubmitState extends AccState {}

class GetTicketListLoadedState extends AccState {}

class GetTicketListLoadingState extends AccState {}

class AddAttachmentTicketState extends AccState {}

class ClearAttachmentState extends AccState {}

class TicketReplyMessageState extends AccState {}

class TicketSubmitState extends AccState {}

class InvoiceDownloadSuccessState extends AccState {}

class AccLocationUpdated extends AccState {
  final LatLng latLng;
  final String address;

  AccLocationUpdated(this.latLng, this.address);
}

class AccSearchVisibilityChanged extends AccState {
  final bool showSearch;

  AccSearchVisibilityChanged(this.showSearch);
}

//my route address update

class MyRouteAddressUpdateState extends AccState {
  final double myRouteLat;
  final double myRouteLng;
  final String myRouteAddress;

  MyRouteAddressUpdateState({
    required this.myRouteLat,
    required this.myRouteLng,
    required this.myRouteAddress,
  });
}

class MyRouteAddressUpdateSuccessState extends AccState {
  final AddMyRouteAddressResponse response;

  MyRouteAddressUpdateSuccessState({required this.response});
}

class EnableMyRouteBookingSuccessState extends AccState {
  final bool isEnable;
  final double currentLat;
  final double currentLng;
  final String currentAddress;

  EnableMyRouteBookingSuccessState({
    required this.isEnable,
    required this.currentLat,
    required this.currentAddress,
    required this.currentLng,
  });
}

class ResetLocationConfirmedState extends AccState {}

class MyRouteLoadingStartState extends AccState {}

class MyRouteLoadingStopState extends AccState {}

final class ReferalHistoryLoadingState extends AccState {}

final class ReferalHistorySuccessState extends AccState {}

final class ReferalHistoryFailureState extends AccState {}

final class ReferralResponseLoadingState extends AccState {}

final class ReferralResponseSuccessState extends AccState {}

final class ReferralResponseFailureState extends AccState {}
