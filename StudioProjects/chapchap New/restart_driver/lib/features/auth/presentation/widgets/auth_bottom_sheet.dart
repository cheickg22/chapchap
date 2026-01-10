import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';

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

  _closeDialog() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: <Widget>[
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
                              // mainAxisAlignment: MainAxisAlignment.center,
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
