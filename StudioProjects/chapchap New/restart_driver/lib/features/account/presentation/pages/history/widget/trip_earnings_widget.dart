import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history/widget/fare_breakup.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class TripEarningsWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripEarningsWidget({super.key, required this.cont, required this.arg});

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
              // color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(width: 1, color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(children: [
              Row(
                children: [
                  MyText(
                    text: AppLocalizations.of(context)!.earnings,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.totalFare,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColorDark),
                        )
                      ],
                    )),
                    CustomPaint(
                      painter: DashedLinePainter(),
                      child: Container(
                        height: 2,
                      ),
                    ),
                    if (arg.historyData.requestBill != null)
                      MyText(
                        text: (arg.historyData.isBidRide == 1)
                            ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.acceptedRideFare}'
                            : (arg.historyData.isCompleted == 1)
                                ? '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.totalAmount}'
                                : '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.requestEtaAmount}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 16,
                                color: Theme.of(context).primaryColorDark),
                      ),
                  ],
                ),
              ),
              // CustomPaint(
              //   painter: DashedLinePainter(),
              //   child: Container(
              //     height: 2,
              //   ),
              // ),
              if (arg.historyData.requestBill.data.driverTips != "0")
                FareBreakup(
                  showBorder: false,
                  text: AppLocalizations.of(context)!.tips,
                  price:
                      '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.driverTips}',
                  textcolor: Theme.of(context).primaryColorDark,
                  pricecolor: Theme.of(context).primaryColorDark,
                ),
              CustomPaint(
                painter: DashedLinePainter(),
                child: Container(
                  height: 2,
                ),
              ),
              if (arg.historyData.requestBill != null)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: size.width * 0.025,
                    top: size.width * 0.025,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!
                                .customerConvenienceFee,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          )
                        ],
                      )),
                      CustomPaint(
                        painter: DashedLinePainter(),
                        child: Container(
                          height: 2,
                        ),
                      ),
                      MyText(
                        text:
                            '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommision}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.red, fontSize: 16),
                      )
                    ],
                  ),
                ),
              CustomPaint(
                painter: DashedLinePainter(),
                child: Container(
                  height: 2,
                ),
              ),
              if (arg.historyData.requestBill != null)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: size.width * 0.025,
                    top: size.width * 0.025,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.commission,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          )
                        ],
                      )),
                      CustomPaint(
                        painter: DashedLinePainter(),
                        child: Container(
                          height: 2,
                        ),
                      ),
                      MyText(
                        text:
                            '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.adminCommisionFromDriver}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.red, fontSize: 16),
                      )
                    ],
                  ),
                ),
              CustomPaint(
                painter: DashedLinePainter(),
                child: Container(
                  height: 2,
                ),
              ),
              if (arg.historyData.requestBill != null)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: size.width * 0.025,
                    top: size.width * 0.025,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.taxText,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          )
                        ],
                      )),
                      MyText(
                        text:
                            '-${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.serviceTax}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.red, fontSize: 16),
                      )
                    ],
                  ),
                ),
              // CustomPaint(
              //   painter: DashedLinePainter(),
              //   child: Container(
              //     height: 2,
              //   ),
              // ),
              if (arg.historyData.requestBill.data.promoDiscount != 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .discountFromWallet,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).primaryColorDark),
                            )
                          ],
                        ),
                      ),
                      CustomPaint(
                        painter: DashedLinePainter(),
                        child: Container(
                          height: 2,
                        ),
                      ),
                      MyText(
                        text:
                            '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.promoDiscount}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: AppColors.green, fontSize: 16),
                      )
                    ],
                  ),
                ),
              // CustomPaint(
              //   painter: DashedLinePainter(),
              //   child: Container(
              //     height: 2,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Row(
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.tripEarnings,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(width: size.width * 0.08),
                        MyText(
                          text:
                              '${arg.historyData.requestBill.data.requestedCurrencySymbol} ${arg.historyData.requestBill.data.driverCommision}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ..color = AppColors.textSelectionColor.withAlpha((0.5 * 255).toInt())
      ..color = AppColors.borderColors
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Or use this simpler alternative with a Container:
