import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.driverPerformance,
                automaticallyImplyLeading: true,
              ),
              body: SingleChildScrollView(
                child: (context.read<AccBloc>().driverPerformanceData != null)
                    ? Column(
                        children: [
                          SizedBox(height: size.width * 0.1),
                          DriverPerformDetailsWidget(
                              cont: context, args: widget.args),
                          SizedBox(height: size.width * 0.07),
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
                                SizedBox(width: size.width * 0.025),
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
                          SizedBox(height: size.width * 0.07),
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
                                SizedBox(height: size.width * 0.025),
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
                                                  '${double.tryParse(context.read<AccBloc>().driverPerformanceData!.totalDurationInHours)!.toStringAsFixed(2).split('.')[0]} Hrs ${double.tryParse(context.read<AccBloc>().driverPerformanceData!.totalDurationInHours)!.toStringAsFixed(2).split('.')[1]} mins',
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
                                            SizedBox(height: size.width * 0.02),
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
                                                  '${double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageLoginHoursPerDay)!.toStringAsFixed(2).split('.')[0]} Hrs ${double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageLoginHoursPerDay)!.toStringAsFixed(2).split('.')[1]} mins',
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
                                            SizedBox(height: size.width * 0.02),
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
                          SizedBox(height: size.width * 0.07),
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
                                SizedBox(height: size.width * 0.025),
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
                                                  '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.totalRevenue}',
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
                                            SizedBox(height: size.width * 0.02),
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
                                                  '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.perDayRevenue}',
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
                                            SizedBox(height: size.width * 0.02),
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
                          SizedBox(height: size.width * 0.07),
                          if (double.parse(context
                                  .read<AccBloc>()
                                  .driverPerformanceData!
                                  .averageUserRating) >
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
                                        SizedBox(width: size.width * 0.01),
                                        MyText(
                                          text:
                                              '${context.read<AccBloc>().driverPerformanceData!.averageUserRating} out of 5',
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
                                  SizedBox(height: size.width * 0.05),
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
                                        SizedBox(width: size.width * 0.015),
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
                                                              .driverPerformanceData!
                                                              .rating5Average !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating
                                                              .toString() !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .rating5Average)! /
                                                          int.parse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating)))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(width: size.width * 0.015),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating5Average)! / int.parse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)) * 100).toStringAsFixed(0)}%',
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
                                  SizedBox(height: size.width * 0.05),
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
                                        SizedBox(width: size.width * 0.015),
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
                                                              .driverPerformanceData!
                                                              .rating4Average !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating
                                                              .toString() !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .rating4Average)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(width: size.width * 0.015),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating4Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
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
                                  SizedBox(height: size.width * 0.05),
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
                                        SizedBox(width: size.width * 0.015),
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
                                                              .driverPerformanceData!
                                                              .rating3Average !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating
                                                              .toString() !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .rating3Average)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                      size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(width: size.width * 0.015),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating3Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
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
                                  SizedBox(height: size.width * 0.05),
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
                                        SizedBox(width: size.width * 0.015),
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
                                                              .driverPerformanceData!
                                                              .rating2Average !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .rating2Average)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(width: size.width * 0.015),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating2Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
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
                                  SizedBox(height: size.width * 0.05),
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
                                        SizedBox(width: size.width * 0.015),
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
                                                              .driverPerformanceData!
                                                              .rating1Average !=
                                                          '0.0000' ||
                                                      context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating !=
                                                          '0')
                                                  ? (size.width *
                                                      0.45 *
                                                      (double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .rating1Average)! /
                                                          double.tryParse(context
                                                              .read<AccBloc>()
                                                              .driverPerformanceData!
                                                              .averageUserRating)!))
                                                  : size.width * 0,
                                              height: size.width * 0.03,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * 0.015),
                                                  color: AppColors.primary)),
                                        ),
                                        SizedBox(width: size.width * 0.015),
                                        MyText(
                                          text:
                                              '${((double.tryParse(context.read<AccBloc>().driverPerformanceData!.rating1Average)! / double.tryParse(context.read<AccBloc>().driverPerformanceData!.averageUserRating)!) * 100).toStringAsFixed(0)}%',
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
                          SizedBox(height: size.width * 0.05)
                        ],
                      )
                    : Container(),
              ),
            );
          },
        ),
      ),
    );
  }
}
