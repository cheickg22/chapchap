import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/custom_textfield.dart';
import 'package:restart_user/core/utils/extensions.dart';
import 'package:restart_user/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_user/features/driverprofile/presentation/widgets/image_picker_dialog.dart';
import 'package:restart_user/l10n/app_localizations.dart';

class EditDocumentWidget extends StatelessWidget {
  final BuildContext cont;
  const EditDocumentWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();
          return driverBloc.neededDocuments.isEmpty
          ? const SizedBox()
          : SafeArea(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.05),
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () {
                              // final edit = driverBloc.neededDocuments
                              //     .firstWhere((e) =>
                              //         e.id == driverBloc.choosenDocument)
                              //     .isEditable;
                              final upload = driverBloc.neededDocuments
                                  .firstWhere((e) =>
                                      e.id ==
                                      driverBloc.choosenDocument)
                                  .isUploaded;

                              if ((upload)) {
                                driverBloc.add(EnableEditEvent(isEditable: false));
                              } else {
                                driverBloc.add(ChooseDocumentEvent(id: null));
                              }
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: size.width * 0.07,
                              color: AppColors.blackText,
                            )),
                        SizedBox(width: size.width * 0.05),
                        Expanded(
                            child: MyText(
                          text:
                              '${AppLocalizations.of(context)!.upload} ${driverBloc.neededDocuments.firstWhere((e) => e.id == driverBloc.choosenDocument).name}',
                          textStyle:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 18,
                                    color: AppColors.blackText,
                                  ),
                        ))
                      ],
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.width * 0.1),
                        InkWell(
                          onTap: () {
                            if(driverBloc.neededDocuments
                                            .firstWhere((e) =>
                                                e.id ==
                                                driverBloc.choosenDocument)
                                            .isEditable ==
                                        true ||
                                    driverBloc.isEditable) {
                              showModalBottomSheet(
                                    isScrollControlled: false,
                                    context: context,
                                    useSafeArea: true,
                                    builder: (_) {
                                      return SafeArea(
                                        child: ImagePickerDialog(
                                          size: size.width,
                                          onImageSelected:
                                              (ImageSource source) {
                                           driverBloc.add(
                                                  PickImageEvent(
                                                      source: source,
                                                      isFront: true),
                                                );
                                          },
                                        ),
                                      );
                                    });
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: driverBloc.neededDocuments
                                      .firstWhere((e) =>
                                          e.id ==
                                          driverBloc.choosenDocument)
                                      .isFrontAndBack ==
                                  true
                                    ? '${driverBloc.neededDocuments.firstWhere((e) => e.id == driverBloc.choosenDocument).name} Front'
                                    : driverBloc.neededDocuments.firstWhere((e) => e.id == driverBloc.choosenDocument).name,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      color: AppColors.blackText,
                                    ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              SizedBox(
                                height: size.width * 0.5,
                                width: size.width * 0.8,
                                child: DottedBorder(
                                  color: AppColors.darkGrey,
                                  strokeWidth: 2,
                                  dashPattern: const [6, 3],
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(5),
                                  child: (driverBloc.docImage ==
                                          null)
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt,
                                                color: AppColors.black
                                                    .withAlpha((0.5 * 255).toInt()),
                                                size: size.width * 0.07,
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.025),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .tapToUploadImage,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 15,
                                                      color: AppColors.black
                                                          .withAlpha((0.5 * 255).toInt()),
                                                    ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: size.width * 0.5,
                                          width: size.width * 0.8,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(driverBloc.docImage!),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                                5), // Matching borderRadius
                                          ),
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: driverBloc.neededDocuments
                                      .firstWhere((e) =>
                                          e.id ==
                                          driverBloc.choosenDocument)
                                      .isFrontAndBack ==
                                  true
                              ? size.width * 0.05
                              : size.width * 0,
                        ),
                        driverBloc.neededDocuments
                                    .firstWhere((e) =>
                                        e.id ==
                                        driverBloc.choosenDocument)
                                    .isFrontAndBack ==
                                true
                            ? InkWell(
                                onTap: () {
                                  if(driverBloc.neededDocuments
                                              .firstWhere((e) =>
                                                  e.id ==
                                                  driverBloc.choosenDocument)
                                              .isEditable ==
                                          true ||
                                    driverBloc.isEditable) {
                                    showModalBottomSheet(
                                          isScrollControlled: false,
                                          context: context,
                                          useSafeArea: true,
                                          builder: (builder) {
                                            return ImagePickerDialog(
                                              size: size.width,
                                              onImageSelected:
                                                  (ImageSource source) {
                                                driverBloc.add(
                                                      PickImageEvent(
                                                          source: source,
                                                          isFront: false),
                                                    );
                                              },
                                            );
                                          });
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text:
                                          '${driverBloc.neededDocuments.firstWhere((e) => e.id == driverBloc.choosenDocument).name} Back',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontSize: 18,
                                            color: AppColors.blackText,
                                          ),
                                    ),
                                    SizedBox(height: size.width * 0.01),
                                    SizedBox(
                                      height: size.width * 0.5,
                                      width: size.width * 0.8,
                                      child: DottedBorder(
                                        color: AppColors.darkGrey,
                                        strokeWidth: 2,
                                        dashPattern: const [6, 3],
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(5),
                                        child: (driverBloc.docImageBack ==
                                                null)
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.camera_alt,
                                                      color: AppColors.black
                                                          .withAlpha((0.5 * 255).toInt()),
                                                      size: size.width * 0.07,
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.width * 0.025),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .tapToUploadImage,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 15,
                                                                color: AppColors
                                                                    .black
                                                                    .withAlpha((0.5 * 255).toInt()),
                                                              ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                height: size.width * 0.5,
                                                width: size.width * 0.8,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                      File(driverBloc.docImageBack!),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        if (driverBloc.neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                driverBloc.choosenDocument)
                            .hasIdNumer)
                          Column(
                            children: [
                              SizedBox(height: size.width * 0.07),
                              SizedBox(
                                width: size.width * 0.9,
                                child: MyText(
                                  text:driverBloc.neededDocuments
                                      .firstWhere((e) =>
                                          e.id ==
                                          driverBloc.choosenDocument)
                                      .idKey,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 16,
                                        color: AppColors.blackText,
                                      ),
                                ),
                              ),
                              SizedBox(height: size.width * 0.05),
                              Container(
                                color: AppColors.darkGrey.withAlpha((0.1 * 255).toInt()),
                                child: CustomTextField(
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 16,
                                        color: AppColors.blackText,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.darkGrey, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.darkGrey, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.black.withAlpha((0.5 * 255).toInt()),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  controller: driverBloc.documentId,
                                  hintText: driverBloc.neededDocuments
                                      .firstWhere((e) =>
                                          e.id ==
                                          driverBloc.choosenDocument)
                                      .idKey,
                                ),
                              )
                            ],
                          ),
                        if (driverBloc.neededDocuments
                            .firstWhere((e) =>
                                e.id ==
                                driverBloc.choosenDocument)
                            .hasExpiryDate)
                          Column(
                            children: [
                              SizedBox(height: size.width * 0.07),
                              SizedBox(
                                width: size.width * 0.9,
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .chooseExpiryDate,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 16,
                                        color: AppColors.blackText,
                                      ),
                                ),
                              ),
                              SizedBox(height: size.width * 0.05),
                              InkWell(
                                onTap: () {
                                  driverBloc.add(ChooseDateEvent(context: context));
                                },
                                child: Container(
                                  color: AppColors.darkGrey.withAlpha((0.1 * 255).toInt()),
                                  child: CustomTextField(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontSize: 16,
                                          color: AppColors.blackText,
                                        ),
                                    enabled: false,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.darkGrey, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.darkGrey, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.darkGrey, width: 1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    controller:driverBloc.documentExpiry,
                                    hintText:
                                        '${driverBloc.neededDocuments.firstWhere((e) => e.id == driverBloc.choosenDocument).name} ${AppLocalizations.of(context)!.expiryDate}',
                                  ),
                                ),
                              )
                            ],
                          ),
                        SizedBox(height: size.width * 0.05),
                      ],
                    ),
                  )),
                  CustomButton(
                      buttonName: AppLocalizations.of(context)!.submit,
                      onTap: () {
                        if (driverBloc.docImage !=
                                null &&
                            (driverBloc.neededDocuments
                                        .firstWhere((e) =>
                                            e.id ==
                                            driverBloc.choosenDocument)
                                        .hasExpiryDate ==
                                    false ||
                                driverBloc.documentExpiry
                                    .text
                                    .isNotEmpty) &&
                            (driverBloc.neededDocuments
                                        .firstWhere((e) =>
                                            e.id ==
                                            driverBloc.choosenDocument)
                                        .hasIdNumer ==
                                    false ||
                                driverBloc.documentId
                                    .text
                                    .isNotEmpty)) {
                          driverBloc.add(
                              UploadDocumentEvent(
                                  id:driverBloc.choosenDocument!,
                                  fleetId: driverBloc.fleetId));
                        } else {
                          context.showSnackBar(
                              color: AppColors.red,
                              message: AppLocalizations.of(context)!
                                  .enterRequiredField);
                        }
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
