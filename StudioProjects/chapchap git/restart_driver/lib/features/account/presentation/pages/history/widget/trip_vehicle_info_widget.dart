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
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(AppImages.noImage),
                                    ),
                              shape: BoxShape.circle,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          MyText(
                            text: arg.historyData.vehicleTypeName,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.typeOfRide,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
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
                                    fontWeight: FontWeight.bold, fontSize: 13),
                          ),
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
                                  ),
                            ),
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
                            textStyle: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * 0.035),
                  if (arg.historyData.isCompleted == 1)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!.duration,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                                MyText(
                                  text:
                                      '${arg.historyData.totalTime} ${AppLocalizations.of(context)!.mins}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                ),
                                SizedBox(height: size.width * 0.02),
                                MyText(
                                  text: AppLocalizations.of(context)!.colorText,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                                MyText(
                                  text: arg.historyData.carColor,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!.distance,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                                MyText(
                                  text:
                                      '${arg.historyData.totalDistance} ${arg.historyData.unit}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.width * 0.025),
                      ],
                    ),
                  SizedBox(height: size.width * 0.02),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
