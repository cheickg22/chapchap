import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_dialoges.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/extensions.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: size.width * 0.05),
                                              padding: EdgeInsets.all(
                                                  size.width * 0.05),
                                              width: size.width * 0.9,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColorDark
                                                      .withAlpha(
                                                          (0.1 * 255).toInt()),
                                                  border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColorDark
                                                          .withAlpha((0.5 * 255)
                                                              .toInt())),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Container(
                                                        height:
                                                            size.width * 0.15,
                                                        width:
                                                            size.width * 0.15,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: NetworkImage(context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .driverData[
                                                                        index]
                                                                    .profile),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                      SizedBox(
                                                          height: size.width *
                                                              0.025),
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
                                                              .bodySmall!
                                                              .copyWith(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
                                                    color: Theme.of(context)
                                                        .primaryColorDark
                                                        .withAlpha((0.5 * 255)
                                                            .toInt()),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.05,
                                                  ),
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            height: size.width *
                                                                0.06,
                                                            width: size.width *
                                                                0.06,
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: AppColors
                                                                    .darkGrey),
                                                            child: Icon(
                                                              Icons.call,
                                                              color: AppColors
                                                                  .white,
                                                              size: size.width *
                                                                  0.04,
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
                                                                .driverData[
                                                                    index]
                                                                .mobile,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: AppColors
                                                                        .darkGrey),
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
                                                                Container(
                                                                  height:
                                                                      size.width *
                                                                          0.06,
                                                                  width:
                                                                      size.width *
                                                                          0.06,
                                                                  decoration: const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: AppColors
                                                                          .darkGrey),
                                                                  child: Icon(
                                                                    CupertinoIcons
                                                                        .car_detailed,
                                                                    color: AppColors
                                                                        .white,
                                                                    size: size
                                                                            .width *
                                                                        0.04,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          0.025,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        MyText(
                                                                  text: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .driverData[
                                                                              index]
                                                                          .carNumber ??
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .fleetNotAssigned,
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodySmall!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          color: AppColors
                                                                              .red,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ))
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ),
                                            if (context
                                                    .read<AccBloc>()
                                                    .driverData[index]
                                                    .approve ==
                                                false)
                                              Positioned(
                                                  top: 0,
                                                  right: (context
                                                              .read<AccBloc>()
                                                              .textDirection ==
                                                          'ltr')
                                                      ? 0
                                                      : null,
                                                  left: (context
                                                              .read<AccBloc>()
                                                              .textDirection ==
                                                          'rtl')
                                                      ? 0
                                                      : null,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        size.width * 0.025),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color: (context
                                                                .read<AccBloc>()
                                                                .driverData[
                                                                    index]
                                                                .documentUploaded)
                                                            ? Colors.orange
                                                            : const Color
                                                                .fromARGB(255,
                                                                248, 92, 81)),
                                                    child: MyText(
                                                      text: (context
                                                              .read<AccBloc>()
                                                              .driverData[index]
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
                                                          .bodySmall!
                                                          .copyWith(
                                                              fontSize: 12,
                                                              color: AppColors
                                                                  .white),
                                                    ),
                                                  )),
                                            Positioned(
                                                bottom: 5 + size.width * 0.05,
                                                right: (context
                                                            .read<AccBloc>()
                                                            .textDirection ==
                                                        'ltr')
                                                    ? size.width * 0.05
                                                    : null,
                                                left: (context
                                                            .read<AccBloc>()
                                                            .textDirection ==
                                                        'rtl')
                                                    ? size.width * 0.05
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
                                                                            .read<AccBloc>()
                                                                            .choosenDriverForDelete!));
                                                              },
                                                            );
                                                          });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      size: size.width * 0.06,
                                                      color: AppColors.red,
                                                    ))),
                                          ],
                                        ),
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
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.darkGrey),
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      spreadRadius: 1,
                                      blurRadius: 1)
                                ]),
                            child: Icon(
                              Icons.add,
                              size: size.width * 0.1,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.05),
                ],
              ),
            ),
          );
        })));
  }
}
