import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../common/pickup_icon.dart';
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
            margin: EdgeInsets.only(bottom: size.width * 0.02),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .disabledColor
                  .withAlpha((0.15 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: size.width * 0.001,
                color: Theme.of(context).disabledColor,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const PickupIcon(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: MyText(
                            overflow: TextOverflow.ellipsis,
                            text: history.pickAddress,
                            textStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      MyText(
                        text: history.cvTripStartTime,
                        textStyle:
                            Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const DropIcon(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: MyText(
                            overflow: TextOverflow.ellipsis,
                            text: (history.requestStops != null &&
                                    history.requestStops!.isNotEmpty)
                                ? history.requestStops!.last['address']
                                : history.dropAddress,
                            textStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      MyText(
                        text: history.cvCompletedAt,
                        textStyle:
                            Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.03),
                Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (history.isOutStation != 1)
                          ? Column(
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
                                  textStyle:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            image: history
                                                    .vehicleTypeImage.isNotEmpty
                                                ? DecorationImage(
                                                    image: NetworkImage(history
                                                        .vehicleTypeImage),
                                                  )
                                                : const DecorationImage(
                                                    image: AssetImage(
                                                        AppImages.noImage),
                                                  ),
                                            // shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor)),
                                    SizedBox(width: size.width * 0.025),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: history.vehicleTypeName,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        if (history.isOutStation == 1 &&
                                            history.isCancelled != 1 &&
                                            history.isCompleted != 1)
                                          MyText(
                                            text: (history.driverDetail != null)
                                                ? AppLocalizations.of(context)!
                                                    .assinged
                                                : AppLocalizations.of(context)!
                                                    .unAssinged,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        (history.driverDetail !=
                                                                null)
                                                            ? AppColors.green
                                                            : AppColors.red),
                                          ),
                                        MyText(
                                          text: history.carColor,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    MyText(
                                      text: (history.isOutStation == 1 &&
                                              history.isRoundTrip != '')
                                          ? AppLocalizations.of(context)!
                                              .roundTrip
                                          : AppLocalizations.of(context)!
                                              .oneWayTrip,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: AppColors.yellowColor,
                                          ),
                                    ),
                                    if (history.isOutStation == 1 &&
                                        history.isRoundTrip != '')
                                      const Icon(Icons.import_export)
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                      child: CachedNetworkImage(
                                        imageUrl: history.vehicleTypeImage,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: Loader(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                          child: Text(""),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: history.vehicleTypeName,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                        MyText(
                                          text: history.carColor,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      (history.isOutStation != 1)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: history.isCompleted == 1
                                      ? AppLocalizations.of(context)!.completed
                                      : history.isCancelled == 1
                                          ? AppLocalizations.of(context)!
                                              .cancelled
                                          : history.isLater == true
                                              ? (history.isRental == false)
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .upcoming
                                                  : '${AppLocalizations.of(context)!.rental} ${history.rentalPackageName.toString()}'
                                              : '',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: history.isCompleted == 1
                                            ? AppColors.green
                                            : history.isCancelled == 1
                                                ? AppColors.red
                                                : history.isLater == true
                                                    ? AppColors.secondaryDark
                                                    : Theme.of(context)
                                                        .primaryColorDark,
                                      ),
                                ),
                                MyText(
                                    text: (history.isBidRide == 1)
                                        ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                                        : (history.isCompleted == 1)
                                            ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                                            : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}')
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: (history.laterRide == true &&
                                          history.isOutStation == 1)
                                      ? history.tripStartTime
                                      : (history.laterRide == true &&
                                              history.isOutStation != 1)
                                          ? history.tripStartTimeWithDate
                                          : history.isCompleted == 1
                                              ? history.convertedCompletedAt
                                              : history.isCancelled == 1
                                                  ? history.convertedCancelledAt
                                                  : history.convertedCreatedAt,
                                  textStyle:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                MyText(
                                  text: history.returnTime,
                                  textStyle:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                SizedBox(
                                  height: size.width * 0.025,
                                ),
                                Row(
                                  children: [
                                    MyText(
                                      text: (history.paymentOpt == '1')
                                          ? AppLocalizations.of(context)!.cash
                                          : (history.paymentOpt == '2')
                                              ? AppLocalizations.of(context)!
                                                  .wallet
                                              : (history.paymentOpt == '0')
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .card
                                                  : (history.paymentOpt == '4')
                                                      ? 'Orange Money'
                                                      : '',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    MyText(
                                      text: (history.isBidRide == 1)
                                          ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                                          : (history.isCompleted == 1)
                                              ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                                              : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
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
          );
        },
      ),
    );
  }
}
