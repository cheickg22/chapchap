// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import 'package:restart_tagxi/features/loading/application/loading_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../home/presentation/pages/home_page/page/home_page.dart';
import '../../landing/presentation/page/landing_page.dart';
import '../../language/presentation/page/choose_language_page.dart';

class LoaderPage extends StatefulWidget {
  static const String routeName = '/loaderPage';

  const LoaderPage({super.key});

  @override
  State<LoaderPage> createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => LoaderBloc()..add(CheckPermissionEvent()),
      child: BlocListener<LoaderBloc, LoaderState>(
        listener: (context, state) {
          if (state is LoaderLocationSuccessState) {
            context.read<LoaderBloc>().add(LoaderGetLocalDataEvent());
          }
          if (state is LoaderSuccessState) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (!state.loginStatus) {
                    if (state.selectedLanguage.isNotEmpty) {
                      if (state.landingStatus) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginPage.routeName,
                          (route) => false,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LandingPage.routeName, (route) => false,
                            arguments: LandingPageArguments(type: 'driver'));
                      }
                    } else {
                      Navigator.pushNamed(
                        context,
                        ChooseLanguagePage.routeName,
                        arguments: ChangeLanguageArguments(from: 0),
                      );
                    }
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                        context, HomePage.routeName, (route) => false);
                  }
                });
              },
            );
          }
        },
        child: BlocBuilder<LoaderBloc, LoaderState>(
          builder: (context, state) {
            return PopScope(
              canPop: false,
              child: Scaffold(
                backgroundColor:
                    (context.read<LoaderBloc>().locationApproved == null ||
                            context.read<LoaderBloc>().locationApproved == true)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).scaffoldBackgroundColor,
                resizeToAvoidBottomInset: false,
                body: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Center(
                    child: (context.read<LoaderBloc>().locationApproved ==
                                null ||
                            context.read<LoaderBloc>().locationApproved == true)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.loader,
                                width: size.width * 0.51,
                                height: size.height * 0.51,
                              )
                            ],
                          )
                        : (context.read<LoaderBloc>().locationApproved == false)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.locationImage,
                                    width: size.width * 0.9,
                                    height: size.width * 0.9,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  SizedBox(
                                    width: size.width * 0.9,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .whyBackgroundLocation,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  SizedBox(
                                    width: size.width * 0.9,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .locationPermDesc
                                          .replaceAll(
                                              '111', AppConstants.title),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: const Color(0xff5D5F62),
                                            fontSize: 16,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 10,
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  SizedBox(height: size.width * 0.2),
                                  CustomButton(
                                      buttonName: AppLocalizations.of(context)!
                                          .continueText,
                                      width: size.width,
                                      textSize: 16,
                                      borderRadius: 10,
                                      onTap: () async {
                                        await Permission.location.request();
                                        await Permission.locationAlways
                                            .request()
                                            .whenComplete(
                                          () async {
                                            context
                                                .read<LoaderBloc>()
                                                .add(LoaderGetLocalDataEvent());
                                          },
                                        );
                                      })
                                ],
                              )
                            : Container(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
