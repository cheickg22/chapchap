import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/earnings/page/earnings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/dashboard/page/fleet_dashboard_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/vehicle_info/page/vehicle_data_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';
import 'driver_performance_page.dart';

class OwnerDashboard extends StatefulWidget {
  static const String routeName = '/ownerDashboard';
  final OwnerDashboardArguments args;
  const OwnerDashboard({super.key, required this.args});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()..add(GetOwnerDashboardEvent()),
        child:
            BlocListener<AccBloc, AccState>(listener: (context, state) async {
          if (state is DashboardLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is DashboardLoadingStopState) {
            CustomLoader.dismiss(context);
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.ownerDashboard,
              automaticallyImplyLeading: widget.args.from == '' ? true : false,
              onBackTap: widget.args.from == ''
                  ? () {
                      Navigator.pop(context);
                    }
                  : null,
              titleFontSize: 18,
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (context.read<AccBloc>().fleetData != null &&
                              context.read<AccBloc>().fleetData!.activeFleets !=
                                  '0')
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, VehicleDataPage.routeName,
                                    arguments: VehicleDataArguments(from: 0));
                              },
                              child: Container(
                                width: size.width * 0.425,
                                // height: size.width * 0.25,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    border: Border.all(
                                        width: 1, color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.all(size.width * 0.025),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MyText(
                                      text:
                                          '${AppLocalizations.of(context)!.active} ${AppLocalizations.of(context)!.cabs}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.025,
                                    ),
                                    MyText(
                                      text:
                                          (context.read<AccBloc>().fleetData !=
                                                  null)
                                              ? context
                                                  .read<AccBloc>()
                                                  .fleetData!
                                                  .activeFleets
                                              : '0',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, VehicleDataPage.routeName,
                                  arguments: VehicleDataArguments(from: 1));
                            },
                            child: Container(
                              width: size.width * 0.425,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                      width: 1, color: AppColors.borderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.all(size.width * 0.025),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    text:
                                        '${AppLocalizations.of(context)!.inactive} ${AppLocalizations.of(context)!.cabs}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  MyText(
                                    text: (context.read<AccBloc>().fleetData !=
                                            null)
                                        ? context
                                            .read<AccBloc>()
                                            .fleetData!
                                            .inactiveFleets
                                        : '0',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Row(
                      children: [
                        if (context.read<AccBloc>().fleetData != null &&
                            context.read<AccBloc>().fleetData!.blockedFleets !=
                                '0')
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, VehicleDataPage.routeName,
                                  arguments: VehicleDataArguments(from: 2));
                            },
                            child: Container(
                              width: size.width * 0.425,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                      width: 1, color: AppColors.borderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.all(size.width * 0.025),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    text:
                                        '${AppLocalizations.of(context)!.blocked} ${AppLocalizations.of(context)!.cabs}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            color: AppColors.red,
                                            fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  MyText(
                                    text: (context.read<AccBloc>().fleetData !=
                                            null)
                                        ? context
                                            .read<AccBloc>()
                                            .fleetData!
                                            .blockedFleets
                                        : '0',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, EarningsPage.routeName,
                            arguments: EarningArguments(from: 'dashboard'));
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.only(
                            top: size.width * 0.04, bottom: size.width * 0.05),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(
                                width: 1, color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            SizedBox(
                              width: size.width * 0.84,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: MyText(
                                      text: (context
                                                  .read<AccBloc>()
                                                  .fleetData !=
                                              null)
                                          ? '${AppLocalizations.of(context)!.revenue} ${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.revenue}'
                                          : AppLocalizations.of(context)!
                                              .revenue,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: size.width * 0.04,
                                    color: Theme.of(context).hintColor,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width * 0.25,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text: (context
                                                      .read<AccBloc>()
                                                      .fleetData !=
                                                  null)
                                              ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.cash}'
                                              : '-',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                      SizedBox(
                                        height: size.width * 0.015,
                                      ),
                                      MyText(
                                        text:
                                            AppLocalizations.of(context)!.cash,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .hintColor),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border(
                                    right: BorderSide(color: AppColors.grey),
                                    left: BorderSide(color: AppColors.grey),
                                  )),
                                  width: size.width * 0.33,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text: (context
                                                      .read<AccBloc>()
                                                      .fleetData !=
                                                  null)
                                              ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.digitalEarnings}'
                                              : '-',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                      SizedBox(
                                        height: size.width * 0.015,
                                      ),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .digitalPayment,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .hintColor),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.25,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text: (context
                                                      .read<AccBloc>()
                                                      .fleetData !=
                                                  null)
                                              ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.discount}'
                                              : '-',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                      SizedBox(
                                        height: size.width * 0.015,
                                      ),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .discount,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .hintColor),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.025,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.cabPerformance,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.025,
                    ),
                    (context.read<AccBloc>().fleetEarnings != null &&
                            context.read<AccBloc>().fleetEarnings!.isNotEmpty)
                        ? SizedBox(
                            width: size.width * 0.94,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var i = 0;
                                      i <
                                          context
                                              .read<AccBloc>()
                                              .fleetEarnings!
                                              .length;
                                      i++)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, FleetDashboard.routeName,
                                            arguments: FleetDashboardArguments(
                                              fleetId: context
                                                  .read<AccBloc>()
                                                  .fleetEarnings![i]
                                                  .fleetId,
                                            ));
                                      },
                                      child: Container(
                                        width: size.width * 0.425,
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        margin: (context
                                                    .read<AccBloc>()
                                                    .textDirection ==
                                                'ltr')
                                            ? EdgeInsets.only(
                                                right: size.width * 0.05)
                                            : EdgeInsets.only(
                                                left: size.width * 0.05),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .fleetEarnings![i]
                                                  .licenseNo,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .primaryColorDark),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.011,
                                            ),
                                            MyText(
                                              text:
                                                  '${userData!.currencySymbol} ${context.read<AccBloc>().fleetEarnings![i].totalEarnings}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                            Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .star_border_outlined,
                                                      size: size.width * 0.05,
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.01,
                                                    ),
                                                    MyText(
                                                        text: context
                                                            .read<AccBloc>()
                                                            .fleetEarnings![i]
                                                            .averageRating,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 12,
                                                                ))
                                                  ],
                                                ),
                                                Expanded(
                                                  child: MyText(
                                                      text:
                                                          '${AppLocalizations.of(context)!.rides}: ${context.read<AccBloc>().fleetEarnings![i].totalCompletedRequests}',
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              fontSize: 14,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                      textAlign: TextAlign.end),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          )
                        : (context.read<AccBloc>().fleetEarnings != null &&
                                context.read<AccBloc>().fleetEarnings!.isEmpty)
                            ? Column(children: [
                                Image.asset(
                                  AppImages.dashboardEmptyData,
                                  width: size.width,
                                  height: size.width * 0.5,
                                  fit: BoxFit.contain,
                                ),
                                MyText(
                                  text:
                                      AppLocalizations.of(context)!.noDataFound,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                ),
                              ])
                            : Container(),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          MyText(
                            text:
                                AppLocalizations.of(context)!.driverPerformance,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.025,
                    ),
                    (context.read<AccBloc>().fleetDriverData != null &&
                            context.read<AccBloc>().fleetDriverData!.isNotEmpty)
                        ? SizedBox(
                            width: size.width * 0.93,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var i = 0;
                                      i <
                                          context
                                              .read<AccBloc>()
                                              .fleetDriverData!
                                              .length;
                                      i++)
                                    if (context
                                        .read<AccBloc>()
                                        .fleetDriverData![i]
                                        .isApproved)
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              DriverPerformancePage.routeName,
                                              arguments:
                                                  DriverDashboardArguments(
                                                      driverId: context
                                                          .read<AccBloc>()
                                                          .fleetDriverData![i]
                                                          .driverId,
                                                      driverName: context
                                                          .read<AccBloc>()
                                                          .fleetDriverData![i]
                                                          .name,
                                                      profile: context
                                                          .read<AccBloc>()
                                                          .fleetDriverData![i]
                                                          .profile));
                                        },
                                        child: Container(
                                          width: size.width * 0.425,
                                          padding: EdgeInsets.all(
                                              size.width * 0.025),
                                          margin: (context
                                                      .read<AccBloc>()
                                                      .textDirection ==
                                                  'ltr')
                                              ? EdgeInsets.only(
                                                  right: size.width * 0.05)
                                              : EdgeInsets.only(
                                                  left: size.width * 0.05),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              border: Border.all(
                                                  width: 1,
                                                  color: AppColors.borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              Container(
                                                height: size.width * 0.15,
                                                width: size.width * 0.15,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            context
                                                                .read<AccBloc>()
                                                                .fleetDriverData![
                                                                    i]
                                                                .profile),
                                                        fit: BoxFit.cover)),
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              MyText(
                                                text: context
                                                    .read<AccBloc>()
                                                    .fleetDriverData![i]
                                                    .name,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                              ),
                                              MyText(
                                                text:
                                                    '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDriverData![i].totalEarnings}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 16,
                                                    ),
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .star_border_outlined,
                                                        size: size.width * 0.05,
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.01,
                                                      ),
                                                      MyText(
                                                          text: context
                                                              .read<AccBloc>()
                                                              .fleetDriverData![
                                                                  i]
                                                              .averageRating,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    fontSize:
                                                                        12,
                                                                  ))
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: MyText(
                                                      text:
                                                          '${AppLocalizations.of(context)!.rides}: ${context.read<AccBloc>().fleetDriverData![i].totalCompletedRequests}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 14,
                                                              ),
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                ],
                              ),
                            ),
                          )
                        : (context.read<AccBloc>().fleetDriverData != null &&
                                context
                                    .read<AccBloc>()
                                    .fleetDriverData!
                                    .isEmpty)
                            ? Column(children: [
                                Image.asset(
                                  AppImages.noDataFound,
                                  width: size.width,
                                  height: size.width * 0.5,
                                  fit: BoxFit.contain,
                                ),
                                MyText(
                                  text:
                                      AppLocalizations.of(context)!.noDataFound,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                ),
                              ])
                            : Container(),
                    SizedBox(
                      height: size.width * 0.25,
                    )
                  ],
                ),
              ),
            ),
          );
        })));
  }
}
