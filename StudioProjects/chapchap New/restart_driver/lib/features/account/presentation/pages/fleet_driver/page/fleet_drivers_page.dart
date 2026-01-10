import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../widget/add_fleet_driver.dart';

class FleetDriversPage extends StatelessWidget {
  static const String routeName = '/driversPage';

  const FleetDriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()..add(GetDriverEvent(from: 0)),
        child: BlocListener<AccBloc, AccState>(listener: (context, state) {
          if (state is DriversLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is DriversLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.drivers,
              automaticallyImplyLeading: true,
              titleFontSize: 18,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: size.width * 0.1),
                  Expanded(
                      child: (context.read<AccBloc>().driverData.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.noDriversAvail,
                                  width: 300,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .noDriversAdded,
                                  textStyle:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    itemCount: context
                                        .read<AccBloc>()
                                        .driverData
                                        .length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                bottom: size.width * 0.05,
                                                left: size.width * 0.05,
                                                right: size.width * 0.05),
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            width: size.width * 0.9,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color:
                                                        AppColors.borderColor),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      height: size.width * 0.15,
                                                      width: size.width * 0.15,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .driverData[
                                                                          index]
                                                                      .profile),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.width * 0.025),
                                                    SizedBox(
                                                      width: size.width * 0.2,
                                                      child: MyText(
                                                        text: context
                                                            .read<AccBloc>()
                                                            .driverData[index]
                                                            .name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.025,
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: size.width * 0.21,
                                                  color: AppColors.borderColors,
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.025,
                                                ),
                                                Expanded(
                                                    child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              size.width * 0.05,
                                                          width:
                                                              size.width * 0.05,
                                                          child: Image.asset(
                                                            AppImages.phone,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: size.width *
                                                              0.025,
                                                        ),
                                                        Expanded(
                                                            child: MyText(
                                                          text: context
                                                              .read<AccBloc>()
                                                              .driverData[index]
                                                              .mobile,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                        ))
                                                      ],
                                                    ),
                                                    if (context
                                                        .read<AccBloc>()
                                                        .driverData[index]
                                                        .approve)
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                              height:
                                                                  size.width *
                                                                      0.05),
                                                          Row(
                                                            children: [
                                                              (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .driverData[
                                                                              index]
                                                                          .carNumber ==
                                                                      null)
                                                                  ? SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.04,
                                                                      width: size
                                                                              .width *
                                                                          0.04,
                                                                      child: Image.asset(
                                                                          AppImages
                                                                              .carFront,
                                                                          color:
                                                                              AppColors.red),
                                                                    )
                                                                  : SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.05,
                                                                      width: size
                                                                              .width *
                                                                          0.05,
                                                                      child: Image
                                                                          .asset(
                                                                        AppImages
                                                                            .carFront,
                                                                        color: Theme.of(context)
                                                                            .hintColor,
                                                                      ),
                                                                    ),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.025,
                                                              ),
                                                              (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .driverData[
                                                                              index]
                                                                          .carNumber ==
                                                                      null)
                                                                  ? Expanded(
                                                                      child:
                                                                          MyText(
                                                                      text: AppLocalizations.of(
                                                                              context)!
                                                                          .fleetNotAssigned,
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                AppColors.red,
                                                                          ),
                                                                    ))
                                                                  : Expanded(
                                                                      child:
                                                                          MyText(
                                                                      text: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .driverData[
                                                                              index]
                                                                          .carNumber,
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Theme.of(context).primaryColorDark,
                                                                          ),
                                                                    )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    if (context
                                                            .read<AccBloc>()
                                                            .driverData[index]
                                                            .approve ==
                                                        false)
                                                      Column(
                                                        children: [
                                                          SizedBox(
                                                            height: size.width *
                                                                0.025,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  size: 14,
                                                                  weight: 35,
                                                                  color:
                                                                      AppColors
                                                                          .red),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.02,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.45,
                                                                child: MyText(
                                                                  text: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .driverData[
                                                                              index]
                                                                          .documentUploaded)
                                                                      ? AppLocalizations.of(
                                                                              context)!
                                                                          .waitingForApproval
                                                                      : AppLocalizations.of(
                                                                              context)!
                                                                          .documentNotUploaded,
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              AppColors.red),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                )),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 5 + size.width * 0.05,
                                              right: (context
                                                          .read<AccBloc>()
                                                          .textDirection ==
                                                      'ltr')
                                                  ? size.width * 0.065
                                                  : null,
                                              left: (context
                                                          .read<AccBloc>()
                                                          .textDirection ==
                                                      'rtl')
                                                  ? size.width * 0.065
                                                  : null,
                                              child: InkWell(
                                                  onTap: () {
                                                    context
                                                            .read<AccBloc>()
                                                            .choosenDriverForDelete =
                                                        context
                                                            .read<AccBloc>()
                                                            .driverData[index]
                                                            .id;
                                                    showDialog(
                                                        context: context,
                                                        builder: (builder) {
                                                          return CustomSingleButtonDialoge(
                                                            title: AppLocalizations
                                                                    .of(context)!
                                                                .deleteDriver,
                                                            content: AppLocalizations
                                                                    .of(context)!
                                                                .deleteDriverSure,
                                                            btnName: AppLocalizations
                                                                    .of(context)!
                                                                .deleteDriver,
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .add(DeleteDriverEvent(
                                                                      driverId: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .choosenDriverForDelete!));
                                                            },
                                                          );
                                                        });
                                                  },
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: size.width * 0.06,
                                                    color: AppColors.red,
                                                  )))
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            )),
                  SizedBox(height: size.width * 0.05),
                  SizedBox(
                    width: size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                useSafeArea: true,
                                builder: (builder) {
                                  return AddFleetDriverWidget(cont: context);
                                });
                          },
                          child: Container(
                            width: size.width * 0.128,
                            height: size.width * 0.128,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Icon(
                              Icons.add,
                              size: size.width * 0.075,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.075),
                ],
              ),
            ),
          );
        })));
  }
}
