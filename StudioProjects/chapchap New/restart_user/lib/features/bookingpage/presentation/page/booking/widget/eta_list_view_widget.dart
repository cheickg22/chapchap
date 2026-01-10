import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/booking_bloc.dart';
import 'bottom/apply_coupons_widget.dart';
import 'bottom/select_payment_widget.dart';
import 'bottom/select_preference_widget.dart';
import 'schedule_ride.dart';

class EtaListViewWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;
  final dynamic thisValue;

  const EtaListViewWidget(
      {super.key, required this.cont, required this.arg, this.thisValue});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final bookingBloc = context.read<BookingBloc>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingBloc.isMultiTypeVechiles &&
                  // !arg.isOutstationRide &&
                  !bookingBloc.isOutstationRide &&
                  (arg.isWithoutDestinationRide == null ||
                      (arg.isWithoutDestinationRide != null &&
                          !arg.isWithoutDestinationRide!))) ...[
                SizedBox(height: size.width * 0.04),
                if ((context.read<BookingBloc>().enableOndemandRides &&
                        context.read<BookingBloc>().enableBiddingRides) ||
                    (context.read<BookingBloc>().enableOndemandRides &&
                        context.read<BookingBloc>().enableShareRides) ||
                    (context.read<BookingBloc>().enableBiddingRides &&
                        context.read<BookingBloc>().enableShareRides))
                  Padding(
                    padding:
                        (context.read<BookingBloc>().textDirection == 'ltr')
                            ? EdgeInsetsGeometry.only(
                                left: size.width * 0.035,
                                right: size.width * 0.04)
                            : EdgeInsetsGeometry.only(
                                left: size.width * 0.04,
                                right: size.width * 0.035),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.all(size.width * 0.0125),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!bookingBloc.isOutstationRide &&
                              (arg.isWithoutDestinationRide == null ||
                                  (arg.isWithoutDestinationRide != null &&
                                      !arg.isWithoutDestinationRide!))) ...[
                            if (context.read<BookingBloc>().enableOndemandRides)
                              InkWell(
                                onTap: () {
                                  // Switch to On Demand if currently in Bidding or Shared
                                  if (bookingBloc.showBiddingVehicles ||
                                      bookingBloc.showSharedRide) {
                                    bookingBloc.add(SelectBiddingOrDemandEvent(
                                        selectedTypeEta: 'On Demand',
                                        isBidding: false,
                                        shareRide: false));
                                    // For Check near ETA
                                    bookingBloc.checkNearByEta(
                                        bookingBloc.nearByDriversData,
                                        thisValue);
                                    // Refresh ETA for On Demand (no shared parameters)
                                    final baseBloc =
                                        context.read<BookingBloc>();
                                    baseBloc.add(BookingEtaRequestEvent(
                                      picklat: arg.picklat,
                                      picklng: arg.picklng,
                                      droplat: arg.droplat,
                                      droplng: arg.droplng,
                                      ridetype: 1,
                                      transporttype: arg.transportType,
                                      distance: baseBloc.distance,
                                      duration: baseBloc.duration,
                                      polyLine: baseBloc.polyLine,
                                      pickupAddressList: arg.pickupAddressList,
                                      dropAddressList: arg.stopAddressList,
                                      isOutstationRide: arg.isOutstationRide,
                                      isWithoutDestinationRide:
                                          arg.isWithoutDestinationRide ?? false,
                                      preferenceId: baseBloc
                                              .selectedPreferenceDetailsList
                                              .isNotEmpty
                                          ? baseBloc
                                              .selectedPreferenceDetailsList
                                          : null,
                                    ));
                                  }
                                },
                                child: Container(
                                  width: (arg.transportType == 'taxi' &&
                                          context
                                              .read<BookingBloc>()
                                              .enableBiddingRides &&
                                          context
                                              .read<BookingBloc>()
                                              .enableShareRides)
                                      ? size.width * 0.3
                                      : size.width * 0.4,
                                  padding: EdgeInsets.fromLTRB(
                                      size.width * 0.025,
                                      size.width * 0.015,
                                      size.width * 0.025,
                                      size.width * 0.015),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: (!bookingBloc.showBiddingVehicles &&
                                            !bookingBloc.showSharedRide)
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .onDemand,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: (!bookingBloc
                                                          .showBiddingVehicles &&
                                                      !bookingBloc
                                                          .showSharedRide)
                                                  ? AppColors.white
                                                  : AppColors.hintColor),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (arg.isWithoutDestinationRide == null ||
                              !arg.isWithoutDestinationRide!) ...[
                            if (context.read<BookingBloc>().enableBiddingRides)
                              InkWell(
                                onTap: () {
                                  if ((bookingBloc.showBiddingVehicles ||
                                          bookingBloc.showSharedRide) ||
                                      bookingBloc.showBiddingVehicles ==
                                              false &&
                                          bookingBloc.showSharedRide == false) {
                                    bookingBloc.add(SelectBiddingOrDemandEvent(
                                        selectedTypeEta: 'Bidding',
                                        isBidding: true,
                                        shareRide: false));
                                    // For Check near ETA
                                    bookingBloc.checkNearByEta(
                                        bookingBloc.nearByDriversData,
                                        thisValue);
                                    final baseBloc =
                                        context.read<BookingBloc>();
                                    baseBloc.add(BookingEtaRequestEvent(
                                      picklat: arg.picklat,
                                      picklng: arg.picklng,
                                      droplat: arg.droplat,
                                      droplng: arg.droplng,
                                      ridetype: 1,
                                      transporttype: arg.transportType,
                                      distance: baseBloc.distance,
                                      duration: baseBloc.duration,
                                      polyLine: baseBloc.polyLine,
                                      pickupAddressList: arg.pickupAddressList,
                                      dropAddressList: arg.stopAddressList,
                                      isOutstationRide: arg.isOutstationRide,
                                      isWithoutDestinationRide:
                                          arg.isWithoutDestinationRide ?? false,
                                      preferenceId: baseBloc
                                              .selectedPreferenceDetailsList
                                              .isNotEmpty
                                          ? baseBloc
                                              .selectedPreferenceDetailsList
                                          : null,
                                    ));
                                    // }
                                  }
                                },
                                child: Container(
                                  // height: size.width * 0.08,
                                  width: (arg.transportType == 'taxi' &&
                                          context
                                              .read<BookingBloc>()
                                              .enableShareRides &&
                                          context
                                              .read<BookingBloc>()
                                              .enableOndemandRides)
                                      ? size.width * 0.24
                                      : size.width * 0.48,
                                  // width: size.width * 0.275,
                                  padding: EdgeInsets.fromLTRB(
                                      size.width * 0.025,
                                      size.width * 0.015,
                                      size.width * 0.025,
                                      size.width * 0.015),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: (bookingBloc.showBiddingVehicles &&
                                            bookingBloc.showSharedRide == false)
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text:
                                          AppLocalizations.of(context)!.bidding,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: (bookingBloc
                                                          .showBiddingVehicles &&
                                                      bookingBloc
                                                              .showSharedRide ==
                                                          false)
                                                  ? AppColors.white
                                                  : AppColors.hintColor),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if ((arg.transportType == 'taxi' &&
                              (arg.isWithoutDestinationRide == null ||
                                  !arg.isWithoutDestinationRide!) &&
                              (arg.isRentalRide == null ||
                                  !arg.isRentalRide!))) ...[
                            if (context.read<BookingBloc>().enableShareRides)
                              InkWell(
                                onTap: () {
                                  // Switch to Shared rides if not already selected, or if currently in Bidding
                                  if (bookingBloc.showBiddingVehicles ||
                                      !bookingBloc.showSharedRide) {
                                    bookingBloc.add(SelectBiddingOrDemandEvent(
                                        selectedTypeEta: 'Shared',
                                        isBidding: false,
                                        shareRide: true));
                                    // For Check near ETA
                                    bookingBloc.checkNearByEta(
                                        bookingBloc.nearByDriversData,
                                        thisValue);

                                    final baseBloc =
                                        context.read<BookingBloc>();
                                    baseBloc.add(BookingEtaRequestEvent(
                                      picklat: arg.picklat,
                                      picklng: arg.picklng,
                                      droplat: arg.droplat,
                                      droplng: arg.droplng,
                                      ridetype: 1,
                                      transporttype: arg.transportType,
                                      distance: baseBloc.distance,
                                      duration: baseBloc.duration,
                                      polyLine: baseBloc.polyLine,
                                      pickupAddressList: arg.pickupAddressList,
                                      dropAddressList: arg.stopAddressList,
                                      isOutstationRide: arg.isOutstationRide,
                                      isWithoutDestinationRide:
                                          arg.isWithoutDestinationRide ?? false,
                                      preferenceId: baseBloc
                                              .selectedPreferenceDetailsList
                                              .isNotEmpty
                                          ? baseBloc
                                              .selectedPreferenceDetailsList
                                          : null,
                                      sharedRide: 1,
                                      seatsTaken: baseBloc.selectedSharedSeats,
                                    ));
                                  }
                                },
                                child: Container(
                                  // height: size.width * 0.08,
                                  width: (context
                                          .read<BookingBloc>()
                                          .enableBiddingRides)
                                      ? size.width * 0.275
                                      : size.width * 0.48,
                                  padding: EdgeInsets.fromLTRB(
                                      size.width * 0.025,
                                      size.width * 0.015,
                                      size.width * 0.025,
                                      size.width * 0.015),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: bookingBloc.showSharedRide
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .shareRide,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: bookingBloc.showSharedRide
                                                  ? AppColors.white
                                                  : AppColors.hintColor),
                                    ),
                                  ),
                                ),
                              ),
                          ]
                        ],
                      ),
                    ),
                  ),
              ],
              if (arg.isWithoutDestinationRide != null &&
                  arg.isWithoutDestinationRide!)
                SizedBox(height: size.width * 0.04),
              if (bookingBloc.isOutstationRide) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: size.width * 0.025),
                      Container(
                        width: size.width,
                        // height: size.width * 0.15,
                        decoration: BoxDecoration(
                          color: AppColors.borderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(size.width * 0.0125),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                bookingBloc.isRoundTrip = false;
                                bookingBloc.showReturnDateTime = '';
                                bookingBloc.scheduleDateTimeForReturn = '';
                                bookingBloc.add(UpdateEvent());
                              },
                              child: Container(
                                height: size.width * 0.22,
                                width: size.width * 0.425,
                                decoration: BoxDecoration(
                                  color: (!bookingBloc.isRoundTrip)
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(size.width * 0.025),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.27,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .oneWayTrip,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: (!bookingBloc
                                                              .isRoundTrip)
                                                          ? AppColors.white
                                                          : AppColors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                              maxLines: 2,
                                            ),
                                          ),
                                          if (!bookingBloc.isRoundTrip &&
                                              arg.userData
                                                      .enableOutstationRoundTripFeature ==
                                                  '1')
                                            Image.asset(
                                              AppImages.circleCheckImage,
                                              width: size.width * 0.05,
                                              color: AppColors.white,
                                            )
                                        ],
                                      ),
                                      SizedBox(
                                        width: size.width * 0.3,
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .getDropOff,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: (!bookingBloc
                                                          .isRoundTrip)
                                                      ? AppColors.white
                                                      : AppColors.hintColor),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (arg.userData.enableOutstationRoundTripFeature ==
                                '1')
                              InkWell(
                                onTap: () {
                                  bookingBloc.isRoundTrip = true;
                                  bookingBloc.add(UpdateEvent());
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: false,
                                      enableDrag: false,
                                      isDismissible: true,
                                      barrierColor:
                                          Theme.of(context).shadowColor,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      builder: (_) {
                                        return scheduleRide(
                                            context, size, arg, true);
                                      });
                                },
                                child: Container(
                                  height: size.width * 0.22,
                                  width: size.width * 0.425,
                                  decoration: BoxDecoration(
                                    color: (bookingBloc.isRoundTrip)
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: size.width * 0.27,
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .roundTrip,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: (bookingBloc
                                                                .isRoundTrip)
                                                            ? AppColors.white
                                                            : AppColors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            if (bookingBloc.isRoundTrip)
                                              Image.asset(
                                                AppImages.circleCheckImage,
                                                width: size.width * 0.05,
                                                color: AppColors.white,
                                              )
                                            // Icon(Icons.check_circle,
                                            //     size: 20,
                                            //     color: AppColors.white)
                                          ],
                                        ),
                                        SizedBox(
                                          width: size.width * 0.3,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .keepTheCarTillReturn,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: (bookingBloc
                                                            .isRoundTrip)
                                                        ? AppColors.white
                                                        : AppColors.hintColor),
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.02),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(size.width * 0.025),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: false,
                                    enableDrag: false,
                                    isDismissible: true,
                                    barrierColor: Theme.of(context).shadowColor,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    builder: (_) {
                                      return scheduleRide(
                                          context, size, arg, false);
                                    });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                      text:
                                          '${AppLocalizations.of(context)!.leaveOn} : ',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.hintColor)),
                                  if (bookingBloc.showDateTime.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        MyText(
                                          text: bookingBloc.showDateTime,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.01,
                                        ),
                                        Icon(
                                          Icons.edit,
                                          size: size.width * 0.05,
                                        )
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            if (bookingBloc.isRoundTrip)
                              SizedBox(height: size.width * 0.025),
                            if (bookingBloc.isRoundTrip)
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: false,
                                      enableDrag: false,
                                      isDismissible: true,
                                      barrierColor:
                                          Theme.of(context).shadowColor,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      builder: (_) {
                                        return scheduleRide(
                                            context, size, arg, true);
                                      });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text:
                                          '${AppLocalizations.of(context)!.returnBy} : ',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.hintColor),
                                    ),
                                    if (bookingBloc
                                        .showReturnDateTime.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          MyText(
                                            text:
                                                bookingBloc.showReturnDateTime,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.01,
                                          ),
                                          Icon(
                                            Icons.edit,
                                            size: size.width * 0.05,
                                          )
                                        ],
                                      ),
                                    ],
                                    if (bookingBloc
                                        .showReturnDateTime.isEmpty) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            size: size.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: size.width * 0.01,
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .selectDate,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.rideDetails,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                              // fontWeight: FontWeight.bold
                              ),
                    ),
                    // In Shared mode, show seat selection control instead of calendar
                    if (bookingBloc.showSharedRide)
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: false,
                            enableDrag: true,
                            isDismissible: true,
                            barrierColor: Theme.of(context).shadowColor,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            builder: (ctx) {
                              return BlocProvider.value(
                                value: context.read<BookingBloc>(),
                                child: BlocBuilder<BookingBloc, BookingState>(
                                    builder: (context, state) {
                                  final b = context.read<BookingBloc>();
                                  // Local state for temporary seat selection
                                  int tempSelectedSeats = b.selectedSharedSeats;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .selectSeats,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Builder(
                                                    builder: (context) {
                                                      // Get the selected vehicle's capacity
                                                      final selectedVehicle = b
                                                              .isMultiTypeVechiles
                                                          ? b.sortedEtaDetailsList
                                                                  .isNotEmpty
                                                              ? b.sortedEtaDetailsList[b
                                                                  .selectedVehicleIndex]
                                                              : null
                                                          : b.etaDetailsList
                                                                  .isNotEmpty
                                                              ? b.etaDetailsList[
                                                                  b.selectedVehicleIndex]
                                                              : null;

                                                      final maxCapacity =
                                                          (selectedVehicle
                                                                      ?.capacity ??
                                                                  10)
                                                              .toDouble();
                                                      final divisions =
                                                          (maxCapacity - 1)
                                                              .toInt();

                                                      // Ensure tempSelectedSeats doesn't exceed capacity
                                                      tempSelectedSeats =
                                                          tempSelectedSeats >
                                                                  maxCapacity
                                                                      .toInt()
                                                              ? maxCapacity
                                                                  .toInt()
                                                              : tempSelectedSeats;

                                                      return Column(
                                                        children: [
                                                          // Add tick marks with numbers below the slider
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children:
                                                                  List.generate(
                                                                maxCapacity
                                                                    .toInt(),
                                                                (index) => Text(
                                                                  '${index + 1}',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall!
                                                                      .copyWith(
                                                                        color: Theme.of(context)
                                                                            .primaryColorDark,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Slider(
                                                            value:
                                                                tempSelectedSeats
                                                                    .toDouble(),
                                                            min: 1.0,
                                                            max: maxCapacity,
                                                            divisions:
                                                                divisions > 0
                                                                    ? divisions
                                                                    : 1,
                                                            label:
                                                                '$tempSelectedSeats',
                                                            activeColor: Theme
                                                                    .of(context)
                                                                .primaryColor,
                                                            inactiveColor: Theme
                                                                    .of(context)
                                                                .dividerColor
                                                                .withAlpha((0.4 *
                                                                        255)
                                                                    .toInt()),
                                                            onChanged: (val) {
                                                              setState(() {
                                                                tempSelectedSeats =
                                                                    val.round();
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.center,
                                                child: CustomButton(
                                                  isBorder: false,
                                                  buttonColor: Theme.of(context)
                                                      .primaryColor,
                                                  textColor: AppColors.white,
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .confirm,
                                                  onTap: () {
                                                    // Update the bloc with the temporary selected seats
                                                    b.add(SelectSharedSeatsEvent(
                                                        seats:
                                                            tempSelectedSeats));

                                                    final baseBloc = context
                                                        .read<BookingBloc>();
                                                    baseBloc.add(
                                                        BookingEtaRequestEvent(
                                                      picklat: arg.picklat,
                                                      picklng: arg.picklng,
                                                      droplat: arg.droplat,
                                                      droplng: arg.droplng,
                                                      ridetype: 1,
                                                      transporttype:
                                                          arg.transportType,
                                                      distance:
                                                          baseBloc.distance,
                                                      duration:
                                                          baseBloc.duration,
                                                      polyLine:
                                                          baseBloc.polyLine,
                                                      pickupAddressList:
                                                          arg.pickupAddressList,
                                                      dropAddressList:
                                                          arg.stopAddressList,
                                                      isOutstationRide:
                                                          arg.isOutstationRide,
                                                      isWithoutDestinationRide:
                                                          arg.isWithoutDestinationRide ??
                                                              false,
                                                      preferenceId: baseBloc
                                                              .selectedPreferenceDetailsList
                                                              .isNotEmpty
                                                          ? baseBloc
                                                              .selectedPreferenceDetailsList
                                                          : null,
                                                      sharedRide: 1,
                                                      seatsTaken:
                                                          tempSelectedSeats,
                                                    ));
                                                    Navigator.pop(ctx);
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text:
                                    '${AppLocalizations.of(context)!.selectSeats}:  ',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                              ),
                              MyText(
                                text: '${bookingBloc.selectedSharedSeats}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if ((!bookingBloc.showBiddingVehicles ||
                            !bookingBloc.isMultiTypeVechiles) &&
                        !bookingBloc.showSharedRide &&
                        arg.userData.showRideLaterFeature)
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: false,
                              enableDrag: false,
                              isDismissible: true,
                              barrierColor: Theme.of(context).shadowColor,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              builder: (_) {
                                return scheduleRide(context, size, arg, false);
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (bookingBloc.showDateTime.isEmpty) ...[
                                MyText(
                                  text: AppLocalizations.of(context)!.now,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        // fontWeight: FontWeight.bold
                                      ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Icon(Icons.calendar_month,
                                    size: size.width * 0.05,
                                    color: Theme.of(context).primaryColorDark),
                              ],
                              if (bookingBloc.showDateTime.isNotEmpty) ...[
                                MyText(
                                  text: bookingBloc.showDateTime,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                ),
                                SizedBox(
                                  width: size.width * 0.01,
                                ),
                                Icon(Icons.cancel_outlined,
                                    size: size.width * 0.05,
                                    color: Theme.of(context).primaryColorDark)
                              ]
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: size.width * 0.02),
              ((bookingBloc.isEtaFilter && !bookingBloc.filterSuccess) ||
                      ((bookingBloc.isMultiTypeVechiles &&
                              bookingBloc.sortedEtaDetailsList.isEmpty) ||
                          bookingBloc.etaDetailsList.isEmpty))
                  ? SizedBox(
                      height: size.height * 0.49,
                      child: Center(child: Image.asset(AppImages.noDataFound)))
                  : (bookingBloc.showSharedRide == false)
                      ? RawScrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: bookingBloc.etaScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: () {
                              final baseList = bookingBloc.isMultiTypeVechiles
                                  ? bookingBloc.sortedEtaDetailsList
                                  : bookingBloc.etaDetailsList;
                              final etaList = bookingBloc.etaDetailsList;
                              final displayList = bookingBloc.showSharedRide
                                  ? etaList
                                      .where((e) => e.enableSharedRide == true)
                                      .toList()
                                  : baseList;
                              return displayList.length;
                            }(),
                            itemBuilder: (context, index) {
                              final baseList = bookingBloc.isMultiTypeVechiles
                                  ? bookingBloc.sortedEtaDetailsList
                                  : bookingBloc.etaDetailsList;
                              final etaList = bookingBloc.etaDetailsList;
                              final displayList = bookingBloc.showSharedRide
                                  ? etaList
                                      .where((e) => e.enableSharedRide == true)
                                      .toList()
                                  : baseList;
                              final eta = displayList.elementAt(index);
                              // Map back to the original index in the base list to keep bloc selection consistent
                              final originalIndex = baseList.indexOf(eta);
                              return InkWell(
                                onTap: () {
                                  bookingBloc.add(BookingEtaSelectEvent(
                                      selectedTypeEta: '',
                                      selectedVehicleIndex: originalIndex,
                                      isOutstationRide:
                                          bookingBloc.isOutstationRide));
                                  final selectedSize = bookingBloc
                                              .dropAddressList.length ==
                                          1
                                      ? bookingBloc.currentSize
                                      : bookingBloc.dropAddressList.length == 2
                                          ? bookingBloc.currentSizeTwo
                                          : bookingBloc.currentSizeThree;
                                  bookingBloc.updateScrollHeight(selectedSize);
                                  bookingBloc.scrollToBottomFunction(context
                                      .read<BookingBloc>()
                                      .dropAddressList
                                      .length);

                                  // Jump to the selected size position in the scroll controller
                                  bookingBloc.etaScrollController
                                      .jumpTo(selectedSize);

                                  // For Check near ETA
                                  bookingBloc.checkNearByEta(
                                      bookingBloc.nearByDriversData, thisValue);
                                },
                                child: Container(
                                  width: size.width * 0.99,
                                  height: size.width * 0.2,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.5,
                                        color: (index == 0)
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.01),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: eta.vehicleIcon,
                                              height: 45,
                                              width: 45,
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
                                            SizedBox(width: size.width * 0.03),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  spacing: size.width * 0.02,
                                                  children: [
                                                    MyText(
                                                      text: eta.name,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                    ),
                                                    Image.asset(
                                                      AppImages.capacity,
                                                      width: size.width * 0.04,
                                                    ),
                                                    MyText(
                                                      text: eta.capacity
                                                          .toString(),
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                color: AppColors
                                                                    .hintColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    eta.hasDiscount &&
                                                            !bookingBloc
                                                                .showBiddingVehicles
                                                        ? Image(
                                                            image: const AssetImage(
                                                                AppImages
                                                                    .discount),
                                                            height: size.width *
                                                                0.04,
                                                            width: size.width *
                                                                0.04)
                                                        : const SizedBox()
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      color:
                                                          AppColors.hintColor,
                                                      size: 14,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.005),
                                                    MyText(
                                                      text: (bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .isNotEmpty &&
                                                              bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .elementAt(bookingBloc
                                                                      .nearByEtaVechileList
                                                                      .indexWhere((element) =>
                                                                          element.typeId ==
                                                                          eta
                                                                              .typeId))
                                                                  .duration
                                                                  .isNotEmpty)
                                                          ? bookingBloc
                                                              .nearByEtaVechileList
                                                              .elementAt(bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .indexWhere((element) =>
                                                                      element.typeId ==
                                                                      eta.typeId))
                                                              .duration
                                                          : '--',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .hintColor,
                                                              ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.005),
                                                    InkWell(
                                                      onTap: () {
                                                        bookingBloc.add(
                                                            ShowEtaInfoEvent(
                                                                infoIndex:
                                                                    originalIndex));
                                                      },
                                                      child: const Icon(
                                                        Icons.info_outline,
                                                        color:
                                                            AppColors.hintColor,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyText(
                                                    text: (bookingBloc
                                                            .isRoundTrip)
                                                        ? '${eta.currency.toString()} ${eta.pricePerDistance.toStringAsFixed(2)}/${eta.unitInWords}'
                                                        : '${eta.currency.toString()} ${eta.total.toStringAsFixed(2)}',
                                                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        fontSize:
                                                            (eta.hasDiscount &&
                                                                    !bookingBloc
                                                                        .showBiddingVehicles)
                                                                ? 14
                                                                : 16,
                                                        fontWeight: (eta.hasDiscount &&
                                                                !bookingBloc
                                                                    .showBiddingVehicles)
                                                            ? FontWeight.normal
                                                            : FontWeight.bold,
                                                        color: (eta.hasDiscount &&
                                                                !bookingBloc
                                                                    .showBiddingVehicles)
                                                            ? Theme.of(context)
                                                                .hintColor
                                                            : Theme.of(context)
                                                                .primaryColorDark,
                                                        decoration: (eta.hasDiscount &&
                                                                !bookingBloc.showBiddingVehicles)
                                                            ? TextDecoration.lineThrough
                                                            : null,
                                                        decorationColor: Theme.of(context).primaryColorDark,
                                                        decorationThickness: 2),
                                                  ),
                                                  if (eta.hasDiscount &&
                                                      !bookingBloc
                                                          .showBiddingVehicles)
                                                    MyText(
                                                      text:
                                                          '${eta.currency.toString()} ${eta.discountTotal.toStringAsFixed(2)}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : RawScrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: bookingBloc.etaScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: () {
                              final baseList = bookingBloc.etaDetailsList;
                              final displayList = bookingBloc.showSharedRide
                                  ? baseList
                                      .where((e) => e.enableSharedRide == true)
                                      .toList()
                                  : baseList;
                              return displayList.length;
                            }(),
                            itemBuilder: (context, index) {
                              final baseList = bookingBloc.etaDetailsList;
                              final displayList = bookingBloc.showSharedRide
                                  ? baseList
                                      .where((e) => e.enableSharedRide == true)
                                      .toList()
                                  : baseList;
                              final eta = displayList.elementAt(index);
                              // Map back to the original index in the base list to keep bloc selection consistent
                              final originalIndex = baseList.indexOf(eta);
                              return InkWell(
                                onTap: () {
                                  bookingBloc.add(BookingEtaSelectEvent(
                                      selectedTypeEta: 'Shared',
                                      selectedVehicleIndex: originalIndex,
                                      isOutstationRide:
                                          bookingBloc.isOutstationRide));
                                  final selectedSize = bookingBloc
                                              .dropAddressList.length ==
                                          1
                                      ? bookingBloc.currentSize
                                      : bookingBloc.dropAddressList.length == 2
                                          ? bookingBloc.currentSizeTwo
                                          : bookingBloc.currentSizeThree;
                                  bookingBloc.updateScrollHeight(selectedSize);
                                  bookingBloc.scrollToBottomFunction(context
                                      .read<BookingBloc>()
                                      .dropAddressList
                                      .length);

                                  // Jump to the selected size position in the scroll controller
                                  bookingBloc.etaScrollController
                                      .jumpTo(selectedSize);

                                  // For Check near ETA
                                  bookingBloc.checkNearByEta(
                                      bookingBloc.nearByDriversData, thisValue);
                                },
                                child: Container(
                                  width: size.width * 0.99,
                                  height: size.width * 0.2,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.5,
                                        color: (index == 0)
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.01),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: eta.vehicleIcon,
                                              height: 45,
                                              width: 45,
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
                                            SizedBox(width: size.width * 0.03),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  spacing: size.width * 0.02,
                                                  children: [
                                                    MyText(
                                                      text: eta.name,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                    ),
                                                    Image.asset(
                                                      AppImages.capacity,
                                                      width: size.width * 0.04,
                                                    ),
                                                    MyText(
                                                      text: eta.capacity
                                                          .toString(),
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                color: AppColors
                                                                    .hintColor,
                                                                fontSize: 14,
                                                              ),
                                                    ),
                                                    eta.hasDiscount &&
                                                            !bookingBloc
                                                                .showBiddingVehicles
                                                        ? Image(
                                                            image: const AssetImage(
                                                                AppImages
                                                                    .discount),
                                                            height: size.width *
                                                                0.04,
                                                            width: size.width *
                                                                0.04)
                                                        : const SizedBox()
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      color:
                                                          AppColors.hintColor,
                                                      size: 14,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.005),
                                                    MyText(
                                                      text: (bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .isNotEmpty &&
                                                              bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .elementAt(bookingBloc
                                                                      .nearByEtaVechileList
                                                                      .indexWhere((element) =>
                                                                          element.typeId ==
                                                                          eta
                                                                              .typeId))
                                                                  .duration
                                                                  .isNotEmpty)
                                                          ? bookingBloc
                                                              .nearByEtaVechileList
                                                              .elementAt(bookingBloc
                                                                  .nearByEtaVechileList
                                                                  .indexWhere((element) =>
                                                                      element.typeId ==
                                                                      eta.typeId))
                                                              .duration
                                                          : '--',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .hintColor,
                                                              ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.005),
                                                    InkWell(
                                                      onTap: () {
                                                        bookingBloc.add(
                                                            ShowEtaInfoEvent(
                                                                infoIndex:
                                                                    originalIndex));
                                                      },
                                                      child: const Icon(
                                                        Icons.info_outline,
                                                        color:
                                                            AppColors.hintColor,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MyText(
                                                    text: (bookingBloc
                                                            .isRoundTrip)
                                                        ? '${eta.currency.toString()} ${eta.pricePerDistance.toStringAsFixed(2)}/${eta.unitInWords}'
                                                        : '${eta.currency.toString()} ${eta.total.toStringAsFixed(2)}',
                                                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                        fontSize:
                                                            (eta.hasDiscount &&
                                                                    !bookingBloc
                                                                        .showBiddingVehicles)
                                                                ? 14
                                                                : 16,
                                                        fontWeight: (eta.hasDiscount &&
                                                                !bookingBloc
                                                                    .showBiddingVehicles)
                                                            ? FontWeight.normal
                                                            : FontWeight.bold,
                                                        color: (eta.hasDiscount &&
                                                                !bookingBloc
                                                                    .showBiddingVehicles)
                                                            ? Theme.of(context)
                                                                .hintColor
                                                            : Theme.of(context)
                                                                .primaryColorDark,
                                                        decoration: (eta.hasDiscount &&
                                                                !bookingBloc.showBiddingVehicles)
                                                            ? TextDecoration.lineThrough
                                                            : null,
                                                        decorationColor: Theme.of(context).primaryColorDark,
                                                        decorationThickness: 2),
                                                  ),
                                                  if (eta.hasDiscount &&
                                                      !bookingBloc
                                                          .showBiddingVehicles)
                                                    MyText(
                                                      text:
                                                          '${eta.currency.toString()} ${eta.discountTotal.toStringAsFixed(2)}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

              // payment
              if (context.read<BookingBloc>().transportType == 'taxi')
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        barrierColor: Theme.of(context).shadowColor,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.0),
                          ),
                        ),
                        builder: (_) {
                          return SelectPaymentMethodWidget(cont: context);
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: size.width * 0.05,
                        left: size.width * 0.05,
                        bottom: size.width * 0.025,
                        top: size.width * 0.05),
                    child: Container(
                      width: size.width,
                      padding: EdgeInsets.fromLTRB(
                          size.width * 0.05,
                          size.width * 0.025,
                          size.width * 0.05,
                          size.width * 0.025),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  context.read<BookingBloc>().isSavedCardChoose
                                      ? Icons.credit_card_rounded
                                      : context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'cash'
                                          ? Icons.payments_outlined
                                          : context
                                                      .read<BookingBloc>()
                                                      .selectedPaymentType ==
                                                  'card'
                                              ? Icons.credit_card_rounded
                                              : Icons
                                                  .account_balance_wallet_outlined,
                                  size: size.width * 0.05,
                                  color: (context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'wallet' &&
                                          context
                                                  .read<BookingBloc>()
                                                  .userData!
                                                  .wallet
                                                  .data
                                                  .amountBalance <
                                              context
                                                  .read<BookingBloc>()
                                                  .selectedEtaAmount)
                                      ? AppColors.red
                                      : Theme.of(context).primaryColorDark),
                              SizedBox(width: size.width * 0.025),
                              MyText(
                                  text: context
                                          .read<BookingBloc>()
                                          .isSavedCardChoose
                                      ? 'Card'
                                      : (context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'cash')
                                          ? AppLocalizations.of(context)!.cash
                                          : (context
                                                      .read<BookingBloc>()
                                                      .selectedPaymentType ==
                                                  'wallet')
                                              ? AppLocalizations.of(context)!
                                                  .wallet
                                              : context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          // fontWeight: FontWeight.bold,
                                          color: (context
                                                          .read<BookingBloc>()
                                                          .selectedPaymentType ==
                                                      'wallet' &&
                                                  context
                                                          .read<BookingBloc>()
                                                          .userData!
                                                          .wallet
                                                          .data
                                                          .amountBalance <
                                                      context
                                                          .read<BookingBloc>()
                                                          .selectedEtaAmount)
                                              ? AppColors.red
                                              : null)),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: size.width * 0.06,
                            color: AppColors.hintColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // preference
              InkWell(
                onTap: () {
                  if ((context
                      .read<BookingBloc>()
                      .preferenceDetailsList!
                      .isNotEmpty)) {
                    context.read<BookingBloc>().add(UpdateEvent());
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: false,
                        enableDrag: false,
                        isDismissible: false,
                        barrierColor: Theme.of(context).shadowColor,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
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
                  } else {}
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                      bottom: size.width * 0.025),
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.05,
                        size.width * 0.025,
                        size.width * 0.05,
                        size.width * 0.025),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.tune,
                              size: 20,
                              color: (context
                                      .read<BookingBloc>()
                                      .preferenceDetailsList!
                                      .isEmpty)
                                  ? AppColors.greyHeader
                                  : Theme.of(context).primaryColorDark),
                          SizedBox(width: size.width * 0.025),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  text:
                                      AppLocalizations.of(context)!.preferences,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: (context
                                                  .read<BookingBloc>()
                                                  .preferenceDetailsList!
                                                  .isEmpty)
                                              ? AppColors.greyHeader
                                              : Theme.of(context)
                                                  .primaryColorDark)),
                              (context.read<BookingBloc>().isRentalRide ==
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
                                                  .selectedPreferenceDetailsList[
                                              index];
                                          final prefList = context
                                                  .read<BookingBloc>()
                                                  .preferenceDetailsList ??
                                              [];
                                          final pref = prefList.firstWhere(
                                            (e) => e.preferenceId == prefId,
                                          );
                                          return CachedNetworkImage(
                                            imageUrl: pref.icon,
                                            fit: BoxFit.cover,
                                            width: 12,
                                            height: 12,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox.shrink(),
                                          );
                                        } catch (e) {
                                          return const SizedBox.shrink();
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
                                                  .selectedPreferenceDetailsList[
                                              index];
                                          final prefList = context
                                                  .read<BookingBloc>()
                                                  .rentalPreferenceDetailsList ??
                                              [];
                                          final pref = prefList.firstWhere(
                                            (e) => e.preferenceId == prefId,
                                          );
                                          return CachedNetworkImage(
                                            imageUrl: pref.icon,
                                            fit: BoxFit.cover,
                                            width: 12,
                                            height: 12,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox.shrink(),
                                          );
                                        } catch (e) {
                                          return const SizedBox.shrink();
                                        }
                                      }),
                                    )
                            ],
                          )
                        ]),
                        Icon(
                          Icons.arrow_forward,
                          size: size.width * 0.06,
                          color: AppColors.hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // coupon
              InkWell(
                onTap: () {
                  context.read<BookingBloc>().promoErrorText = '';
                  context.read<BookingBloc>().add(UpdateEvent());
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    barrierColor: Theme.of(context).shadowColor,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.0),
                      ),
                    ),
                    builder: (_) {
                      return BlocProvider.value(
                        value: context.read<BookingBloc>(),
                        child: ApplyCouponWidget(
                          arg: arg,
                          cont: context,
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                      bottom: size.width * 0.025),
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.05,
                        size.width * 0.025,
                        size.width * 0.05,
                        size.width * 0.025),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Image.asset(
                            AppImages.ticketImage,
                            width: size.width * 0.05,
                          ),
                          SizedBox(width: size.width * 0.025),
                          MyText(
                              text: AppLocalizations.of(context)!.coupon,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith())
                        ]),
                        Icon(
                          Icons.arrow_forward,
                          size: size.width * 0.06,
                          color: AppColors.hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // instructions
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.05,
                    right: size.width * 0.05,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: CustomTextField(
                  controller:
                      context.read<BookingBloc>().instructionsController,
                  borderRadius: 10,
                  filled: true,
                  hintText:
                      '${AppLocalizations.of(context)!.instructions}(${AppLocalizations.of(context)!.optional})',
                  maxLine: 3,
                  keyboardType: TextInputType.text,
                  onChange: (p0) {
                    context.read<BookingBloc>().add(UpdateEvent());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ignore: unused_element
class _AddPreferenceButton extends StatelessWidget {
  final Size size;
  final BookingPageArguments arg;

  const _AddPreferenceButton({
    required this.size,
    required this.arg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: size.width * 0.01),
      child: InkWell(
        onTap: () {
          final bookingBloc = context.read<BookingBloc>();
          final userData = bookingBloc.userData;
          final canSelectPreference = bookingBloc.transportType == 'taxi' &&
              userData != null &&
              (userData.enablePetPreferenceForUser == '1' ||
                  userData.enableLuggagePreferenceForUser == '1');

          if (canSelectPreference) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: false,
                enableDrag: false,
                isDismissible: false,
                barrierColor: Theme.of(context).shadowColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                builder: (_) {
                  return SelectPreferenceWidget(
                    cont: context,
                    arg: arg,
                  );
                });
          } else {
            // showToast(message: 'Unavailable');
          }
        },
        child: MyText(text: AppLocalizations.of(context)!.addPrefrence),
      ),
    );
  }
}
