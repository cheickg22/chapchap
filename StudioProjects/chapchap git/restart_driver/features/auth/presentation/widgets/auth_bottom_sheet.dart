import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';

class AuthBottomSheet extends StatefulWidget {
  final LandingPageArguments args;
  final TextEditingController emailOrMobile;
  final dynamic continueFunc;
  final bool showLoginBtn;
  final bool isLoginByEmail;
  final Function()? onTapEvent;
  final Function(String)? onChangeEvent;
  final Function(String)? onSubmitEvent;
  final Function()? countrySelectFunc;
  final GlobalKey<FormState> formKey;
  final String dialCode;
  final String flagImage;
  final FocusNode focusNode;
  final bool isShowLoader;

  const AuthBottomSheet(
      {super.key,
      required this.emailOrMobile,
      required this.continueFunc,
      required this.showLoginBtn,
      required this.isLoginByEmail,
      this.onTapEvent,
      this.onChangeEvent,
      this.onSubmitEvent,
      required this.formKey,
      required this.dialCode,
      required this.flagImage,
      this.countrySelectFunc,
      required this.focusNode,
      required this.isShowLoader,
      required this.args});

  @override
  State<StatefulWidget> createState() => AuthBottomSheetState();
}

class AuthBottomSheetState extends State<AuthBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.linearToEaseOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continuePressed() {
    _controller.forward();
  }

  _closeDialog() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: <Widget>[
        Container(
          height: widget.showLoginBtn ? size.height * 0.38 : size.height * 0.25,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 1,
              )
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      text: (widget.args.type == "driver")
                          ? "${AppLocalizations.of(context)!.welcome}, ${AppLocalizations.of(context)!.driver}!"
                          : "${AppLocalizations.of(context)!.welcome}, ${AppLocalizations.of(context)!.owner}!",
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(AppImages.hi, height: 20, width: 25)
                  ],
                ),
                SizedBox(height: size.width * 0.05),
                MyText(
                  text:
                      '${AppLocalizations.of(context)!.email}/${AppLocalizations.of(context)!.mobile}',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: size.width * 0.02),
                Form(
                  key: widget.formKey,
                  child: CustomTextField(
                    controller: widget.emailOrMobile,
                    filled: true,
                    focusNode: widget.focusNode,
                    hintText: AppLocalizations.of(context)!.emailOrMobile,
                    prefixConstraints:
                        BoxConstraints(maxWidth: size.width * 0.2),
                    prefixIcon: !widget.isLoginByEmail
                        ? Center(
                            child: InkWell(
                              onTap: widget.countrySelectFunc,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 25,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: AppColors.darkGrey,
                                      borderRadius: BorderRadius.circular(5),
                                      image: (widget.flagImage.isNotEmpty)
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  widget.flagImage),
                                              fit: BoxFit.fill)
                                          : null,
                                    ),
                                  ),
                                  MyText(
                                    text: widget.dialCode,
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : null,
                    onTap: widget.onTapEvent,
                    onSubmitted: widget.onSubmitEvent,
                    onChange: widget.onChangeEvent,
                    validator: (value) {
                      if (value!.isNotEmpty &&
                          !AppValidation.emailValidate(value) &&
                          !AppValidation.mobileNumberValidate(value)) {
                        return AppLocalizations.of(context)!
                            .enterValidEmailOrMobile;
                      } else if (value.isEmpty) {
                        return AppLocalizations.of(context)!.enterEmailOrMobile;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                // if (widget.showLoginBtn) ...[
                SizedBox(height: size.width * 0.05),
                Center(
                  child: CustomButton(
                    buttonName: AppLocalizations.of(context)!.continueText,
                    borderRadius: 18,
                    width: size.width,
                    height: size.width * 0.12,
                    textColor: AppColors.white,
                    buttonColor: (widget.emailOrMobile.text.isEmpty)
                        ? Theme.of(context)
                            .disabledColor
                            .withAlpha((0.5 * 255).toInt())
                        : null,
                    onTap: () {
                      if (widget.formKey.currentState!.validate() &&
                          widget.emailOrMobile.text.isNotEmpty) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _continuePressed();
                      }
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.02),
                SizedBox(
                  width: size.width,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0;
                          i <
                              AppLocalizations.of(context)!
                                  .agreeTermsAndPrivacy
                                  .toString()
                                  .split(' ')
                                  .length;
                          i++)
                        (AppLocalizations.of(context)!
                                        .agreeTermsAndPrivacy
                                        .toString()
                                        .split(' ')[i] ==
                                    '1111' ||
                                AppLocalizations.of(context)!
                                        .agreeTermsAndPrivacy
                                        .toString()
                                        .split(' ')[i] ==
                                    '2222')
                            ? InkWell(
                                onTap: () async {
                                  if (AppLocalizations.of(context)!
                                          .agreeTermsAndPrivacy
                                          .toString()
                                          .split(' ')[i] ==
                                      '1111') {
                                    Navigator.pushNamed(context,
                                        TermsPrivacyPolicyViewPage.routeName,
                                        arguments:
                                            TermsAndPrivacyPolicyArguments(
                                                isPrivacyPolicy: false));
                                  } else {
                                    Navigator.pushNamed(context,
                                        TermsPrivacyPolicyViewPage.routeName,
                                        arguments:
                                            TermsAndPrivacyPolicyArguments(
                                                isPrivacyPolicy: true));
                                  }
                                },
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                              .agreeTermsAndPrivacy
                                              .toString()
                                              .split(' ')[i] ==
                                          '1111'
                                      ? '${AppLocalizations.of(context)!.terms} '
                                      : '${AppLocalizations.of(context)!.privacy} ',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.normal),
                                ),
                              )
                            : MyText(
                                text:
                                    '${AppLocalizations.of(context)!.agreeTermsAndPrivacy.toString().split(' ')[i]} ',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.normal),
                              ),
                    ],
                  ),
                ),
                // ],
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _closeDialog,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                if (!widget.isLoginByEmail)
                                  MyText(
                                    text: widget.dialCode,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontSize: 20),
                                  ),
                                SizedBox(width: size.width * 0.02),
                                MyText(
                                  text: widget.emailOrMobile.text,
                                  maxLines: 3,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    text:
                                        "${AppLocalizations.of(context)!.isThisCorrect}  ",
                                  ),
                                  TextSpan(
                                    style: AppTextStyle.boldStyle(
                                      size: 16,
                                      weight: FontWeight.normal,
                                    ).copyWith(
                                        color: (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? AppColors.black
                                            : AppColors.white,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                        decorationStyle:
                                            TextDecorationStyle.solid),
                                    text: AppLocalizations.of(context)!.edit,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _closeDialog,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              buttonName:
                                  AppLocalizations.of(context)!.continueText,
                              borderRadius: 18,
                              width: size.width,
                              height: size.width * 0.12,
                              isLoader: widget.isShowLoader,
                              onTap: widget.continueFunc,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
