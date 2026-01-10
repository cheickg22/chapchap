import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_header.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';

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
              body: SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                CustomHeader(
                  title: AppLocalizations.of(context)!.cabPerformance,
                  automaticallyImplyLeading: true,
                  titleFontSize: 18,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: (context.read<AccBloc>().fleetDashboardData != null)
                        ? Column(
                            children: [
                              SizedBox(
                                height: size.width * 0.025,
                              ),
                              Container(
                                  width: size.width,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.borderColor)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: size.width * 0.15,
                                            width: size.width * 0.15,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                image: DecorationImage(
                                                    image: NetworkImage(context
                                                        .read<AccBloc>()
                                                        .fleetDashboardData!
                                                        .vehicleTypeIcon),
                                                    fit: BoxFit.cover)),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.05,
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  MyText(
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
                                                                FontWeight
                                                                    .w400),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  MyText(
                                                    text: context
                                                        .read<AccBloc>()
                                                        .fleetDashboardData!
                                                        .licenseNo,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Add space evenly
                                        children: [
                                          // Booking Row
                                          Container(
                                            padding: EdgeInsets.all(
                                                size.width * 0.02),
                                            // width: size.width * 0.3,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  color: AppColors.primary,
                                                  size: size.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.02,
                                                ),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .booking,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                                const SizedBox(width: 5),
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .fleetDashboardData!
                                                      .totalTrips,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.025,
                                          ),

                                          // Distance Row
                                          Container(
                                            padding: EdgeInsets.all(
                                                size.width * 0.02),
                                            // width: size.width * 0.3,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.speed,
                                                  color: AppColors.primary,
                                                  size: size.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.025,
                                                ),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .distance,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                                const SizedBox(width: 5),
                                                MyText(
                                                  text:
                                                      '${context.read<AccBloc>().fleetDashboardData!.totalDistance} Km',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                size.width * 0.02),
                                            // width: size.width * 0.3,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.money,
                                                  size: size.width * 0.05,
                                                  color: AppColors.primary,
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                MyText(
                                                  text:
                                                      '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.totalEarnings}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              Container(
                                height: size.width * 0.475,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    Container(
                                      width: size.width,
                                      height: size.width * 0.125,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: AppColors.borderColor),
                                          )),
                                      padding:
                                          EdgeInsets.all(size.width * 0.025),
                                      alignment: Alignment.centerLeft,
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .loginHourDetails,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: AppColors.white,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: size.width * 0.41,
                                            height: size.width * 0.25,
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: AppColors.borderColors),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyText(
                                                  text:
                                                      '${double.parse(context.read<AccBloc>().fleetDashboardData!.totalDuration).toStringAsFixed(2).split('.')[0]} Hrs ${double.parse(context.read<AccBloc>().fleetDashboardData!.totalDuration).toStringAsFixed(2).split('.')[1]} mins',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.02,
                                                ),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .totalLoginHours,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                        fontSize: 14,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: size.width * 0.41,
                                            height: size.width * 0.25,
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: AppColors.borderColors),
                                            child: Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      '${double.parse(context.read<AccBloc>().fleetDashboardData!.avgLoginHours).toStringAsFixed(2).split('.')[0]} Hrs ${double.parse(context.read<AccBloc>().fleetDashboardData!.avgLoginHours).toStringAsFixed(2).split('.')[1]} mins',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.02,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.35,
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .averageLoginHrs,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                          fontSize: 14,
                                                        ),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                  ),
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
                                height: size.width * 0.05,
                              ),
                              Container(
                                height: size.width * 0.475,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(10)),
                                alignment: Alignment.topCenter,
                                child: Column(
                                  children: [
                                    Container(
                                      width: size.width,
                                      height: size.width * 0.125,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: AppColors.borderColor),
                                          )),
                                      padding:
                                          EdgeInsets.all(size.width * 0.025),
                                      alignment: Alignment.centerLeft,
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .returningDetails,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: AppColors.white,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: size.width * 0.41,
                                            height: size.width * 0.25,
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: AppColors.borderColors),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyText(
                                                  text:
                                                      '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.totalRevenue}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.02,
                                                ),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .totalRevenue,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                        fontSize: 14,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: size.width * 0.41,
                                            height: size.width * 0.25,
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: AppColors.borderColors),
                                            child: Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDashboardData!.perDayRevenue}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: size.width * 0.02,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.35,
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .averageRevenue,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
                                                          fontSize: 14,
                                                        ),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                  ),
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
                                height: size.width * 0.05,
                              ),
                              if (double.parse(context
                                      .read<AccBloc>()
                                      .fleetDashboardData!
                                      .avgRating) >
                                  1)
                                Container(
                                  height: size.width * 0.7,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.borderColor),
                                      borderRadius: BorderRadius.circular(10)),
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: size.width,
                                        height: size.width * 0.125,
                                        decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            border: Border(
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: AppColors.borderColor),
                                            )),
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .overallRatings,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: AppColors.white,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star_border,
                                                  size: size.width * 0.05,
                                                  color: Colors.orange[400],
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.01),
                                                MyText(
                                                  text:
                                                      '${context.read<AccBloc>().fleetDashboardData!.avgRating} out of 5',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: AppColors.white,
                                                        fontSize: 14,
                                                      ),
                                                ),
                                              ],
                                            )
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
                                                text: AppLocalizations.of(
                                                        context)!
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
                                                                  .read<
                                                                      AccBloc>()
                                                                  .fleetDashboardData!
                                                                  .ratingFive !=
                                                              '0.0000' ||
                                                          context.read<AccBloc>().fleetDashboardData!.avgRating !=
                                                              '0')
                                                      ? (size.width *
                                                          0.45 *
                                                          (double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFive)! /
                                                              double.tryParse(context
                                                                  .read<
                                                                      AccBloc>()
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
                                                  '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFive)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
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
                                                text: AppLocalizations.of(
                                                        context)!
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
                                                                  .read<
                                                                      AccBloc>()
                                                                  .fleetDashboardData!
                                                                  .ratingFour !=
                                                              '0.0000' ||
                                                          context.read<AccBloc>().fleetDashboardData!.avgRating !=
                                                              '0')
                                                      ? (size.width *
                                                          0.45 *
                                                          (double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFour)! /
                                                              double.tryParse(context
                                                                  .read<
                                                                      AccBloc>()
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
                                                  '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingFour)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
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
                                                text: AppLocalizations.of(
                                                        context)!
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
                                                                  .read<
                                                                      AccBloc>()
                                                                  .fleetDashboardData!
                                                                  .ratingThree !=
                                                              '0.0000' ||
                                                          context.read<AccBloc>().fleetDashboardData!.avgRating !=
                                                              '0')
                                                      ? (size.width *
                                                          0.45 *
                                                          (double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingThree)! /
                                                              double.tryParse(context
                                                                  .read<
                                                                      AccBloc>()
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
                                                  '${((double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingThree)! / double.tryParse(context.read<AccBloc>().fleetDashboardData!.avgRating)!) * 100).toStringAsFixed(0)}%',
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
                                                text: AppLocalizations.of(
                                                        context)!
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
                                                  width: (context.read<AccBloc>().fleetDashboardData!.ratingTwo !=
                                                              '0.0000' ||
                                                          context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .fleetDashboardData!
                                                                  .avgRating !=
                                                              '0')
                                                      ? (size.width *
                                                          0.45 *
                                                          (double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingTwo)! /
                                                              double.tryParse(context
                                                                  .read<
                                                                      AccBloc>()
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
                                                      fontWeight:
                                                          FontWeight.w600),
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
                                                text: AppLocalizations.of(
                                                        context)!
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
                                                  width: (context.read<AccBloc>().fleetDashboardData!.ratingOne !=
                                                              '0.0000' ||
                                                          context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .fleetDashboardData!
                                                                  .avgRating !=
                                                              '0')
                                                      ? (size.width *
                                                          0.45 *
                                                          (double.tryParse(context.read<AccBloc>().fleetDashboardData!.ratingOne)! /
                                                              double.tryParse(context
                                                                  .read<
                                                                      AccBloc>()
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
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: size.width * 0.025),
                                    ],
                                  ),
                                ),
                            ],
                          )
                        : Container(),
                  ),
                ))
              ],
            ),
          ));
        })));
  }
}
