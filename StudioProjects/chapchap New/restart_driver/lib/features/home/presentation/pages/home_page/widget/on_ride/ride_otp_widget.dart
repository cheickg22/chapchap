import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class RideOtpWidget extends StatelessWidget {
  final BuildContext cont;
  const RideOtpWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = cont.read<HomeBloc>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: (userData!.onTripRequest != null &&
                userData!.onTripRequest!.transportType == 'delivery')
            ? AppLocalizations.of(context)!.shipmentVerification
            : AppLocalizations.of(context)!.rideVerification,
        automaticallyImplyLeading: true,
        titleFontSize: 18,
        onBackTap: () {
          if (homeBloc.showImagePick) {
            homeBloc.add(ShowImagePickEvent());
          } else {
            homeBloc.add(ShowOtpEvent());
          }
          Navigator.pop(context, userData);
        },
      ),
      body: BlocProvider.value(
        value: homeBloc,
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is RideStartSuccessState) {
              Navigator.pop(context, userData);
            }
            if (state is ShowSignatureState) {
              Navigator.pop(context, userData);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Container(
                height: size.height,
                width: size.width,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.2),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: size.width * 0.9,
                            height: size.width * 0.65,
                            padding: EdgeInsets.all(size.width * 0.05),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: (context.read<HomeBloc>().showImagePick)
                                ? _productImagePickerView(size, context)
                                : (userData!.onTripRequest!.showOtpFeature)
                                    ? Column(
                                        children: [
                                          SizedBox(height: size.width * 0.05),
                                          Row(
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .enterOtp,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.width * 0.05),
                                          SizedBox(
                                              width: size.width * 0.8,
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .enterRideOtpDesc,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                      fontSize: 14,
                                                    ),
                                                maxLines: 4,
                                              )),
                                          SizedBox(height: size.width * 0.05),
                                          _pinCodeView(context, size),
                                        ],
                                      )
                                    : const SizedBox(),
                          ),
                          if (userData!.onTripRequest != null &&
                              userData!.onTripRequest!.isTripStart == 0 &&
                              userData!.onTripRequest!.transportType ==
                                  'delivery' &&
                              userData!.onTripRequest!.enableShipmentLoad ==
                                  '1' &&
                              context.read<HomeBloc>().showOtp) ...[
                            _deliveryRideView(context, size),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                    _bottomActionView(context, size),
                    SizedBox(height: size.width * 0.1)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Column _productImagePickerView(
    Size size,
    BuildContext context,
  ) {
    return Column(
      children: [
        SizedBox(
            width: size.width * 0.8,
            child: MyText(
              text: AppLocalizations.of(context)!.uploadShipmentProof,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            )),
        SizedBox(
          height: size.width * 0.05,
        ),

        // Loading & unloading Image
        InkWell(
          onTap: () {
            context.read<HomeBloc>().add(ImageCaptureEvent());
          },
          child: SizedBox(
            height: size.width * 0.35,
            width: size.width * 0.35,
            child: DottedBorder(
                // color: AppColors.white.withAlpha((0.5 * 255).toInt()),
                color: Theme.of(context).hintColor,
                strokeWidth: 1,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(5),
                child: (context.read<HomeBloc>().loadImage == null &&
                        context.read<HomeBloc>().unloadImage == null)
                    ? SizedBox(
                        height: size.width * 0.35,
                        width: size.width * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload,
                              size: size.width * 0.05,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            SizedBox(
                              height: size.width * 0.025,
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!.dropImageHere,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      // color: AppColors.white
                                      //     .withAlpha((0.5 * 255).toInt()),
                                      color: Theme.of(context).hintColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: size.width * 0.025,
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .supportedImage
                                  .toString()
                                  .replaceAll('1111', 'jpg,png'),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      // color: AppColors.white
                                      //     .withAlpha((0.5 * 255).toInt()),
                                      color: Theme.of(context).hintColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      )
                    : Container(
                        height: size.width * 0.35,
                        width: size.width * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: (userData?.onTripRequest == null ||
                                  userData!.onTripRequest!.isTripStart == 0)
                              ? (context.read<HomeBloc>().showLoadImage != null
                                  ? DecorationImage(
                                      image: FileImage(File(context
                                          .read<HomeBloc>()
                                          .showLoadImage!)),
                                      fit: BoxFit.cover)
                                  : null)
                              : (context.read<HomeBloc>().showUnloadImage !=
                                      null
                                  ? DecorationImage(
                                      image: FileImage(File(context
                                          .read<HomeBloc>()
                                          .showUnloadImage!)),
                                      fit: BoxFit.cover)
                                  : null),
                        ),
                      )),
          ),
        ),
        SizedBox(
          height: size.width * 0.05,
        )
      ],
    );
  }

  Widget _bottomActionView(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: CustomButton(
          isLoader: context.read<HomeBloc>().isLoading,
          width: size.width,
          buttonName: AppLocalizations.of(context)!.continueText,
          textSize: 18,
          onTap: () {
            // context.read<HomeBloc>().currentLatLng= currentLatLng;
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (currentFocus.hasFocus) {
              currentFocus.unfocus();
            }
            if (userData!.onTripRequest != null &&
                userData!.onTripRequest!.isTripStart == 0) {
              if (context.read<HomeBloc>().rideOtp.text.isNotEmpty ||
                  context.read<HomeBloc>().showOtp == false) {
                if (userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.enableShipmentLoad == '1') {
                  if (context.read<HomeBloc>().showImagePick == false) {
                    context.read<HomeBloc>().add(ShowImagePickEvent());
                  } else {
                    if (userData!.onTripRequest == null ||
                        userData!.onTripRequest!.isTripStart == 0) {
                      if (context.read<HomeBloc>().loadImage != null) {
                        if (userData!.onTripRequest == null) {
                          context
                              .read<HomeBloc>()
                              .add(CreateInstantRideEvent());
                        } else {
                          context.read<HomeBloc>().add(UploadProofEvent(
                              image: context.read<HomeBloc>().loadImage!,
                              isBefore: false,
                              id: userData!.onTripRequest!.id));
                        }
                      }
                    } else {
                      if (context.read<HomeBloc>().unloadImage != null) {
                        Navigator.pop(context);
                        context.read<HomeBloc>().add(UploadProofEvent(
                            image: context.read<HomeBloc>().unloadImage!,
                            isBefore: false,
                            id: userData!.onTripRequest!.id));
                      }
                    }
                  }
                } else {
                  context.read<HomeBloc>().add(RideStartEvent(
                      requestId: userData!.onTripRequest!.id,
                      otp: context.read<HomeBloc>().rideOtp.text,
                      pickLat: userData!.onTripRequest!.pickLat,
                      pickLng: userData!.onTripRequest!.pickLng));
                  context.read<HomeBloc>().rideOtp.clear();
                }
              } else {
                showToast(message: AppLocalizations.of(context)!.enterOTPText);
              }
            } else if (userData!.onTripRequest != null &&
                userData!.onTripRequest!.transportType == 'delivery' &&
                userData!.onTripRequest!.enableShipmentLoad == '1' &&
                userData!.onTripRequest!.isTripStart == 1 &&
                userData!.onTripRequest!.showOtpFeature) {
              if (context.read<HomeBloc>().showOtp) {
                if (context.read<HomeBloc>().rideOtp.text.isNotEmpty) {
                  if (userData!.onTripRequest!.requestStops
                          .where((e) => e['completed_at'] == null)
                          .length >
                      1) {
                    context.read<HomeBloc>().add(StopVerifyOtpEvent(
                        otp: context.read<HomeBloc>().rideOtp.text,
                        stopId: context.read<HomeBloc>().choosenCompleteStop!));
                    context.read<HomeBloc>().rideOtp.clear();
                  } else if ((userData!.onTripRequest!.requestStops
                              .where((e) => e['completed_at'] == null)
                              .length ==
                          1) ||
                      userData!.onTripRequest!.requestStops.isEmpty) {
                    context.read<HomeBloc>().add(StopVerifyOtpEvent(
                        otp: context.read<HomeBloc>().rideOtp.text,
                        stopId: '',
                        requestId: userData!.onTripRequest!.id));
                    context.read<HomeBloc>().rideOtp.clear();
                  } else {
                    if (context.read<HomeBloc>().unloadImage != null) {
                      Navigator.pop(context);
                      context.read<HomeBloc>().add(UploadProofEvent(
                          image: context.read<HomeBloc>().unloadImage!,
                          isBefore: false,
                          id: userData!.onTripRequest!.id));
                    } else {
                      context.read<HomeBloc>().add(ShowImagePickEvent());
                    }
                  }
                } else {
                  showToast(
                      message: AppLocalizations.of(context)!.enterOTPText);
                }
              } else {
                if (context.read<HomeBloc>().unloadImage != null) {
                  Navigator.pop(context);
                  context.read<HomeBloc>().add(UploadProofEvent(
                      image: context.read<HomeBloc>().unloadImage!,
                      isBefore: false,
                      id: userData!.onTripRequest!.id));
                }
              }
            } else {
              if (context.read<HomeBloc>().unloadImage != null) {
                context.read<HomeBloc>().add(UploadProofEvent(
                    image: context.read<HomeBloc>().unloadImage!,
                    isBefore: false,
                    id: userData!.onTripRequest!.id));
              } else if (userData!.onTripRequest == null) {
                context.read<HomeBloc>().add(CreateInstantRideEvent());
              }
            }
          }),
    );
  }

  Widget _pinCodeView(BuildContext context, Size size) {
    return SizedBox(
      width: size.width * 0.7,
      child: PinCodeTextField(
        appContext: (context),
        length: 4,
        autoFocus: true,
        controller: context.read<HomeBloc>().rideOtp,
        textStyle: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Theme.of(context).disabledColor),
        obscureText: false,
        blinkWhenObscuring: false,
        animationType: AnimationType.none,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          fieldHeight: size.width * 0.13,
          fieldWidth: size.width * 0.13,
          activeFillColor: Theme.of(context).scaffoldBackgroundColor,
          inactiveFillColor: Theme.of(context).scaffoldBackgroundColor,
          inactiveColor: Theme.of(context).disabledColor,
          selectedFillColor: Theme.of(context).scaffoldBackgroundColor,
          selectedColor: Theme.of(context).disabledColor,
          selectedBorderWidth: 1,
          inactiveBorderWidth: 1,
          activeBorderWidth: 1,
          activeColor: Theme.of(context).disabledColor,
        ),
        cursorColor: Theme.of(context).dividerColor,
        // animationDuration:
        //     const Duration(milliseconds: 300),
        enableActiveFill: true,
        enablePinAutofill: false,
        autoDisposeControllers: false,
        keyboardType: TextInputType.number,
        boxShadows: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
        onChanged: (_) => context.read<HomeBloc>().add(UpdateEvent()),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }

  Widget _deliveryRideView(BuildContext context, Size size) {
    return Column(
      children: [
        SizedBox(
          height: size.width * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (context.read<HomeBloc>().showImagePick == false)
                      ? AppColors.primary
                      : Theme.of(context).disabledColor),
            ),
            SizedBox(
              width: size.width * 0.015,
            ),
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (context.read<HomeBloc>().showImagePick)
                      ? AppColors.primary
                      : Theme.of(context).disabledColor),
            )
          ],
        )
      ],
    );
  }
}
