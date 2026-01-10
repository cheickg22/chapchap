import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/local_data.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';

class FleetDashboard extends StatefulWidget {
  static const String routeName = '/fleetDashboard';
  final FleetDashboardArguments args;

  const FleetDashboard({super.key, required this.args});

  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()
          ..add(GetFleetDashboardEvent(fleetId: widget.args.fleetId)),
        child:
            BlocListener<AccBloc, AccState>(listener: (context, state) async {
          if (state is FleetDashboardLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is FleetDashboardLoadingStopState) {
            CustomLoader.dismiss(context);
          }
          if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            body: TopBarDesign(
              onTap: () {
                Navigator.pop(context);
              },
              isHistoryPage: false,
              title: AppLocalizations.of(context)!.cabPerformance,
              child: SingleChildScrollView(
                child: (context.read<AccBloc>().fleetDashboardData != null)
                    ? Column(
                        children: [
                          SizedBox(
                            height: size.width * 0.1,
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: size.width * 0.010,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: MyText(
                                            text: context
                                                .read<AccBloc>()
                                                .fleetDashboardData!
                                                .vehicleName,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          )),
                                          MyText(
                                            text: context
                                                .read<AccBloc>()
                                                .fleetDashboardData!
                                                .licenseNo,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: AppColors.darkGrey,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      Container(
                                        height: size.width * 0.155,
                                        width: size.width * 0.90,
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withAlpha((0.2 * 255).toInt()),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.02),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween, // Add space evenly
                                          children: [
                                            // Booking Row
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .booking,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    MyText(
                                                      text: context
                                                          .read<AccBloc>()
                                                          .fleetDashboardData!
                                                          .totalTrips,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            // Divider (Vertical)
                                            VerticalDivider(
                                              color: AppColors.darkGrey,
                                              thickness: 1,
                                              width: size.width * 0.015,
                                              indent: 10,
                                              endIndent: 10,
                                            ),

                                            // Distance Row
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .distance,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    MyText(
                                                      text:
                                                          '${context.read<AccBloc>().fleetDashboardData!.totalDistance} Km',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            // Divider (Vertical)
                                            VerticalDivider(
                                              color: AppColors.darkGrey,
                                              thickness: 1,
                                              width: size.width * 0.015,
                                              indent: 10,
                                              endIndent: 10,
                                            ),

                                            // Earnings Row
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.money,
                                                      size: size.width * 0.05,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    const SizedBox(width: 1),
                                                    MyText(
                                                      text:
                                                          '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.totalEarnings}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.07,
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .performanceAndRating,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: size.width * 0.025,
                                ),
                                Expanded(
                                    child: Text(
                                  '--------------------------------------------',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.07,
                          ),
                          Container(
                            width: size.width * 0.9,
                            padding: EdgeInsets.all(size.width * 0.025),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withAlpha((0.5 * 255).toInt()))),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .primaryColorDark
                                          .withAlpha((0.5 * 255).toInt())),
                                  width: size.width * 0.85,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .loginHourDetails,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.025,
                                ),
                                SizedBox(
                                  width: size.width * 0.85,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width * 0.41,
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withAlpha(
                                                    (0.3 * 255).toInt())),
                                        child: Column(
                                          children: [
                                            MyText(
                                              text:
                                                  '${double.parse(context.read<AccBloc>().fleetDashboardData!.totalDuration).toStringAsFixed(2).split('.')[0]} Hrs ${double.parse(context.read<AccBloc>().fleetDashboardData!.totalDuration).toStringAsFixed(2).split('.')[1]} mins',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.02,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .totalLoginHours,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.41,
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withAlpha(
                                                    (0.3 * 255).toInt())),
                                        child: Column(
                                          children: [
                                            MyText(
                                              text:
                                                  '${double.parse(context.read<AccBloc>().fleetDashboardData!.avgLoginHours).toStringAsFixed(2).split('.')[0]} Hrs ${double.parse(context.read<AccBloc>().fleetDashboardData!.avgLoginHours).toStringAsFixed(2).split('.')[1]} mins',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.02,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .averageLoginHrs,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.07,
                          ),
                          Container(
                            width: size.width * 0.9,
                            padding: EdgeInsets.all(size.width * 0.025),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColorDark
                                        .withAlpha((0.5 * 255).toInt()))),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context)
                                          .primaryColorDark
                                          .withAlpha((0.5 * 255).toInt())),
                                  width: size.width * 0.85,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .revenueDetails,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.025,
                                ),
                                SizedBox(
                                  width: size.width * 0.85,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: size.width * 0.41,
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withAlpha(
                                                    (0.3 * 255).toInt())),
                                        child: Column(
                                          children: [
                                            MyText(
                                              text:
                                                  '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.totalRevenue}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.02,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .totalRevenue,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.41,
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Theme.of(context)
                                                .primaryColorDark
                                                .withAlpha(
                                                    (0.3 * 255).toInt())),
                                        child: Column(
                                          children: [
                                            MyText(
                                              text:
                                                  '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.perDayRevenue}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.02,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .averageRevenue,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: AppColors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.07,
                          ),
                          if (double.parse(context
                                  .read<AccBloc>()
                                  .fleetDashboardData!
                                  .avgRating) >
                              1)
                            Container(
                              width: size.width * 0.9,
                              padding: EdgeInsets.all(size.width * 0.025),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColorDark
                                          .withAlpha((0.5 * 255).toInt()))),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withAlpha((0.5 * 255).toInt())),
                                    width: size.width * 0.85,
                                    padding: EdgeInsets.all(size.width * 0.025),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .overallRatings,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: AppColors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          size: size.width * 0.05,
                                          color: Colors.orange[400],
                                        ),
                                        SizedBox(
                                          width: size.width * 0.01,
                                        ),
                                        MyText(
                                          text:
                                              '${context.read<AccBloc>().fleetDashboardData!.avgRating} out of 5',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: AppColors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .excellent,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        Container(
                                          width: size.width * 0.45,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * 0.015),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              width: (context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingFive !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingFive)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFive)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .good,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        Container(
                                          width: size.width * 0.45,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * 0.015),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              width: (context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingFour !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingFour)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFour)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .below,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        Container(
                                          width: size.width * 0.45,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * 0.015),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              width: (context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingThree !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingThree)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingThree)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .average,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        Container(
                                          width: size.width * 0.45,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * 0.015),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              width: (context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingTwo !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingTwo)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingTwo)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .bad,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        Container(
                                          width: size.width * 0.45,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * 0.015),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              width: (context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingOne !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .ratingOne)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .fleetDashboardData!
                                                              .avgRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.015,
                                        ),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingOne)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: size.width * 0.05,
                          )
                        ],
                      )
                    : Container(),
              ),
            ),
          );
        })));
  }
}
