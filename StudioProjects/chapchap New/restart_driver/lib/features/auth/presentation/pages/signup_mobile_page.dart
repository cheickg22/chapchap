import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/otp_page.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_validators.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';

class SignupMobilePage extends StatelessWidget {
  static const String routeName = '/SignupMobilePage';
  final SignupMobilePageArguments arg;

  const SignupMobilePage({super.key, required this.arg});

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
          } else if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is VerifySuccessState ||
              state is UserNotExistState) {
            final authBloc = context.read<AuthBloc>();
            // final mobileOrEmail = arg.mobileOrEmailSignUp
            final mobileOrEmail = authBloc.selectLoginMethods
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();
            if (mobileOrEmail.isNotEmpty) {
              Navigator.pushNamed(context, OtpPage.routeName,
                  arguments: OtpPageArguments(
                      mobileOrEmail: mobileOrEmail,
                      dialCode: authBloc.dialCode,
                      countryCode: context.read<AuthBloc>().countryCode,
                      countryFlag: context.read<AuthBloc>().flagImage,
                      isLoginByEmail: arg.mobileOrEmailSignUp,
                      isOtpVerify: true,
                      userExist: context.read<AuthBloc>().userExist,
                      isDemoLogin: true,
                      countryList: context.read<AuthBloc>().countries,
                      isRefferalEarnings:
                          context.read<AuthBloc>().isRefferalEarnings,
                      type: arg.type));
            } else {
              showToast(
                  message:
                      AppLocalizations.of(context)!.pleaseEnterMobileNumber);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.verifyPhone,
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
                        SizedBox(
                          height: size.width * 0.4,
                        ),
                        MyText(
                          text:
                              AppLocalizations.of(context)!.verifyMobileNumber,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          textStyle:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  // fontWeight: FontWeight.w600,
                                  fontSize: 26,
                                  color: Theme.of(context).primaryColorDark),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.confirmOtpNumber,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14,
                                  ),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        buildMobileField(context, size),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            MyText(
                              text: "By continuing, you agree to our",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 12,
                                  ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    TermsPrivacyPolicyViewPage.routeName,
                                    arguments: TermsAndPrivacyPolicyArguments(
                                        isPrivacyPolicy: false));
                              },
                              child: MyText(
                                text: " Terms of Service ",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                            MyText(
                              text: "and ",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 12,
                                  ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context,
                                    TermsPrivacyPolicyViewPage.routeName,
                                    arguments: TermsAndPrivacyPolicyArguments(
                                        isPrivacyPolicy: true));
                              },
                              child: MyText(
                                text: "Privacy Policy.",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.width * 0.1,
                        ),
                        buildSendOtpButton(context),
                        SizedBox(
                          height: size.width * 0.25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              text:
                                  '${AppLocalizations.of(context)!.alreadyHaveAccount} ',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 14),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    LoginPage.routeName, (route) => false,
                                    arguments:
                                        LoginPageArguments(type: arg.type));
                              },
                              child: MyText(
                                text: AppLocalizations.of(context)!.signIn,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.primary, fontSize: 14),
                              ),
                            ),
                          ],
                        )
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

  Widget buildMobileField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rMobileController,
      filled: true,
      fillColor: !context.read<AuthBloc>().isLoginByEmail
          ? Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).disabledColor.withAlpha((0.1 * 255).toInt())
              : AppColors.darkGrey
          : null,
      enabled: context.read<AuthBloc>().isLoginByEmail,
      hintText: AppLocalizations.of(context)!.mobile,
      focusNode: context.read<AuthBloc>().mobileFocusNode,
      keyboardType: TextInputType.number,
      prefixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      prefixIcon: Center(
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              context: context,
              builder: (cont) {
                return SelectCountryWidget(
                    countries: context.read<AuthBloc>().countries,
                    cont: context);
              },
            );
          },
          child: Row(
            children: [
              Container(
                height: 20,
                width: 25,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(5),
                  image: (context.read<AuthBloc>().flagImage.isNotEmpty)
                      ? DecorationImage(
                          image:
                              NetworkImage(context.read<AuthBloc>().flagImage),
                          fit: BoxFit.fill)
                      : null,
                ),
              ),
              MyText(text: context.read<AuthBloc>().dialCode),
            ],
          ),
        ),
      ),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().rMobileController.clear();
        },
        child: const Icon(
          Icons.cancel_outlined,
          color: AppColors.darkGrey,
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.mobileNumberValidate(value)) {
          return AppLocalizations.of(context)!.enterValidMobile;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterMobileNumber;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.email,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColorDark, fontSize: 14),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          controller: context.read<AuthBloc>().rEmailController,
          filled: true,
          borderRadius: 10,
          fillColor: !context.read<AuthBloc>().isLoginByEmail
              ? Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context)
                      .disabledColor
                      .withAlpha((0.1 * 255).toInt())
                  : AppColors.darkGrey
              : null,
          hintText: AppLocalizations.of(context)!.enterEmail,
          focusNode: context.read<AuthBloc>().emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().rEmailController.clear();
            },
            child: const Icon(
              Icons.cancel_outlined,
              color: AppColors.darkGrey,
            ),
          ),
          validator: (value) {
            if (value!.isNotEmpty && !AppValidation.emailValidate(value)) {
              return AppLocalizations.of(context)!.enterValidEmail;
            } else if (value.isEmpty) {
              return AppLocalizations.of(context)!.enterEmail;
            } else {
              return null;
            }
          },
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
            borderRadius: 5,
            width: MediaQuery.sizeOf(context).width,
            buttonName: AppLocalizations.of(context)!.sendOtp,
            textSize: 16,
            isLoader: context.read<AuthBloc>().isLoading,
            onTap: () {
              final mobileNumber =
                  context.read<AuthBloc>().rMobileController.text.trim();
              final email = context.read<AuthBloc>().rEmailController.text;
              context.read<AuthBloc>();
              context.read<AuthBloc>().add(VerifyUserEvent(
                  loginAs: context.read<AuthBloc>().loginAs,
                  mobileOrEmail: (context.read<AuthBloc>().selectLoginMethods)
                      ? email
                      : mobileNumber,
                  loginByMobile: (context.read<AuthBloc>().selectLoginMethods)
                      ? true
                      : false,
                  forgotPassword: false));
            },
          ),
        );
      },
    );
  }
}
