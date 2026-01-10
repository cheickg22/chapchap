import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/bookingpage/presentation/page/booking/widget/custom_timer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_loader.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../application/booking_bloc.dart';

class BiddingWaitingForDriverConfirmation extends StatelessWidget {
  final double maximumTime;
  final bool isOutstationRide;
  const BiddingWaitingForDriverConfirmation(
      {super.key, required this.maximumTime, required this.isOutstationRide});

  bool _isDecreaseDisabled(BuildContext context) {
    final bloc = context.read<BookingBloc>();
    final double baseAmount = double.parse(bloc.requestData != null
        ? bloc.requestData!.requestEtaAmount
        : bloc.isMultiTypeVechiles
            ? bloc.sortedEtaDetailsList[bloc.selectedVehicleIndex].total
                .toString()
            : bloc.etaDetailsList[bloc.selectedVehicleIndex].total.toString());
    final String lowPct = bloc.requestData != null
        ? bloc.requestData!.biddingLowPercentage
        : (bloc.isMultiTypeVechiles
            ? bloc.sortedEtaDetailsList[bloc.selectedVehicleIndex]
                .biddingLowPercentage
            : bloc.etaDetailsList[bloc.selectedVehicleIndex]
                .biddingLowPercentage);
    final double minAllowed = (lowPct == '0')
        ? 0.0
        : baseAmount - ((double.parse(lowPct) / 100) * baseAmount);
    final double currentFare =
        double.tryParse(bloc.farePriceController.text) ?? baseAmount;
    return currentFare <= minAllowed;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final timerDuration = context.read<BookingBloc>().timerDuration;
        return Container(
          width: size.width,
          padding: EdgeInsets.only(
              top: size.width * 0.05,
              right: size.width * 0.05,
              left: size.width * 0.05,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: context.read<BookingBloc>().biddingDriverList.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: size.width * 0.02),
                    Container(
                      height: size.width * 0.02,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.024),
                        color: (timerDuration == 0)
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: size.width * 0.02,
                        width:
                            (size.width * 0.9 * (timerDuration / maximumTime)),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(size.width * 0.024),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          text:
                              '${Duration(seconds: timerDuration).toString().substring(3, 7)} ${AppLocalizations.of(context)!.mins}',
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    SizedBox(height: size.width * 0.05),
                    MyText(
                      text: AppLocalizations.of(context)!.lookingNearbyDrivers,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: size.width * 0.02),
                    MyText(
                      text:
                          '(${AppLocalizations.of(context)!.offeredRideFare.replaceAll('***', ':${context.read<BookingBloc>().userData!.currencySymbol} ${context.read<BookingBloc>().farePriceController.text.isNotEmpty ? context.read<BookingBloc>().farePriceController.text : (context.read<BookingBloc>().requestData != null) ? context.read<BookingBloc>().requestData!.offerredRideFare : ''}')})',
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.5 * 255).toInt())),
                    ),
                    SizedBox(height: size.width * 0.02),
                    MyText(
                      text: AppLocalizations.of(context)!.currentFare,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                    SizedBox(height: size.width * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (!_isDecreaseDisabled(context)) {
                              context.read<BookingBloc>().add(
                                  BiddingIncreaseOrDecreaseEvent(
                                      isIncrease: false,
                                      isOutStation: isOutstationRide));
                            }
                          },
                          child: Container(
                            width: size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: _isDecreaseDisabled(context)
                                    ? Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.2 * 255).toInt())
                                    : Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(size.width * 0.025),
                            child: MyText(
                              text:
                                  '-${double.parse(context.read<BookingBloc>().userData!.biddingAmountIncreaseOrDecrease.toString())}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: _isDecreaseDisabled(context)
                                        ? (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? AppColors.black
                                            : AppColors.white
                                        : AppColors.white,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.3,
                          child: TextField(
                            enabled: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller:
                                context.read<BookingBloc>().farePriceController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                double typedFare =
                                    double.tryParse(value) ?? 0.0;
                                double minFare = double.parse(
                                    context.read<BookingBloc>().requestData !=
                                            null
                                        ? context
                                            .read<BookingBloc>()
                                            .requestData!
                                            .requestEtaAmount
                                        : context
                                                .read<BookingBloc>()
                                                .isMultiTypeVechiles
                                            ? context
                                                .read<BookingBloc>()
                                                .sortedEtaDetailsList[context
                                                    .read<BookingBloc>()
                                                    .selectedVehicleIndex]
                                                .total
                                                .toString()
                                            : context
                                                .read<BookingBloc>()
                                                .etaDetailsList[context
                                                    .read<BookingBloc>()
                                                    .selectedVehicleIndex]
                                                .total
                                                .toString());

                                double maxFare = minFare +
                                    (minFare *
                                        (double.parse(context
                                                        .read<BookingBloc>()
                                                        .requestData !=
                                                    null
                                                ? context
                                                    .read<BookingBloc>()
                                                    .requestData!
                                                    .biddingHighPercentage
                                                : context
                                                        .read<BookingBloc>()
                                                        .isMultiTypeVechiles
                                                    ? context
                                                        .read<BookingBloc>()
                                                        .sortedEtaDetailsList[context
                                                            .read<BookingBloc>()
                                                            .selectedVehicleIndex]
                                                        .biddingHighPercentage
                                                    : context
                                                        .read<BookingBloc>()
                                                        .etaDetailsList[context
                                                            .read<BookingBloc>()
                                                            .selectedVehicleIndex]
                                                        .biddingHighPercentage) /
                                            100));

                                if (typedFare < minFare) {
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingDecreaseLimitReach = true;
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingIncreaseLimitReach = false;
                                } else if (typedFare > maxFare) {
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingIncreaseLimitReach = true;
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingDecreaseLimitReach = false;
                                } else {
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingIncreaseLimitReach = false;
                                  context
                                      .read<BookingBloc>()
                                      .isBiddingDecreaseLimitReach = false;
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  context.read<BookingBloc>().requestData !=
                                          null
                                      ? context
                                          .read<BookingBloc>()
                                          .requestData!
                                          .offerredRideFare
                                      : '',
                              border: const UnderlineInputBorder(),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w600),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (!context
                                .read<BookingBloc>()
                                .isBiddingIncreaseLimitReach) {
                              context.read<BookingBloc>().add(
                                  BiddingIncreaseOrDecreaseEvent(
                                      isIncrease: true,
                                      isOutStation: isOutstationRide));
                            }
                          },
                          child: Container(
                            width: size.width * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: context
                                        .read<BookingBloc>()
                                        .isBiddingIncreaseLimitReach
                                    ? Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.2 * 255).toInt())
                                    : Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(size.width * 0.025),
                            child: MyText(
                              text:
                                  '+${double.parse(context.read<BookingBloc>().userData!.biddingAmountIncreaseOrDecrease.toString())}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: context
                                            .read<BookingBloc>()
                                            .isBiddingIncreaseLimitReach
                                        ? ((Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? AppColors.black
                                            : AppColors.white)
                                        : AppColors.white,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.width * 0.05),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            width: size.width * 0.4,
                            buttonName: AppLocalizations.of(context)!.cancel,
                            isBorder: true,
                            buttonColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            textColor: Theme.of(context).primaryColor,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isDismissible: true,
                                isScrollControlled: true,
                                enableDrag: false,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0),
                                  ),
                                ),
                                builder: (_) {
                                  return BlocProvider.value(
                                      value: context.read<BookingBloc>(),
                                      child: SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // SizedBox(height: size.width * 0.05),
                                              Center(
                                                  child: Image.asset(
                                                      AppImages.cancelGif,
                                                      height:
                                                          size.width * 0.2)),
                                              Center(
                                                child: MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .cancelRide,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.05),
                                              Center(
                                                child: MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .cancelRideText,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.05),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  CustomButton(
                                                    buttonName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .cancelRide,
                                                    borderRadius: 5,
                                                    width: size.width * 0.4,
                                                    height: size.width * 0.1,
                                                    isBorder: true,
                                                    buttonColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    textSize: context
                                                                .read<
                                                                    BookingBloc>()
                                                                .languageCode ==
                                                            'fr'
                                                        ? 14
                                                        : null,
                                                    textColor: Theme.of(context)
                                                        .primaryColor,
                                                    onTap: () {
                                                      context
                                                          .read<BookingBloc>()
                                                          .timerCount(context,
                                                              isNormalRide:
                                                                  false,
                                                              isCloseTimer:
                                                                  true,
                                                              duration: 0);
                                                      context
                                                          .read<BookingBloc>()
                                                          .add(
                                                            BookingCancelRequestEvent(
                                                                requestId: context
                                                                    .read<
                                                                        BookingBloc>()
                                                                    .requestData!
                                                                    .id),
                                                          );
                                                    },
                                                  ),
                                                  CustomButton(
                                                    buttonName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .back,
                                                    borderRadius: 5,
                                                    width: size.width * 0.4,
                                                    height: size.width * 0.1,
                                                    buttonColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    textColor: AppColors.white,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.1),
                                            ],
                                          ),
                                        ),
                                      ));
                                },
                              );
                            },
                          ),
                          CustomButton(
                            width: size.width * 0.4,
                            buttonColor: Theme.of(context).primaryColor,
                            isLoader: context.read<BookingBloc>().isLoading,
                            buttonName: AppLocalizations.of(context)!.update,
                            onTap: () {
                              final currencySymbol = context
                                      .read<BookingBloc>()
                                      .isMultiTypeVechiles
                                  ? context
                                      .read<BookingBloc>()
                                      .sortedEtaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .currency
                                  : context
                                      .read<BookingBloc>()
                                      .etaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .currency;
                              final total = double.parse(context
                                      .read<BookingBloc>()
                                      .isMultiTypeVechiles
                                  ? context
                                      .read<BookingBloc>()
                                      .sortedEtaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .total
                                      .toString()
                                  : context
                                      .read<BookingBloc>()
                                      .etaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .total
                                      .toString());

                              final lowPercentage = double.parse(context
                                      .read<BookingBloc>()
                                      .isMultiTypeVechiles
                                  ? context
                                      .read<BookingBloc>()
                                      .sortedEtaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .biddingLowPercentage
                                  : context
                                      .read<BookingBloc>()
                                      .etaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .biddingLowPercentage);
                              final highPercentage = double.parse(context
                                      .read<BookingBloc>()
                                      .isMultiTypeVechiles
                                  ? context
                                      .read<BookingBloc>()
                                      .sortedEtaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .biddingHighPercentage
                                  : context
                                      .read<BookingBloc>()
                                      .etaDetailsList[context
                                          .read<BookingBloc>()
                                          .selectedVehicleIndex]
                                      .biddingHighPercentage);

                              double roundToTwoDecimals(double number) {
                                return double.parse(number.toStringAsFixed(2));
                              }

                              final value = roundToTwoDecimals(
                                  total - ((lowPercentage / 100) * total));

                              final highValue = roundToTwoDecimals(
                                  total + ((highPercentage / 100) * total));

                              final fare = roundToTwoDecimals(double.tryParse(
                                      context
                                          .read<BookingBloc>()
                                          .farePriceController
                                          .text
                                          .trim()) ??
                                  0.0);
                              if (fare >= value) {
                                if ((!context
                                        .read<BookingBloc>()
                                        .isBiddingIncreaseLimitReach) ||
                                    (context
                                            .read<BookingBloc>()
                                            .isBiddingIncreaseLimitReach &&
                                        fare >= value &&
                                        fare <= highValue)) {
                                  context
                                      .read<BookingBloc>()
                                      .add(BiddingFareUpdateEvent());
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    isScrollControlled: true,
                                    enableDrag: false,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.0),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    builder: (_) {
                                      return BlocProvider.value(
                                        value: context.read<BookingBloc>(),
                                        child: SafeArea(
                                          child: Container(
                                            width: size.width,
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            )),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                      height: size.width * 0.1),
                                                  MyText(
                                                    text:
                                                        '${AppLocalizations.of(context)!.maximumRideFareError} ($currencySymbol ${highValue.toStringAsFixed(2)})',
                                                    maxLines: 3,
                                                    textAlign: TextAlign.center,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .error),
                                                  ),
                                                  SizedBox(
                                                      height: size.width * 0.1),
                                                  CustomButton(
                                                    width: size.width,
                                                    buttonName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .okText,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              } else {
                                showModalBottomSheet(
                                  context: context,
                                  isDismissible: true,
                                  isScrollControlled: true,
                                  enableDrag: false,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20.0),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  builder: (_) {
                                    return BlocProvider.value(
                                      value: context.read<BookingBloc>(),
                                      child: SafeArea(
                                        child: Container(
                                          width: size.width,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          )),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                    height: size.width * 0.1),
                                                MyText(
                                                  text:
                                                      '${AppLocalizations.of(context)!.minimumRideFareError} ($currencySymbol ${value.toStringAsFixed(2)})',
                                                  maxLines: 3,
                                                  textAlign: TextAlign.center,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error),
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.1),
                                                CustomButton(
                                                  width: size.width,
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .okText,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                  ],
                )
              : SizedBox(
                  height: size.height * 0.6,
                  child: Column(
                    children: [
                      SizedBox(height: size.width * 0.01),
                      MyText(
                        text: AppLocalizations.of(context)!.availableDrivers,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: size.width * 0.01),
                      SizedBox(
                        height: size.height * 0.5,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: context
                              .read<BookingBloc>()
                              .biddingDriverList
                              .length,
                          itemBuilder: (context, index) {
                            final driver = context
                                .read<BookingBloc>()
                                .biddingDriverList
                                .elementAt(index);
                            int val = DateTime.now()
                                .difference(DateTime.fromMillisecondsSinceEpoch(
                                    driver['bid_time']))
                                .inSeconds;
                            if (int.parse(val.toString()) >=
                                int.parse(context
                                        .read<BookingBloc>()
                                        .userData!
                                        .maximumTimeForFindDriversForBittingRide) +
                                    1) {
                              FirebaseDatabase.instance
                                  .ref()
                                  .child(
                                      'bid-meta/${context.read<BookingBloc>().requestData!.id}/drivers/driver_${driver["driver_id"]}')
                                  .update({"is_rejected": 'by_user'});
                              context.read<BookingBloc>().add(UpdateEvent());
                            }
                            return Container(
                              width: size.width,
                              decoration: BoxDecoration(
                                color: AppColors.darkGrey
                                    .withAlpha((0.5 * 255).toInt()),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: size.width * 0.1,
                                              height: size.width * 0.1,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: driver['driver_img'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child: Loader(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Center(
                                                  child: Text(""),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.05),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          MyText(
                                                            text: driver[
                                                                'driver_name'],
                                                            maxLines: 1,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          const Icon(
                                                              Icons
                                                                  .star_border_purple500_rounded,
                                                              color: AppColors
                                                                  .goldenColor),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.01),
                                                          MyText(
                                                            text: driver[
                                                                'rating'],
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      MyText(
                                                        text:
                                                            '${driver['vehicle_make']} | ${driver['vehicle_model']}',
                                                        maxLines: 1,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      MyText(
                                                        text:
                                                            '${driver['vehicle_number']}',
                                                        maxLines: 1,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      MyText(
                                                        text: context
                                                                .read<
                                                                    BookingBloc>()
                                                                .userData!
                                                                .currencySymbol +
                                                            driver['price'],
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      CustomPaint(
                                                        painter: CustomTimer(
                                                          width:
                                                              size.width * 0.01,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .disabledColor,
                                                          values: (DateTime
                                                                          .now()
                                                                      .difference(DateTime.fromMillisecondsSinceEpoch(
                                                                          driver[
                                                                              'bid_time']))
                                                                      .inSeconds <
                                                                  int.parse(context
                                                                      .read<
                                                                          BookingBloc>()
                                                                      .userData!
                                                                      .maximumTimeForFindDriversForBittingRide))
                                                              ? 1 -
                                                                  (((int.parse(context.read<BookingBloc>().userData!.maximumTimeForFindDriversForBittingRide) + 2) - DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(driver['bid_time'])).inSeconds) /
                                                                      int.parse(context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .userData!
                                                                          .maximumTimeForFindDriversForBittingRide))
                                                              : 1,
                                                        ),
                                                        child: Container(
                                                          height:
                                                              size.width * 0.1,
                                                          width:
                                                              size.width * 0.1,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: MyText(
                                                          text:
                                                              '${(int.parse(context.read<BookingBloc>().userData!.maximumTimeForFindDriversForBittingRide) - int.parse(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(driver['bid_time'])).inSeconds.toString()))} s',
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                  color: (Theme.of(context)
                                                                              .brightness ==
                                                                          Brightness
                                                                              .light)
                                                                      ? AppColors
                                                                          .black
                                                                      : AppColors
                                                                          .white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size.width * 0.02),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomButton(
                                              onTap: () {
                                                context.read<BookingBloc>().add(
                                                    BiddingAcceptOrDeclineEvent(
                                                        isAccept: false,
                                                        driver: driver));
                                              },
                                              isBorder: true,
                                              buttonName:
                                                  AppLocalizations.of(context)!
                                                      .reject,
                                              width: size.width * 0.4,
                                              buttonColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              textColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            CustomButton(
                                              onTap: () {
                                                context.read<BookingBloc>().add(
                                                    BiddingAcceptOrDeclineEvent(
                                                        isAccept: true,
                                                        driver: driver));
                                              },
                                              buttonName:
                                                  AppLocalizations.of(context)!
                                                      .accept,
                                              width: size.width * 0.4,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: size.width * 0.02);
                          },
                        ),
                      ),
                      SizedBox(height: size.width * 0.1),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
