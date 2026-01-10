import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/help/page/help_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history/page/history_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/menu_options.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../language/presentation/page/choose_language_page.dart';
import 'dashboard/page/owner_dashboard.dart';
import 'driver_report/pages/reports_page.dart';
import 'earnings/page/earnings_page.dart';
import 'fleet_driver/page/fleet_drivers_page.dart';
import 'incentive/page/incentive_page.dart';
import 'levelup/page/driver_levels_page.dart';
import 'myroute_booking/page/myroute_booking.dart';
import 'notification/page/notification_page.dart';
import 'profile/page/profile_info_page.dart';
import 'refferal/page/referral_page.dart';
import 'rewards/page/rewards_page.dart';
import 'settings/page/settings_page.dart';
import 'sos/page/sos_page.dart';
import 'subscription/page/subscription_page.dart';
import 'vehicle_info/page/vehicle_data_page.dart';
import 'wallet/page/wallet_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(UserDataInitEvent(userDetails: arg.userData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UserDetailState) {
            Navigator.pushNamed(
              context,
              ProfileInfoPage.routeName,
            ).then(
              (value) {
                if (!context.mounted) return;
                context.read<AccBloc>().add(AccGetUserDetailsEvent());
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return SafeArea(
            child: Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                body: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.borderColors, // border color
                              width: 1, // border width
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, HomePage.routeName);
                                      },
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: size.width * 0.07,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.55,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: userData!.name,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                            maxLines: 2,
                                          ),
                                          if (userData!.role == "driver")
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_border,
                                                  size: size.width * 0.05,
                                                  color: AppColors.primary,
                                                ),
                                                MyText(
                                                  text: userData!.rating,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, HelpPage.routeName);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: size.width * 0.06,
                                      color: AppColors.green,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    MyText(
                                      text: AppLocalizations.of(context)!.help,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 14,
                                            color: AppColors.green,
                                          ),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.width * 0.025,
                      ),
                      Expanded(
                          child: Container(
                        width: size.width,
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.yourAccount,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              // personal info
                              MenuOptions(
                                label: AppLocalizations.of(context)!
                                    .personalInformation,
                                subtitle: userData!.mobile,
                                imagePath: AppImages.user,
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, ProfileInfoPage.routeName,
                                          arguments: arg)
                                      .then((value) {
                                    if (!context.mounted) {
                                      return;
                                    }
                                    context.read<AccBloc>().add(UpdateEvent());
                                  });
                                },
                              ),
                              // wallet
                              if (userData!.showWalletFeatureOnMobileApp == '1')
                                MenuOptions(
                                  label: AppLocalizations.of(context)!.wallet,
                                  imagePath: AppImages.creditCard,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, WalletHistoryPage.routeName);
                                  },
                                ),

                              // vehicle details
                              MenuOptions(
                                label: userData!.role != 'owner'
                                    // ? AppLocalizations.of(context)!
                                    //     .vehicleInfo
                                    ? AppLocalizations.of(context)!.myVehicle
                                    : AppLocalizations.of(context)!.manageFleet,
                                // label: 'My Vehicle',
                                imagePath: AppImages.vehicleMakeImage,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    VehicleDataPage.routeName,
                                    arguments: VehicleDataArguments(from: 0),
                                  );
                                },
                              ),

                              // Fleet Driver
                              if (userData!.role == 'owner')
                                MenuOptions(
                                  icon: Icons.drive_eta,
                                  label: AppLocalizations.of(context)!.drivers,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, FleetDriversPage.routeName);
                                  },
                                ),

                              // Owmer Dashboard
                              if (userData!.role == 'owner')
                                MenuOptions(
                                  icon: Icons.dashboard,
                                  label:
                                      AppLocalizations.of(context)!.dashboard,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      OwnerDashboard.routeName,
                                      arguments:
                                          OwnerDashboardArguments(from: ''),
                                    );
                                  },
                                ),

                              // Documents
                              MenuOptions(
                                icon: Icons.folder,
                                label: AppLocalizations.of(context)!.documents,
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, DriverProfilePage.routeName,
                                          arguments: VehicleUpdateArguments(
                                              from: 'docs'))
                                      .then(
                                    (value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    },
                                  );
                                },
                              ),

                              // History
                              MenuOptions(
                                label: AppLocalizations.of(context)!.history,
                                icon: Icons.history,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, HistoryPage.routeName,
                                      arguments: HistoryAccountPageArguments(
                                          isFrom: 'account',
                                          isSupportTicketEnabled: userData!
                                              .enableSupportTicketFeature));
                                },
                              ),

                              // Notifications
                              if (userData!.role != 'owner')
                                MenuOptions(
                                  label: AppLocalizations.of(context)!
                                      .notifications,
                                  imagePath: AppImages.bell,
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, NotificationPage.routeName);
                                  },
                                ),

                              // My subscription
                              if (userData!.role == 'driver' &&
                                  userData!.hasSubscription! &&
                                  (userData!.driverMode == 'subscription' ||
                                      userData!.driverMode == 'both'))
                                MenuOptions(
                                  label: AppLocalizations.of(context)!
                                      .mySubscription,
                                  imagePath: AppImages.giftIcon,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      SubscriptionPage.routeName,
                                      arguments: SubscriptionPageArguments(
                                          isFromAccPage: true),
                                    ).then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    });
                                  },
                                ),
                              MyText(
                                text: AppLocalizations.of(context)!.benefits,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),

                              // Refer and earn
                              if (userData!.role == 'driver')
                                MenuOptions(
                                  label: AppLocalizations.of(context)!
                                      .referAndEarn,
                                  imagePath: AppImages.share,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      ReferralPage.routeName,
                                      arguments: ReferralArguments(
                                          title: AppLocalizations.of(context)!
                                              .referAndEarn,
                                          userData: arg.userData),
                                    );
                                  },
                                ),

                              // Rewards
                              if (userData!.role == 'driver' &&
                                  userData!.showDriverLevel == true)
                                MenuOptions(
                                  label:
                                      AppLocalizations.of(context)!.rewardsText,
                                  imagePath: AppImages.award,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RewardsPage.routeName,
                                    );
                                  },
                                ),

                              // Incentives
                              if (userData!.role == 'driver' &&
                                  userData!.showIncentiveFeatureForDriver ==
                                      "1" &&
                                  userData!.availableIncentive != null)
                                MenuOptions(
                                  label:
                                      AppLocalizations.of(context)!.incentives,
                                  imagePath: AppImages.dollarSign,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      IncentivePage.routeName,
                                    );
                                  },
                                ),

                              // Level up
                              if (userData!.role == 'driver' &&
                                  userData!.showDriverLevel == true)
                                MenuOptions(
                                  icon: Icons.leaderboard,
                                  label:
                                      AppLocalizations.of(context)!.levelupText,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      DriverLevelsPage.routeName,
                                    );
                                  },
                                ),

                              // SOS
                              if (userData!.role == 'driver')
                                MenuOptions(
                                  icon: Icons.sos,
                                  label: AppLocalizations.of(context)!.sosText,
                                  onTap: () {
                                    Navigator.pushNamed(
                                            context, SosPage.routeName,
                                            arguments: SOSPageArguments(
                                                sosData: userData!.sos!.data))
                                        .then(
                                      (value) {
                                        if (!context.mounted) return;
                                        if (value != null) {
                                          final sos = value as List<SOSDatum>;
                                          context.read<AccBloc>().sosdata = sos;
                                          userData!.sos!.data =
                                              context.read<AccBloc>().sosdata;
                                          context
                                              .read<AccBloc>()
                                              .add(UpdateEvent());
                                        }
                                      },
                                    );
                                  },
                                ),

                              // Admin chat
                              //   MenuOptions(
                              //   icon: Icons.chat,
                              //   label: AppLocalizations.of(context)!
                              //       .chatWithUs,
                              //   onTap: () {
                              //     Navigator.pushNamed(
                              //         context, AdminChat.routeName);
                              //   },
                              // ),

                              MyText(
                                text: AppLocalizations.of(context)!.earnings,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),

                              // My Earnings
                              MenuOptions(
                                label: AppLocalizations.of(context)!.myEarnings,
                                imagePath: AppImages.wallet,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, EarningsPage.routeName,
                                      arguments:
                                          EarningArguments(from: 'dashboard'));
                                },
                              ),

                              // Report
                              MenuOptions(
                                label:
                                    AppLocalizations.of(context)!.reportsText,
                                imagePath: AppImages.fileText,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ReportsPage.routeName);
                                },
                              ),

                              MyText(
                                text: AppLocalizations.of(context)!.preferences,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),

                              // Language
                              MenuOptions(
                                label: AppLocalizations.of(context)!.languages,
                                imagePath: AppImages.globe,
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, ChooseLanguagePage.routeName,
                                          arguments:
                                              ChangeLanguageArguments(from: 1))
                                      .then(
                                    (value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(AccGetDirectionEvent());
                                    },
                                  );
                                },
                              ),
                              if (userData!.role != 'owner' &&
                                  userData!.enableMyRouteFeature == '1')
                                MenuOptions(
                                  label: AppLocalizations.of(context)!
                                      .myRouteBooking,
                                  icon: Icons.route,
                                  showroute: true,
                                  showrouteValue:
                                      userData!.enableMyRouteBooking == '1',
                                  onTap: () {
                                    Navigator.pushNamed(
                                            context, RouteBooking.routeName)
                                        .then(
                                      (value) {
                                        accBloc.add(AccGetUserDetailsEvent());
                                      },
                                    );
                                  },
                                ),

                              // settings
                              MyText(
                                text: AppLocalizations.of(context)!.settings,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),

                              MenuOptions(
                                label: AppLocalizations.of(context)!.settings,
                                imagePath: AppImages.vehicleModelImage,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, SettingsPage.routeName);
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
