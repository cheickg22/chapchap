import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:restart_user/core/utils/extensions.dart';
import '../../../../../../common/app_constants.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/circle_ui.dart';

class ReferralPage extends StatelessWidget {
  final ReferralArguments args;

  static const String routeName = '/ReferralPage';

  const ReferralPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          size: 20,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      MyText(
                        text: args.title,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                      )
                    ],
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        width: size.width,
                        height: size.height * 0.6,
                        child: Column(
                          children: [
                            const Image(
                              image: AssetImage(AppImages.referral),
                            ),
                            MyText(
                              text: args
                                  .userData.referralComissionString, // Display,
                              textAlign: TextAlign.center,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(left: -80, top: -70, child: CircleOne()),
                      const Positioned(left: 40, top: -130, child: CircleTwo()),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.shareYourInvite,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 18),
                          // size: 16,
                        ),
                        SizedBox(
                          height: size.width * 0.04,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: args.userData.refferalCode,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor,fontSize: 18),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: args.userData.refferalCode));
                                context.showSnackBar(
                                    message: AppLocalizations.of(context)!
                                        .referralCopied);
                              },
                              child: Icon(
                                Icons.copy,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.width * 0.03,
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(context).disabledColor,
                        )
                      ],
                    ),
                  ),
                  //  SizedBox(
                  //   height: size.width * 0.2,
                  // ),
                  const Spacer(),
                  CustomButton(
                      buttonName: AppLocalizations.of(context)!.invite,
                      onTap: () async {
                         String androidUrl = args.userData.androidApp;
                         String iosUrl = args.userData.iosApp;     
                        
                          if(!context.mounted)return;
                          await Share.share("${AppLocalizations.of(context)!.referalShareOne.replaceAll('222', args.userData.refferalCode).replaceAll('111', AppConstants.title)}\n$androidUrl \n$iosUrl");
                      }),
                  SizedBox(
                    height: size.width * 0.1,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
