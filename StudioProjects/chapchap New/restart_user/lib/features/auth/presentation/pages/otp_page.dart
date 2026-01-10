// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/register_page.dart';
import '../../../../common/app_colors.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../loading/application/loader_bloc.dart';
import '../../application/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  static const String routeName = '/otpPage';
  final OtpPageArguments arg;

  const OtpPage({super.key, required this.arg});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
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
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(CountryGetEvent())
        ..add(GetCommonModuleEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is GetCommonModuleSuccess) {
            CustomLoader.dismiss(context);
            final authBloc = context.read<AuthBloc>();
            authBloc.isOtpVerify = true;
            authBloc.add(
              SignInWithOTPEvent(
                isOtpVerify: widget.arg.isOtpVerify,
                isForgotPassword: false,
                mobileOrEmail: widget.arg.mobileOrEmail,
                dialCode: widget.arg.dialCode,
                isLoginByEmail: authBloc.selectLoginMethods,
                context: context,
              ),
            );
            timerCount(context, duration: 60);
          } else if (state is GetCommonModuleFailure) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
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
                    isRefferalEarnings: widget.arg.isRefferalEarnings,
                  ));
            }
          } else if (state is LoginSuccessState ||
              state is ConfirmMobileOrEmailState) {
            context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            Navigator.pushNamedAndRemoveUntil(
                context, HomePage.routeName, (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.verifyYourAccount,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
                textColor: Theme.of(context).primaryColorDark,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // padding: EdgeInsets.all(size.width*0.05),
                          padding: EdgeInsets.fromLTRB(
                              size.width * 0.025,
                              size.width * 0.05,
                              size.width * 0.025,
                              size.width * 0.05),
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.2, color: const Color(0xffFAFAFB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.sendCode,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 14),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      MyText(
                                        text: widget.arg.dialCode,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 18),
                                      ),
                                      MyText(
                                        text: widget.arg.mobileOrEmail,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: (widget.arg
                                                            .isLoginByEmail ==
                                                        false)
                                                    ? 18
                                                    : 16),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .changeNumber,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: AppColors.primary,
                                              fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.width * 0.1),
                        Container(
                            padding: EdgeInsets.all(size.width * 0.025),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: (Theme.of(context).brightness ==
                                        Brightness.dark)
                                    ? AppColors.black
                                    : const Color(0xffFAFAFB)),
                            child: buildPinField(context)),
                        SizedBox(
                          height: size.width * 0.1,
                        ),
                        buildSendOtpButton(context),
                        SizedBox(
                          height: size.width * 0.1,
                        ),
                      ],
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

  Widget buildPinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.enterOtp,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 16,
                color: Theme.of(context).primaryColorDark,
              ),
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          appContext: context,
          controller: context.read<AuthBloc>().otpController,
          textStyle: Theme.of(context).textTheme.bodyLarge,
          length: 6,
          obscureText: false,
          blinkWhenObscuring: false,
          autoFocus: true,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 45,
            fieldWidth: 45,
            activeFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveColor: AppColors.borderColors,
            selectedFillColor: Theme.of(context).scaffoldBackgroundColor,
            selectedColor: AppColors.borderColors,
            selectedBorderWidth: 1,
            inactiveBorderWidth: 1,
            activeBorderWidth: 1,
            activeColor: Theme.of(context).hintColor,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              text: context.read<AuthBloc>().timerDuration != 0
                  ? '${AppLocalizations.of(context)!.resendOtp} 00:${context.read<AuthBloc>().timerDuration}'
                  : '${AppLocalizations.of(context)!.resendOtp} 00:00',
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: context.read<AuthBloc>().timerDuration != 0
                        ? Theme.of(context).hintColor
                        : Theme.of(context).primaryColorDark,
                    // : AppColors.blackText,
                  ),
            ),
            InkWell(
              onTap: context.read<AuthBloc>().timerDuration != 0
                  ? null
                  : () {
                      final authBloc = context.read<AuthBloc>();
                      authBloc.isOtpVerify = true;
                      context.read<AuthBloc>().add(
                            SignInWithOTPEvent(
                              isOtpVerify: widget.arg.isOtpVerify,
                              isForgotPassword: false,
                              mobileOrEmail: widget.arg.mobileOrEmail,
                              dialCode: widget.arg.dialCode,
                              isLoginByEmail: widget.arg.isLoginByEmail,
                              context: context,
                            ),
                          );
                      timerCount(context, duration: 60);
                    },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.white,
                    border:
                        Border.all(width: 1.1, color: AppColors.borderColors)),
                child: MyText(
                  text: AppLocalizations.of(context)!.resendOtp,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: context.read<AuthBloc>().timerDuration != 0
                            ? AppColors.primary.withOpacity(0.5)
                            : AppColors.primary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSendOtpButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: CustomButton(
            borderRadius: 10,
            width: MediaQuery.sizeOf(context).width,
            buttonName: AppLocalizations.of(context)!.verifyOtp,
            textSize: 16,
            isLoader: context.read<AuthBloc>().isLoading,
            onTap: () {
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
                      context: context,
                    ),
                  );
            },
          ),
        );
      },
    );
  }
}
