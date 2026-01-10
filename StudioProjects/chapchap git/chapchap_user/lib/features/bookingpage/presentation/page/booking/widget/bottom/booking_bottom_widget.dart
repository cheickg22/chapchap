import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';
import 'add_instruction_widget.dart';
import 'apply_coupons_widget.dart';
import 'select_payment_widget.dart';
import 'select_preference_widget.dart';

class BookingBottomWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;
  const BookingBottomWidget({super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bookingBloc = context.read<BookingBloc>();
    final isTaxi = bookingBloc.transportType == 'taxi';
    final isRental = bookingBloc.isRentalRide;
    final walletBalance = bookingBloc.userData?.wallet.data.amountBalance ?? 0;
    final selectedEtaAmount = bookingBloc.selectedEtaAmount;
    final hasLowWalletBalance = bookingBloc.selectedPaymentType == 'wallet' &&
        walletBalance < selectedEtaAmount;

    final bool hasNonRentalPreferences =
        (bookingBloc.preferenceDetailsList?.isNotEmpty ?? false) && !isRental;

    final bool hasRentalPreferences =
        (bookingBloc.rentalPreferenceDetailsList?.isNotEmpty ?? false) &&
            isRental;

    bool shouldHideAddInstruction() {
      final shouldToggleByType = bookingBloc.transportType == 'taxi' ||
          bookingBloc.isOutstationRide ||
          bookingBloc.isRentalRide;
      if (!shouldToggleByType) return false;
      if (!bookingBloc.draggableController.isAttached) {
        return false;
      }

      final controllerSize = bookingBloc.draggableController.size;
      return controllerSize >= bookingBloc.maxChildSize;
    }

    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return SafeArea(
            child: Container(
              width: size.width,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: size.width * 0.03),
                      BlocBuilder<BookingBloc, BookingState>(
                          builder: (context, state) {
                        return AnimatedBuilder(
                          animation: bookingBloc.draggableController,
                          builder: (context, _) {
                            if (shouldHideAddInstruction()) {
                              return const SizedBox.shrink();
                            }

                            return Row(
                              mainAxisAlignment: isTaxi
                                  // ? MainAxisAlignment.spaceAround
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.start,
                              children: [
                                // PAYMENT
                                if (isTaxi)
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          context: context,
                                          barrierColor:
                                              Theme.of(context).shadowColor,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20.0),
                                            ),
                                          ),
                                          builder: (_) {
                                            return SelectPaymentMethodWidget(
                                                cont: context);
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                            bookingBloc.isSavedCardChoose
                                                ? Icons.credit_card_rounded
                                                : bookingBloc
                                                            .selectedPaymentType ==
                                                        'cash'
                                                    ? Icons.payments_outlined
                                                    : bookingBloc
                                                                .selectedPaymentType ==
                                                            'card'
                                                        ? Icons
                                                            .credit_card_rounded
                                                        : Icons
                                                            .account_balance_wallet_outlined,
                                            size: size.width * 0.05,
                                            color: hasLowWalletBalance
                                                ? AppColors.red
                                                : Theme.of(context)
                                                    .primaryColorDark),
                                        SizedBox(width: size.width * 0.025),
                                        MyText(
                                            text: bookingBloc.isSavedCardChoose
                                                ? 'Card'
                                                : (bookingBloc
                                                            .selectedPaymentType ==
                                                        'cash')
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .cash
                                                    : (context
                                                                .read<
                                                                    BookingBloc>()
                                                                .selectedPaymentType ==
                                                            'wallet')
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .wallet
                                                        : bookingBloc
                                                            .selectedPaymentType,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    // fontWeight: FontWeight.bold,
                                                    color: hasLowWalletBalance
                                                        ? AppColors.red
                                                        : null))
                                      ],
                                    ),
                                  ),
                                if (isTaxi && !isRental) ...[
                                  if (hasNonRentalPreferences) ...[
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: false,
                                            enableDrag: false,
                                            isDismissible: false,
                                            barrierColor:
                                                Theme.of(context).shadowColor,
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(
                                                    20.0), // Adjust the radius to your liking
                                              ),
                                            ),
                                            builder: (_) {
                                              return SelectPreferenceWidget(
                                                cont: context,
                                                arg: arg,
                                              );
                                            });
                                        // } else {
                                        //   showToast(message: "Unavailable");
                                        // }
                                      },
                                      child: Row(children: [
                                        Icon(Icons.tune,
                                            size: 20,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                        SizedBox(width: size.width * 0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .preferences,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith()),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: List.generate(
                                                  bookingBloc
                                                      .selectedPreferenceDetailsList
                                                      .length, (index) {
                                                try {
                                                  final prefId = bookingBloc
                                                          .selectedPreferenceDetailsList[
                                                      index];
                                                  final prefList = bookingBloc
                                                          .preferenceDetailsList ??
                                                      [];
                                                  final pref =
                                                      prefList.firstWhere(
                                                    (e) =>
                                                        e.preferenceId ==
                                                        prefId,
                                                  );
                                                  return Container(
                                                    padding: EdgeInsets.all(
                                                        size.width * 0.005),
                                                    width: 14,
                                                    height: 14,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppColors.white,
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: pref.icon,
                                                      fit: BoxFit.cover,
                                                      width: 12,
                                                      height: 12,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const SizedBox
                                                              .shrink(),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                              }),
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                  ] else ...[
                                    MyText(
                                        text: AppLocalizations.of(context)!
                                            .preferences,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.hintColor)),
                                  ]
                                ],

                                if (isTaxi && isRental) ...[
                                  if (hasRentalPreferences) ...[
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: false,
                                            enableDrag: false,
                                            isDismissible: false,
                                            barrierColor:
                                                Theme.of(context).shadowColor,
                                            backgroundColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(
                                                    20.0), // Adjust the radius to your liking
                                              ),
                                            ),
                                            builder: (_) {
                                              return SelectPreferenceWidget(
                                                cont: context,
                                                arg: arg,
                                              );
                                            });
                                        // } else {
                                        //   showToast(message: "Unavailable");
                                        // }
                                      },
                                      child: Row(children: [
                                        Icon(Icons.tune,
                                            size: 20,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                        SizedBox(width: size.width * 0.03),
                                        Column(
                                          children: [
                                            MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .preferences,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith()),
                                            (context
                                                        .read<BookingBloc>()
                                                        .isRentalRide ==
                                                    false)
                                                ? Row(
                                                    children: List.generate(
                                                        context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList
                                                            .length, (index) {
                                                      try {
                                                        final prefId = context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList[index];
                                                        final prefList = context
                                                                .read<
                                                                    BookingBloc>()
                                                                .preferenceDetailsList ??
                                                            [];
                                                        final pref =
                                                            prefList.firstWhere(
                                                          (e) =>
                                                              e.preferenceId ==
                                                              prefId,
                                                        );
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size.width *
                                                                      0.005),
                                                          width: 14,
                                                          height: 14,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: pref.icon,
                                                            fit: BoxFit.cover,
                                                            width: 12,
                                                            height: 12,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const SizedBox
                                                                    .shrink(),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    }),
                                                  )
                                                : Row(
                                                    children: List.generate(
                                                        context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList
                                                            .length, (index) {
                                                      try {
                                                        final prefId = context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList[index];
                                                        final prefList = context
                                                                .read<
                                                                    BookingBloc>()
                                                                .rentalPreferenceDetailsList ??
                                                            [];
                                                        final pref =
                                                            prefList.firstWhere(
                                                          (e) =>
                                                              e.preferenceId ==
                                                              prefId,
                                                        );
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size.width *
                                                                      0.005),
                                                          width: 14,
                                                          height: 14,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: pref.icon,
                                                            fit: BoxFit.cover,
                                                            width: 12,
                                                            height: 12,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const SizedBox
                                                                    .shrink(),
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                    }),
                                                  )
                                          ],
                                        )
                                      ]),
                                    ),
                                  ] else ...[
                                    MyText(
                                        text: AppLocalizations.of(context)!
                                            .preferences,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.hintColor)),
                                  ]
                                ],

                                if (isTaxi) ...[
                                  Builder(builder: (context) {
                                    final disableCoupons =
                                        bookingBloc.showBiddingVehicles;
                                    return InkWell(
                                      onTap: disableCoupons
                                          ? null
                                          : () {
                                              context
                                                  .read<BookingBloc>()
                                                  .promoErrorText = '';
                                              context
                                                  .read<BookingBloc>()
                                                  .add(UpdateEvent());
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                barrierColor: Theme.of(context)
                                                    .shadowColor,
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .scaffoldBackgroundColor,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20.0),
                                                  ),
                                                ),
                                                builder: (_) {
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<BookingBloc>(),
                                                    child: ApplyCouponWidget(
                                                      arg: arg,
                                                      cont: context,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                      child: Opacity(
                                        opacity: disableCoupons ? 0.4 : 1,
                                        child: Row(children: [
                                          Image.asset(
                                            AppImages.ticketImage,
                                            width: size.width * 0.05,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          SizedBox(width: size.width * 0.025),
                                          MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .coupon,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith())
                                        ]),
                                      ),
                                    );
                                  })
                                ]
                              ],
                            );
                          },
                        );
                      }),
                      SizedBox(height: size.width * 0.03),
                      if (isTaxi ||
                          bookingBloc.isOutstationRide ||
                          isRental) ...[
                        BlocBuilder<BookingBloc, BookingState>(
                            builder: (context, state) {
                          return AnimatedBuilder(
                            animation: bookingBloc.draggableController,
                            builder: (context, _) {
                              if (shouldHideAddInstruction()) {
                                return const SizedBox.shrink();
                              }

                              return InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isDismissible: true,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    barrierColor: Theme.of(context).shadowColor,
                                    builder: (_) {
                                      return BlocProvider.value(
                                        value: cont.read<BookingBloc>(),
                                        child: const AddInstructionWidget(),
                                      );
                                    },
                                  );
                                },
                                child: Center(
                                  child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .addInstructions,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 14,
                                          )),
                                ),
                              );
                            },
                          );
                        }),
                        SizedBox(height: size.width * 0.05),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (bookingBloc.detailView)
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(width: size.width * 0.1))),
                          Center(
                            child: CustomButton(
                              width: (bookingBloc.detailView)
                                  ? size.width * 0.6
                                  : size.width * 0.9,
                              buttonColor: hasLowWalletBalance
                                  ? Theme.of(context).dividerColor
                                  : Theme.of(context).primaryColor,
                              buttonName: (bookingBloc.transportType ==
                                          'delivery' &&
                                      !bookingBloc.detailView)
                                  ? AppLocalizations.of(context)!.continueN
                                  : (bookingBloc.scheduleDateTime.isEmpty)
                                      ? AppLocalizations.of(context)!.rideNow
                                      : AppLocalizations.of(context)!
                                          .scheduleRide,
                              isLoader: bookingBloc.isLoading,
                              onTap: () {
                                if (bookingBloc.selectedVehicleIndex != 999) {
                                  if (bookingBloc.transportType == 'delivery' &&
                                      !bookingBloc.detailView) {
                                    // Update detail view state using DetailViewUpdateEvent
                                    context
                                        .read<BookingBloc>()
                                        .add(DetailViewUpdateEvent(true));
                                    Future.delayed(
                                        const Duration(milliseconds: 301), () {
                                      if (!context.mounted) return;
                                      context.read<BookingBloc>().detailView =
                                          true;
                                      context
                                          .read<BookingBloc>()
                                          .add(UpdateEvent());
                                    });
                                  } else {
                                    if ((bookingBloc.isOutstationRide &&
                                            context
                                                .read<BookingBloc>()
                                                .isRoundTrip &&
                                            context
                                                .read<BookingBloc>()
                                                .scheduleDateTimeForReturn
                                                .isNotEmpty) ||
                                        ((bookingBloc.isOutstationRide &&
                                                !context
                                                    .read<BookingBloc>()
                                                    .isRoundTrip) ||
                                            (!bookingBloc.isOutstationRide))) {
                                      if (bookingBloc.transportType == 'taxi' ||
                                          (context
                                                      .read<BookingBloc>()
                                                      .transportType ==
                                                  'delivery' &&
                                              context
                                                      .read<BookingBloc>()
                                                      .selectedGoodsTypeId !=
                                                  0)) {
                                        if (!hasLowWalletBalance) {
                                          bookingBloc.detailView = false;
                                          bool showBid = context
                                              .read<BookingBloc>()
                                              .showBiddingVehicles;
                                          bool multiVehicle = context
                                              .read<BookingBloc>()
                                              .isMultiTypeVechiles;
                                          bool biddingDispatch = !context
                                                  .read<BookingBloc>()
                                                  .isRentalRide
                                              ? context
                                                      .read<BookingBloc>()
                                                      .isMultiTypeVechiles
                                                  ? context
                                                          .read<BookingBloc>()
                                                          .sortedEtaDetailsList[context
                                                              .read<
                                                                  BookingBloc>()
                                                              .selectedVehicleIndex]
                                                          .dispatchType !=
                                                      'normal'
                                                  : context
                                                          .read<BookingBloc>()
                                                          .etaDetailsList[context
                                                              .read<
                                                                  BookingBloc>()
                                                              .selectedVehicleIndex]
                                                          .dispatchType !=
                                                      'normal'
                                              : false;
                                          if (((!multiVehicle &&
                                                      biddingDispatch) ||
                                                  (multiVehicle &&
                                                      showBid &&
                                                      biddingDispatch)) &&
                                              context
                                                      .read<BookingBloc>()
                                                      .showSharedRide ==
                                                  false) {
                                            context
                                                .read<BookingBloc>()
                                                .add(EnableBiddingEvent());
                                          } else {
                                            if (context
                                                    .read<BookingBloc>()
                                                    .showSharedRide ==
                                                false) {
                                              context.read<BookingBloc>().add(
                                                      BookingCreateRequestEvent(
                                                    userData: context
                                                        .read<BookingBloc>()
                                                        .userData!,
                                                    vehicleData: !context
                                                            .read<BookingBloc>()
                                                            .isRentalRide
                                                        ? context
                                                                .read<
                                                                    BookingBloc>()
                                                                .isMultiTypeVechiles
                                                            ? context
                                                                    .read<
                                                                        BookingBloc>()
                                                                    .sortedEtaDetailsList[
                                                                context
                                                                    .read<
                                                                        BookingBloc>()
                                                                    .selectedVehicleIndex]
                                                            : context
                                                                    .read<
                                                                        BookingBloc>()
                                                                    .etaDetailsList[
                                                                context
                                                                    .read<
                                                                        BookingBloc>()
                                                                    .selectedVehicleIndex]
                                                        : context
                                                                .read<BookingBloc>()
                                                                .rentalEtaDetailsList[
                                                            context
                                                                .read<
                                                                    BookingBloc>()
                                                                .selectedVehicleIndex],
                                                    pickupAddressList:
                                                        arg.pickupAddressList,
                                                    dropAddressList:
                                                        arg.stopAddressList,
                                                    selectedTransportType:
                                                        context
                                                            .read<BookingBloc>()
                                                            .transportType,
                                                    paidAt: context
                                                            .read<BookingBloc>()
                                                            .payAtDrop
                                                        ? 'Receiver'
                                                        : 'Sender',
                                                    selectedPaymentType: context
                                                        .read<BookingBloc>()
                                                        .selectedPaymentType,
                                                    scheduleDateTime: context
                                                        .read<BookingBloc>()
                                                        .scheduleDateTime,
                                                    goodsTypeId: context
                                                        .read<BookingBloc>()
                                                        .selectedGoodsTypeId
                                                        .toString(),
                                                    goodsQuantity: context
                                                        .read<BookingBloc>()
                                                        .goodsQtyController
                                                        .text,
                                                    polyLine: context
                                                        .read<BookingBloc>()
                                                        .polyLine,
                                                    isRentalRide: context
                                                        .read<BookingBloc>()
                                                        .isRentalRide,
                                                    cardToken: context
                                                        .read<BookingBloc>()
                                                        .selectedCardToken,
                                                    parcelType: arg.title,
                                                    preferences: context
                                                            .read<BookingBloc>()
                                                            .selectPreference
                                                            .isNotEmpty
                                                        ? context
                                                            .read<BookingBloc>()
                                                            .selectPreference
                                                        : context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList,
                                                    sharedRide: context
                                                            .read<BookingBloc>()
                                                            .showSharedRide
                                                        ? 1
                                                        : null,
                                                    seatsTaken: context
                                                            .read<BookingBloc>()
                                                            .showSharedRide
                                                        ? context
                                                            .read<BookingBloc>()
                                                            .selectedSharedSeats
                                                        : null,
                                                  ));
                                            } else {
                                              context.read<BookingBloc>().add(
                                                      BookingCreateRequestEvent(
                                                    userData: context
                                                        .read<BookingBloc>()
                                                        .userData!,
                                                    vehicleData: !context
                                                            .read<BookingBloc>()
                                                            .isRentalRide
                                                        ? context
                                                                .read<BookingBloc>()
                                                                .etaDetailsList[
                                                            context
                                                                .read<
                                                                    BookingBloc>()
                                                                .selectedVehicleIndex]
                                                        : context
                                                                .read<BookingBloc>()
                                                                .rentalEtaDetailsList[
                                                            context
                                                                .read<
                                                                    BookingBloc>()
                                                                .selectedVehicleIndex],
                                                    pickupAddressList:
                                                        arg.pickupAddressList,
                                                    dropAddressList:
                                                        arg.stopAddressList,
                                                    selectedTransportType:
                                                        context
                                                            .read<BookingBloc>()
                                                            .transportType,
                                                    paidAt: context
                                                            .read<BookingBloc>()
                                                            .payAtDrop
                                                        ? 'Receiver'
                                                        : 'Sender',
                                                    selectedPaymentType: context
                                                        .read<BookingBloc>()
                                                        .selectedPaymentType,
                                                    scheduleDateTime: context
                                                        .read<BookingBloc>()
                                                        .scheduleDateTime,
                                                    goodsTypeId: context
                                                        .read<BookingBloc>()
                                                        .selectedGoodsTypeId
                                                        .toString(),
                                                    goodsQuantity: context
                                                        .read<BookingBloc>()
                                                        .goodsQtyController
                                                        .text,
                                                    polyLine: context
                                                        .read<BookingBloc>()
                                                        .polyLine,
                                                    isRentalRide: context
                                                        .read<BookingBloc>()
                                                        .isRentalRide,
                                                    cardToken: context
                                                        .read<BookingBloc>()
                                                        .selectedCardToken,
                                                    parcelType: arg.title,
                                                    preferences: context
                                                            .read<BookingBloc>()
                                                            .selectPreference
                                                            .isNotEmpty
                                                        ? context
                                                            .read<BookingBloc>()
                                                            .selectPreference
                                                        : context
                                                            .read<BookingBloc>()
                                                            .selectedPreferenceDetailsList,
                                                    sharedRide: context
                                                            .read<BookingBloc>()
                                                            .showSharedRide
                                                        ? 1
                                                        : null,
                                                    seatsTaken: context
                                                            .read<BookingBloc>()
                                                            .showSharedRide
                                                        ? context
                                                            .read<BookingBloc>()
                                                            .selectedSharedSeats
                                                        : null,
                                                  ));
                                            }
                                          }
                                        } else {
                                          showToast(
                                              message:
                                                  AppLocalizations.of(context)!
                                                      .lowWalletBalance);
                                        }
                                      } else {
                                        showToast(
                                            message:
                                                AppLocalizations.of(context)!
                                                    .pleaseSelectGoodsType);
                                      }
                                    } else {
                                      showToast(
                                          message: AppLocalizations.of(context)!
                                              .pleaseSelectReturnDate);
                                    }
                                  }
                                } else {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .pleaseSelectVehicle);
                                }
                              },
                            ),
                          ),
                          if (bookingBloc.detailView)
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () {
                                    context.read<BookingBloc>().add(
                                          DetailViewUpdateEvent(context
                                                  .read<BookingBloc>()
                                                  .detailView
                                              ? false
                                              : true),
                                        );
                                  },
                                  child: Icon(
                                    bookingBloc.detailView
                                        ? Icons.keyboard_arrow_down_rounded
                                        : Icons.tune,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: size.width * 0.05)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
