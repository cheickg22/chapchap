import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../widget/driver_perform_details_widget.dart';

class DriverPerformancePage extends StatefulWidget {
  static const String routeName = '/driverPerformance';
  final DriverDashboardArguments args;

  const DriverPerformancePage({super.key, required this.args});

  @override
  State<DriverPerformancePage> createState() => _DriverPerformancePageState();
}

class _DriverPerformancePageState extends State<DriverPerformancePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetDriverPerformanceEvent(driverId: widget.args.driverId)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is DriverPerformanceLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is DriverPerformanceLoadingStartState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              body: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    CustomAppBar(
                      title: AppLocalizations.of(context)!.driverPerformance,
                      automaticallyImplyLeading: true,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: (context.read<AccBloc>().driverPerformanceData !=
                                null)
                            ? Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: Column(
                                  children: [
                                    DriverPerformDetailsWidget(
                                        cont: context, args: widget.args),
                                    SizedBox(
                                      height: size.width * 0.05,
                                    ),
                                    Container(
                                      height: size.width * 0.475,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.borderColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                                                      color: AppColors
                                                          .borderColor),
                                                )),
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            alignment: Alignment.centerLeft,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: size.width * 0.41,
                                                  height: size.width * 0.25,
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.025),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: AppColors
                                                          .borderColors),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${double.tryParse(context.read<AccBloc>().driverPerformanceData!.totalDurationInHours)!.toStringAsFixed(2).split('.')[0]} Hrs ${double.tryParse(context.read<AccBloc>().driverPerformanceData!.totalDurationInHours)!.toStringAsFixed(2).split('.')[1]} mins',
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 16,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.02,
                                                      ),
                                                      MyText(
                                                        text: AppLocalizations
                                                                .of(context)!
                                                            .totalLoginHours,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                  fontSize: 14,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
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
                                                          BorderRadius.circular(
                                                              5),
                                                      color: AppColors
                                                          .borderColors),
                                                  child: Column(
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageLoginHoursPerDay)!.toStringAsFixed(2).split('.')[0]} Hrs ${double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageLoginHoursPerDay)!.toStringAsFixed(2).split('.')[1]} mins',
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 16,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.02,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.35,
                                                        child: MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .averageLoginHrs,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
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
                                    SizedBox(height: size.width * 0.05),
                                    Container(
                                      height: size.width * 0.475,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.borderColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                                                      color: AppColors
                                                          .borderColor),
                                                )),
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            alignment: Alignment.centerLeft,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: size.width * 0.41,
                                                  height: size.width * 0.25,
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.025),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: AppColors
                                                          .borderColors),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.totalRevenue}',
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 16,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.02,
                                                      ),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .totalRevenue,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                  fontSize: 14,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
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
                                                          BorderRadius.circular(
                                                              5),
                                                      color: AppColors
                                                          .borderColors),
                                                  child: Column(
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.perDayRevenue}',
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 16,
                                                                ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.02,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.35,
                                                        child: MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .averageRevenue,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
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
                                    SizedBox(height: size.width * 0.07),
                                    if (double.parse(context
                                            .read<AccBloc>()
                                            .driverPerformanceData!
                                            .averageUserRating) >
                                        1)
                                      Container(
                                        height: size.width * 0.7,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: size.width,
                                              height: size.width * 0.125,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        width: 1,
                                                        color: AppColors
                                                            .borderColor),
                                                  )),
                                              padding: EdgeInsets.all(
                                                  size.width * 0.025),
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .overallRatings,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color:
                                                              AppColors.white,
                                                          fontSize: 14,
                                                        ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star_border,
                                                        size: size.width * 0.05,
                                                        color:
                                                            Colors.orange[400],
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.01),
                                                      MyText(
                                                        text:
                                                            '${context.read<AccBloc>().driverPerformanceData!.averageUserRating} out of 5',
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .white,
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
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  Container(
                                                    width: size.width * 0.45,
                                                    height: size.width * 0.03,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        0.015),
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        width: (context.read<AccBloc>().driverPerformanceData!.rating5Average !=
                                                                    '0.0000' ||
                                                                context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating
                                                                        .toString() !=
                                                                    '0')
                                                            ? (size.width *
                                                                0.45 *
                                                                (double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating5Average)! /
                                                                    int.parse(context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating)))
                                                            : size.width * 0,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(size.width * 0.015),
                                                            color: AppColors.primary)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  MyText(
                                                    text:
                                                        '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating5Average)! / int.parse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)) * 100).toStringAsFixed(0)}%',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: size.width * 0.05),
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
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  Container(
                                                    width: size.width * 0.45,
                                                    height: size.width * 0.03,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        0.015),
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        width: (context.read<AccBloc>().driverPerformanceData!.rating4Average !=
                                                                    '0.0000' ||
                                                                context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating
                                                                        .toString() !=
                                                                    '0')
                                                            ? (size.width *
                                                                0.45 *
                                                                (double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating4Average)! /
                                                                    double.tryParse(context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating)!))
                                                            : size.width * 0,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(size.width * 0.015),
                                                            color: AppColors.primary)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  MyText(
                                                    text:
                                                        '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating4Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: size.width * 0.05),
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
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  Container(
                                                    width: size.width * 0.45,
                                                    height: size.width * 0.03,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        0.015),
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        width: (context.read<AccBloc>().driverPerformanceData!.rating3Average !=
                                                                    '0.0000' ||
                                                                context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating
                                                                        .toString() !=
                                                                    '0')
                                                            ? (size.width *
                                                                0.45 *
                                                                (double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating3Average)! /
                                                                    double.tryParse(context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating)!))
                                                            : size.width * 0,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(size.width * 0.015),
                                                            color: AppColors.primary)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  MyText(
                                                    text:
                                                        '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating3Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: size.width * 0.05),
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
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  Container(
                                                    width: size.width * 0.45,
                                                    height: size.width * 0.03,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        0.015),
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        width: (context.read<AccBloc>().driverPerformanceData!.rating2Average !=
                                                                    '0.0000' ||
                                                                context.read<AccBloc>().driverPerformanceData!.averageUserRating !=
                                                                    '0')
                                                            ? (size.width *
                                                                0.45 *
                                                                (double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating2Average)! /
                                                                    double.tryParse(context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating)!))
                                                            : size.width * 0,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    size.width *
                                                                        0.015),
                                                            color: AppColors.primary)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  MyText(
                                                    text:
                                                        '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating2Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: size.width * 0.05),
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
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  Container(
                                                    width: size.width * 0.45,
                                                    height: size.width * 0.03,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        0.015),
                                                        color: Theme.of(context)
                                                            .scaffoldBackgroundColor),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        width: (context.read<AccBloc>().driverPerformanceData!.rating1Average !=
                                                                    '0.0000' ||
                                                                context.read<AccBloc>().driverPerformanceData!.averageUserRating !=
                                                                    '0')
                                                            ? (size.width *
                                                                0.45 *
                                                                (double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating1Average)! /
                                                                    double.tryParse(context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverPerformanceData!
                                                                        .averageUserRating)!))
                                                            : size.width * 0,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    size.width *
                                                                        0.015),
                                                            color: AppColors.primary)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.015),
                                                  MyText(
                                                    text:
                                                        '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating1Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.width * 0.025),
                                          ],
                                        ),
                                      ),
                                    SizedBox(height: size.width * 0.15)
                                  ],
                                ),
                              )
                            : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
