import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
                if (userData!.enableModulesForApplications == 'both' &&
                    args.from != 'owner')
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.check_mark,
                              size: size.width * 0.07,
                              color: AppColors.black,
                            ),
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!.registerFor,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontSize: 15,
                                    color: AppColors.blackText,
                                  ),
                            ))
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                      SizedBox(
                        width: size.width * 0.9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: size.width * 0.025),
                            Column(
                              children: [
                                for (var i = 0; i < 10; i++)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    height: 3,
                                    width: 1,
                                    color: (context
                                                .read<DriverProfileBloc>()
                                                .registerFor !=
                                            null)
                                        ? AppColors.darkGrey
                                        : AppColors.black
                                            .withAlpha((0.5 * 255).toInt()),
                                  )
                              ],
                            ),
                            SizedBox(width: size.width * 0.02),
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
                                            left: size.width * 0.05),
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
                                                        color: AppColors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2)),
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
                                                        color: AppColors.black,
                                                        size: size.width * 0.03,
                                                      )
                                                    : Container(),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.025),
                                              MyText(
                                                text: context
                                                    .read<DriverProfileBloc>()
                                                    .vehicleRegisterFor[i],
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.blackText,
                                                    ),
                                              )
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
                if (args.from != 'owner')
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.check_mark,
                              size: size.width * 0.07,
                              color: (context
                                          .read<DriverProfileBloc>()
                                          .registerFor !=
                                      null)
                                  ? AppColors.black
                                  : AppColors.black
                                      .withAlpha((0.5 * 255).toInt()),
                            ),
                            SizedBox(width: size.width * 0.025),
                            SizedBox(
                              width: size.width * 0.8,
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .chooseServiceLocation,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 15,
                                      color: (context
                                                  .read<DriverProfileBloc>()
                                                  .registerFor !=
                                              null)
                                          ? AppColors.blackText
                                          : AppColors.black
                                              .withAlpha((0.5 * 255).toInt()),
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
                            SizedBox(width: size.width * 0.025),
                            Column(
                              children: [
                                for (var i = 0; i < 15; i++)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 2),
                                    height: 3,
                                    width: 1,
                                    color: (context
                                                .read<DriverProfileBloc>()
                                                .choosenServiceLocation !=
                                            null)
                                        ? AppColors.darkGrey
                                        : AppColors.black
                                            .withAlpha((0.5 * 255).toInt()),
                                  )
                              ],
                            ),
                            SizedBox(width: size.width * 0.07),
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
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor
                                                .withAlpha((0.8 * 255).toInt()),
                                            width: size.width,
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: size.width * 0.8,
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .chooseServiceLoc,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            fontSize: 15,
                                                            color: (context
                                                                        .read<
                                                                            DriverProfileBloc>()
                                                                        .registerFor !=
                                                                    null)
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColorDark
                                                                : AppColors
                                                                    .black
                                                                    .withAlpha((0.5 *
                                                                            255)
                                                                        .toInt()),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                  ),
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
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                      size.width *
                                                                          0.05),
                                                          child: InkWell(
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
                                                            child: SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.8,
                                                              child: MyText(
                                                                text: context
                                                                    .read<
                                                                        DriverProfileBloc>()
                                                                    .serviceLocations[
                                                                        i]
                                                                    .name,
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .copyWith(
                                                                      fontSize:
                                                                          15,
                                                                    ),
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
                                  height: size.width * 0.10,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: (context
                                                      .read<DriverProfileBloc>()
                                                      .registerFor !=
                                                  null)
                                              ? AppColors.darkGrey
                                              : AppColors.black.withAlpha(
                                                  (0.5 * 255).toInt())),
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: EdgeInsets.only(
                                      left: size.width * 0.05,
                                      right: size.width * 0.05),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          text: (context
                                                      .read<DriverProfileBloc>()
                                                      .choosenServiceLocation !=
                                                  null)
                                              ? context
                                                  .read<DriverProfileBloc>()
                                                  .serviceLocations
                                                  .firstWhere((e) =>
                                                      e.id ==
                                                      context
                                                          .read<
                                                              DriverProfileBloc>()
                                                          .choosenServiceLocation)
                                                  .name
                                              : AppLocalizations.of(context)!
                                                  .chooseServiceLoc,
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
                                                    ? AppColors.blackText
                                                    : AppColors.black.withAlpha(
                                                        (0.5 * 255).toInt()),
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                      Icon(
                                        CupertinoIcons.placemark_fill,
                                        color: (context
                                                    .read<DriverProfileBloc>()
                                                    .registerFor !=
                                                null)
                                            ? AppColors.black
                                            : AppColors.black
                                                .withAlpha((0.5 * 255).toInt()),
                                        size: size.width * 0.07,
                                      )
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
                (userData!.role == 'driver' || args.from == 'owner')
                    ? GetVehicleInfo(cont: context)
                    : GetCompanyInfo(cont: context),
                if (((userData!.role == 'driver' || args.from == 'owner') &&
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
                          buttonName: AppLocalizations.of(context)!.submit,
                          onTap: () {
                            if (context
                                .read<DriverProfileBloc>()
                                .driverProfileformKey
                                .currentState!
                                .validate()) {
                              context
                                  .read<DriverProfileBloc>()
                                  .add(UpdateVehicleEvent(from: args.from));
                            }
                          }),
                      SizedBox(height: size.width * 0.05)
                    ],
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
