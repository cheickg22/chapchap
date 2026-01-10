import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_snack_bar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
              SizedBox(
                width: size.width * 0.9,
                child: MyText(
                  text: AppLocalizations.of(context)!.submitNecessaryDocs,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black.withAlpha((0.5 * 255).toInt()),
                      ),
                  maxLines: 2,
                ),
              ),
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
                          Row(
                            children: [
                              Container(
                                height: size.width * 0.04,
                                width: size.width * 0.04,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.black, width: 2)),
                                alignment: Alignment.center,
                                child: Container(
                                  height: size.width * 0.02,
                                  width: size.width * 0.02,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.black),
                                ),
                              ),
                              SizedBox(width: size.width * 0.025),
                              Expanded(
                                  child: MyText(
                                text: driverBloc.neededDocuments[i]
                                    .name,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 18,
                                      color: AppColors.blackText,
                                    ),
                              ))
                            ],
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: size.width * 0.02),
                                Column(
                                  children: [
                                    for (var k = 0; k < 20; k++)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 2),
                                        height: 3,
                                        width: 1,
                                        color: (i != driverBloc.neededDocuments
                                                        .length -
                                                    1)
                                            ? AppColors.darkGrey
                                            : Colors.transparent,
                                      )
                                  ],
                                ),
                                SizedBox(width: size.width * 0.05),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: InkWell(
                                      onTap: () {
                                        // final edit = driverBloc
                                        //                     .neededDocuments[i]
                                        //                     .isEditable;
                                        final upload = driverBloc.neededDocuments[i]
                                                            .isUploaded;                    
                                        driverBloc.add(
                                            EnableEditEvent(
                                                isEditable: (!upload)
                                                    ? true
                                                    : false));
                                        driverBloc.add(
                                            ChooseDocumentEvent(
                                                id: driverBloc.neededDocuments[i]
                                                    .id));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            size.width * 0.05,
                                            0,
                                            size.width * 0.05,
                                            0),
                                        height: size.width * 0.14,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.darkGrey),
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            color: AppColors.darkGrey
                                                .withAlpha((0.1 * 255).toInt())),
                                        child: (driverBloc.neededDocuments[i]
                                                    .document !=
                                                null)
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: MyText(
                                                      text: driverBloc.neededDocuments[i]
                                                              .document!['data']
                                                          [
                                                          'document_status_string'],
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                                color: AppColors
                                                                    .blackText,
                                                              ),
                                                    ),
                                                  )
                                                ],
                                              )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .upload,
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
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.025),
                                                      Icon(
                                                        Icons.cloud_upload,
                                                        color: AppColors.black
                                                            .withAlpha((0.5 * 255).toInt()),
                                                        size: size.width * 0.05,
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
                    },),
                ],
              ),
              SizedBox(height: size.width * 0.05),
              if ((driverBloc.showSubmitButton && arg.from != 'docs') ||
                  (driverBloc.fleetId != null && arg.from != 'docs'))
                Column(
                  children: [
                    CustomButton(
                        buttonName: AppLocalizations.of(context)!.submit,
                        onTap: () {
                          if (context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .any((doc) => (doc.isRequired && !doc.isUploaded))) {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .documentMissingText); 
                          } else {
                            if (driverBloc.fleetId !=
                                null) {
                              Navigator.pop(context);
                              driverBloc.add(DriverUpdateEvent());
                            } else {
                              driverBloc.reUploadDocument = false; 
                              driverBloc.add(ModifyDocEvent());
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
