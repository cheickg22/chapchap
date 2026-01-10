import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/model/user_detail_model.dart';
import '../features/account/domain/models/history_model.dart';
import '../features/auth/application/auth_bloc.dart';
import '../features/auth/domain/models/country_list_model.dart';
import '../features/home/domain/models/stop_address_model.dart';

class VerifyArguments {
  final String mobileOrEmail;
  final String dialCode;
  final String countryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final bool isOtpVerify;
  final bool userExist;
  final bool isDemoLogin;
  final List<Country> countryList;
  final String loginAs;
  final AuthBloc value;
  final String isRefferalEarnings;

  VerifyArguments(
      {required this.mobileOrEmail,
      required this.dialCode,
      required this.countryCode,
      required this.countryFlag,
      required this.isLoginByEmail,
      required this.isOtpVerify,
      required this.userExist,
      required this.isDemoLogin,
      required this.countryList,
      required this.loginAs,
      required this.value,
      required this.isRefferalEarnings});
}

class UpdateDetailsArguments {
  final String header;
  final String text;
  final UserDetail userData;

  UpdateDetailsArguments({
    required this.header,
    required this.text,
    required this.userData,
  });
}

class ComplaintPageArguments {
  final String title;
  final String complaintTitleId;
  final String? selectedHistoryId;

  ComplaintPageArguments(
      {required this.title,
      required this.complaintTitleId,
      this.selectedHistoryId});
}

class ChangeLanguageArguments {
  final int from;

  ChangeLanguageArguments({
    required this.from,
  });
}

class ComplaintListPageArguments {
  final String? choosenHistoryId;

  ComplaintListPageArguments({
    this.choosenHistoryId,
  });
}

class ReferralArguments {
  final String title;
  final UserDetail userData;

  ReferralArguments({required this.title, required this.userData});
}

class VehicleUpdateArguments {
  final String from;
  final String? fleetId;

  VehicleUpdateArguments({required this.from, this.fleetId});
}

class EarningArguments {
  final String? from;

  EarningArguments({this.from});
}

class FleetDashboardArguments {
  final String fleetId;

  FleetDashboardArguments({
    required this.fleetId,
  });
}

class DriverDashboardArguments {
  final String driverId;
  final String driverName;
  final String profile;

  DriverDashboardArguments(
      {required this.driverId,
      required this.driverName,
      required this.profile});
}

class VehicleDataArguments {
  final int from;

  VehicleDataArguments({required this.from});
}

class ConfirmLocationPageArguments {
  final UserDetail userData;
  final List<AddressList>? stopAddressList;
  final List<AddressList>? pickupAddressList;
  final bool isPickupEdit;
  final bool isAddStopAddress;
  final bool isEditAddress;
  final int? editAddressIndex;
  final LatLng? latlng;
  final String transportType;

  ConfirmLocationPageArguments({
    required this.userData,
    this.stopAddressList,
    this.pickupAddressList,
    required this.isPickupEdit,
    required this.isAddStopAddress,
    required this.isEditAddress,
    this.editAddressIndex,
    this.latlng,
    required this.transportType,
  });
}

class TripHistoryPageArguments {
  final HistoryData historyData;
  final RequestbillData? requestbillData;
  final String isSupportTicketEnabled;
  final int? historyIndex;
  final int pageNumber;

  TripHistoryPageArguments(
      {required this.historyData,
      this.requestbillData,
      required this.isSupportTicketEnabled,
      required this.pageNumber,
      this.historyIndex});
}

class AccountPageArguments {
  final UserDetail userData;

  AccountPageArguments({
    required this.userData,
  });
}

class HistoryAccountPageArguments {
  final String isFrom;
  final String isSupportTicketEnabled;
  HistoryAccountPageArguments(
      {required this.isFrom, required this.isSupportTicketEnabled});
}

class RegisterPageArguments {
  final String emailOrMobile;
  final String dialCode;
  final String contryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final List<Country> countryList;
  final String loginAs;
  final String isRefferalEarnings;

  RegisterPageArguments(
      {required this.isLoginByEmail,
      required this.dialCode,
      required this.contryCode,
      required this.countryFlag,
      required this.emailOrMobile,
      required this.countryList,
      required this.loginAs,
      required this.isRefferalEarnings});
}

class ForgotPasswordPageArguments {
  final String emailOrMobile;
  final String contryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final String loginAs;

  ForgotPasswordPageArguments(
      {required this.isLoginByEmail,
      required this.contryCode,
      required this.countryFlag,
      required this.emailOrMobile,
      required this.loginAs});
}

class UpdatePasswordPageArguments {
  final String emailOrMobile;
  final bool isLoginByEmail;

  UpdatePasswordPageArguments({
    required this.isLoginByEmail,
    required this.emailOrMobile,
  });
}

class DestinationPageArguments {
  final String pickupAddress;
  final LatLng pickupLatLng;
  final bool pickUpChange;

  DestinationPageArguments(
      {required this.pickupAddress,
      required this.pickupLatLng,
      required this.pickUpChange});
}

class PaymentGateWayPageArguments {
  final String from;
  final String url;
  final String userId;
  final String requestId;
  final String currencySymbol;
  final String money;
  final String planId;

  PaymentGateWayPageArguments({
    required this.from,
    required this.url,
    required this.userId,
    required this.requestId,
    required this.currencySymbol,
    required this.money,
    required this.planId,
  });
}

class SubscriptionPageArguments {
  final bool isFromAccPage;

  SubscriptionPageArguments({required this.isFromAccPage});
}

class WalletPageArguments {
  final UserDetail userData;

  WalletPageArguments({required this.userData});
}

class LandingPageArguments {
  final String type;

  LandingPageArguments({required this.type});
}

class AuthPageArguments {
  final String type;

  AuthPageArguments({required this.type});
}

class OwnerDashboardArguments {
  final String? from;

  OwnerDashboardArguments({this.from});
}

class SOSPageArguments {
  final List<SOSDatum> sosData;

  SOSPageArguments({
    required this.sosData,
  });
}

class HomePageArguments {
  final bool? isFromHistory;

  HomePageArguments({
    required this.isFromHistory,
  });
}

class WithdrawPageArguments {
  final String minWalletAmount;
  final int? initialBankIndex;
  final bool? openEdit; // true = view/edit, false = add

  WithdrawPageArguments({
    required this.minWalletAmount,
    this.initialBankIndex,
    this.openEdit,
  });
}

class PaymentMethodArguments {
  final UserDetail userData;

  PaymentMethodArguments({required this.userData});
}

class SupportTicketPageArguments {
  final bool isFromRequest;
  final String requestId;

  SupportTicketPageArguments(
      {required this.isFromRequest, required this.requestId});
}

class ViewTicketPageArguments {
  final bool isViewTicketPage;
  final String ticketId;
  final String id;

  ViewTicketPageArguments(
      {required this.isViewTicketPage,
      required this.ticketId,
      required this.id});
}

class TermsAndPrivacyPolicyArguments {
  final bool isPrivacyPolicy;

  TermsAndPrivacyPolicyArguments({required this.isPrivacyPolicy});
}

class RouteBookingArguments {
  final UserDetail userData;

  RouteBookingArguments({required this.userData});
}

class LoginPageArguments {
  final String type;

  LoginPageArguments({required this.type});
}

class SignupMobilePageArguments {
  final String type;
  final bool mobileOrEmailSignUp;

  SignupMobilePageArguments(
      {required this.type, required this.mobileOrEmailSignUp});
}

class OtpPageArguments {
  final String mobileOrEmail;
  final String dialCode;
  final String countryCode;
  final String countryFlag;
  final bool isLoginByEmail;
  final bool isOtpVerify;
  final bool userExist;
  final bool isDemoLogin;
  final List<Country> countryList;
  final String isRefferalEarnings;
  final String type;

  OtpPageArguments({
    required this.mobileOrEmail,
    required this.dialCode,
    required this.countryCode,
    required this.countryFlag,
    required this.isLoginByEmail,
    required this.isOtpVerify,
    required this.userExist,
    required this.isDemoLogin,
    required this.countryList,
    required this.isRefferalEarnings,
    required this.type,
  });
}

class LeaderBoardArguments {
  final String? from;

  LeaderBoardArguments({this.from});
}
