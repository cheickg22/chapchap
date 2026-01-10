import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/help/help.dart';
import 'package:restart_tagxi/features/account/presentation/pages/outstation/page/outstation_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/profile/page/profile_info_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/menu_options.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/models/user_details_model.dart';
import '../../application/acc_bloc.dart';
import 'fav_location/page/fav_location.dart';
import 'history/page/history_page.dart';
import 'notification/page/notification_page.dart';
import 'refferal/page/referral_page.dart';
import 'settings/page/settings_page.dart';
import 'sos/page/sos_page.dart';
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
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return (accBloc.userData != null)
              ? Directionality(
                  textDirection: context.read<AccBloc>().textDirection == 'rtl'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: SafeArea(
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
                                    color: AppColors.borderColors,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(
                                                  context, accBloc.userData);
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              size: size.width * 0.07,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.025),
                                          SizedBox(
                                            width: size.width * 0.55,
                                            child: MyText(
                                              text: accBloc.userData!.name,
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
                                          SizedBox(width: size.width * 0.025),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .help,
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
                            SizedBox(height: size.width * 0.025),

                            // Main content
                            Expanded(
                              child: Container(
                                width: size.width,
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .yourAccount,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .personalInformation,
                                        subtitle: accBloc.userData!.mobile,
                                        imagePath: AppImages.user,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                                  ProfileInfoPage.routeName,
                                                  arguments:
                                                      ProfileInfoPageArguments(
                                                          userData: context
                                                              .read<AccBloc>()
                                                              .userData!))
                                              .then((value) {
                                            if (!context.mounted) {
                                              return;
                                            }
                                            if (value != null) {
                                              context.read<AccBloc>().userData =
                                                  value as UserDetail;
                                              context
                                                  .read<AccBloc>()
                                                  .add(AccUpdateEvent());
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .notifications,
                                        imagePath: AppImages.notifications,
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              NotificationPage.routeName);
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .history,
                                        icon: Icons.history,
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, HistoryPage.routeName,
                                              arguments: HistoryPageArguments(
                                                  isSupportTicketEnabled: context
                                                      .read<AccBloc>()
                                                      .userData!
                                                      .enableSupportTicketFeature));
                                        },
                                      ),
                                      if (context
                                              .read<AccBloc>()
                                              .userData!
                                              .showOutstationRideFeature ==
                                          '1') ...[
                                        SizedBox(height: size.width * 0.05),
                                        MenuOptions(
                                          label: AppLocalizations.of(context)!
                                              .outStation,
                                          icon: Icons.taxi_alert_outlined,
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                OutstationHistoryPage.routeName,
                                                arguments:
                                                    OutstationHistoryPageArguments(
                                                        isFromBooking: false));
                                          },
                                        ),
                                      ],
                                      SizedBox(height: size.width * 0.05),
                                      if (context
                                              .read<AccBloc>()
                                              .userData!
                                              .showWalletFeatureOnMobileApp ==
                                          '1')
                                        MenuOptions(
                                          label: AppLocalizations.of(context)!
                                              .wallet,
                                          imagePath: AppImages.wallet,
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                    WalletHistoryPage.routeName,
                                                    arguments:
                                                        WalletPageArguments(
                                                            userData: context
                                                                .read<AccBloc>()
                                                                .userData!))
                                                .then(
                                              (value) {
                                                if (!context.mounted) return;
                                                context.read<AccBloc>().add(
                                                    AccGetUserDetailsEvent());
                                              },
                                            );
                                          },
                                        ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .favoriteLocation,
                                        icon: Icons.favorite_border,
                                        onTap: () {
                                          Navigator.pushNamed(
                                                  context,
                                                  FavoriteLocationPage
                                                      .routeName,
                                                  arguments:
                                                      FavouriteLocationPageArguments(
                                                          userData: context
                                                              .read<AccBloc>()
                                                              .userData!))
                                              .then(
                                            (value) {
                                              if (!context.mounted) return;
                                              if (value != null) {
                                                context
                                                        .read<AccBloc>()
                                                        .userData =
                                                    value as UserDetail;
                                                context
                                                    .read<AccBloc>()
                                                    .add(AccUpdateEvent());
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .benefits,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .referEarn,
                                        icon: Icons.share,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            ReferralPage.routeName,
                                            arguments: ReferralArguments(
                                                title: AppLocalizations.of(
                                                        context)!
                                                    .referEarn,
                                                userData: context
                                                    .read<AccBloc>()
                                                    .userData!),
                                          );
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label:
                                            AppLocalizations.of(context)!.sos,
                                        icon: Icons.sos,
                                        onTap: () {
                                          Navigator.pushNamed(
                                                  context, SosPage.routeName,
                                                  arguments: SOSPageArguments(
                                                      sosData: context
                                                          .read<AccBloc>()
                                                          .userData!
                                                          .sos
                                                          .data))
                                              .then(
                                            (value) {
                                              if (!context.mounted) return;
                                              if (value != null) {
                                                final sos =
                                                    value as List<SOSDatum>;
                                                context
                                                    .read<AccBloc>()
                                                    .sosdata = sos;
                                                context
                                                        .read<AccBloc>()
                                                        .userData!
                                                        .sos
                                                        .data =
                                                    context
                                                        .read<AccBloc>()
                                                        .sosdata;
                                                context
                                                    .read<AccBloc>()
                                                    .add(AccUpdateEvent());
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .preferences,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .changeLanguage,
                                        icon: Icons.language,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            ChooseLanguagePage.routeName,
                                            arguments: ChooseLanguageArguments(
                                                isInitialLanguageChange: false),
                                          ).then(
                                            (value) {
                                              if (!context.mounted) return;
                                              context
                                                  .read<AccBloc>()
                                                  .add(AccGetDirectionEvent());
                                            },
                                          );
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .settings,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuOptions(
                                        label: AppLocalizations.of(context)!
                                            .settings,
                                        imagePath: AppImages.settings,
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            SettingsPage.routeName,
                                            arguments: SettingsPageArguments(
                                                userData: accBloc.userData!),
                                          );
                                        },
                                      ),
                                      SizedBox(height: size.width * 0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
