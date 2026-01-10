// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/history_model.dart';

class HistoryCardWidget extends StatelessWidget {
  final BuildContext cont;
  final HistoryData history;

  const HistoryCardWidget({
    super.key,
    required this.cont,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(width: 1, color: Theme.of(context).shadowColor)),
            child: Column(
              children: [
                // === Pickup & Drop Address Section ===
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Pickup
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Image.asset(
                              AppImages.historyDot,
                              height: 44,
                              width: 44,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: history.pickAddress,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                MyText(
                                  text: history.cvTripStartTime,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: AppColors.greyHintColor,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Drop (or last stop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Image.asset(
                              AppImages.mapPin,
                              height: 44,
                              width: 44,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  text: (history
                                              .requestStops?.data.isNotEmpty ==
                                          true)
                                      ? history.requestStops!.data.last.address
                                      : history.dropAddress,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                MyText(
                                  text: history.cvCompletedAt,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: AppColors.greyHintColor,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: Theme.of(context).disabledColor.withOpacity(0.1),
                ),

                // === Bottom Section ===
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: (history.isOutStation != 1)
                      ? _buildRegularTripDetails(context)
                      : _buildOutstationTripDetails(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Regular City Ride
  Widget _buildRegularTripDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Vehicle Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: history.laterRide == true
                    ? history.tripStartTimeWithDate
                    : history.isCompleted == 1
                        ? history.convertedCompletedAt
                        : history.isCancelled == 1
                            ? history.convertedCancelledAt
                            : history.convertedCreatedAt,
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).disabledColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: history.vehicleTypeImage,
                    height: 48,
                    width: 48,
                    placeholder: (_, __) => const Loader(),
                    errorWidget: (_, __, ___) => Image.asset(AppImages.noImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: history.vehicleTypeName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: history.carColor,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.greyHintColor,
                                    fontSize: 13,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right: Status + Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (history.isCompleted == 1 ||
                history.isCancelled == 1 ||
                history.isLater == true)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: history.isCompleted == 1
                      ? AppColors.green
                      : history.isCancelled == 1
                          ? AppColors.red
                          : AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: MyText(
                  text: history.isCompleted == 1
                      ? AppLocalizations.of(context)!.completed
                      : history.isCancelled == 1
                          ? AppLocalizations.of(context)!.cancelled
                          : (history.isRental == false)
                              ? AppLocalizations.of(context)!.upcoming
                              : 'Rental ${history.rentalPackageName}',
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                ),
              ),
            const SizedBox(height: 12),
            MyText(
              text: (history.isBidRide == 1)
                  ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                  : (history.isCompleted == 1)
                      ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                      : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}',
              textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // Outstation Ride
  Widget _buildOutstationTripDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Trip Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellowColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.yellowColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(
                    text: (history.isRoundTrip == 1)
                        ? AppLocalizations.of(context)!.roundTrip
                        : AppLocalizations.of(context)!.oneWayTrip,
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.yellowColor,
                        ),
                  ),
                  if (history.isRoundTrip == 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.import_export,
                          size: 14, color: AppColors.yellowColor),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info
            Expanded(
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: history.vehicleTypeImage,
                    height: 48,
                    width: 48,
                    placeholder: (_, __) => const Loader(),
                    errorWidget: (_, __, ___) => Image.asset(AppImages.noImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: history.vehicleTypeName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: history.carColor,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.greyHintColor,
                                    fontSize: 13,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Date + Payment + Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text: (history.laterRide == true)
                      ? history.tripStartTimeWithDate
                      : history.isCompleted == 1
                          ? history.convertedCompletedAt
                          : history.isCancelled == 1
                              ? history.convertedCancelledAt
                              : history.convertedCreatedAt,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: AppColors.greyHintColor,
                        fontSize: 12,
                      ),
                ),
                if (history.returnTime.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: MyText(
                      text: history.returnTime,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),

                // Payment Method Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: MyText(
                    text: (history.paymentOpt == '1')
                        ? AppLocalizations.of(context)!.cash
                        : (history.paymentOpt == '2')
                            ? AppLocalizations.of(context)!.wallet
                            : AppLocalizations.of(context)!.card,
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Final Price
                MyText(
                  text: (history.isBidRide == 1)
                      ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                      : (history.isCompleted == 1)
                          ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                          : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}',
                  textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
