import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_loader.dart';
import '../../../../../../../core/utils/custom_slider/custom_sliderbutton.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class OnrideCustomSliderButtonWidget extends StatelessWidget {
  final Size size;

  const OnrideCustomSliderButtonWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                if (userData!.onTripRequest!.isPaid == 0 &&
                    userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.paidAt == 'Sender' &&
                    userData!.onTripRequest!.paymentType != 'cash' &&
                    userData!.onTripRequest!.paymentType != 'wallet' &&
                    (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt!.isNotEmpty))
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.waitingForPayment,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: size.width * 0.05,
                          width: size.width * 0.05,
                          child: Loader(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        )
                      ],
                    ),
                  ),
                if (userData!.onTripRequest!.isPaid == 0 &&
                    !userData!.onTripRequest!.isRental &&
                    userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.paidAt == 'Sender' &&
                    userData!.onTripRequest!.paymentType == 'cash' &&
                    (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt!.isNotEmpty))
                  CustomButton(
                    buttonName: AppLocalizations.of(context)!.paymentRecieved,
                    textSize: 18,
                    onTap: () {
                      if (userData!.onTripRequest!.paymentOpt == '1' &&
                          userData!.onTripRequest!.isPaid == 0) {
                        context.read<HomeBloc>().add(PaymentRecievedEvent());
                      }
                    },
                  ),
                if (((((userData!.onTripRequest!.isPaid == 1 &&
                                    userData!.onTripRequest!.paidAt ==
                                        'Sender') ||
                                userData!.onTripRequest!.paidAt ==
                                    'Receiver') &&
                            userData!.onTripRequest!.transportType ==
                                'delivery') ||
                        (userData!.onTripRequest!.isRental &&
                            userData!.onTripRequest!.transportType ==
                                'delivery')) ||
                    userData!.onTripRequest!.arrivedAt == null ||
                    userData!.onTripRequest!.transportType == 'taxi')
                  CustomSliderButton(
                    isLoader: context.read<HomeBloc>().isLoading,
                    sliderIcon: Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.white,
                      size: size.width * 0.07,
                    ),
                    buttonName: (userData!.onTripRequest!.arrivedAt == null)
                        ? AppLocalizations.of(context)!.arrived
                        : (userData!.onTripRequest!.isTripStart == 0)
                            ? (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.startRide
                                : AppLocalizations.of(context)!.pickGoods
                            : (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.endRide
                                : AppLocalizations.of(context)!.dispatchGoods,
                    onSlideSuccess: () async {
                      if (userData != null && userData!.onTripRequest != null) {
                        if (userData!.onTripRequest!.requestStops.isNotEmpty &&
                            userData!.onTripRequest!.isTripStart == 1 &&
                            userData!.onTripRequest!.requestStops
                                    .where((e) => e['completed_at'] == null)
                                    .length >
                                1) {
                          context.read<HomeBloc>().add(ShowChooseStopEvent());
                        } else if (userData!.onTripRequest!.arrivedAt == null) {
                          context.read<HomeBloc>().add(RideArrivedEvent(
                              requestId: userData!.onTripRequest!.id));
                        } else if (userData!.onTripRequest!.isTripStart == 0) {
                          if (userData!.onTripRequest!.showOtpFeature == true) {
                            context.read<HomeBloc>().add(ShowOtpEvent());
                          } else {
                            if (userData!.onTripRequest!.transportType ==
                                    'delivery' &&
                                userData!.onTripRequest!.enableShipmentLoad ==
                                    '1') {
                              context
                                  .read<HomeBloc>()
                                  .add(ShowImagePickEvent());
                            } else {
                              context.read<HomeBloc>().add(RideStartEvent(
                                  requestId: userData!.onTripRequest!.id,
                                  otp: '',
                                  pickLat: userData!.onTripRequest!.pickLat,
                                  pickLng: userData!.onTripRequest!.pickLng));
                            }
                          }
                        } else {
                          if (userData!.onTripRequest!.transportType ==
                                  'delivery' &&
                              userData!.onTripRequest!.enableShipmentUnload ==
                                  '1') {
                            if (userData!.onTripRequest!.showOtpFeature ==
                                true) {
                              context.read<HomeBloc>().add(ShowOtpEvent());
                            } else {
                              context
                                  .read<HomeBloc>()
                                  .add(ShowImagePickEvent());
                            }
                          } else if (userData!.onTripRequest!.transportType ==
                                  'delivery' &&
                              userData!.onTripRequest!.enableDigitalSignature ==
                                  '1') {
                            context.read<HomeBloc>().add(ShowSignatureEvent());
                          } else {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (builder) {
                                  return AlertDialog(
                                    title: MyText(
                                      text:
                                          AppLocalizations.of(context)!.endRide,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(fontSize: 16),
                                    ),
                                    content: MyText(
                                      text: AppLocalizations.of(context)!
                                          .rideEndConfirmationText,
                                      maxLines: 5,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!,
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    actionsPadding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16),
                                    actions: [
                                      CustomButton(
                                          width: size.width * 0.3,
                                          textSize: 18,
                                          buttonName:
                                              AppLocalizations.of(context)!.no,
                                          buttonColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          textColor: AppColors.buttonColor,
                                          border: Border.all(
                                              color: AppColors.buttonColor),
                                          onTap: () {
                                            Navigator.pop(context);
                                            context
                                                .read<HomeBloc>()
                                                .add(UpdateEvent());
                                          }),
                                      CustomButton(
                                          width: size.width * 0.3,
                                          textSize: 18,
                                          buttonName:
                                              AppLocalizations.of(context)!
                                                  .endRide,
                                          onTap: () {
                                            Navigator.pop(context);
                                            if (userData!
                                                        .onTripRequest!.isRental ==
                                                    false &&
                                                userData!.onTripRequest!
                                                        .isOutstation !=
                                                    1 &&
                                                userData!.onTripRequest!
                                                        .dropAddress !=
                                                    null) {
                                              context.read<HomeBloc>().add(
                                                  RideEndEvent(
                                                      isAfterGeoCodeEnd: false,
                                                      isAfterRoutesDistanceCall:
                                                          false));
                                            } else {
                                              context.read<HomeBloc>().add(
                                                  GeocodingLatLngEvent(
                                                      lat: context
                                                          .read<HomeBloc>()
                                                          .currentLatLng!
                                                          .latitude,
                                                      lng: context
                                                          .read<HomeBloc>()
                                                          .currentLatLng!
                                                          .longitude));
                                            }
                                          })
                                    ],
                                  );
                                });
                          }
                        }
                        return true;
                      }
                      return null;
                    },
                  ),
                if (userData!.onTripRequest!.isTripStart == 0 &&
                    userData!.onTripRequest!.isPaid == 0) ...[
                  SizedBox(height: size.width * 0.05),
                  InkWell(
                    onTap: () {
                      context.read<HomeBloc>().add(GetCancelReasonEvent());
                    },
                    child: MyText(
                        text: AppLocalizations.of(context)!.cancelRide,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: AppColors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )),
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
