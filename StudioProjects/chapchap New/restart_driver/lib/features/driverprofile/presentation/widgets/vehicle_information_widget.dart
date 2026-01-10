import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import 'get_company_info.dart';
import 'get_vehicle_info.dart';

class VehicleInformationWidget extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments args;
  const VehicleInformationWidget(
      {super.key, required this.cont, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return Form(
            key: context.read<DriverProfileBloc>().driverProfileformKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(size.width * 0.025),
                  // margin: EdgeInsets.all(size.width*0.05),
                  margin: EdgeInsets.fromLTRB(size.width * 0.05, 0,
                      size.width * 0.05, size.width * 0.05),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(width: 1.2, color: AppColors.borderColor)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.025,
                      ),
                      if (userData!.enableModulesForApplications == 'both' &&
                          args.from != 'owner')
                        Column(
                          children: [
                            Row(
                              children: [
                                MyText(
                                  text:
                                      AppLocalizations.of(context)!.registerFor,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.05),
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  context
                                                      .read<DriverProfileBloc>()
                                                      .vehicleRegisterFor
                                                      .length;
                                              i++)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: size.width * 0.05),
                                              child: InkWell(
                                                onTap: () {
                                                  context
                                                      .read<DriverProfileBloc>()
                                                      .add(GetServiceLocationEvent(
                                                          type: context
                                                              .read<
                                                                  DriverProfileBloc>()
                                                              .vehicleRegisterFor[i]));
                                                },
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: size.width * 0.04,
                                                      width: size.width * 0.04,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2)),
                                                      child: (context
                                                                  .read<
                                                                      DriverProfileBloc>()
                                                                  .registerFor ==
                                                              context
                                                                  .read<
                                                                      DriverProfileBloc>()
                                                                  .vehicleRegisterFor[i])
                                                          ? Icon(
                                                              Icons.done,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              size: size.width *
                                                                  0.03,
                                                            )
                                                          : Container(),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.025),
                                                    MyText(
                                                      text: context
                                                          .read<
                                                              DriverProfileBloc>()
                                                          .vehicleRegisterFor[i],
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      if (args.from != 'owner')
                        Column(
                          children: [
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.7,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .serviceLocation,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 14,
                                            color: (context
                                                        .read<
                                                            DriverProfileBloc>()
                                                        .registerFor !=
                                                    null)
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : Theme.of(context)
                                                    .primaryColorDark,
                                          ),
                                      maxLines: 2,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (context
                                                .read<DriverProfileBloc>()
                                                .registerFor !=
                                            null) {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (builder) {
                                                return Container(
                                                  width: size.width,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor
                                                          .withAlpha((0.8 * 255)
                                                              .toInt()),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  0.075)),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                            size.width * 0.05),
                                                        child: SizedBox(
                                                          width:
                                                              size.width * 0.8,
                                                          child: MyText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .chooseServiceLoc,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height:
                                                            size.width * 0.005,
                                                        width: size.width,
                                                        color: AppColors
                                                            .borderColors,
                                                      ),
                                                      Expanded(
                                                          child:
                                                              SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            for (var i = 0;
                                                                i <
                                                                    context
                                                                        .read<
                                                                            DriverProfileBloc>()
                                                                        .serviceLocations
                                                                        .length;
                                                                i++)
                                                              InkWell(
                                                                onTap: () {
                                                                  context.read<DriverProfileBloc>().add(GetVehicleTypeEvent(
                                                                      id: context
                                                                          .read<
                                                                              DriverProfileBloc>()
                                                                          .serviceLocations[
                                                                              i]
                                                                          .id,
                                                                      type: context
                                                                          .read<
                                                                              DriverProfileBloc>()
                                                                          .registerFor!,
                                                                      from: args
                                                                          .from));
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: size
                                                                      .width,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    border:
                                                                        Border(
                                                                      bottom:
                                                                          BorderSide(
                                                                        color: AppColors
                                                                            .borderColors, // border color
                                                                        width:
                                                                            1, // border width
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        size.width *
                                                                            0.05),
                                                                    child:
                                                                        MyText(
                                                                      text: context
                                                                          .read<
                                                                              DriverProfileBloc>()
                                                                          .serviceLocations[
                                                                              i]
                                                                          .name,
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall!
                                                                          .copyWith(
                                                                              fontSize: 16,
                                                                              color: Theme.of(context).primaryColorDark),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                          ],
                                                        ),
                                                      ))
                                                    ],
                                                  ),
                                                );
                                              });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.borderColors),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding:
                                            EdgeInsets.all(size.width * 0.025),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              AppImages.serviceLocationPin,
                                              fit: BoxFit.contain,
                                              width: size.width * 0.065,
                                            ),
                                            SizedBox(width: size.width * 0.045),
                                            Expanded(
                                              child: MyText(
                                                text: (context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .choosenServiceLocation !=
                                                        null)
                                                    ? context
                                                        .read<
                                                            DriverProfileBloc>()
                                                        .serviceLocations
                                                        .firstWhere((e) =>
                                                            e.id ==
                                                            context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .choosenServiceLocation)
                                                        .name
                                                    : 'e.g., New York, NY',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      fontSize: 14,
                                                      color: (context
                                                                  .read<
                                                                      DriverProfileBloc>()
                                                                  .choosenServiceLocation !=
                                                              null)
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : Theme.of(context)
                                                              .hintColor,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      (userData!.role == 'driver' || args.from == 'owner')
                          ? GetVehicleInfo(cont: context)
                          : GetCompanyInfo(cont: context),
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      if (((userData!.role == 'driver' ||
                                  args.from == 'owner') &&
                              context
                                  .read<DriverProfileBloc>()
                                  .vehicleColor
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .vehicleNumber
                                  .text
                                  .isNotEmpty &&
                              context
                                      .read<DriverProfileBloc>()
                                      .vehicleYear
                                      .text
                                      .length >=
                                  4 &&
                              context
                                  .read<DriverProfileBloc>()
                                  .customMake
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .customModel
                                  .text
                                  .isNotEmpty) ||
                          (userData!.role == 'owner' &&
                              context
                                  .read<DriverProfileBloc>()
                                  .companyName
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .companyCity
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .companyAddress
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .companyPostalCode
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<DriverProfileBloc>()
                                  .companyTaxNumber
                                  .text
                                  .isNotEmpty))
                        Column(
                          children: [
                            CustomButton(
                                buttonName:
                                    AppLocalizations.of(context)!.submit,
                                width: size.width,
                                textSize: 18,
                                onTap: () {
                                  if (context
                                      .read<DriverProfileBloc>()
                                      .driverProfileformKey
                                      .currentState!
                                      .validate()) {
                                    context.read<DriverProfileBloc>().add(
                                        UpdateVehicleEvent(from: args.from));
                                  }
                                }),
                            SizedBox(height: size.width * 0.05)
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
