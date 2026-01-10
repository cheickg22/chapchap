import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/pages/admin_chat/page/admin_chat.dart';
import 'package:restart_user/features/account/presentation/pages/company_info/page/company_information_page.dart';
import 'package:restart_user/features/account/presentation/pages/driver_report/pages/reports_page.dart';
import 'package:restart_user/features/account/presentation/pages/levelup/page/driver_levels_page.dart';
import 'package:restart_user/features/account/presentation/pages/rewards/page/rewards_page.dart';
import 'package:restart_user/features/account/presentation/pages/fleet_driver/page/fleet_drivers_page.dart';
import 'package:restart_user/features/account/presentation/pages/profile/page/profile_info_page.dart';
import 'package:restart_user/features/account/presentation/pages/history/page/history_page.dart';
import 'package:restart_user/features/account/presentation/pages/incentive/page/incentive_page.dart';
import 'package:restart_user/features/account/presentation/pages/dashboard/page/owner_dashboard.dart';
import 'package:restart_user/features/account/presentation/pages/refferal/page/referral_page.dart';
import 'package:restart_user/features/account/presentation/pages/settings/page/settings_page.dart';
import 'package:restart_user/features/account/presentation/pages/sos/page/sos_page.dart';
import 'package:restart_user/features/account/presentation/pages/subscription/page/subscription_page.dart';
import 'package:restart_user/features/account/presentation/pages/support_ticket/page/support_ticket.dart';
import 'package:restart_user/features/account/presentation/pages/vehicle_info/page/vehicle_data_page.dart';
import 'package:restart_user/features/account/presentation/pages/wallet/page/wallet_page.dart';
import 'package:restart_user/features/account/presentation/widgets/page_options.dart';
import 'package:restart_user/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_user/features/language/presentation/page/choose_language_page.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import 'myroute_booking/page/myroute_booking.dart';
import 'notification/page/notification_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
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
          return (userData != null)
              ? Scaffold(
                  appBar: CustomAppBar(
                    automaticallyImplyLeading: false,
                    title: AppLocalizations.of(context)!.myAccount,
                    centerTitle: true,
                  ),
                  body: SizedBox(
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
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
                            child: Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 2, top: 10, bottom: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: size.width * 0.15,
                                          width: size.width * 0.15,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                              color: Theme.of(context)
                                                  .dividerColor),
                                          child: (userData!
                                                  .profilePicture.isEmpty)
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                  child: CachedNetworkImage(
                                                    imageUrl: userData!
                                                        .profilePicture,
                                                    height: size.width * 0.15,
                                                    fit: BoxFit.fill,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child: Loader(),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Center(
                                                      child: Text(""),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.03,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              IntrinsicWidth(
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.64,
                                                      child: MyText(
                                                        text: userData!.name,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
                                                        maxLines: 5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.01),
                                              MyText(
                                                  text:
                                                      "${AppLocalizations.of(context)!.tripsTaken} : ${userData!.totalRidesTaken!}",
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                          fontSize: 12)),
                                              SizedBox(
                                                  height: size.width * 0.01),
                                              if (userData!.role == 'driver')
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.star,
                                                        color: AppColors
                                                            .goldenColor,
                                                        size: 20),
                                                    MyText(
                                                      text: userData!.rating,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.width * 0.05),
                                  if (userData!.role != 'owner' &&
                                      userData!.enableMyRouteFeature == '1')
                                    PageOptions(
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
                                            accBloc
                                                .add(AccGetUserDetailsEvent());
                                          },
                                        );
                                      },
                                    ),
                                  if (userData!.role == 'owner')
                                    PageOptions(
                                        label: AppLocalizations.of(context)!
                                            .companyInfo,
                                        icon: Icons.info,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              CompanyInformationPage.routeName,
                                              arguments: arg);
                                        }),
                                  if (userData!.role != 'owner')
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .notifications,
                                      icon: Icons.notifications,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            NotificationPage.routeName);
                                      },
                                    ),
                                  PageOptions(
                                    label:
                                        AppLocalizations.of(context)!.history,
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
                                  PageOptions(
                                    icon: Icons.taxi_alert_outlined,
                                    label: userData!.role != 'owner'
                                        ? AppLocalizations.of(context)!
                                            .vehicleInfo
                                        : AppLocalizations.of(context)!
                                            .manageFleet,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        VehicleDataPage.routeName,
                                        arguments:
                                            VehicleDataArguments(from: 0),
                                      );
                                    },
                                  ),
                                  if (userData!.role == 'owner')
                                    PageOptions(
                                      icon: Icons.drive_eta,
                                      label:
                                          AppLocalizations.of(context)!.drivers,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            FleetDriversPage.routeName);
                                      },
                                    ),
                                  PageOptions(
                                    icon: Icons.folder,
                                    label:
                                        AppLocalizations.of(context)!.documents,
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                              DriverProfilePage.routeName,
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
                                  if (userData!.role == 'owner')
                                    PageOptions(
                                      icon: Icons.dashboard,
                                      label: AppLocalizations.of(context)!
                                          .dashboard,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          OwnerDashboard.routeName,
                                          arguments:
                                              OwnerDashboardArguments(from: ''),
                                        );
                                      },
                                    ),
                                  if (userData!.showWalletFeatureOnMobileApp ==
                                      '1')
                                    PageOptions(
                                      icon: Icons.payment,
                                      label:
                                          AppLocalizations.of(context)!.payment,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            WalletHistoryPage.routeName);
                                      },
                                    ),
                                  if (userData!.role == 'driver')
                                    PageOptions(
                                      icon: Icons.share,
                                      label: AppLocalizations.of(context)!
                                          .referAndEarn,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          ReferralPage.routeName,
                                          arguments: ReferralArguments(
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .referAndEarn,
                                              userData: arg.userData),
                                        );
                                      },
                                    ),
                                  PageOptions(
                                    icon: Icons.language,
                                    label: AppLocalizations.of(context)!
                                        .changeLanguage,
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                              ChooseLanguagePage.routeName,
                                              arguments:
                                                  ChangeLanguageArguments(
                                                      from: 1))
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
                                  if (userData!.role == 'driver')
                                    PageOptions(
                                      icon: Icons.sos,
                                      label:
                                          AppLocalizations.of(context)!.sosText,
                                      onTap: () {
                                        Navigator.pushNamed(
                                                context, SosPage.routeName,
                                                arguments: SOSPageArguments(
                                                    sosData:
                                                        userData!.sos!.data))
                                            .then(
                                          (value) {
                                            if (!context.mounted) return;
                                            if (value != null) {
                                              final sos =
                                                  value as List<SOSDatum>;
                                              context.read<AccBloc>().sosdata =
                                                  sos;
                                              userData!.sos!.data = context
                                                  .read<AccBloc>()
                                                  .sosdata;
                                              context
                                                  .read<AccBloc>()
                                                  .add(UpdateEvent());
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  if (userData!.role == 'driver' &&
                                      userData!.hasSubscription! &&
                                      (userData!.driverMode == 'subscription' ||
                                          userData!.driverMode == 'both'))
                                    PageOptions(
                                      icon: Icons.subscriptions,
                                      label: AppLocalizations.of(context)!
                                          .subscription,
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
                                  if (userData!.role == 'driver' &&
                                      userData!.showIncentiveFeatureForDriver ==
                                          "1" &&
                                      userData!.availableIncentive != null)
                                    PageOptions(
                                      icon: Icons.celebration,
                                      label: AppLocalizations.of(context)!
                                          .incentives,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          IncentivePage.routeName,
                                        );
                                      },
                                    ),
                                  if (userData!.role == 'driver' &&
                                      userData!.showDriverLevel == true)
                                    PageOptions(
                                      icon: Icons.leaderboard,
                                      label: AppLocalizations.of(context)!
                                          .levelupText,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          DriverLevelsPage.routeName,
                                        );
                                      },
                                    ),
                                  if (userData!.role == 'driver' &&
                                      userData!.showDriverLevel == true)
                                    PageOptions(
                                      icon: Icons.receipt_long,
                                      label: AppLocalizations.of(context)!
                                          .rewardsText,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          RewardsPage.routeName,
                                        );
                                      },
                                    ),
                                  PageOptions(
                                    icon: Icons.report,
                                    label: AppLocalizations.of(context)!
                                        .reportsText,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, ReportsPage.routeName);
                                    },
                                  ),
                                  SizedBox(height: size.width * 0.03),
                                  MyText(
                                    text: AppLocalizations.of(context)!.general,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontSize: 16),
                                  ),
                                  SizedBox(height: size.width * 0.03),
                                  PageOptions(
                                    icon: Icons.chat,
                                    label: AppLocalizations.of(context)!
                                        .chatWithUs,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AdminChat.routeName);
                                    },
                                  ),
                                  if (userData!.enableSupportTicketFeature ==
                                      '1')
                                    PageOptions(
                                      label: AppLocalizations.of(context)!
                                          .supportTicket,
                                      icon: Icons.support,
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            SupportTicketPage.routeName,
                                            arguments:
                                                SupportTicketPageArguments(
                                                    isFromRequest: false,
                                                    requestId: ''));
                                      },
                                    ),
                                  PageOptions(
                                    icon: Icons.settings,
                                    label:
                                        AppLocalizations.of(context)!.settings,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, SettingsPage.routeName);
                                    },
                                  ),
                                  SizedBox(height: size.width * 0.25)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Scaffold(
                  body: Loader(),
                );
        }),
      ),
    );
  }
}
