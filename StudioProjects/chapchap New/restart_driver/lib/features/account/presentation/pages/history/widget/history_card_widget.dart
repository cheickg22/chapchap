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
  const HistoryCardWidget(
      {super.key, required this.cont, required this.history});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
                // Pickup and Drop Address Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Pickup Location
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
                                  text: (history.requestStops != null &&
                                          history.requestStops!.isNotEmpty)
                                      ? history.requestStops!.last['address']
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

                // Bottom Section with Vehicle Details and Price
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: (history.isOutStation != 1)
                      ? _buildRegularTripDetails(context, size)
                      : _buildOutstationTripDetails(context, size),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegularTripDetails(BuildContext context, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Vehicle Info
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
                  history.vehicleTypeImage.isNotEmpty
                      ? Image.network(
                          history.vehicleTypeImage,
                          height: 48,
                          width: 48,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(AppImages.noImage),
                        )
                      : Image.asset(AppImages.noImage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: history.vehicleTypeName,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        if (history.isOutStation == 1 &&
                            history.isCancelled != 1 &&
                            history.isCompleted != 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (history.driverDetail != null)
                                  ? AppColors.green.withOpacity(0.1)
                                  : AppColors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: MyText(
                              text: (history.driverDetail != null)
                                  ? AppLocalizations.of(context)!.assinged
                                  : AppLocalizations.of(context)!.unAssinged,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: (history.driverDetail != null)
                                        ? AppColors.green
                                        : AppColors.red,
                                  ),
                            ),
                          )
                        else
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

        // Right Side - Status and Price
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
                          : history.isLater == true
                              ? (history.isRental == false)
                                  ? AppLocalizations.of(context)!.upcoming
                                  : '${AppLocalizations.of(context)!.rental} ${history.rentalPackageName.toString()}'
                              : '',
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: history.isCompleted == 1
                            ? AppColors.black
                            : history.isCancelled == 1
                                ? AppColors.black
                                : AppColors.black,
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

  Widget _buildOutstationTripDetails(BuildContext context, Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side - Vehicle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Type Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          text: (history.isOutStation == 1 &&
                                  history.isRoundTrip != '')
                              ? AppLocalizations.of(context)!.roundTrip
                              : AppLocalizations.of(context)!.oneWayTrip,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: AppColors.yellowColor,
                                  ),
                        ),
                        if (history.isOutStation == 1 &&
                            history.isRoundTrip != '')
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.import_export,
                              size: 14,
                              color: AppColors.yellowColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: history.vehicleTypeImage,
                        // fit: BoxFit.contain,
                        height: 48,
                        width: 48,
                        placeholder: (context, url) => const Center(
                          child: Loader(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Text(""),
                        ),
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
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: history.carColor,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
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

            // Right Side - Date and Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyText(
                  text: (history.laterRide == true && history.isOutStation == 1)
                      ? history.tripStartTime
                      : (history.laterRide == true && history.isOutStation != 1)
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
                      textStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: 12,
                              ),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                  decoration: BoxDecoration(
                    color: history.isCompleted == 1
                        ? AppColors.green
                        : history.isCancelled == 1
                            ? AppColors.red
                            : AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: MyText(
                    text: (history.paymentOpt == '1')
                        ? AppLocalizations.of(context)!.cash
                        : (history.paymentOpt == '2')
                            ? AppLocalizations.of(context)!.wallet
                            : (history.paymentOpt == '0')
                                ? AppLocalizations.of(context)!.card
                                : '',
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Theme.of(context).primaryColorDark,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                // Price
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
