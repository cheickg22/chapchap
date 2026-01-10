import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class UploadShipmentProofWidget extends StatelessWidget {
  const UploadShipmentProofWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          height: size.height,
          width: size.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              CustomAppBar(
                title: AppLocalizations.of(context)!.shipmentVerification,
                automaticallyImplyLeading: true,
              ),
              SizedBox(height: size.width * 0.2),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: size.width * 0.9,
                        height: size.width * 0.65,
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.white,
                            border: Border.all(
                                color: Theme.of(context).disabledColor)),
                        child: Column(
                          children: [
                            SizedBox(
                                width: size.width * 0.8,
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .uploadShipmentProof,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: AppColors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                )),
                            SizedBox(height: size.width * 0.05),
                            InkWell(
                              onTap: () {
                                context
                                    .read<HomeBloc>()
                                    .add(ImageCaptureEvent());
                              },
                              child: SizedBox(
                                height: size.width * 0.35,
                                width: size.width * 0.35,
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColorDark,
                                  strokeWidth: 1,
                                  dashPattern: const [6, 3],
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(5),
                                  child: (context.read<HomeBloc>().loadImage ==
                                              null &&
                                          context.read<HomeBloc>().unloadImage ==
                                              null)
                                      ? SizedBox(
                                          height: size.width * 0.35,
                                          width: size.width * 0.35,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.upload,
                                                size: size.width * 0.05,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .dropImageHere,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                height: size.width * 0.025,
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .supportedImage
                                                    .toString()
                                                    .replaceAll(
                                                        '1111', 'jpg,png'),
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: size.width * 0.35,
                                          width: size.width * 0.35,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: (context
                                                              .read<HomeBloc>()
                                                              .showLoadImage !=
                                                          null ||
                                                      context
                                                              .read<HomeBloc>()
                                                              .showUnloadImage !=
                                                          null)
                                                  ? ((userData!.onTripRequest ==
                                                                  null ||
                                                              userData!
                                                                      .onTripRequest!
                                                                      .isTripStart ==
                                                                  0) &&
                                                          context.read<HomeBloc>().showLoadImage !=
                                                              null)
                                                      ? DecorationImage(
                                                          image: FileImage(File(context.read<HomeBloc>().showLoadImage!)),
                                                          fit: BoxFit.cover)
                                                      : (context.read<HomeBloc>().showUnloadImage != null)
                                                          ? DecorationImage(image: FileImage(File(context.read<HomeBloc>().showUnloadImage!)), fit: BoxFit.cover)
                                                          : null
                                                  : null)),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * 0.05)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.05),
              CustomButton(
                  width: size.width * 0.8,
                  buttonName: AppLocalizations.of(context)!.continueText,
                  onTap: () {
                    if (userData!.onTripRequest == null ||
                        userData!.onTripRequest!.isTripStart == 0) {
                      if (context.read<HomeBloc>().loadImage != null) {
                        Navigator.pop(context);
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
                  }),
              SizedBox(height: size.width * 0.05)
            ],
          ),
        );
      },
    );
  }
}
