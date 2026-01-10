import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class TripVehicleInfoWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripVehicleInfoWidget(
      {super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              // color: AppColors.white,
              border: Border.all(width: 1, color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row - Vehicle Image and Type of Ride
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side - Vehicle Image and Name
                      Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: arg.historyData.vehicleTypeImage.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          arg.historyData.vehicleTypeImage),
                                      fit: BoxFit.cover,
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(AppImages.noImage),
                                      fit: BoxFit.cover,
                                    ),
                              shape: BoxShape.circle,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          MyText(
                            text: arg.historyData.vehicleTypeName,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                        ],
                      ),
                      // Right Side - Type of Ride Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.typeOfRide,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14,
                                ),
                          ),
                          SizedBox(height: size.width * 0.01),
                          MyText(
                            text: (arg.historyData.isRental == false)
                                ? (arg.historyData.isOutStation == 1)
                                    ? AppLocalizations.of(context)!.outStation
                                    : (arg.historyData.isLater == true)
                                        ? AppLocalizations.of(context)!
                                            .rideLater
                                        : AppLocalizations.of(context)!.regular
                                : '${AppLocalizations.of(context)!.rental}-${arg.historyData.rentalPackageName}',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                          SizedBox(height: size.width * 0.01),
                          if (arg.historyData.isOutStation == 1)
                            MyText(
                              text: (arg.historyData.isOutStation == 1 &&
                                      arg.historyData.isRoundTrip != '')
                                  ? AppLocalizations.of(context)!.roundTrip
                                  : AppLocalizations.of(context)!.oneWayTrip,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: AppColors.yellowColor,
                                    fontSize: 13,
                                  ),
                            ),
                          SizedBox(height: size.width * 0.005),
                          MyText(
                            text: (arg.historyData.laterRide == true &&
                                    arg.historyData.isOutStation == 1)
                                ? arg.historyData.tripStartTime
                                : (arg.historyData.laterRide == true &&
                                        arg.historyData.isOutStation != 1)
                                    ? arg.historyData.tripStartTimeWithDate
                                    : arg.historyData.isCompleted == 1
                                        ? arg.historyData.convertedCompletedAt
                                        : arg.historyData.isCancelled == 1
                                            ? arg.historyData
                                                .convertedCancelledAt
                                            : arg
                                                .historyData.convertedCreatedAt,
                            textStyle: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: size.width * 0.06),

                  // Bottom Section - Duration, Distance, Color (only if completed)
                  if (arg.historyData.isCompleted == 1)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_outlined,
                                      size: size.width * 0.05,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .duration,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.width * 0.01),
                                MyText(
                                  text:
                                      '${arg.historyData.totalTime} ${AppLocalizations.of(context)!.mins}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                ),
                              ],
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        AppImages.routes,
                                        height: size.width * 0.05,
                                        width: size.width * 0.05,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .distance,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontSize: 13,
                                            ),
                                      ),
                                    ],
                                  ),
                                  MyText(
                                    text:
                                        '${arg.historyData.totalDistance} ${arg.historyData.unit}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ])
                          ],
                        ),

                        SizedBox(height: size.width * 0.04),

                        // Color Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  AppImages.vehicleColorImage,
                                  height: size.width * 0.05,
                                  width: size.width * 0.05,
                                  color: Theme.of(context).hintColor,
                                ),
                                SizedBox(width: size.width * 0.02),
                                MyText(
                                  text: AppLocalizations.of(context)!.colorText,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                            MyText(
                              text: arg.historyData.carColor,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
