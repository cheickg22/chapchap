import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/page/home_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class DiagnosticPage extends StatelessWidget {
  static const String routeName = '/diagnostics';
  const DiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => HomeBloc()..add(CheckInternet()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          if (state is DiagnosticPageCheckState) {
            printWrapped("Page changed");
          }
          if (state is CheckLocationState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: state.isLocationEnabled
                      ? CustomDoubleButtonDialoge(
                          title: AppLocalizations.of(context)!.currentLocation,
                          content: AppLocalizations.of(context)!
                              .alertCurrentLocation,
                          yesBtnName: AppLocalizations.of(context)!.yes,
                          noBtnName: AppLocalizations.of(context)!.no,
                          yesBtnColor: AppColors.primary,
                          yesBtnFunc: () {
                            Navigator.of(context).pop();
                          },
                          noBtnFunc: () {
                            context.read<HomeBloc>().isLocationsEnabled = false;
                            context.read<HomeBloc>().add(UpdateEvent());
                            Navigator.of(context).pop();
                          },
                        )
                      : CustomSingleButtonDialoge(
                          title: AppLocalizations.of(context)!.currentLocation,
                          content: AppLocalizations.of(context)!
                              .locationPermissionText,
                          btnName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                );
              },
            );
          }
          if (state is CheckNotificationState && state.isNotificationEnabled) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: CustomDoubleButtonDialoge(
                    title: AppLocalizations.of(context)!.alertNotificationText,
                    content: AppLocalizations.of(context)!
                        .alertNotificationSubText
                        .replaceAll("*", "notification"),
                    yesBtnName: AppLocalizations.of(context)!.yes,
                    noBtnName: AppLocalizations.of(context)!.no,
                    yesBtnColor: AppColors.primary,
                    yesBtnFunc: () {
                      Navigator.of(context).pop();
                      if (userData!.role == 'driver' &&
                          userData!.approve == false) {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            DriverProfilePage.routeName,
                            arguments: VehicleUpdateArguments(
                              from: 'rejected',
                            ),
                            (route) => false);
                      }
                    },
                    noBtnFunc: () {
                      context.read<HomeBloc>().isNotificationsEnabled = false;
                      context.read<HomeBloc>().add(UpdateEvent());
                      Navigator.of(context).pop();
                      if (userData!.role == 'driver' &&
                          userData!.approve == false) {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            DriverProfilePage.routeName,
                            arguments: VehicleUpdateArguments(
                              from: 'rejected',
                            ),
                            (route) => false);
                      }
                    },
                  ),
                );
              },
            );
          }
          if (state is CheckSoundState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: CustomDoubleButtonDialoge(
                    title: AppLocalizations.of(context)!.alertSoundText,
                    content: AppLocalizations.of(context)!
                        .alertNotificationSubText
                        .replaceAll("*", "sound"),
                    yesBtnName: AppLocalizations.of(context)!.yes,
                    noBtnName: AppLocalizations.of(context)!.no,
                    yesBtnColor: AppColors.primary,
                    yesBtnFunc: () {
                      context.read<HomeBloc>().add(DiagnosticCompleteEvent());
                      Navigator.of(context).pop();
                    },
                    noBtnFunc: () {
                      context.read<HomeBloc>().isSoundsChecked = false;
                      context.read<HomeBloc>().add(UpdateEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            );
          }
          if (state is DiagnosticCompleteState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: AlertDialog(
                      actionsAlignment: MainAxisAlignment.center,
                      content: SizedBox(
                        height: size.height * 0.35,
                        child: Column(
                          children: [
                            const Image(
                              image: AssetImage(AppImages.diagnosticFinalAlert),
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .diagnosticFinalAlertText,
                              maxLines: 4,
                            )
                          ],
                        ),
                      ),
                      actions: [
                        CustomButton(
                          buttonName: AppLocalizations.of(context)!.done,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<HomeBloc>().add(
                                  DiagnosticCheckEvent(
                                      isDiagnosticsCheckPage: false),
                                );
                            Navigator.pushNamedAndRemoveUntil(
                                context, HomePage.routeName, (route) => false);
                          },
                        )
                      ],
                    ));
              },
            );
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SafeArea(
              child: Material(
                child: Directionality(
                  textDirection: context.read<HomeBloc>().textDirection == 'ltr'
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Scaffold(
                    body: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                width: size.width,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors
                                          .borderColors, // border color
                                      width: 1, // border width
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: size.width * 0.07,
                                        color: AppColors.hintColor,
                                      ),
                                    ),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .diagnotics,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    )
                                  ],
                                ),
                              ),
                              if (!context
                                  .read<HomeBloc>()
                                  .isDiagnosticsCheckPage)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: size.width * 0.08,
                                    ),
                                    const Image(
                                      image: AssetImage(
                                        AppImages.diagnosticInit,
                                      ),
                                    ),
                                    MyText(
                                      textAlign: TextAlign.center,
                                      text: AppLocalizations.of(context)!
                                          .dignosticsAssistText
                                          .replaceAll(
                                            "**",
                                            "\n",
                                          ),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.02,
                                    ),
                                    MyText(
                                      textAlign: TextAlign.center,
                                      text: AppLocalizations.of(context)!
                                          .dignosticsSolutionText
                                          .replaceAll(
                                            "**",
                                            "\n",
                                          ),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 16,
                                              color: AppColors.greyHintColor,
                                              fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                )
                            ],
                          ),
                          if (context.read<HomeBloc>().isDiagnosticsCheckPage)
                            Container(
                              padding: EdgeInsets.all(size.width * 0.05),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: size.width * 0.18,
                                  ),
                                  diagnosticListWidgets(
                                      size,
                                      context,
                                      Icons.language,
                                      AppLocalizations.of(context)!
                                          .internetConnectivity,
                                      AppLocalizations.of(context)!
                                          .internetSubText,
                                      context
                                          .read<HomeBloc>()
                                          .isInternetConnected,
                                      true),
                                  diagnosticListWidgets(
                                      size,
                                      context,
                                      Icons.location_on,
                                      AppLocalizations.of(context)!
                                          .currentLocation,
                                      AppLocalizations.of(context)!
                                          .locationSubText,
                                      context
                                          .read<HomeBloc>()
                                          .isLocationsEnabled,
                                      true),
                                  diagnosticListWidgets(
                                      size,
                                      context,
                                      Icons.notifications,
                                      AppLocalizations.of(context)!
                                          .notificationStatus,
                                      AppLocalizations.of(context)!
                                          .notificationSubText,
                                      context
                                          .read<HomeBloc>()
                                          .isNotificationsEnabled,
                                      true),
                                  diagnosticListWidgets(
                                      size,
                                      context,
                                      Icons.volume_up,
                                      AppLocalizations.of(context)!.soundStatus,
                                      AppLocalizations.of(context)!
                                          .soundSubText,
                                      context.read<HomeBloc>().isSoundsChecked,
                                      false)
                                ],
                              ),
                            ),
                          !context.read<HomeBloc>().isDiagnosticsCheckPage
                              ? Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: CustomButton(
                                    width: size.width * 0.8,
                                    buttonColor: AppColors.red,
                                    buttonName:
                                        AppLocalizations.of(context)!.check,
                                    borderRadius: 5,
                                    onTap: () {
                                      context.read<HomeBloc>().add(
                                            DiagnosticCheckEvent(
                                                isDiagnosticsCheckPage: true),
                                          );
                                    },
                                  ),
                                )
                              : Positioned(
                                  bottom: 20,
                                  left: 0,
                                  right: 0,
                                  child: CustomButton(
                                      width: size.width * 0.8,
                                      buttonColor: AppColors.primary,
                                      textSize: 16,
                                      buttonName: (context
                                                      .read<HomeBloc>()
                                                      .isLocationsEnabled ==
                                                  null ||
                                              (context
                                                          .read<HomeBloc>()
                                                          .isLocationsEnabled !=
                                                      null &&
                                                  context
                                                          .read<HomeBloc>()
                                                          .isLocationsEnabled ==
                                                      false))
                                          ? AppLocalizations.of(context)!
                                              .checkLocation
                                          : (context
                                                          .read<HomeBloc>()
                                                          .isNotificationsEnabled ==
                                                      null ||
                                                  (context
                                                              .read<HomeBloc>()
                                                              .isNotificationsEnabled !=
                                                          null &&
                                                      context
                                                              .read<HomeBloc>()
                                                              .isNotificationsEnabled ==
                                                          false))
                                              ? AppLocalizations.of(context)!
                                                  .checkNotification
                                              : AppLocalizations.of(context)!
                                                  .testSound,
                                      borderRadius: 10,
                                      onTap: () {
                                        (context
                                                        .read<HomeBloc>()
                                                        .isLocationsEnabled ==
                                                    null ||
                                                (context
                                                            .read<HomeBloc>()
                                                            .isLocationsEnabled !=
                                                        null &&
                                                    context
                                                            .read<HomeBloc>()
                                                            .isLocationsEnabled ==
                                                        false))
                                            ? context
                                                .read<HomeBloc>()
                                                .add(CheckLocation())
                                            : (context
                                                            .read<HomeBloc>()
                                                            .isNotificationsEnabled ==
                                                        null ||
                                                    (context
                                                                .read<
                                                                    HomeBloc>()
                                                                .isNotificationsEnabled !=
                                                            null &&
                                                        context
                                                                .read<
                                                                    HomeBloc>()
                                                                .isNotificationsEnabled ==
                                                            false))
                                                ? context
                                                    .read<HomeBloc>()
                                                    .add(CheckNotification())
                                                : context
                                                    .read<HomeBloc>()
                                                    .add(CheckSound());
                                      }),
                                ),
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

  Row diagnosticListWidgets(Size size, BuildContext context, IconData icons,
      String mainText, String subText, bool? status, bool showVerticalLine) {
    return Row(
      children: [
        SizedBox(
          height: size.width * 0.41,
          child: Column(
            children: [
              Container(
                height: size.width * 0.1,
                width: size.width * 0.1,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (status != null)
                        ? status
                            ? AppColors.primary
                            : Theme.of(context).primaryColorDark
                        : Theme.of(context).disabledColor),
                alignment: Alignment.center,
                child: Icon(icons, color: AppColors.white),
              ),
              showVerticalLine
                  ? SizedBox(
                      height: size.height * 0.136,
                      child: VerticalDivider(
                        color: Theme.of(context).dividerColor,
                        thickness: 1,
                        width: 20,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        SizedBox(
          height: size.width * 0.4,
          child: Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.04, bottom: size.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: mainText,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16,
                      color: (status != null)
                          ? status
                              ? Theme.of(context).primaryColorDark
                              : Theme.of(context).dividerColor
                          : Theme.of(context).dividerColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.width * 0.01,
                ),
                SizedBox(
                  width: size.width * 0.7,
                  child: MyText(
                    text: subText,
                    maxLines: 2,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).dividerColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: size.width * 0.012,
                ),
                (status != null)
                    ? status
                        ? checkedContainer(size, context)
                        : unCheckedContainer(size, context)
                    : const SizedBox()
              ],
            ),
          ),
        )
      ],
    );
  }

  Container checkedContainer(Size size, BuildContext context) {
    return Container(
      height: size.width * 0.08,
      width: size.width * 0.3,
      decoration: BoxDecoration(
          color: AppColors.primary,
          border: Border.all(color: AppColors.primary),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check,
            color: AppColors.white,
            size: 18,
          ),
          SizedBox(
            width: size.width * 0.01,
          ),
          MyText(
            text: AppLocalizations.of(context)!.checkedText,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.white, fontSize: 14),
          )
        ],
      ),
    );
  }

  Container unCheckedContainer(Size size, BuildContext context) {
    return Container(
      height: size.width * 0.08,
      width: size.width * 0.3,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.red),
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.cancel,
            color: AppColors.red,
          ),
          MyText(
            text: AppLocalizations.of(context)!.failed,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
