part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthUpdateEvent extends AuthEvent {}

class GetDirectionEvent extends AuthEvent {}

class CountryGetEvent extends AuthEvent {}

class SplashImageChangeEvent extends AuthEvent {
  final int splashIndex;

  SplashImageChangeEvent({required this.splashIndex});
}

class EmailorMobileOnTapEvent extends AuthEvent {}

class GetUserEvent extends AuthEvent {}

class EmailorMobileOnChangeEvent extends AuthEvent {
  final String value;

  EmailorMobileOnChangeEvent({required this.value});
}

class ChooseLoginAsEvent extends AuthEvent {
  final String loginAs;
  ChooseLoginAsEvent({required this.loginAs});
}

class UpdateLoginAsEvent extends AuthEvent {
  final String loginAs;
  UpdateLoginAsEvent({required this.loginAs});
}

class EmailorMobileOnSubmitEvent extends AuthEvent {}

// Verify

class GetCommonModuleEvent extends AuthEvent {}

class VerifyUserEvent extends AuthEvent {
  final String loginAs;
  final String mobileOrEmail;
  final bool loginByMobile;
  final bool? forgotPassword;

  VerifyUserEvent(
      {required this.loginAs,
      required this.mobileOrEmail,
      required this.loginByMobile,
      this.forgotPassword});
}

class ShowPasswordIconEvent extends AuthEvent {
  final bool showPassword;

  ShowPasswordIconEvent({required this.showPassword});
}

class OTPOnChangeEvent extends AuthEvent {}

class VerifyTimerEvent extends AuthEvent {
  final int duration;

  VerifyTimerEvent({
    required this.duration,
  });
}

class SignInWithOTPEvent extends AuthEvent {
  final bool isOtpVerify;
  final bool isLoginByEmail;
  final bool isForgotPassword;
  final String mobileOrEmail;
  final String dialCode;

  SignInWithOTPEvent(
      {required this.isOtpVerify,
      required this.isLoginByEmail,
      required this.isForgotPassword,
      required this.mobileOrEmail,
      required this.dialCode});
}

class ConfirmOrVerifyOTPEvent extends AuthEvent {
  final bool isUserExist;
  final bool isLoginByEmail;
  final bool isOtpVerify;
  final bool isForgotPasswordVerify;
  final String mobileOrEmail;
  final String otp;
  final String password;
  final String firebaseVerificationId;
  final String loginAs;

  ConfirmOrVerifyOTPEvent(
      {required this.isUserExist,
      required this.isLoginByEmail,
      required this.isOtpVerify,
      required this.isForgotPasswordVerify,
      required this.mobileOrEmail,
      required this.otp,
      required this.password,
      required this.firebaseVerificationId,
      required this.loginAs});
}

// Register
class RegisterUserEvent extends AuthEvent {
  final String userName;
  final String mobileNumber;
  final String emailAddress;
  final String password;
  final String countryCode;
  final String gender;
  final String profileImage;
  final String loginAs;

  RegisterUserEvent({
    required this.userName,
    required this.mobileNumber,
    required this.emailAddress,
    required this.password,
    required this.countryCode,
    required this.gender,
    required this.profileImage,
    required this.loginAs,
  });
}

class RegisterPageInitEvent extends AuthEvent {
  final RegisterPageArguments arg;

  RegisterPageInitEvent({required this.arg});
}

class VerifyPageInitEvent extends AuthEvent {
  final VerifyArguments arg;

  VerifyPageInitEvent({required this.arg});
}

class ImageUpdateEvent extends AuthEvent {
  final ImageSource source;

  ImageUpdateEvent({required this.source});
}

class ReferralEvent extends AuthEvent {
  final String referralCode;

  ReferralEvent({required this.referralCode});
}

// Login

class LoginUserEvent extends AuthEvent {
  final String emailOrMobile;
  final String otp;
  final String password;
  final bool isOtpLogin;
  final bool isLoginByEmail;
  final String loginAs;
  LoginUserEvent(
      {required this.emailOrMobile,
      required this.otp,
      required this.password,
      required this.isOtpLogin,
      required this.isLoginByEmail,
      required this.loginAs});
}

// Update Password

class UpdatePasswordEvent extends AuthEvent {
  final String emailOrMobile;
  final String password;
  final String role;
  final bool isLoginByEmail;
  UpdatePasswordEvent(
      {required this.emailOrMobile,
      required this.password,
      required this.role,
      required this.isLoginByEmail});
}

class SelectLoginMethodEvent extends AuthEvent {
  final bool selectLoginByEmail;

  SelectLoginMethodEvent({required this.selectLoginByEmail});
}

class TermsAcceptEvent extends AuthEvent {
  final bool isAccepted;
  TermsAcceptEvent({required this.isAccepted});
}

class OtpVerifyEvent extends AuthEvent {
  final bool isOtpVerify;
  OtpVerifyEvent({required this.isOtpVerify});
}
