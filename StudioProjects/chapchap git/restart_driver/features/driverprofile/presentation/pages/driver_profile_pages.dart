import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_background.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/extensions.dart';
import 'package:restart_user/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_user/features/driverprofile/presentation/widgets/document_view_widget.dart';
import 'package:restart_user/features/driverprofile/presentation/widgets/edit_document_widget.dart';
import 'package:restart_user/features/driverprofile/presentation/widgets/needed_documents_widget.dart';
import 'package:restart_user/features/driverprofile/presentation/widgets/vehicle_information_widget.dart';

import 'package:restart_user/features/home/presentation/pages/home_page/page/home_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
              CustomBackground(
                child: ((context.read<DriverProfileBloc>().choosenDocument !=
                            null &&
                        context.read<DriverProfileBloc>().isEditable))
                    ? EditDocumentWidget(cont: context)
                    : (context.read<DriverProfileBloc>().choosenDocument !=
                                null &&
                            !context.read<DriverProfileBloc>().isEditable)
                        ? DocumentViewWidget(cont: context)
                        : (args!.from == 'vehicle' || args.from == 'owner')
                            ? Container(
                                height: size.height,
                                width: size.width,
                                padding: EdgeInsets.fromLTRB(size.width * 0.05,
                                    size.width * 0.05, size.width * 0.05, 0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.paddingOf(context).top),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              size: size.width * 0.07,
                                              color: AppColors.black,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.05),
                                          MyText(
                                            text: (args.from == 'owner')
                                                ? AppLocalizations.of(context)!
                                                    .addNewVehicle
                                                : AppLocalizations.of(context)!
                                                    .modifyVehicleInfo,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .headlineMedium!
                                                .copyWith(
                                                    fontSize: 20,
                                                    color: AppColors.blackText),
                                          ),
                                        ],
                                      ),
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
                                ? Container(
                                    height: size.height,
                                    width: size.width,
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        size.width * 0.05,
                                        size.width * 0.05,
                                        0),
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: [
                                        SizedBox(
                                            height:
                                                MediaQuery.paddingOf(context)
                                                    .top),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(
                                                  Icons.arrow_back,
                                                  size: size.width * 0.07,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.05),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .documents,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!
                                                    .copyWith(
                                                        fontSize: 20,
                                                        color: AppColors
                                                            .blackText),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.12),
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
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        size.width * 0.05,
                                        size.width * 0.05,
                                        0),
                                    height: size.height,
                                    width: size.width,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height:
                                                MediaQuery.paddingOf(context)
                                                    .top),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .requiredInfo,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .headlineMedium!
                                                .copyWith(
                                                    fontSize: 18,
                                                    color: AppColors.blackText),
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.12),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  width: size.width * 0.66,
                                                  child: RichText(
                                                    maxLines: 5,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      text:
                                                          "${AppLocalizations.of(context)!.welcome} ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            fontSize: 18,
                                                            color: AppColors
                                                                .darkGrey,
                                                          ),
                                                      children: [
                                                        TextSpan(
                                                          text: userData!.name,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                    color: AppColors
                                                                        .blackText,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: MyText(
                                            text: (userData!.role == 'driver')
                                                ? AppLocalizations.of(context)!
                                                    .followSteps
                                                : AppLocalizations.of(context)!
                                                    .followStepsOwner,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 12,
                                                    color: AppColors.black
                                                        .withAlpha((0.5 * 255)
                                                            .toInt())),
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.07),
                                        SizedBox(
                                          width: size.width * 0.725,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: size.width * 0.077,
                                                width: size.width * 0.077,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: AppColors.black),
                                                    color: AppColors.black
                                                        .withAlpha((0.16 * 255)
                                                            .toInt())),
                                                alignment: Alignment.center,
                                                child: MyText(
                                                  text: '1',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.black),
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    const Expanded(
                                                      child: Text(
                                                        '---------------------',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .black),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: size.width * 0.04,
                                                      color: AppColors.black,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: size.width * 0.077,
                                                width: size.width * 0.077,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: AppColors.black),
                                                    color: (userData!
                                                                .serviceLocationId !=
                                                            '')
                                                        ? AppColors.black
                                                            .withAlpha(
                                                                (0.16 * 255)
                                                                    .toInt())
                                                        : Colors.transparent),
                                                alignment: Alignment.center,
                                                child: MyText(
                                                  text: '2',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.black),
                                                ),
                                              ),
                                              Expanded(
                                                child: (userData!
                                                            .serviceLocationId !=
                                                        '')
                                                    ? Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          const Expanded(
                                                            child: Text(
                                                              '---------------------',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .black),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: size.width *
                                                                0.04,
                                                            color:
                                                                AppColors.black,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                              ),
                                              Container(
                                                height: size.width * 0.077,
                                                width: size.width * 0.077,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: AppColors.black),
                                                    color: (context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .showSubmitButton)
                                                        ? AppColors.black
                                                            .withAlpha(
                                                                (0.16 * 255)
                                                                    .toInt())
                                                        : Colors.transparent),
                                                alignment: Alignment.center,
                                                child: MyText(
                                                  text: '3',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.black),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.015),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: size.width * 0.25,
                                                height: 20,
                                                child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .profile,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .blackText),
                                                    maxLines: 2,
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Expanded(
                                                child: MyText(
                                                    text: (userData!.role ==
                                                            'driver')
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .vehicleInfo
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .companyInfo,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .blackText),
                                                    maxLines: 2,
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.25,
                                                  height: 20,
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .documents,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .blackText,
                                                        ),
                                                    maxLines: 2,
                                                    textAlign: TextAlign.center,
                                                  ))
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.width * 0.05),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: (userData!
                                                        .serviceLocationId ==
                                                    '')
                                                ? VehicleInformationWidget(
                                                    cont: context, args: args)
                                                : (context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .isRejected &&
                                                        !context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .reUploadDocument &&
                                                        !userData!.available)
                                                    ? DocumentDeclinedWidget(
                                                        cont: context)
                                                    : (((userData!.uploadedDocument ==
                                                                true &&
                                                            !context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .modifyDocument &&
                                                            !context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .modifyDocument &&
                                                            context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .neededDocuments
                                                                .every((doc) =>
                                                                    doc.document !=
                                                                    null))
                                                        ? SizedBox(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  AppImages
                                                                      .waitingApprovel,
                                                                  height:
                                                                      size.width *
                                                                          0.6,
                                                                ),
                                                                MyText(
                                                                  text: AppLocalizations.of(
                                                                          context)!
                                                                      .waitingForApprovelText
                                                                      .toString()
                                                                      .replaceAll(
                                                                          '\\n',
                                                                          '\n'),
                                                                  textStyle: const TextStyle(
                                                                      color: AppColors
                                                                          .red,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  maxLines: 4,
                                                                ),
                                                              ],
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
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      AppImages
                                                                          .waitingApprovel,
                                                                      height:
                                                                          size.width *
                                                                              0.6,
                                                                    ),
                                                                    MyText(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .waitingForApprovelText
                                                                          .toString()
                                                                          .replaceAll(
                                                                              '\\n',
                                                                              '\n'),
                                                                      textStyle: const TextStyle(
                                                                          color: AppColors
                                                                              .red,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      maxLines:
                                                                          4,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ))),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
              ),
            ],
          ),
        ),
      );
    })),
  );
}
