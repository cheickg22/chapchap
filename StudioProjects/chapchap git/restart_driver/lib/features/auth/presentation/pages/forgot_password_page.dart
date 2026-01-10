import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_background.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_bloc.dart';
import 'update_password_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  static const String routeName = '/forgotPasswordPage';
  final ForgotPasswordPageArguments arg;
  const ForgotPasswordPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is ForgotPasswordOTPVerifyState) {
            Navigator.pushNamed(context, UpdatePasswordPage.routeName,
                arguments: UpdatePasswordPageArguments(
                    isLoginByEmail: arg.isLoginByEmail,
                    emailOrMobile: arg.emailOrMobile));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                body: CustomBackground(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: context.read<AuthBloc>().formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).width * 0.05),
                              Center(
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .forgotPassword,
                                  textAlign: TextAlign.center,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                          color: AppColors.blackText,
                                          fontSize: 18),
                                ),
                              ),
                              SizedBox(height: size.width * 0.1),
                              MyText(
                                text:
                                    AppLocalizations.of(context)!.otpSentMobile,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ),
                              ),
                              SizedBox(height: size.width * 0.05),
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (!arg.isLoginByEmail)
                                      SizedBox(
                                        height: 20,
                                        width: 30,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.network(
                                            arg.countryFlag,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 10),
                                    MyText(
                                      text: arg.emailOrMobile,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(
                                            color: AppColors.blackText,
                                          ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.1),
                              buildPinField(context),
                              SizedBox(height: size.width * 0.02),
                              SizedBox(height: size.width * 0.1),
                              buildButton(context),
                              SizedBox(height: size.width * 0.3),
                            ],
                          ),
                        ),
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

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.confirm,
        borderRadius: 10,
        height: MediaQuery.sizeOf(context).height * 0.06,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          context.read<AuthBloc>().add(
                ConfirmOrVerifyOTPEvent(
                    isUserExist: true,
                    isLoginByEmail: arg.isLoginByEmail,
                    isOtpVerify: true,
                    isForgotPasswordVerify: true,
                    mobileOrEmail: arg.emailOrMobile,
                    otp: context.read<AuthBloc>().otpController.text,
                    password: '',
                    firebaseVerificationId:
                        context.read<AuthBloc>().firebaseVerificationId,
                    loginAs: (arg.loginAs == '')? 'driver': arg.loginAs),
              );
        },
      ),
    );
  }

  Widget buildPinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.enterOtp,
          textStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                color: AppColors.blackText,
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
                          isForgotPassword: true,
                          dialCode: arg.contryCode,
                          mobileOrEmail: arg.emailOrMobile,
                          isLoginByEmail: arg.isLoginByEmail,
                        ),
                      );
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
}
