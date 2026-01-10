// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:restart_tagxi/common/common.dart";
import "package:restart_tagxi/core/utils/custom_appbar.dart";
import "package:restart_tagxi/core/utils/custom_button.dart";
import "package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/create_ticket_sheet.dart";
import "../../../../../../core/utils/custom_dialoges.dart";
import "../../../../../../core/utils/custom_loader.dart";
import "../../../../../../core/utils/custom_slider/custom_sliderbutton.dart";
import "../../../../../../core/utils/custom_text.dart";
import "../../../../../../l10n/app_localizations.dart";
import "../../../../../home/presentation/pages/home_page/page/home_page.dart";
import "../../../../application/acc_bloc.dart";

import "../widget/cancel_ride_widget.dart";
import "../widget/trip_earnings_widget.dart";
import "../widget/trip_farebreakup_widget.dart";
import "../widget/trip_user_details_widget.dart";
import "../widget/trip_vehicle_info_widget.dart";

class HistoryTripSummaryPage extends StatelessWidget {
  static const String routeName = '/historytripsummary';
  final TripHistoryPageArguments arg;

  const HistoryTripSummaryPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AddHistoryMarkerEvent(
            stops: arg.historyData.requestStops,
            pickLat: arg.historyData.pickLat,
            pickLng: arg.historyData.pickLng,
            dropLat: arg.historyData.dropLat,
            dropLng: arg.historyData.dropLng,
            polyline: arg.historyData.polyLine))
        ..add(TripSummaryHistoryDataEvent(tripHistoryData: arg.historyData))
        ..add(ComplaintEvent(complaintType: 'request')),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is HistoryTypeChangeState) {
            String filter;
            switch (state.selectedHistoryType) {
              case 0:
                filter = 'is_completed=1';
                break;
              case 1:
                filter = 'is_later=1';
                break;
              case 2:
                filter = 'is_cancelled=1';
                break;
              default:
                filter = '';
            }
            context.read<AccBloc>().add(HistoryGetEvent(historyFilter: filter));
          } else if (state is RequestCancelState) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (state is OutstationReadyToPickupState) {
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: HomePageArguments(isFromHistory: true));
          } else if (state is ShowErrorState) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext ctx) {
                return CustomSingleButtonDialoge(
                  title: AppLocalizations.of(context)!.cancel,
                  content: AppLocalizations.of(context)!.userCancelledRide,
                  btnName: AppLocalizations.of(context)!.ok,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                );
              },
            );
          } else if (state is GetTicketListLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is CreateSupportTicketState) {
            if (context.read<AccBloc>().isTicketSheetOpened) return;
            context.read<AccBloc>().isTicketSheetOpened = true;
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              context: context,
              builder: (cont) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: CreateTicketSheet(
                    requestId: state.requestId,
                    cont: context,
                    ticketNamesList: state.ticketNamesList,
                    isFromRequest: state.isFromRequest,
                    index: state.historyIndex,
                    historyPagenumber: state.historyPageNumber,
                  ),
                );
              },
            ).whenComplete(() {
              if (context.mounted) {
                context.read<AccBloc>().isTicketSheetOpened = false;
              }
            });
          } else if (state is InvoiceDownloadSuccessState) {
            showDialog(
              context: context,
              builder: (_) {
                return CustomSingleButtonDialoge(
                  title: AppLocalizations.of(context)!.success,
                  content: AppLocalizations.of(context)!.invoiceSendContent,
                  btnName: AppLocalizations.of(context)!.ok,
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final tripHistoryData = context.read<AccBloc>().historyData;

          if (Theme.of(context).brightness == Brightness.dark) {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().darkMapString);
            }
          } else {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().lightMapString);
            }
          }
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.fareBreakdown,
              automaticallyImplyLeading: true,
              titleFontSize: 18,
            ),
            // backgroundColor: AppColors.white,
            body: (tripHistoryData != null)
                ? SafeArea(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: size.height,
                          width: size.width,
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: 1, (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(size.width * 0.03),
                                  width: size.width,
                                  // color: const Color(0xffDEDCDC),
                                  child: Column(
                                    children: [
                                      TripFarebreakupWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.02),
                                      if (tripHistoryData.requestBill != null)
                                        TripEarningsWidget(
                                            cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.02),
                                      TripUserDetailsWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.height * 0.01),
                                      TripVehicleInfoWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.02),
                                      Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          decoration: BoxDecoration(
                                            // color: Theme.of(context)
                                            //     .scaffoldBackgroundColor,
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .tripId,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.02),
                                                  MyText(
                                                    text: tripHistoryData
                                                        .requestNumber,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                      SizedBox(height: size.width * 0.02),
                                      Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          decoration: BoxDecoration(
                                            // color: Theme.of(context)
                                            //     .scaffoldBackgroundColor,
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .ratings,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(fontSize: 18),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.02),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(
                                                  5,
                                                  (index) {
                                                    return (index <
                                                            tripHistoryData
                                                                .rideUserRating)
                                                        ? const Icon(Icons.star,
                                                            size: 25,
                                                            color: AppColors
                                                                .primary)
                                                        : const Icon(
                                                            Icons
                                                                .star_border_outlined,
                                                            size: 25);
                                                  },
                                                ),
                                              ),
                                            ],
                                          )),
                                      SizedBox(height: size.width * 0.5),
                                    ],
                                  ),
                                );
                              })),
                            ],
                          ),
                        ),
                        if (tripHistoryData.isCancelled != 1)
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: (tripHistoryData.isCompleted == 1 &&
                                      tripHistoryData.supportTicketExist ==
                                          true &&
                                      arg.isSupportTicketEnabled == '1')
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          top: 10,
                                          right: 10,
                                          bottom: 10),
                                      child: Container(
                                        // height: size.width * 0.1,
                                        width: size.width * 0.5,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                          color:
                                              Theme.of(context).disabledColor,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyText(
                                                  text:
                                                      "${AppLocalizations.of(context)!.ticketCreated} :",
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.02,
                                                ),
                                                MyText(
                                                  text: tripHistoryData
                                                      .supportTicketId,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            MyText(
                                              text: tripHistoryData
                                                          .supportTicketStatus ==
                                                      1
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .pending
                                                  : tripHistoryData
                                                              .supportTicketStatus ==
                                                          2
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .acknowledged
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .closed,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: tripHistoryData
                                                                  .supportTicketStatus ==
                                                              1
                                                          ? AppColors.blue
                                                          : tripHistoryData
                                                                      .supportTicketStatus ==
                                                                  2
                                                              ? AppColors.orange
                                                              : AppColors.red,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : (tripHistoryData.isCompleted == 1 &&
                                          arg.isSupportTicketEnabled == '1')
                                      ? Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 4,
                                                    offset: Offset(0, -2),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 14),
                                                child: GestureDetector(
                                                    onDoubleTap: null,
                                                    onDoubleTapDown: null,
                                                    onTap: () {
                                                      context
                                                          .read<AccBloc>()
                                                          .add(
                                                              CreateSupportTicketEvent(
                                                            requestId:
                                                                tripHistoryData
                                                                    .requestNumber,
                                                            isFromRequest: true,
                                                            index: arg
                                                                .historyIndex,
                                                            pageNumber:
                                                                arg.pageNumber,
                                                          ));
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .report_outlined,
                                                            size: 20,
                                                            color:
                                                                AppColors.red),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.01),
                                                        MyText(
                                                            text: AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .reportIssue,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13)),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          ],
                                        )
                                      : (tripHistoryData.isLater &&
                                              tripHistoryData.isCancelled == 0)
                                          ? Container(
                                              width: size.width,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                              ),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 10),
                                                      if (tripHistoryData.isLater ==
                                                              true &&
                                                          tripHistoryData
                                                                  .isCancelled ==
                                                              0 &&
                                                          tripHistoryData
                                                                  .isOutStation ==
                                                              0)
                                                        CustomButton(
                                                            width: size.width *
                                                                0.9,
                                                            height: size.width *
                                                                0.12,
                                                            buttonName:
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .cancel,
                                                            borderRadius: 20,
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      false,
                                                                  enableDrag:
                                                                      false,
                                                                  isDismissible:
                                                                      true,
                                                                  builder: (_) {
                                                                    return CancelRideWidget(
                                                                        cont:
                                                                            context,
                                                                        requestId:
                                                                            tripHistoryData.id);
                                                                  });
                                                            }),
                                                      SizedBox(
                                                          height: size.width *
                                                              0.02),
                                                      if (tripHistoryData
                                                                  .isLater ==
                                                              true &&
                                                          tripHistoryData
                                                                  .isCancelled ==
                                                              0)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child:
                                                              CustomSliderButton(
                                                            sliderIcon: Icon(
                                                              Icons
                                                                  .keyboard_double_arrow_right_rounded,
                                                              color: AppColors
                                                                  .white,
                                                              size: size.width *
                                                                  0.07,
                                                            ),
                                                            width: size.width *
                                                                0.8,
                                                            buttonName:
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .readyToPickup,
                                                            onSlideSuccess:
                                                                () async {
                                                              context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .add(OutstationReadyToPickupEvent(
                                                                      requestId:
                                                                          tripHistoryData
                                                                              .id));
                                                              return true;
                                                            },
                                                          ),
                                                        )
                                                    ],
                                                  )),
                                            )
                                          : Container())
                      ],
                    ),
                  )
                : const SizedBox(),
          );
        }),
      ),
    );
  }
}
