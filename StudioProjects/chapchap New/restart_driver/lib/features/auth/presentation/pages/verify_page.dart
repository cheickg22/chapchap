import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_background.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../loading/application/loading_bloc.dart';
import '../../application/auth_bloc.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class VerifyPage extends StatefulWidget {
  static const String routeName = '/verifyPage';
  final VerifyArguments arg;
  const VerifyPage({super.key, required this.arg});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage>
    with SingleTickerProviderStateMixin {
  Timer? timer;
  timerCount(BuildContext cont,
      {required int duration, bool? isCloseTimer}) async {
    int count = duration;

    if (isCloseTimer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        count--;
        if (count <= 0) {
          timer?.cancel();
        }
        cont.read<AuthBloc>().add(VerifyTimerEvent(duration: count));
      });
    }

    if (isCloseTimer != null && isCloseTimer) {
      timer?.cancel();
      cont.read<AuthBloc>().add(VerifyTimerEvent(duration: 0));
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(GetCommonModuleEvent())
        ..add(VerifyPageInitEvent(arg: widget.arg)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
            if (!widget.arg.userExist && widget.arg.isOtpVerify) {
              context.read<AuthBloc>().add(
                    SignInWithOTPEvent(
                      isOtpVerify: widget.arg.isOtpVerify,
                      isForgotPassword: false,
                      mobileOrEmail: widget.arg.mobileOrEmail,
                      dialCode: widget.arg.dialCode,
                      isLoginByEmail: widget.arg.isLoginByEmail,
                    ),
                  );
              timerCount(context, duration: 60);
            }
          } else if (state is ForgotPasswordOTPSendState) {
            Navigator.pushNamed(
              context,
              ForgotPasswordPage.routeName,
              arguments: ForgotPasswordPageArguments(
                  isLoginByEmail: widget.arg.isLoginByEmail,
                  contryCode: widget.arg.dialCode,
                  countryFlag: widget.arg.countryFlag,
                  emailOrMobile: widget.arg.mobileOrEmail,
                  loginAs: (widget.arg.loginAs == '')
                      ? 'driver'
                      : widget.arg.loginAs),
            );
          } else if (state is NewUserRegisterState) {
            if (mounted) {
              Navigator.pushNamed(context, RegisterPage.routeName,
                  arguments: RegisterPageArguments(
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    dialCode: widget.arg.dialCode,
                    contryCode: widget.arg.countryCode,
                    countryFlag: widget.arg.countryFlag,
                    emailOrMobile: widget.arg.mobileOrEmail,
                    countryList: widget.arg.countryList,
                    loginAs: widget.arg.loginAs,
                    isRefferalEarnings: widget.arg.isRefferalEarnings,
                  ));
            }
          } else if (state is LoginSuccessState ||
              state is ConfirmMobileOrEmailState) {
            if (userData != null) {
              context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            }
            if (userData!.serviceLocationId != null) {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  DriverProfilePage.routeName,
                  arguments: VehicleUpdateArguments(
                    from: '',
                  ),
                  (route) => false);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: CustomBackground(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.sizeOf(context).width * 0.1),
                          context.read<AuthBloc>().isOtpVerify
                              ? MyText(
                                  text: widget.arg.isLoginByEmail
                                      ? AppLocalizations.of(context)!
                                          .otpSentEmail
                                      : AppLocalizations.of(context)!
                                          .testOtp
                                          .replaceAll('***', '123456'),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: AppColors.blackText,
                                      ),
                                )
                              : MyText(
                                  text: AppLocalizations.of(context)!
                                      .enterYourPassword,
                                  textAlign: TextAlign.center,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: AppColors.blackText,
                                      ),
                                ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (!widget.arg.isLoginByEmail)
                                SizedBox(
                                  height: 20,
                                  width: 30,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      widget.arg.countryFlag,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 10),
                              MyText(
                                text: widget.arg.mobileOrEmail,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: AppColors.blackText,
                                    ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: MyText(
                                  text: AppLocalizations.of(context)!.change,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: AppColors.blackText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          if (widget.arg.userExist &&
                              !context.read<AuthBloc>().isOtpVerify)
                            passwordField(context),
                          if (!widget.arg.userExist ||
                              context.read<AuthBloc>().isOtpVerify)
                            buildPinField(context),
                          const SizedBox(height: 20),
                          buildLoginButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget passwordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              text: AppLocalizations.of(context)!.password,
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.blackText, fontSize: 16),
            ),
            InkWell(
              onTap: () {
                context.read<AuthBloc>().isOtpVerify = true;
                context.read<AuthBloc>().add(SignInWithOTPEvent(
                      isOtpVerify: true,
                      isForgotPassword: false,
                      dialCode: widget.arg.dialCode,
                      mobileOrEmail: widget.arg.mobileOrEmail,
                      isLoginByEmail: widget.arg.isLoginByEmail,
                    ));

                timerCount(context, duration: 60);
              },
              child: MyText(
                text: AppLocalizations.of(context)!.signUsingOtp,
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.blackText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: context.read<AuthBloc>().passwordController,
          filled: true,
          obscureText: !context.read<AuthBloc>().showPassword,
          hintText: AppLocalizations.of(context)!.enterYourPassword,
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(ShowPasswordIconEvent(
                  showPassword: context.read<AuthBloc>().showPassword));
            },
            child: !context.read<AuthBloc>().showPassword
                ? const Icon(
                    Icons.visibility_off_outlined,
                    color: AppColors.darkGrey,
                  )
                : const Icon(
                    Icons.visibility,
                    color: AppColors.darkGrey,
                  ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            context.read<AuthBloc>().add(
                  SignInWithOTPEvent(
                    isOtpVerify: true,
                    isForgotPassword: true,
                    mobileOrEmail: widget.arg.mobileOrEmail,
                    dialCode: widget.arg.dialCode,
                    isLoginByEmail: widget.arg.isLoginByEmail,
                  ),
                );
          },
          child: MyText(
            text: '${AppLocalizations.of(context)!.forgotPassword} ?',
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).disabledColor, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget buildPinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              text: AppLocalizations.of(context)!.enterOtp,
              textStyle: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppColors.blackText, fontSize: 16),
            ),
            if (widget.arg.userExist &&
                context.read<AuthBloc>().timerDuration == 0)
              InkWell(
                onTap: () {
                  context.read<AuthBloc>().isOtpVerify = false;
                  timerCount(context, duration: 0, isCloseTimer: true);
                },
                child: MyText(
                  text: AppLocalizations.of(context)!.signUsingPassword,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          appContext: context,
          controller: context.read<AuthBloc>().otpController,
          textStyle: Theme.of(context).textTheme.bodyLarge,
          length: 6,
          autoFocus: true,
          obscureText: false,
          blinkWhenObscuring: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 45,
            fieldWidth: 45,
            activeFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveColor: Theme.of(context).scaffoldBackgroundColor,
            selectedFillColor: Theme.of(context).scaffoldBackgroundColor,
            selectedColor: Theme.of(context).disabledColor,
            selectedBorderWidth: 1,
            inactiveBorderWidth: 1,
            activeBorderWidth: 1,
            activeColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          cursorColor: Theme.of(context).dividerColor,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          enablePinAutofill: false,
          autoDisposeControllers: false,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          beforeTextPaste: (_) => false,
          onChanged: (_) => context.read<AuthBloc>().add(OTPOnChangeEvent()),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: context.read<AuthBloc>().timerDuration != 0
              ? null
              : () {
                  context.read<AuthBloc>().add(
                        SignInWithOTPEvent(
                          isOtpVerify: true,
                          isForgotPassword: false,
                          dialCode: widget.arg.dialCode,
                          mobileOrEmail: widget.arg.mobileOrEmail,
                          isLoginByEmail: widget.arg.isLoginByEmail,
                        ),
                      );
                  timerCount(context, duration: 60);
                },
          child: MyText(
            text: context.read<AuthBloc>().timerDuration != 0
                ? '${AppLocalizations.of(context)!.resendOtp} 00:${context.read<AuthBloc>().timerDuration}'
                : AppLocalizations.of(context)!.resendOtp,
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: context.read<AuthBloc>().timerDuration != 0
                      ? Theme.of(context).disabledColor
                      : AppColors.blackText,
                ),
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: CustomButton(
            borderRadius: 10,
            height: MediaQuery.sizeOf(context).height * 0.06,
            buttonName: (!widget.arg.userExist)
                ? AppLocalizations.of(context)!.signup
                : AppLocalizations.of(context)!.login,
            isLoader: context.read<AuthBloc>().isLoading,
            onTap: () {
              if (widget.arg.isOtpVerify ||
                  context.read<AuthBloc>().isOtpVerify) {
                // OTPverify
                context.read<AuthBloc>().add(
                      ConfirmOrVerifyOTPEvent(
                          isUserExist: widget.arg.userExist,
                          isLoginByEmail: widget.arg.isLoginByEmail,
                          isOtpVerify: context.read<AuthBloc>().isOtpVerify,
                          isForgotPasswordVerify: false,
                          mobileOrEmail: widget.arg.mobileOrEmail,
                          otp: context.read<AuthBloc>().otpController.text,
                          password:
                              context.read<AuthBloc>().passwordController.text,
                          firebaseVerificationId:
                              context.read<AuthBloc>().firebaseVerificationId,
                          loginAs: widget.arg.loginAs),
                    );
              } else {
                // PasswordLogin
                context.read<AuthBloc>().add(LoginUserEvent(
                    emailOrMobile: widget.arg.mobileOrEmail,
                    otp: context.read<AuthBloc>().otpController.text,
                    password: context.read<AuthBloc>().passwordController.text,
                    isOtpLogin: context.read<AuthBloc>().isOtpVerify,
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    loginAs: widget.arg.loginAs));
              }
            },
          ),
        );
      },
    );
  }
}
