import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../common/common.dart';
import '../../../../core/network/network.dart';

class AuthApi {
  Future getLanguagesApi() async {
    try {
      Response response = await DioProviderImpl().get(ApiEndpoints.countryList);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future verifyUserApi(
      {required String emailOrMobileNumber,
      required bool isLoginByEmail,
      required String role}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.verifyUser,
        body: isLoginByEmail
            ? FormData.fromMap({'email': emailOrMobileNumber, 'role': role})
            : FormData.fromMap({'mobile': emailOrMobileNumber, 'role': role}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future getUserDetailsApi() async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().get(
        ApiEndpoints.userDetails,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future commonModuleCheckApi() async {
    try {
      Response response =
          await DioProviderImpl().get(ApiEndpoints.commonModule);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future sendMobileOtpApi(
      {required String mobileNumber, required String dialCode}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.sendMobileOtp,
        body: FormData.fromMap(
            {"mobile": mobileNumber, "country_code": dialCode}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future verifyMobileOtpApi(
      {required String mobileNumber, required String otp}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.verifyMobileOtp,
        body: FormData.fromMap({"mobile": mobileNumber, "otp": otp}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future sendEmailOtpApi({required String emailAddress}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.sendEmailOtp,
        body: FormData.fromMap({"email": emailAddress}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future verifyEmailOtpApi(
      {required String emailAddress, required String otp}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.verifyEmailOtp,
        body: FormData.fromMap({"email": emailAddress, "otp": otp}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future userLoginApi(
      {required String emailOrMobile,
      required String otp,
      required String password,
      required bool isOtpLogin,
      required bool isLoginByEmail,
      required String role}) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.userLogin,
        body: !isOtpLogin
            ? FormData.fromMap({
                if (!isLoginByEmail) "mobile": emailOrMobile,
                if (isLoginByEmail) "email": emailOrMobile,
                'password': password,
                'device_token': fcmToken,
                "login_by": (Platform.isAndroid) ? 'android' : 'ios',
                'role': role
              })
            : (!isLoginByEmail)
                ? FormData.fromMap({
                    "mobile": emailOrMobile,
                    'device_token': fcmToken,
                    "login_by": (Platform.isAndroid) ? 'android' : 'ios',
                    'role': role
                  })
                : FormData.fromMap({
                    "email": emailOrMobile,
                    "otp": otp,
                    'device_token': fcmToken,
                    "login_by": (Platform.isAndroid) ? 'android' : 'ios',
                    'role': role
                  }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future userRegisterApi(
      {required String userName,
      required String mobileNumber,
      required String emailAddress,
      required String password,
      required String countryCode,
      required String gender,
      required String profileImage,
      required String role}) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final choosenLanguage =
          await AppSharedPreference.getSelectedLanguageCode();
      final formData = FormData.fromMap({
        "name": userName,
        "mobile": mobileNumber,
        if (emailAddress.isNotEmpty) "email": emailAddress,
        "password": password,
        "device_token": fcmToken,
        "country": countryCode,
        "login_by": (Platform.isAndroid) ? 'android' : 'ios',
        'lang': choosenLanguage,
        'gender': (gender == 'Male')
            ? 'male'
            : (gender == 'Female')
                ? 'female'
                : 'others',
      });
      if (profileImage.isNotEmpty) {
        formData.files.add(MapEntry(
            'profile_picture', await MultipartFile.fromFile(profileImage)));
      }
      Response response = await DioProviderImpl().post(
        (role == 'driver')
            ? ApiEndpoints.registerUser
            : ApiEndpoints.ownerRegister,
        body: formData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future updatePasswordApi(
      {required String emailOrMobile,
      required String password,
      required String role,
      required bool isLoginByEmail}) async {
    try {
      Response response = await DioProviderImpl().post(
        ApiEndpoints.updatePassword,
        body: isLoginByEmail
            ? FormData.fromMap({
                "email": emailOrMobile,
                "password": password,
                if (role == 'driver') "role": role
              })
            : FormData.fromMap({
                "mobile": emailOrMobile,
                "password": password,
                if (role == 'driver') "role": role
              }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future referralApi({required String referralCode}) async {
    try {
      final token = await AppSharedPreference.getToken();
      Response response = await DioProviderImpl().post(
        ApiEndpoints.referral,
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: FormData.fromMap({"refferal_code": referralCode}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
