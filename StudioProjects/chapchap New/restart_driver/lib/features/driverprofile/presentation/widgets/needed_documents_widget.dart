import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/common.dart';

class NeededDocumentsWidget extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments arg;
  const NeededDocumentsWidget(
      {super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();
          return Column(
            children: [
              SizedBox(height: size.width * 0.05),
              Column(
                children: [
                  ListView.builder(
                    itemCount: driverBloc.neededDocuments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, i) {
                      return SizedBox(
                        width: size.width * 0.9,
                        child: Column(
                          children: [
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (driverBloc.neededDocuments[i].document !=
                                          null)
                                      ? Image.asset(
                                          ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'waiting_for_approval' ||
                                                      driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'reuploaded_and_waiting_for_approval') ||
                                                  (driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'Waiting For Approval' ||
                                                      driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'Reuploaded and Waiting For Approval'))
                                              ? AppImages.circleClock
                                              : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'uploaded_and_approved') ||
                                                      (driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                          'Uploaded and Approved'))
                                                  ? AppImages.circleCheck
                                                  : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                              'reuploaded_and_declined') ||
                                                          (driverBloc.neededDocuments[i].document!['data']
                                                                  ['document_status_string'] ==
                                                              'Reuploaded and Declined'))
                                                      ? AppImages.circleCancel
                                                      : AppImages.circle,
                                          fit: BoxFit.contain,
                                          width: size.width * 0.05,
                                        )
                                      : Image.asset(
                                          AppImages.circle,
                                          fit: BoxFit.contain,
                                          width: size.width * 0.05,
                                        ),
                                  SizedBox(
                                    width: size.width * 0.025,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: InkWell(
                                        onTap: () {
                                          final upload = driverBloc
                                              .neededDocuments[i].isUploaded;
                                          driverBloc.add(EnableEditEvent(
                                              isEditable:
                                                  (!upload) ? true : false));
                                          driverBloc.add(ChooseDocumentEvent(
                                              id: driverBloc
                                                  .neededDocuments[i].id));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              size.width * 0.05,
                                              0,
                                              size.width * 0.05,
                                              0),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                const BoxShadow(
                                                    color:
                                                        AppColors.borderColors,
                                                    spreadRadius: 0.25,
                                                    blurRadius: 0.25,
                                                    offset: Offset(0, 0))
                                              ]),
                                          child: (driverBloc.neededDocuments[i]
                                                      .document !=
                                                  null)
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: size.width * 0.05,
                                                    ),
                                                    MyText(
                                                      text: driverBloc
                                                          .neededDocuments[i]
                                                          .name,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'waiting_for_approval' ||
                                                                      driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'reuploaded_and_waiting_for_approval') ||
                                                                  (driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'Waiting For Approval' ||
                                                                      driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'Reuploaded and Waiting For Approval'))
                                                              ? AppImages
                                                                  .circleClock
                                                              : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'uploaded_and_approved') ||
                                                                      (driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                          'Uploaded and Approved'))
                                                                  ? AppImages
                                                                      .circleCheck
                                                                  : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined') ||
                                                                          (driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                              'Reuploaded and Declined'))
                                                                      ? AppImages
                                                                          .circleCancel
                                                                      : AppImages.circle,
                                                          fit: BoxFit.contain,
                                                          width:
                                                              size.width * 0.04,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.02,
                                                        ),
                                                        Expanded(
                                                          child: MyText(
                                                            text: driverBloc
                                                                    .neededDocuments[
                                                                        i]
                                                                    .document!['data']
                                                                [
                                                                'document_status_string'],
                                                            textStyle:
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'waiting_for_approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_waiting_for_approval') ||
                                                                              (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Waiting For Approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Waiting For Approval'))
                                                                          ? AppColors.waitingForApprovel
                                                                          : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'uploaded_and_approved') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Uploaded and Approved'))
                                                                              ? AppColors.uploadedAndApproved
                                                                              : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Declined'))
                                                                                  ? AppColors.uploadedAndDeclined
                                                                                  : AppColors.waitingForApprovel,
                                                                    ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    CustomButton(
                                                        width: size.width,
                                                        buttonColor: ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'waiting_for_approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_waiting_for_approval') ||
                                                                (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Waiting For Approval' ||
                                                                    driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                        'Reuploaded and Declined' ||
                                                                    driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                        'Reuploaded and Waiting For Approval'))
                                                            ? AppColors.white
                                                            : AppColors
                                                                .borderColor,
                                                        textColor:
                                                            AppColors.black,
                                                        textSize: 14,
                                                        border: Border.all(
                                                            width: 1,
                                                            color: ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'waiting_for_approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_waiting_for_approval') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Waiting For Approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Declined' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Waiting For Approval'))
                                                                ? AppColors.grey
                                                                : AppColors
                                                                    .borderColor),
                                                        leading: ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_waiting_for_approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'waiting_for_approval') ||
                                                                (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Waiting For Approval' ||
                                                                    driverBloc.neededDocuments[i].document!['data']['document_status_string'] ==
                                                                        'Reuploaded and Declined' ||
                                                                    driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Waiting For Approval'))
                                                            ? Image.asset(
                                                                AppImages
                                                                    .refreshCcw,
                                                                width:
                                                                    size.width *
                                                                        0.05,
                                                              )
                                                            : null,
                                                        buttonName: ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'waiting_for_approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_declined') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Waiting For Approval' || driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Declined'))
                                                            ? AppLocalizations.of(context)!.reuploadDocument
                                                            : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'uploaded_and_approved') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Uploaded and Approved'))
                                                                ? AppLocalizations.of(context)!.viewDocument
                                                                : ((driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'reuploaded_and_waiting_for_approval') || (driverBloc.neededDocuments[i].document!['data']['document_status_string'] == 'Reuploaded and Waiting For Approval'))
                                                                    ? AppLocalizations.of(context)!.reuploadDocument
                                                                    : AppLocalizations.of(context)!.viewDocument,
                                                        onTap: () {
                                                          final upload = driverBloc
                                                              .neededDocuments[
                                                                  i]
                                                              .isUploaded;
                                                          driverBloc.add(
                                                              EnableEditEvent(
                                                                  isEditable:
                                                                      (!upload)
                                                                          ? true
                                                                          : false));
                                                          driverBloc.add(
                                                              ChooseDocumentEvent(
                                                                  id: driverBloc
                                                                      .neededDocuments[
                                                                          i]
                                                                      .id));
                                                        }),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    )
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: size.width * 0.05,
                                                    ),
                                                    MyText(
                                                      text: driverBloc
                                                          .neededDocuments[i]
                                                          .name,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 18,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          AppImages.circle,
                                                          fit: BoxFit.contain,
                                                          width:
                                                              size.width * 0.04,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.02,
                                                        ),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .notUploaded,
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    CustomButton(
                                                        width: size.width,
                                                        buttonColor:
                                                            AppColors.primary,
                                                        textColor:
                                                            AppColors.white,
                                                        textSize: 14,
                                                        leading: Image.asset(
                                                          AppImages.cloudUpload,
                                                          fit: BoxFit.contain,
                                                          width:
                                                              size.width * 0.05,
                                                        ),
                                                        buttonName:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .uploadDocuments,
                                                        onTap: () {
                                                          final upload = driverBloc
                                                              .neededDocuments[
                                                                  i]
                                                              .isUploaded;
                                                          driverBloc.add(
                                                              EnableEditEvent(
                                                                  isEditable:
                                                                      (!upload)
                                                                          ? true
                                                                          : false));
                                                          driverBloc.add(
                                                              ChooseDocumentEvent(
                                                                  id: driverBloc
                                                                      .neededDocuments[
                                                                          i]
                                                                      .id));
                                                        }),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    )
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.05)
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: size.width * 0.05),
              if ((driverBloc.showSubmitButton && arg.from != 'docs') ||
                  (driverBloc.fleetId != null && arg.from != 'docs'))
                Column(
                  children: [
                    CustomButton(
                        buttonName: AppLocalizations.of(context)!.submit,
                        width: size.width * 0.9,
                        textSize: 18,
                        onTap: () {
                          if (context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .any((doc) =>
                                  (doc.isRequired && !doc.isUploaded))) {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .documentMissingText);
                          } else {
                            if (driverBloc.fleetId != null) {
                              Navigator.pop(context);
                              driverBloc.add(DriverUpdateEvent());
                            } else {
                              driverBloc.reUploadDocument = false;
                              driverBloc.add(ModifyDocEvent());
                              driverBloc.add(DriverGetUserDetailsEvent());
                            }
                          }
                        }),
                    SizedBox(height: size.width * 0.05),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
