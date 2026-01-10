import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_header.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/document_view_widget.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/edit_document_widget.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/needed_documents_widget.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/vehicle_information_widget.dart';

import 'package:restart_tagxi/features/home/presentation/pages/home_page/page/home_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../core/utils/custom_button.dart';
import '../widgets/document_declined_widget.dart';
import '../widgets/needed_documents_shimmer.dart';

class DriverProfilePage extends StatelessWidget {
  static const String routeName = '/driverProfilePage';
  final VehicleUpdateArguments args;

  const DriverProfilePage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return builderWidget(size, args);
  }
}

Widget builderWidget(Size size, VehicleUpdateArguments? args) {
  return BlocProvider(
    create: (context) => DriverProfileBloc()
      ..add(GetInitialDataEvent(from: args!.from, fleetId: args.fleetId))
      ..add(DriverGetUserDetailsEvent())
      ..add(ModifyDocEvent())
      ..add(GetServiceLocationEvent(
          type: userData!.enableModulesForApplications != 'both'
              ? userData!.enableModulesForApplications
              : 'both')),
    child: BlocListener<DriverProfileBloc, DriverProfileState>(
        listener: (context, state) {
      if (state is LoadingStartState) {
        CustomLoader.loader(context);
      } else if (state is LoadingStopState) {
        CustomLoader.dismiss(context);
      } else if (state is VehicleUpdateSuccessState) {
        Navigator.pop(context, true);
      } else if (state is VehicleAddedState) {
        Navigator.pop(context, true);
      } else if (state is ShowErrorState) {
        context.showSnackBar(color: AppColors.red, message: state.message);
      }
      if (context.read<DriverProfileBloc>().approved) {
        if (args!.from == '' || args.from == 'rejected') {
          if (context.read<DriverProfileBloc>().approvalStream != null) {
            context.read<DriverProfileBloc>().approvalStream?.cancel();
            context.read<DriverProfileBloc>().approvalStream = null;
          }
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.routeName, (route) => false);
        }
      }
    }, child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
            builder: (context, state) {
      return SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              ((context.read<DriverProfileBloc>().choosenDocument != null &&
                      context.read<DriverProfileBloc>().isEditable))
                  ? EditDocumentWidget(cont: context)
                  : (context.read<DriverProfileBloc>().choosenDocument !=
                              null &&
                          !context.read<DriverProfileBloc>().isEditable)
                      ? DocumentViewWidget(cont: context)
                      : (args!.from == 'vehicle' || args.from == 'owner')
                          ? SizedBox(
                              height: size.height,
                              width: size.width,
                              child: Column(
                                children: [
                                  CustomHeader(
                                    title: (args.from == 'owner')
                                        ? AppLocalizations.of(context)!
                                            .addNewVehicle
                                        : AppLocalizations.of(context)!
                                            .modifyVehicleInfo,
                                    automaticallyImplyLeading: true,
                                    titleFontSize: 18,
                                  ),
                                  SizedBox(height: size.width * 0.06),
                                  Expanded(
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: [
                                        SizedBox(height: size.width * 0.06),
                                        VehicleInformationWidget(
                                            cont: context, args: args),
                                      ],
                                    )),
                                  ),
                                ],
                              ))
                          : (args.from == 'docs')
                              ? SizedBox(
                                  height: size.height,
                                  width: size.width,
                                  child: SingleChildScrollView(
                                      child: Column(
                                    children: [
                                      CustomHeader(
                                        title: AppLocalizations.of(context)!
                                            .documents,
                                        automaticallyImplyLeading: true,
                                        titleFontSize: 18,
                                        textColor:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      context
                                              .read<DriverProfileBloc>()
                                              .isLoading
                                          ? neededDocumentsShimmer(
                                              size, context)
                                          : NeededDocumentsWidget(
                                              cont: context, arg: args)
                                    ],
                                  )))
                              : Container(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.025),
                                  height: size.height,
                                  width: size.width,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity, // full width
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.height * 0.015),
                                        margin: EdgeInsets.only(
                                            bottom: size.height * 0.02),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppColors
                                                  .borderColors, // change to AppColors.borderColor
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            (userData!.role == 'driver')
                                                ? MyText(
                                                    text: (userData!
                                                                .serviceLocationId !=
                                                            '')
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .documents
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .vehicleInfo,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          fontSize: 20,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                  )
                                                : MyText(
                                                    text: (userData!
                                                                .serviceLocationId !=
                                                            '')
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .documents
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .companyInfo,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          fontSize: 20,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      if (userData!.uploadedDocument == false)
                                        Padding(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          child: SizedBox(
                                            child: (userData!
                                                        .serviceLocationId !=
                                                    '')
                                                ? MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .necessaryDocument,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor),
                                                    maxLines: 3,
                                                  )
                                                : MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .completeYourRegistration,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor),
                                                    maxLines: 3,
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      if (userData!.uploadedDocument == false)
                                        SizedBox(height: size.width * 0.05),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child:
                                              (userData!.serviceLocationId ==
                                                      '')
                                                  ? VehicleInformationWidget(
                                                      cont: context, args: args)
                                                  : (context.read<DriverProfileBloc>().isRejected &&
                                                          !context
                                                              .read<
                                                                  DriverProfileBloc>()
                                                              .reUploadDocument &&
                                                          !userData!
                                                              .available &&
                                                          userData!.declinedReason !=
                                                              '')
                                                      ? DocumentDeclinedWidget(
                                                          cont: context)
                                                      : ((((userData!.uploadedDocument ==
                                                                      true &&
                                                                  !context
                                                                      .read<
                                                                          DriverProfileBloc>()
                                                                      .modifyDocument &&
                                                                  !context
                                                                      .read<
                                                                          DriverProfileBloc>()
                                                                      .modifyDocument &&
                                                                  context.read<DriverProfileBloc>().neededDocuments.every((doc) =>
                                                                      doc.document !=
                                                                          null &&
                                                                      userData!
                                                                              .declinedReason ==
                                                                          '')) &&
                                                              context.read<DriverProfileBloc>().uploadDocs ==
                                                                  false)
                                                          ? SizedBox(
                                                              height:
                                                                  size.width *
                                                                      1.75,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .all(size
                                                                            .width *
                                                                        0.05),
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            AppImages.pendingApproval,
                                                                            height:
                                                                                size.width * 0.7,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                size.width * 0.05,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.all(size.width * 0.05),
                                                                            decoration: BoxDecoration(
                                                                                color: AppColors.redBackground,
                                                                                border: Border.all(
                                                                                  width: 1,
                                                                                  color: AppColors.red,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(10)),
                                                                            child:
                                                                                MyText(
                                                                              text: AppLocalizations.of(context)!.waitingForApprovelText.toString().replaceAll('\\n', '\n'),
                                                                              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: AppColors.red),
                                                                              maxLines: 4,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    CustomButton(
                                                                        buttonName:
                                                                            AppLocalizations.of(context)!
                                                                                .reuploadDocument,
                                                                        width: size
                                                                            .width,
                                                                        textSize:
                                                                            16,
                                                                        onTap:
                                                                            () {
                                                                          context
                                                                              .read<DriverProfileBloc>()
                                                                              .reUploadDocument = true;
                                                                          context
                                                                              .read<DriverProfileBloc>()
                                                                              .add(DriverUpdateEvent());
                                                                        }),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          : ((context.read<DriverProfileBloc>().modifyDocument ==
                                                                          false ||
                                                                      context
                                                                          .read<
                                                                              DriverProfileBloc>()
                                                                          .reUploadDocument) &&
                                                                  !userData!
                                                                      .available)
                                                              ? NeededDocumentsWidget(
                                                                  cont: context,
                                                                  arg: args)
                                                              : SizedBox(
                                                                  height:
                                                                      size.width *
                                                                          1.75,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        size.width *
                                                                            0.05),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Column(
                                                                          children: [
                                                                            Image.asset(
                                                                              AppImages.pendingApproval,
                                                                              height: size.width * 0.7,
                                                                            ),
                                                                            SizedBox(
                                                                              height: size.width * 0.05,
                                                                            ),
                                                                            Container(
                                                                              padding: EdgeInsets.all(size.width * 0.05),
                                                                              decoration: BoxDecoration(
                                                                                  color: AppColors.redBackground,
                                                                                  border: Border.all(
                                                                                    width: 1,
                                                                                    color: AppColors.red,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(10)),
                                                                              child: MyText(
                                                                                text: AppLocalizations.of(context)!.waitingForApprovelText.toString().replaceAll('\\n', '\n'),
                                                                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16, color: AppColors.red),
                                                                                maxLines: 4,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              size.width * 0.1,
                                                                        ),
                                                                        CustomButton(
                                                                            buttonName: AppLocalizations.of(context)!
                                                                                .reuploadDocument,
                                                                            width: size
                                                                                .width,
                                                                            textSize:
                                                                                16,
                                                                            onTap:
                                                                                () {
                                                                              context.read<DriverProfileBloc>().reUploadDocument = true;
                                                                              context.read<DriverProfileBloc>().add(DriverUpdateEvent());
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
            ],
          ),
        ),
      );
    })),
  );
}
