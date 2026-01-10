import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_navigation_icon.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/booking_bloc.dart';
import 'bidding_ride/bidding_waiting_for_driver.dart';
import 'booking_map_widget.dart';
import 'delivery_booking_widget.dart';
import 'eta_list_shimmer.dart';
import 'on_ride/on_ride_bottom_sheet.dart';
import 'ride_preview_widget.dart';
import 'waiting_for_driver.dart';
import 'package:latlong2/latlong.dart' as fmlt;

class BookingBodyWidget extends StatefulWidget {
  final BuildContext cont;
  final BookingPageArguments arg;

  const BookingBodyWidget({super.key, required this.cont, required this.arg});

  @override
  State<BookingBodyWidget> createState() => _BookingBodyWidgetState();
}

class _BookingBodyWidgetState extends State<BookingBodyWidget> {
  @override
  void initState() {
    super.initState();

    context.read<BookingBloc>().draggableController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: context.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final bookingBloc = context.read<BookingBloc>();
          return Stack(
            children: [
              Stack(
                children: [
                  if (bookingBloc.animation != null)
                    BookingMapWidget(
                        cont: context, mapType: bookingBloc.mapType),
                  if (!bookingBloc.isNormalRideSearching &&
                      !bookingBloc.isBiddingRideSearching)
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Row(
                          children: [
                            if ((bookingBloc.isRentalRide &&
                                    bookingBloc
                                        .rentalEtaDetailsList.isNotEmpty) ||
                                !bookingBloc.isRentalRide)
                              NavigationIconWidget(
                                onTap: () {
                                  bookingBloc.add(BookingNavigatorPopEvent());
                                },
                                icon: Icon(Icons.arrow_back_ios_new_rounded,
                                    size: 20,
                                    color: Theme.of(context).primaryColorDark),
                                isShadowWidget: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: size.height * 0.55,
                    right: size.width * 0.03,
                    child: Column(
                      children: [
                        if (!bookingBloc.isNormalRideSearching &&
                            !bookingBloc.isBiddingRideSearching) ...[
                          if (bookingBloc.mapType == 'google_map')
                            PopupMenuButton<MapType>(
                              color: AppColors.white,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                child: const Icon(Icons.layers,
                                    color: Colors.black),
                              ),
                              onSelected: (mapType) {
                                bookingBloc.add(UpdateMapTypeEvent(mapType));
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: MapType.normal,
                                    child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .normal,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: AppColors.black))),
                                PopupMenuItem(
                                    value: MapType.satellite,
                                    child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .satellite,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: AppColors.black))),
                                PopupMenuItem(
                                  value: MapType.terrain,
                                  child: MyText(
                                      text:
                                          AppLocalizations.of(context)!.terrain,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: AppColors.black)),
                                ),
                                PopupMenuItem(
                                  value: MapType.hybrid,
                                  child: MyText(
                                      text:
                                          AppLocalizations.of(context)!.hybrid,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: AppColors.black)),
                                ),
                              ],
                            ),
                          InkWell(
                            onTap: () {
                              if (bookingBloc.googleMapController != null &&
                                  bookingBloc.bound != null) {
                                if (bookingBloc.requestData != null &&
                                    bookingBloc.requestData!.isRental) {
                                  bookingBloc.add(BookingLocateMeEvent(
                                      mapType: bookingBloc.mapType,
                                      controller:
                                          (bookingBloc.mapType == 'google_map')
                                              ? bookingBloc.googleMapController
                                              : bookingBloc.fmController));
                                } else {
                                  bookingBloc.googleMapController
                                      ?.animateCamera(
                                          CameraUpdate.newLatLngBounds(
                                              bookingBloc.bound!, 100));
                                }
                              } else if (bookingBloc.fmController != null) {
                                bookingBloc.fmController?.move(
                                    fmlt.LatLng(
                                        bookingBloc.bound!.northeast.latitude,
                                        bookingBloc.bound!.northeast.longitude),
                                    14);
                              }
                            },
                            child: Container(
                              height: size.width * 0.11,
                              width: size.width * 0.11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                border: Border.all(
                                  width: 1.2,
                                  color: AppColors.black
                                      .withAlpha((0.8 * 255).toInt()),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.my_location,
                                  size: size.width * 0.05,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: size.width * 0.02),
                        if (bookingBloc.requestData != null &&
                            context
                                    .read<BookingBloc>()
                                    .requestData!
                                    .isTripStart ==
                                1) ...[
                          InkWell(
                            onTap: () async {
                              await Share.share(
                                  'Your Driver is ${bookingBloc.driverData!.name}. ${bookingBloc.driverData!.carColor} ${bookingBloc.driverData!.carMakeName} ${bookingBloc.driverData!.carModelName}, Vehicle Number: ${bookingBloc.driverData!.carNumber}. Track with link: ${AppConstants.baseUrl}track/request/${bookingBloc.requestData!.id}');
                            },
                            child: Container(
                              height: size.width * 0.11,
                              width: size.width * 0.11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                                border: Border.all(
                                  width: 1.2,
                                  color: AppColors.black
                                      .withAlpha((0.8 * 255).toInt()),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.share,
                                size: size.width * 0.05,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              bookingBloc.add(SOSEvent());
                            },
                            child: Container(
                              height: size.width * 0.18,
                              width: size.width * 0.18,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(AppImages.sosImage),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              (bookingBloc.isBiddingRideSearching)
                  ? DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      minChildSize: 0.3,
                      maxChildSize: 0.6,
                      builder: (context, scrollController) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return NotificationListener<
                                DraggableScrollableNotification>(
                              onNotification: (notification) {
                                double newPosition = notification.extent *
                                    size.height; // Convert to pixels

                                // Set bounds for the new position
                                if (newPosition > size.height * 0.6) {
                                  newPosition = size.height * 0.3; // Max height
                                }

                                context
                                    .read<BookingBloc>()
                                    .onRideBottomPosition = newPosition;
                                bookingBloc.add(UpdateEvent());

                                return true;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: BiddingWaitingForDriverConfirmation(
                                    maximumTime: double.parse(
                                      bookingBloc.userData!
                                          .maximumTimeForFindDriversForRegularRide,
                                    ),
                                    isOutstationRide:
                                        bookingBloc.isOutstationRide,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : (bookingBloc.isNormalRideSearching)
                      ? DraggableScrollableSheet(
                          initialChildSize: 0.35,
                          minChildSize: 0.35,
                          maxChildSize: 0.6,
                          builder: (context, scrollController) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return NotificationListener<
                                    DraggableScrollableNotification>(
                                  onNotification: (notification) {
                                    double newPosition = notification.extent *
                                        size.height; // Convert to pixels

                                    // Set bounds for the new position
                                    if (newPosition > size.height * 0.6) {
                                      newPosition =
                                          size.height * 0.3; // Max height
                                    }

                                    context
                                        .read<BookingBloc>()
                                        .onRideBottomPosition = newPosition;
                                    context
                                        .read<BookingBloc>()
                                        .add(UpdateEvent());

                                    return true;
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: WaitingForDriverConfirmation(
                                        maximumTime: double.parse(
                                          bookingBloc.userData!
                                              .maximumTimeForFindDriversForRegularRide,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : (bookingBloc.isTripStart)
                          ? DraggableScrollableSheet(
                              initialChildSize: 0.6,
                              minChildSize: 0.3,
                              maxChildSize: 0.6,
                              builder: (context, scrollController) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return NotificationListener<
                                        DraggableScrollableNotification>(
                                      onNotification: (notification) {
                                        double newPosition = notification
                                                .extent *
                                            size.height; // Convert to pixels

                                        // Set bounds for the new position
                                        if (newPosition > size.height * 0.6) {
                                          newPosition =
                                              size.height * 0.3; // Max height
                                        }

                                        context
                                            .read<BookingBloc>()
                                            .onRideBottomPosition = newPosition;
                                        context
                                            .read<BookingBloc>()
                                            .add(UpdateEvent());

                                        return true;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                        ),
                                        child: SingleChildScrollView(
                                          controller: scrollController,
                                          child: const OnRideBottomSheet(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          : ((!bookingBloc.isRentalRide &&
                                      context
                                          .read<BookingBloc>()
                                          .etaDetailsList
                                          .isNotEmpty) ||
                                  (bookingBloc.isRentalRide &&
                                      context
                                          .read<BookingBloc>()
                                          .rentalEtaDetailsList
                                          .isNotEmpty))
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: BlocBuilder<BookingBloc, BookingState>(
                                    builder: (context, state) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter set) {
                                          return GestureDetector(
                                              onVerticalDragUpdate: (details) {
                                                final dragAmount =
                                                    details.primaryDelta!;

                                                set(() {
                                                  if (context
                                                      .read<BookingBloc>()
                                                      .detailView) {
                                                    if (dragAmount > 0) {
                                                      context
                                                          .read<BookingBloc>()
                                                          .detailView = false;
                                                      context
                                                          .read<BookingBloc>()
                                                          .add(UpdateEvent());
                                                    }
                                                  } else {
                                                    if (widget
                                                            .arg
                                                            .stopAddressList
                                                            .length ==
                                                        1) {
                                                      context
                                                          .read<BookingBloc>()
                                                          .currentSize = (context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSize -
                                                              (dragAmount /
                                                                  size.height))
                                                          .clamp(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSize,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    } else if (widget
                                                            .arg
                                                            .stopAddressList
                                                            .length ==
                                                        2) {
                                                      context
                                                          .read<BookingBloc>()
                                                          .currentSizeTwo = (context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSizeTwo -
                                                              (dragAmount /
                                                                  size.height))
                                                          .clamp(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSizeTwo,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    } else {
                                                      context
                                                          .read<BookingBloc>()
                                                          .currentSizeThree = (context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSizeThree -
                                                              (dragAmount /
                                                                  size.height))
                                                          .clamp(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSizeThree,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    }
                                                  }
                                                });
                                              },
                                              onVerticalDragEnd: (details) {
                                                set(() {
                                                  // Snap to position logic for non-detail view
                                                  if (!context
                                                      .read<BookingBloc>()
                                                      .detailView) {
                                                    if (widget
                                                            .arg
                                                            .stopAddressList
                                                            .length ==
                                                        1) {
                                                      bookingBloc.currentSize = context
                                                          .read<BookingBloc>()
                                                          .snapToPosition(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSize,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSize,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    } else if (widget
                                                            .arg
                                                            .stopAddressList
                                                            .length ==
                                                        2) {
                                                      context
                                                              .read<BookingBloc>()
                                                              .currentSizeTwo =
                                                          bookingBloc.snapToPosition(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSizeTwo,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSizeTwo,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    } else {
                                                      context
                                                              .read<BookingBloc>()
                                                              .currentSizeThree =
                                                          bookingBloc.snapToPosition(
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .currentSizeThree,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .minChildSizeThree,
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .maxChildSize);
                                                    }
                                                  }
                                                });
                                              },
                                              child: DraggableScrollableSheet(
                                                controller: context
                                                    .read<BookingBloc>()
                                                    .draggableController,
                                                initialChildSize: 0.5,
                                                minChildSize: 0.5,
                                                maxChildSize: 0.95,
                                                builder: (context,
                                                    scrollController) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(10),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Theme.of(context)
                                                                  .shadowColor,
                                                          blurRadius: 4.0,
                                                          spreadRadius: 2.0,
                                                        ),
                                                      ],
                                                    ),
                                                    child:
                                                        SingleChildScrollView(
                                                      controller:
                                                          scrollController,
                                                      physics:
                                                          const AlwaysScrollableScrollPhysics(),
                                                      child: context
                                                              .read<
                                                                  BookingBloc>()
                                                              .detailView
                                                          ? DeliveryBookingWidget(
                                                              cont: context,
                                                              arg: widget.arg,
                                                              eta: context
                                                                      .read<
                                                                          BookingBloc>()
                                                                      .isRentalRide
                                                                  ? context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .rentalEtaDetailsList[
                                                                      context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .selectedVehicleIndex]
                                                                  : context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .isMultiTypeVechiles
                                                                      ? bookingBloc.sortedEtaDetailsList[context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .selectedVehicleIndex]
                                                                      : bookingBloc.etaDetailsList[context
                                                                          .read<
                                                                              BookingBloc>()
                                                                          .selectedVehicleIndex],
                                                            )
                                                          : RidePreviewWidget(
                                                              cont: context,
                                                              arg: widget.arg,
                                                            ),
                                                    ),
                                                  );
                                                },
                                              ));
                                        },
                                      );
                                    },
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: EtaListShimmer(size: size))
            ],
          );
        },
      ),
    );
  }
}
