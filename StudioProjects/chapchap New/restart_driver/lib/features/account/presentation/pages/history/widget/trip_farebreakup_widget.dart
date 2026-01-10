import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import 'fare_breakup.dart';

class TripFarebreakupWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripFarebreakupWidget(
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: AppColors.borderColor)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (arg.historyData.isCancelled == 1)
                        ? MyText(
                            text: AppLocalizations.of(context)!.cancelled,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                          )
                        : (arg.historyData.isCompleted == 1)
                            ? MyText(
                                text: AppLocalizations.of(context)!.fareBreakup,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                              )
                            : Container()
                  ],
                ),
                SizedBox(height: size.width * 0.025),
                if (arg.historyData.isBidRide == 1 &&
                    arg.historyData.isCancelled == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: size.width * 0.025,
                          ),
                          MyText(
                              text: (arg.historyData.paymentOpt == '1')
                                  ? AppLocalizations.of(context)!.cash
                                  : (arg.historyData.paymentOpt == '2')
                                      ? AppLocalizations.of(context)!.wallet
                                      : (arg.historyData.paymentOpt == '0')
                                          ? AppLocalizations.of(context)!.card
                                          : '',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(fontSize: 16)),
                          SizedBox(height: size.width * 0.025),
                          (arg.historyData.requestBill == null)
                              ? MyText(
                                  text: (arg.historyData.isBidRide == 1)
                                      ? '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                                      : (arg.historyData.isCompleted == 1)
                                          ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                          : '${arg.historyData.requestedCurrencySymbol} ${arg.historyData.requestEtaAmount}')
                              : MyText(
                                  text:
                                      '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .copyWith(fontSize: 20))
                        ],
                      ),
                    ],
                  ),
                if (arg.historyData.isCancelled != 1 &&
                    arg.historyData.requestBill != null)
                  Column(
                    children: [
                      if (arg.historyData.requestBill.data.basePrice != 0)
                        FareBreakup(
                            showBorder: true,
                            text:
                                "${AppLocalizations.of(context)!.basePrice} (${arg.historyData.requestBill!.data.baseDistance}  ${arg.historyData.requestBill!.data.unit})",
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.basePrice}'),
                      if (arg.historyData.requestBill.data.distancePrice != 0)
                        FareBreakup(
                            showBorder: true,
                            text:
                                "${AppLocalizations.of(context)!.distancePrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.pricePerDistance} x ${arg.historyData.requestBill!.data.calculatedDistance} ${arg.historyData.requestBill!.data.unit})",
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.distancePrice}'),
                      if (arg.historyData.requestBill.data.timePrice != 0)
                        FareBreakup(
                            showBorder: true,
                            text:
                                "${AppLocalizations.of(context)!.timePrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.pricePerTime} x ${arg.historyData.requestBill!.data.totalTime})",
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.timePrice}'),
                      if (arg.historyData.requestBill.data.waitingCharge != 0)
                        FareBreakup(
                            showBorder: true,
                            text:
                                "${AppLocalizations.of(context)!.waitingPrice} (${arg.historyData.requestBill!.data.requestedCurrencySymbol} ${arg.historyData.requestBill!.data.waitingChargePerMin} x ${arg.historyData.requestBill!.data.calculatedWaitingTime} mins)",
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.waitingCharge}'),
                      if (arg.historyData.requestBill.data.adminCommision != 0)
                        FareBreakup(
                            showBorder: true,
                            text: AppLocalizations.of(context)!.convFee,
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}'),
                      if (arg.historyData.requestBill.data.promoDiscount != 0)
                        FareBreakup(
                          showBorder: true,
                          text: AppLocalizations.of(context)!.discount,
                          price:
                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                          textcolor: Theme.of(context).primaryColorDark,
                          pricecolor: Theme.of(context).primaryColorDark,
                        ),
                      if (arg.historyData.requestBill.data
                                  .additionalChargesAmount !=
                              0 &&
                          arg.historyData.requestBill.data
                                  .additionalChargesReason !=
                              null)
                        FareBreakup(
                            showBorder: true,
                            text:
                                AppLocalizations.of(context)!.additionalCharges,
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.additionalChargesAmount}'),
                      if (arg.historyData.requestBill != null &&
                          (arg.historyData.requestBill.data.cancellationFee !=
                              0.0) &&
                          (arg.historyData.requestBill.data.cancellationFee !=
                              0))
                        FareBreakup(
                            showBorder: true,
                            text: AppLocalizations.of(context)!.cancellationFee,
                            price:
                                '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.cancellationFee}'),
                      if (arg.historyData.requestBill.data.airportSurgeFee !=
                              0 &&
                          arg.historyData.requestBill.data.airportSurgeFee !=
                              '' &&
                          arg.historyData.transportType == 'taxi' &&
                          arg.historyData.isBidRide == 0)
                        FareBreakup(
                            showBorder: true,
                            text: AppLocalizations.of(context)!.airportSurgeFee,
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.airportSurgeFee}'),
                      FareBreakup(
                          showBorder: true,
                          text: AppLocalizations.of(context)!.taxes,
                          price:
                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}'),
                      if (arg.historyData.requestBill.data
                              .preferencePriceTotal !=
                          0)
                        FareBreakup(
                            showBorder: true,
                            text: AppLocalizations.of(context)!.preferenceTotal,
                            price:
                                '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.preferencePriceTotal}'),
                      SizedBox(height: size.height * 0.01),
                      (arg.historyData.requestBill != null &&
                              arg.historyData.isBidRide != 1)
                          ? Padding(
                              padding: EdgeInsets.only(
                                bottom: size.width * 0.025,
                                top: size.width * 0.025,
                              ),
                              child: Row(
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .customerPays,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: size.width * 0.07),
                                  Row(
                                    children: [
                                      MyText(
                                        text: (arg.historyData.paymentOpt ==
                                                '1')
                                            ? AppLocalizations.of(context)!.cash
                                            : (arg.historyData.paymentOpt ==
                                                    '2')
                                                ? AppLocalizations.of(context)!
                                                    .wallet
                                                : (arg.historyData.paymentOpt ==
                                                        '0')
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .card
                                                    : '',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      (arg.historyData.requestBill == null)
                                          ? Row(
                                              children: [
                                                MyText(
                                                  text: (arg.historyData
                                                              .isBidRide ==
                                                          1)
                                                      ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.acceptedRideFare}'
                                                      : (arg.historyData
                                                                  .isCompleted ==
                                                              1)
                                                          ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                                          : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.requestEtaAmount}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                ),
                                              ],
                                            )
                                          : MyText(
                                              text:
                                                  '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
