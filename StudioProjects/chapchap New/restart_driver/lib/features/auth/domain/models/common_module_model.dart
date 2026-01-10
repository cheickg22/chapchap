import 'dart:convert';

CommonModuleModel commonModuleResponseModelFromJson(String str) =>
    CommonModuleModel.fromJson(json.decode(str));

class CommonModuleModel {
  bool success;
  String message;
  String enableOwnerLogin;
  String enableEmailOtp;
  String enableUserReferralEarnings;
  String enableRefferal;
  bool firebaseOtpEnabled;
  String enableEmailLogin;
  String enableDriverSignInEmailOtp;
  String enableDriverSignInEmailPassword;
  String enableDriverSignInMobileOtp;
  String enableDriverSignInMobilePassword;
  String enableOwnerSignInEmailOtp;
  String enableOwnerSignInEmailPassword;
  String enableOwnerSignInMobileOtp;
  String enableOwnerSignInMobilePassword;
  String enableDriverEmailLogin;
  String enableDriverMobileLogin;
  String enableOwnerEmailLogin;
  String enableOwnerMobileLogin;

  CommonModuleModel({
    required this.success,
    required this.message,
    required this.enableOwnerLogin,
    required this.enableEmailOtp,
    required this.enableUserReferralEarnings,
    required this.enableRefferal,
    required this.firebaseOtpEnabled,
    required this.enableEmailLogin,
    required this.enableDriverSignInEmailOtp,
    required this.enableDriverSignInEmailPassword,
    required this.enableDriverSignInMobileOtp,
    required this.enableDriverSignInMobilePassword,
    required this.enableOwnerSignInEmailOtp,
    required this.enableOwnerSignInEmailPassword,
    required this.enableOwnerSignInMobileOtp,
    required this.enableOwnerSignInMobilePassword,
    required this.enableDriverEmailLogin,
    required this.enableDriverMobileLogin,
    required this.enableOwnerEmailLogin,
    required this.enableOwnerMobileLogin,
  });

  factory CommonModuleModel.fromJson(Map<String, dynamic> json) =>
      CommonModuleModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        enableOwnerLogin: json["enable_owner_login"] ?? '0',
        enableEmailOtp: json["enable_email_otp"] ?? '0',
        enableUserReferralEarnings:
            json["enable_user_referral_earnings"] ?? '0',
        enableRefferal: json["enable_driver_referral_earnings"] ?? '0',
        firebaseOtpEnabled: json["firebase_otp_enabled"] ?? false,
        enableEmailLogin: json["enable_email_login"] ?? '0',
        enableDriverSignInEmailOtp:
            json["enable_driver_sign_in_email_otp"] ?? '0',
        enableDriverSignInEmailPassword:
            json["enable_driver_sign_in_email_password"] ?? '0',
        enableDriverSignInMobileOtp:
            json["enable_driver_sign_in_mobile_otp"] ?? '0',
        enableDriverSignInMobilePassword:
            json["enable_driver_sign_in_mobile_password"] ?? '0',
        enableOwnerSignInEmailOtp:
            json["enable_owner_sign_in_email_otp"] ?? '0',
        enableOwnerSignInEmailPassword:
            json["enable_owner_sign_in_email_password"] ?? '0',
        enableOwnerSignInMobileOtp:
            json["enable_owner_sign_in_mobile_otp"] ?? '0',
        enableOwnerSignInMobilePassword:
            json["enable_owner_sign_in_mobile_password"] ?? '0',
        enableDriverEmailLogin: json["enable_driver_email_login"] ?? '0',
        enableDriverMobileLogin: json["enable_driver_mobile_login"] ?? '0',
        enableOwnerEmailLogin: json["enable_owner_email_login"] ?? '0',
        enableOwnerMobileLogin: json["enable_owner_mobile_login"] ?? '0',
      );
}
