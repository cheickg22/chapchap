import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../account/presentation/pages/account_page.dart';
import '../../../../../account/presentation/pages/history/page/history_page.dart';
import '../../../../application/home_bloc.dart';
import 'instand_ride/avatar_glow.dart';
import 'fleet_not_assign_widget.dart';
import 'online_offline_widget.dart';

class MapAppBarWidget extends StatelessWidget {
  final BuildContext cont;
  const MapAppBarWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                Row(
                  children: [
                    (context.read<HomeBloc>().showGetDropAddress)
                        ? InkWell(
                            onTap: () {
                              if (context.read<HomeBloc>().choosenRide !=
                                  null) {
                                context
                                    .read<HomeBloc>()
                                    .add(RemoveChoosenRideEvent());
                              } else if (context
                                  .read<HomeBloc>()
                                  .showGetDropAddress) {
                                context
                                    .read<HomeBloc>()
                                    .add(ShowGetDropAddressEvent());
                              } else {
                                Navigator.pushNamed(
                                        context, AccountPage.routeName,
                                        arguments: AccountPageArguments(
                                            userData: userData!))
                                    .then(
                                  (value) {
                                    if (!context.mounted) return;
                                    context
                                        .read<HomeBloc>()
                                        .add(GetUserDetailsEvent());
                                  },
                                );
                              }
                              context
                                  .read<HomeBloc>()
                                  .dropAddressController
                                  .clear();
                            },
                            child: Icon(
                              (context.read<HomeBloc>().choosenRide != null ||
                                      context
                                          .read<HomeBloc>()
                                          .showGetDropAddress)
                                  ? Icons.arrow_back
                                  : Icons.menu,
                              size: size.width * 0.07,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          )
                        : SizedBox(width: size.width * 0.07),
                    (context.read<HomeBloc>().showGetDropAddress)
                        ? Row(
                            children: [
                              SizedBox(width: size.width * 0.05),
                              SizedBox(
                                width: size.width * 0.7,
                                height: size.width * 0.1,
                                child: CustomTextField(
                                  controller: context
                                      .read<HomeBloc>()
                                      .dropAddressController,
                                  fillColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  filled: true,
                                  hintText:
                                      AppLocalizations.of(context)!.searchPlace,
                                  onChange: (v) {
                                    context.read<HomeBloc>().debouncer.run(() {
                                      if (v.length >= 4) {
                                        context.read<HomeBloc>().add(
                                            GetAutoCompleteAddressEvent(
                                                searchText: v));
                                      } else if (v.isEmpty) {
                                        context
                                            .read<HomeBloc>()
                                            .add(ClearAutoCompleteEvent());
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          )
                        : Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (userData!.isDeletedAt.isNotEmpty)
                                    ? SizedBox(
                                        width: size.width * 0.6,
                                        child: MyText(
                                            text: userData!.isDeletedAt,
                                            textAlign: TextAlign.center,
                                            maxLines: 5,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                      )
                                    : ((((userData!.ownerId == '' && userData!.lowBalance == false) ||
                                                        (userData!.ownerId != '' &&
                                                            userData!.vehicleTypeName !=
                                                                '' &&
                                                            userData!.lowBalance ==
                                                                false)) ||
                                                    (userData!.ownerId != '' &&
                                                        userData!.vehicleTypeName !=
                                                            '')) &&
                                                ((userData!.driverMode == 'subscription' &&
                                                        userData!
                                                            .isSubscribed! &&
                                                        !userData!
                                                            .isExpired!) ||
                                                    (userData!.driverMode == 'commission' &&
                                                        !userData!
                                                            .lowBalance) ||
                                                    (userData!.driverMode == 'both' &&
                                                        !userData!
                                                            .lowBalance)) ||
                                            (userData!.wallet?.data.amountBalance != null &&
                                                userData!.wallet!.data.amountBalance >
                                                    0))
                                        ? OnlineOfflineWidget(cont: context)
                                        : (userData!.vehicleTypeName == '')
                                            ? FleetNotAssignedWidget(
                                                cont: context)
                                            : (userData!.driverMode == 'subscription' &&
                                                    userData!.hasSubscription != null &&
                                                    userData!.hasSubscription! &&
                                                    (userData!.subscription == null || userData!.isExpired!))
                                                ? (!userData!.isExpired!)
                                                    ? SizedBox(
                                                        width: size.width * 0.6,
                                                        child: MyText(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .noSubscription,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 4,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                      )
                                                    : SizedBox(
                                                        width: size.width * 0.6,
                                                        child: MyText(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .subscriptionExpired,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 4,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                      )
                                                : SizedBox(
                                                    width: size.width * 0.6,
                                                    child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .lowBalance,
                                                        textAlign:
                                                            TextAlign.center,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .red,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                  ),
                                if (!userData!.active)
                                  SizedBox(width: size.width * 0.07),
                              ],
                            ),
                          ),
                    // SizedBox(width: size.width * 0.07),
                    if (userData!.active != false && userData!.hasLater == true)
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, HistoryPage.routeName,
                              arguments: HistoryAccountPageArguments(
                                  isFrom: 'home',
                                  isSupportTicketEnabled:
                                      userData!.enableSupportTicketFeature));
                        },
                        child: AvatarGlow(
                          glowColor:
                              AppColors.primary.withAlpha((0.7 * 255).toInt()),
                          animate: true,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 17.0,
                            child: Image.asset(
                              AppImages.upComingRides,
                              height: size.width * 0.1,
                              width: 200,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
