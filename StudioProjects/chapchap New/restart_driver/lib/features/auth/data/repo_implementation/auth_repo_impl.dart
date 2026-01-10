import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../core/network/network.dart';
import '../../domain/models/common_module_model.dart';
import '../../domain/models/country_list_model.dart';
import '../../domain/models/login_model.dart';
import '../../domain/models/register_model.dart';
import '../../domain/models/verify_user_res_model.dart';
import '../../domain/repositories/auth_repo.dart';
import '../repository/auth_api.dart';
import '../../domain/models/send_email_otp_res_model.dart';
import '../../domain/models/send_mobile_otp_res_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;

  AuthRepositoryImpl(this._authApi);
  // CountryList
  @override
  Future<Either<Failure, CountryListModel>> getCountryList() async {
    CountryListModel countryListResponseModel;
    try {
      Response response = await _authApi.getLanguagesApi();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          countryListResponseModel = CountryListModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(countryListResponseModel);
  }

  // VerifyUser
  @override
  Future<Either<Failure, VeifyUserResponseModel>> verifyUser(
      {required String emailOrMobileNumber,
      required bool isLoginByEmail,
      required String role}) async {
    VeifyUserResponseModel verifyUserResponseModel;
    try {
      Response response = await _authApi.verifyUserApi(
          emailOrMobileNumber: emailOrMobileNumber,
          isLoginByEmail: isLoginByEmail,
          role: role);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          verifyUserResponseModel =
              VeifyUserResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(verifyUserResponseModel);
  }

  // CommonModuleCheck
  @override
  Future<Either<Failure, CommonModuleModel>> commonModuleCheck() async {
    CommonModuleModel commonModuleResponseModel;
    try {
      Response response = await _authApi.commonModuleCheckApi();

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          commonModuleResponseModel = CommonModuleModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(commonModuleResponseModel);
  }

  // SendMobileOtp
  @override
  Future<Either<Failure, SendMobileOtpResponseModel>> sendMobileOtp(
      {required String mobileNumber, required String dialCode}) async {
    SendMobileOtpResponseModel sendMobileOtpResponseModel;
    try {
      Response response = await _authApi.sendMobileOtpApi(
          mobileNumber: mobileNumber, dialCode: dialCode);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          sendMobileOtpResponseModel =
              SendMobileOtpResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(sendMobileOtpResponseModel);
  }

  // VerifyMobileOtp
  @override
  Future<Either<Failure, dynamic>> verifyMobileOtp(
      {required String mobileNumber, required String otp}) async {
    dynamic verifyResponseModel;
    try {
      Response response = await _authApi.verifyMobileOtpApi(
          mobileNumber: mobileNumber, otp: otp);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['errors']["otp"][0]));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          verifyResponseModel = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(verifyResponseModel);
  }

  // SendEmailOtp
  @override
  Future<Either<Failure, dynamic>> sendEmailOtp(
      {required String emailAddress}) async {
    dynamic sendEmailOtpResponseModel;
    try {
      Response response =
          await _authApi.sendEmailOtpApi(emailAddress: emailAddress);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(
            GetDataFailure(message: response.data['errors']["message"]));
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          sendEmailOtpResponseModel =
              SendEmailOtpResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(sendEmailOtpResponseModel);
  }

  // VerifyEmailOtp
  @override
  Future<Either<Failure, dynamic>> verifyEmailOtp(
      {required String emailAddress, required String otp}) async {
    dynamic verifyResponseModel;
    try {
      Response response = await _authApi.verifyEmailOtpApi(
          emailAddress: emailAddress, otp: otp);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        if (response.data['errors']['email'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['email'][0]));
        } else if (response.data['errors']['mobile'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['mobile'][0]));
        } else {
          return Left(
              GetDataFailure(message: response.data['errors']['message']));
        }
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          verifyResponseModel = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(verifyResponseModel);
  }

  // UserLogin
  @override
  Future<Either<Failure, LoginResponseModel>> userLogin(
      {required String emailOrMobile,
      required String otp,
      required String password,
      required bool isOtpLogin,
      required bool isLoginByEmail,
      required String role}) async {
    LoginResponseModel userLoginResponseModel;
    try {
      Response response = await _authApi.userLoginApi(
          emailOrMobile: emailOrMobile,
          otp: otp,
          password: password,
          isOtpLogin: isOtpLogin,
          isLoginByEmail: isLoginByEmail,
          role: role);
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        if (response.data['errors']['email'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['email'][0]));
        } else if (response.data['errors']['mobile'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['mobile'][0]));
        } else {
          return Left(
              GetDataFailure(message: response.data['errors']['message']));
        }
      } else {
        if (response.statusCode == 400 || response.statusCode == 422) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          userLoginResponseModel = LoginResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(userLoginResponseModel);
  }

  // UserDetailData
  @override
  Future<Either<Failure, UserDetailResponseModel>> getUserDetails() async {
    UserDetailResponseModel userDetailsResponseModel;
    try {
      Response response = await _authApi.getUserDetailsApi();
      printWrapped('Response : ${response.data}');
      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(message: response.data['error']));
      } else {
        if (response.statusCode != 200) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          userDetailsResponseModel =
              UserDetailResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }

    return Right(userDetailsResponseModel);
  }

  @override
  Future<Either<Failure, RegisterResponseModel>> userRegister(
      {required String userName,
      required String mobileNumber,
      required String emailAddress,
      required String password,
      required String countryCode,
      required String gender,
      required String profileImage,
      required String role}) async {
    RegisterResponseModel userRegisterResponse;
    try {
      Response response = await _authApi.userRegisterApi(
          userName: userName,
          mobileNumber: mobileNumber,
          emailAddress: emailAddress,
          password: password,
          countryCode: countryCode,
          gender: gender,
          profileImage: profileImage,
          role: role);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        if (response.data['errors']['email'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['email'][0]));
        } else if (response.data['errors']['mobile'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['mobile'][0]));
        } else {
          return Left(
              GetDataFailure(message: response.data['errors']['message']));
        }
      } else {
        if (response.statusCode == 400 ||
            response.statusCode == 500 ||
            response.statusCode == 401 ||
            response.statusCode == 422) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          userRegisterResponse = RegisterResponseModel.fromJson(response.data);
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(userRegisterResponse);
  }

  @override
  Future<Either<Failure, dynamic>> updatePassword(
      {required String emailOrMobile,
      required String password,
      required String role,
      required bool isLoginByEmail}) async {
    dynamic updateResponseModel;
    try {
      Response response = await _authApi.updatePasswordApi(
          emailOrMobile: emailOrMobile,
          password: password,
          role: role,
          isLoginByEmail: isLoginByEmail);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data.toString().contains('error')) {
        if (response.data['errors']['email'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['email'][0]));
        } else if (response.data['errors']['mobile'] != null) {
          return Left(
              GetDataFailure(message: response.data['errors']['mobile'][0]));
        } else {
          return Left(
              GetDataFailure(message: response.data['errors']['message']));
        }
      } else {
        if (response.statusCode == 400) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          updateResponseModel = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(updateResponseModel);
  }

  @override
  Future<Either<Failure, dynamic>> referralCode(
      {required String referralCode}) async {
    dynamic referralResponse;
    try {
      Response response =
          await _authApi.referralApi(referralCode: referralCode);

      if (response.data == null || response.data == '') {
        return Left(GetDataFailure(message: 'User bad request'));
      } else if (response.data['error'] != null) {
        return Left(GetDataFailure(
            message: response.data['errors']["refferal_code"][0]));
      } else {
        if (response.statusCode == 400 ||
            response.statusCode == 422 ||
            response.statusCode == 500) {
          return Left(GetDataFailure(
              message: response.data["message"],
              statusCode: response.statusCode!));
        } else {
          referralResponse = response.data;
        }
      }
    } on FetchDataException catch (e) {
      return Left(GetDataFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(InPutDataFailure(message: e.message));
    }
    return Right(referralResponse);
  }
}
