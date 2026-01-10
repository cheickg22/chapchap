import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import '../../../common/common.dart';
import '../../../core/utils/custom_snack_bar.dart';
import '../../../di/locator.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/models/common_module_model.dart';
import '../domain/models/country_list_model.dart';
import 'usecases/auth_usecase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final formKey = GlobalKey<FormState>();
  FocusNode textFieldFocus = FocusNode();
  TextEditingController emailOrMobileController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  TextEditingController rUserNameController = TextEditingController();
  TextEditingController rMobileController = TextEditingController();
  TextEditingController rEmailController = TextEditingController();
  TextEditingController rPasswordController = TextEditingController();
  TextEditingController rReferralCodeController = TextEditingController();

  bool isLoading = false;
  bool isLoginByEmail = true;
  bool isOtpVerify = false;
  bool isNewUser = false;
  bool showLoginBtn = false;
  bool showPassword = false;
  bool isMobileNumber = false;
  bool userExist = false;
  bool isFirebaseOtpVerifyEnable = false;
  String loginAs = 'driver';
  String choosenLoginAs = '';

  int splashIndex = 0;
  int timerDuration = 0;
  int dialMaxLength = 14;
  String isRefferalEarnings = "0";
  String isEmailLogin = '0';
  String isOwnerLogin = '0';
  String isEmailOtp = '0';
  String isDriverSignInEmailOtp = '0';
  String isDriverSignInEmailPassword = '0';
  String isDriverSignInMobileOtp = '0';
  String isDriverSignInMobilePassword = '0';
  String isOwnerSignInEmailOtp = '0';
  String isOwnerSignInEmailPassword = '0';
  String isOwnerSignInMobileOtp = '0';
  String isOwnerSignInMobilePassword = '0';
  String isDriverEmailLogin = '0';
  String isDriverMobileLogin = '0';
  String isOwnerEmailLogin = '0';
  String isOwnerMobileLogin = '0';

  String dialCode = '+91';
  String countryCode = 'IN';
  String flagImage = '${AppConstants.baseUrl}image/country/flags/IN.png';
  // String textDirection = 'ltr';
  String selectedGender = '';
  String profileImage = '';
  String textDirection = 'ltr';

  // Firebase
  dynamic firebaseCredentials;
  String firebaseVerificationId = '';
  dynamic firebaseResendToken;

  List<Country> countries = [];
  List<Widget> splashImages = [
    Image.asset(AppImages.splash1),
    Image.asset(AppImages.splash2),
  ];
  List<String> genderList = [
    'Male',
    'Female',
    'Prefer not to say',
  ];
  bool selectLoginMethods = false;
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  bool isTermsAccepted = false;

  AuthBloc() : super(AuthInitialState()) {
    // Auth
    on<AuthUpdateEvent>((event, emit) => emit(AuthUpdateState()));
    on<GetDirectionEvent>(_getDirection);
    on<CountryGetEvent>(_countryList);
    on<SplashImageChangeEvent>(_splashChangeIndex);
    on<EmailorMobileOnChangeEvent>(_emailMobileOnchange);
    on<EmailorMobileOnTapEvent>(_emailMobileOnTap);
    on<EmailorMobileOnSubmitEvent>(_emailMobileOnSubmit);
    on<ChooseLoginAsEvent>(chooseLoginAs);
    on<UpdateLoginAsEvent>(updateLoginAs);

    // Verify
    on<ShowPasswordIconEvent>(_showPassIconOnChange);
    on<VerifyUserEvent>(_verifyUserDetails);
    on<OTPOnChangeEvent>(_otpOnChange);
    on<GetCommonModuleEvent>(_commonModules);
    on<SignInWithOTPEvent>(_signInWithOTP);
    on<ConfirmOrVerifyOTPEvent>(_confirmOrVerifyOTP);
    on<VerifyTimerEvent>(_timerEvent);
    on<VerifyPageInitEvent>(_verifyInit);

    // Register
    on<RegisterUserEvent>(_registerUser);
    on<RegisterPageInitEvent>(_registerInit);
    on<ImageUpdateEvent>(_getProfileImage);
    on<ReferralEvent>(_getReferralCode);

    // Login
    on<LoginUserEvent>(_loginUser);
    on<GetUserEvent>(_getUserDetails);

    // Update Password
    on<UpdatePasswordEvent>(_updatePassword);

    on<SelectLoginMethodEvent>(selectLoginMethod);
    on<TermsAcceptEvent>(TermsAccepted);
    on<OtpVerifyEvent>(OtpVerifyed);
  }

  Future<void> _getDirection(AuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthDataLoadingState());
    textDirection = await AppSharedPreference.getLanguageDirection();
    var val = await AppSharedPreference.getSelectedLanguageCode();
    choosenLanguage = val;

    emit(AuthDataLoadedState());
  }

  FutureOr<void> _countryList(AuthEvent event, Emitter<AuthState> emit) async {
    emit(CountryLoadingState());
    textDirection = await AppSharedPreference.getLanguageDirection();
    var val = await AppSharedPreference.getSelectedLanguageCode();
    choosenLanguage = val;
    final data = await serviceLocator<AuthUsecase>().getCountryList();
    data.fold(
      (error) {
        emit(CountryFailureState());
      },
      (success) {
        countries = success.data;
        dialCode = countries
            .firstWhere((element) => element.datumDefault == true)
            .dialCode;
        countryCode = countries
            .firstWhere((element) => element.datumDefault == true)
            .code;
        flagImage = countries
            .firstWhere((element) => element.datumDefault == true)
            .flag!;
        dialMaxLength = countries
            .firstWhere((element) => element.datumDefault == true)
            .dialMaxLength;
        emit(CountrySuccessState());
      },
    );
  }

  Future<void> _splashChangeIndex(
      SplashImageChangeEvent event, Emitter<AuthState> emit) async {
    splashIndex = event.splashIndex;
    emit(SplashChangeIndexState());
  }

  Future<void> selectLoginMethod(
      SelectLoginMethodEvent event, Emitter<AuthState> emit) async {
    selectLoginMethods = event.selectLoginByEmail;
    emit(SelectLoginMethodState());
  }

  // ignore: non_constant_identifier_names
  Future<void> TermsAccepted(
      TermsAcceptEvent event, Emitter<AuthState> emit) async {
    isTermsAccepted = event.isAccepted;
    emit(TermsAcceptState());
  }

  // ignore: non_constant_identifier_names
  Future<void> OtpVerifyed(
      OtpVerifyEvent event, Emitter<AuthState> emit) async {
    isOtpVerify = event.isOtpVerify;
    emit(OtpVerifyState());
  }

  Future<void> _emailMobileOnchange(
      EmailorMobileOnChangeEvent event, Emitter<AuthState> emit) async {
    if (AppValidation.mobileNumberValidate(event.value)) {
      isLoginByEmail = false;
    } else if (!AppValidation.mobileNumberValidate(event.value)) {
      isLoginByEmail = true;
    }
    emit(EmailorMobileOnChangeState());
  }

  Future<void> _emailMobileOnTap(
      EmailorMobileOnTapEvent event, Emitter<AuthState> emit) async {
    showLoginBtn = true;
    emit(EmailorMobileOnTapState());
  }

  Future<void> _emailMobileOnSubmit(
      EmailorMobileOnSubmitEvent event, Emitter<AuthState> emit) async {
    showLoginBtn = false;
    emit(EmailorMobileOnSubmitState());
  }

  Future<void> chooseLoginAs(
      ChooseLoginAsEvent event, Emitter<AuthState> emit) async {
    choosenLoginAs = event.loginAs;
    emit(DataChangedState());
  }

  Future<void> updateLoginAs(
      UpdateLoginAsEvent event, Emitter<AuthState> emit) async {
    loginAs = event.loginAs;
    await AppSharedPreference.setUserType(event.loginAs);
    emit(
      UpdateLoginAsState(loginAs: loginAs),
    );
  }

  // Verify

  Future<void> _showPassIconOnChange(
      ShowPasswordIconEvent event, Emitter<AuthState> emit) async {
    showPassword = !event.showPassword;
    emit(ShowPasswordIconState());
  }

  Future<void> _commonModules(
    GetCommonModuleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(GetCommonModuleLoading());
    final result = await serviceLocator<AuthUsecase>().commonModuleCheck();

    if (emit.isDone) return;

    CommonModuleModel? success;

    result.fold(
      (error) {
        success = null;
      },
      (data) {
        success = data;
      },
    );

    if (success == null) {
      emit(GetCommonModuleFailure());
      return;
    }

    // ===== USE success SAFELY =====
    isFirebaseOtpVerifyEnable = success!.firebaseOtpEnabled;
    isRefferalEarnings = success!.enableRefferal;
    isEmailLogin = success!.enableEmailLogin;
    isOwnerLogin = success!.enableOwnerLogin;
    isEmailOtp = success!.enableEmailOtp;
    isDriverSignInEmailOtp = success!.enableDriverSignInEmailOtp;
    isDriverSignInEmailPassword = success!.enableDriverSignInEmailPassword;
    isDriverSignInMobileOtp = success!.enableDriverSignInMobileOtp;
    isDriverSignInMobilePassword = success!.enableDriverSignInMobilePassword;
    isOwnerSignInEmailOtp = success!.enableOwnerSignInEmailOtp;
    isOwnerSignInEmailPassword = success!.enableOwnerSignInEmailPassword;
    isOwnerSignInMobileOtp = success!.enableOwnerSignInMobileOtp;
    isOwnerSignInMobilePassword = success!.enableOwnerSignInMobilePassword;
    isDriverEmailLogin = success!.enableDriverEmailLogin;
    isDriverMobileLogin = success!.enableDriverMobileLogin;
    isOwnerEmailLogin = success!.enableOwnerEmailLogin;
    isOwnerMobileLogin = success!.enableOwnerMobileLogin;

    // await calls
    if (success!.enableOwnerLogin == '0') {
      await AppSharedPreference.setUserTypeStatus(false);
    } else {
      await AppSharedPreference.setUserTypeStatus(true);
    }

    if (emit.isDone) return;

    add(AuthUpdateEvent());
    emit(GetCommonModuleSuccess());
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        firebaseCredentials = credential;
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          showToast(
              message: AppLocalizations.of(navigatorKey.currentContext!)!
                  .phoneNumberNotValid);
        }
        isLoading = false;
      },
      codeSent: (String verificationId, int? resendToken) async {
        firebaseVerificationId = verificationId;
        firebaseResendToken = resendToken;
        isLoading = false;
        showToast(
            message: AppLocalizations.of(navigatorKey.currentContext!)!
                .otpSendTo
                .replaceAll('1111', phoneNumber));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _signInWithOTP(
      SignInWithOTPEvent event, Emitter<AuthState> emit) async {
    isLoading = true;
    otpController.text = '';
    isOtpVerify = event.isOtpVerify;
    final firebaseEnabled =
        await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();

    if (firebaseEnabled.value == true && !event.isLoginByEmail) {
      if (isFirebaseOtpVerifyEnable && !event.isLoginByEmail) {
        await verifyPhoneNumber('${event.dialCode}${event.mobileOrEmail}');
        await Future.delayed(
          const Duration(seconds: 3),
          () {
            isLoading = false;
            emit(SignInWithOTPSuccessState());
            if (event.isForgotPassword) {
              emit(ForgotPasswordOTPSendState());
            }
          },
        );
      } else {
        if (!event.isLoginByEmail) {
          final data = await serviceLocator<AuthUsecase>().sendMobileOtp(
            mobileNumber: event.mobileOrEmail,
            dialCode: event.dialCode,
          );
          data.fold(
            (error) {
              showToast(message: '${error.message}');
              isLoading = false;
              emit(SignInWithOTPFailureState());
            },
            (success) {
              showToast(
                  message: AppLocalizations.of(navigatorKey.currentContext!)!
                      .otpSendTo
                      .replaceAll('1111', event.mobileOrEmail));
              isLoading = false;
              emit(SignInWithOTPSuccessState());
              if (event.isForgotPassword) {
                emit(ForgotPasswordOTPSendState());
              }
            },
          );
        }
      }
    } else {
      isLoading = false;
      textFieldFocus.unfocus();

      if (event.isLoginByEmail) {
        final data = await serviceLocator<AuthUsecase>()
            .sendEmailOtp(emailAddress: event.mobileOrEmail);
        data.fold(
          (error) {
            showToast(message: '${error.message}');
            isLoading = false;
            emit(SignInWithOTPFailureState());
          },
          (success) {
            showToast(
                message: AppLocalizations.of(navigatorKey.currentContext!)!
                    .otpSendTo
                    .replaceAll('1111', event.mobileOrEmail));
            isLoading = false;
            emit(SignInWithOTPSuccessState());
            if (event.isForgotPassword) {
              emit(ForgotPasswordOTPSendState());
            }
          },
        );
      } else {
        RemoteNotification noti = RemoteNotification(
            title:
                AppLocalizations.of(navigatorKey.currentContext!)!.otpForLogin,
            body:
                AppLocalizations.of(navigatorKey.currentContext!)!.demoOtpText);
        showOtpNotification(noti);
        if (event.isForgotPassword) {
          emit(ForgotPasswordOTPSendState());
        }
      }
      emit(SignInWithDemoState());
    }
  }

  Future<void> _confirmOrVerifyOTP(
      ConfirmOrVerifyOTPEvent event, Emitter<AuthState> emit) async {
    isLoading = true;
    emit(VerifyLoadingState());
    final firebaseEnabled =
        await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
    if (event.otp.isNotEmpty) {
      if (firebaseEnabled.value == true && !event.isLoginByEmail) {
        if (isFirebaseOtpVerifyEnable && !event.isLoginByEmail) {
          try {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: event.firebaseVerificationId,
                smsCode: event.otp);
            await FirebaseAuth.instance.signInWithCredential(credential);

            if (!event.isForgotPasswordVerify) {
              if (!event.isUserExist) {
                // New User
                isLoading = false;
                emit(NewUserRegisterState());
              } else {
                // Exist User
                add(LoginUserEvent(
                    emailOrMobile: event.mobileOrEmail,
                    otp: event.otp,
                    password: event.password,
                    isOtpLogin: event.isOtpVerify,
                    isLoginByEmail: event.isLoginByEmail,
                    loginAs: event.loginAs));
              }
            } else {
              isLoading = false;
              emit(ForgotPasswordOTPVerifyState());
            }
          } on FirebaseAuthException catch (error) {
            debugPrint(error.toString());
            if (error.code == 'invalid-verification-code') {
              showToast(
                  message: AppLocalizations.of(navigatorKey.currentContext!)!
                      .correctOtporResend);
              isLoading = false;
              otpController.clear();
              emit(SignInWithOTPFailureState());
            } else {
              showToast(message: error.code);
              isLoading = false;
              otpController.clear();
              emit(SignInWithOTPFailureState());
            }
          }
        } else {
          if (!event.isLoginByEmail) {
            final data = await serviceLocator<AuthUsecase>().verifyMobileOtp(
              mobileNumber: event.mobileOrEmail,
              otp: event.otp,
            );
            data.fold(
              (error) {
                showToast(message: '${error.message}');
                isLoading = false;
                emit(ConfirmOrOTPVerifyFailureState());
              },
              (success) {
                showToast(
                    message: AppLocalizations.of(navigatorKey.currentContext!)!
                        .verifiedSuccessfully);
                emit(ConfirmOrOTPVerifySuccessState());
                isLoading = false;
                if (!event.isForgotPasswordVerify) {
                  if (!event.isUserExist) {
                    // New User
                    isLoading = false;
                    emit(NewUserRegisterState());
                  } else {
                    // Exist User
                    add(LoginUserEvent(
                        emailOrMobile: event.mobileOrEmail,
                        otp: event.otp,
                        password: event.password,
                        isOtpLogin: event.isOtpVerify,
                        isLoginByEmail: event.isLoginByEmail,
                        loginAs: event.loginAs));
                  }
                } else {
                  emit(ForgotPasswordOTPVerifyState());
                }
              },
            );
          }
        }
      } else {
        if (event.isLoginByEmail) {
          final data = await serviceLocator<AuthUsecase>().verifyEmailOtp(
            emailAddress: event.mobileOrEmail,
            otp: event.otp,
          );
          data.fold(
            (error) {
              showToast(message: '${error.message}');
              isLoading = false;
              emit(ConfirmOrOTPVerifyFailureState());
            },
            (success) {
              showToast(
                  message: AppLocalizations.of(navigatorKey.currentContext!)!
                      .verifiedSuccessfully);
              emit(ConfirmOrOTPVerifySuccessState());
              isLoading = false;
              if (!event.isForgotPasswordVerify) {
                if (!event.isUserExist) {
                  // New User
                  isLoading = false;
                  emit(NewUserRegisterState());
                } else {
                  // Exist User
                  add(LoginUserEvent(
                      emailOrMobile: event.mobileOrEmail,
                      otp: event.otp,
                      password: event.password,
                      isOtpLogin: event.isOtpVerify,
                      isLoginByEmail: event.isLoginByEmail,
                      loginAs: event.loginAs));
                }
              } else {
                emit(ForgotPasswordOTPVerifyState());
              }
            },
          );
        } else {
          // DEMO LOGIN
          if (event.isUserExist &&
              event.otp == '123456' &&
              !event.isForgotPasswordVerify) {
            add(LoginUserEvent(
                emailOrMobile: event.mobileOrEmail,
                otp: event.otp,
                password: event.password,
                isOtpLogin: event.isOtpVerify,
                isLoginByEmail: event.isLoginByEmail,
                loginAs: event.loginAs));
            // emit(ConfirmMobileOrEmailState());
          } else if (!event.isUserExist &&
              event.otp == '123456' &&
              !event.isForgotPasswordVerify) {
            isLoading = false;
            emit(NewUserRegisterState());
          } else if (event.isUserExist &&
              event.otp == '123456' &&
              event.isForgotPasswordVerify) {
            emit(ForgotPasswordOTPVerifyState());
          } else {
            isLoading = false;
            otpController.clear();
            showToast(
                message: AppLocalizations.of(navigatorKey.currentContext!)!
                    .enterValidOtp);
            emit(SignInWithOTPFailureState());
          }
        }
      }
    } else {
      showToast(
          message:
              AppLocalizations.of(navigatorKey.currentContext!)!.enterValidOtp);
      isLoading = false;
      emit(SignInWithOTPFailureState());
    }
  }

  Future<void> _otpOnChange(
      OTPOnChangeEvent event, Emitter<AuthState> emit) async {
    emit(OTPOnChangeState());
  }

  FutureOr<void> _verifyUserDetails(
      VerifyUserEvent event, Emitter<AuthState> emit) async {
    emit(VerifyLoadingState());
    isLoading = true;
    final data = await serviceLocator<AuthUsecase>().verifyUser(
        emailOrMobileNumber: event.mobileOrEmail,
        isLoginByEmail: event.loginByMobile,
        role: event.loginAs);
    data.fold(
      (error) {
        isLoading = false;
        emit(VerifyFailureState());
      },
      (success) {
        userExist = success.success;
        // emit(VerifySuccessState());
        isLoading = false;
        if (userExist) {
          if (event.forgotPassword == true) {
            emit(ForgotPasswordOnTapState());
          } else {
            emit(VerifySuccessState());
          }
        } else {
          emit(UserNotExistState(message: "User not found. Please register."));
        }
      },
    );
  }

  Future<void> _timerEvent(
      VerifyTimerEvent event, Emitter<AuthState> emit) async {
    timerDuration = event.duration;
    emit(VerifyTimerState(duration: event.duration));
  }

  // Register

  Future<void> _getProfileImage(
      ImageUpdateEvent event, Emitter<AuthState> emit) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: event.source);

    if (image != null) {
      profileImage = image.path.toString();
    }
    emit(ImageUpdateState());
  }

  FutureOr _registerUser(
      RegisterUserEvent event, Emitter<AuthState> emit) async {
    emit(LoginLoadingState());
    isLoading = true;
    // if (event.profileImage.isNotEmpty) {
    final data = await serviceLocator<AuthUsecase>().userRegister(
        userName: event.userName,
        mobileNumber: event.mobileNumber,
        emailAddress: event.emailAddress,
        password: event.password,
        countryCode: event.countryCode,
        gender: event.gender,
        profileImage: event.profileImage,
        role: event.loginAs);
    data.fold(
      (error) {
        showToast(message: '${error.message}');
        isLoading = false;
        emit(LoginFailureState());
      },
      (success) async {
        showToast(
            message: AppLocalizations.of(navigatorKey.currentContext!)!
                .registerSuccessfully);
        isLoading = false;
        // emit(LoginSuccessState());
        await AppSharedPreference.setToken(
            '${success.tokenType} ${success.accessToken}');
        await AppSharedPreference.setLoginStatus(true);
        add(GetUserEvent());
      },
    );
    // } else {
    //   showToast(message: 'Select Profile Image');
    //   isLoading = false;
    //   emit(LoginFailureState());
    // }
  }

  Future<void> _registerInit(
      RegisterPageInitEvent event, Emitter<AuthState> emit) async {
    emit(AuthDataLoadingState());
    if (event.arg.isLoginByEmail) {
      rEmailController.text = event.arg.emailOrMobile;
    } else {
      rMobileController.text = event.arg.emailOrMobile;
    }
    isLoginByEmail = event.arg.isLoginByEmail;
    countries = event.arg.countryList;
    flagImage = event.arg.countryFlag;
    dialCode = event.arg.dialCode;
    countryCode = event.arg.contryCode;
    loginAs = event.arg.loginAs;
    emit(AuthDataSuccessState());
  }

  Future<void> _verifyInit(
      VerifyPageInitEvent event, Emitter<AuthState> emit) async {
    emit(AuthDataLoadingState());
    if (event.arg.isLoginByEmail) {
      rEmailController.text = event.arg.mobileOrEmail;
    } else {
      rMobileController.text = event.arg.mobileOrEmail;
    }
    isLoginByEmail = event.arg.isLoginByEmail;
    countries = event.arg.countryList;
    flagImage = event.arg.countryFlag;
    dialCode = event.arg.dialCode;
    countryCode = event.arg.countryCode;
    loginAs = event.arg.loginAs;
    emit(AuthDataSuccessState());
  }

  FutureOr _getReferralCode(
      ReferralEvent event, Emitter<AuthState> emit) async {
    isLoading = true;
    if (event.referralCode == 'Skip') {
      isLoading = false;
      emit(ReferralSuccessState());
    } else {
      if (event.referralCode.isNotEmpty) {
        final data = await serviceLocator<AuthUsecase>()
            .referralCode(referralCode: event.referralCode);
        data.fold(
          (error) {
            showToast(message: '${error.message}');
            isLoading = false;
            emit(ReferralFailureState());
          },
          (success) async {
            showToast(
                message:
                    AppLocalizations.of(navigatorKey.currentContext!)!.success);
            isLoading = false;
            emit(ReferralSuccessState());
          },
        );
      } else {
        isLoading = false;
        showToast(
            message: AppLocalizations.of(navigatorKey.currentContext!)!
                .enterTheCode);
      }
    }
  }

  // Login

  FutureOr _loginUser(LoginUserEvent event, Emitter<AuthState> emit) async {
    emit(LoginLoadingState());
    isLoading = true;
    final data = await serviceLocator<AuthUsecase>().userLogin(
        emailOrMobile: event.emailOrMobile,
        otp: event.otp,
        password: event.password,
        isOtpLogin: event.isOtpLogin,
        isLoginByEmail: event.isLoginByEmail,
        role: event.loginAs);
    data.fold(
      (error) {
        // showToast(message: '${error.message}');
        if (error.message != null) {
          showToast(message: error.message!);
        } else {
          if (!event.isOtpLogin) {
            showToast(
                message: AppLocalizations.of(navigatorKey.currentContext!)!
                    .enterValidPassword);
          } else {
            showToast(
                message: AppLocalizations.of(navigatorKey.currentContext!)!
                    .enterValidOtp);
          }
        }
        isLoading = false;
        emit(LoginFailureState());
      },
      (success) async {
        isLoading = false;
        showToast(
            message: AppLocalizations.of(navigatorKey.currentContext!)!
                .loginSuccessfully);
        await AppSharedPreference.setToken('Bearer ${success.accessToken}');
        await AppSharedPreference.setLoginStatus(true);
        add(GetUserEvent());
      },
    );
  }

  // UserDetails
  FutureOr<void> _getUserDetails(
      GetUserEvent event, Emitter<AuthState> emit) async {
    final data = await serviceLocator<AuthUsecase>().userDetails();
    data.fold(
      (error) {
        emit(LoginFailureState());
      },
      (success) async {
        userData = success.data;
        emit(LoginSuccessState());
      },
    );
  }

  // Update Password
  FutureOr _updatePassword(
      UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    isLoading = true;
    final data = await serviceLocator<AuthUsecase>().updatePassword(
        emailOrMobile: event.emailOrMobile,
        password: event.password,
        role: event.role,
        isLoginByEmail: event.isLoginByEmail);
    data.fold(
      (error) {
        showToast(message: '${error.message}');
        isLoading = false;
        emit(ForgotPasswordUpdateFailureState());
      },
      (success) async {
        showToast(
            message: AppLocalizations.of(navigatorKey.currentContext!)!
                .passwordChangedSuccessfully);
        isLoading = false;
        emit(ForgotPasswordUpdateSuccessState());
      },
    );
  }
}
