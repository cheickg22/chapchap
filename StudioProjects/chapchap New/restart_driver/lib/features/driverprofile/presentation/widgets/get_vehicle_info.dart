import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/driver_profile_bloc.dart';

class GetVehicleInfo extends StatelessWidget {
  final BuildContext cont;
  const GetVehicleInfo({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.vehicleType,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (context
                                  .read<DriverProfileBloc>()
                                  .choosenServiceLocation !=
                              null) {
                            showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Container(
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor
                                            .withAlpha((0.8 * 255).toInt()),
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.075)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          child: SizedBox(
                                            width: size.width * 0.8,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .chooseVehicleType,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontSize: 18,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontWeight:
                                                          FontWeight.w600),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: size.width * 0.005,
                                          width: size.width,
                                          color: AppColors.borderColors,
                                        ),
                                        Expanded(
                                            child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              for (var i = 0;
                                                  i <
                                                      context
                                                          .read<
                                                              DriverProfileBloc>()
                                                          .vehicleType
                                                          .length;
                                                  i++)
                                                InkWell(
                                                  onTap: () {
                                                    context
                                                        .read<
                                                            DriverProfileBloc>()
                                                        .add(UpdateVehicleTypeEvent(
                                                            id: context
                                                                .read<
                                                                    DriverProfileBloc>()
                                                                .vehicleType[i]
                                                                .id));
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    width: size.width,
                                                    decoration:
                                                        const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: AppColors
                                                              .borderColors, // border color
                                                          width:
                                                              1, // border width
                                                        ),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          size.width * 0.05),
                                                      child: MyText(
                                                        text: context
                                                            .read<
                                                                DriverProfileBloc>()
                                                            .vehicleType[i]
                                                            .name,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
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
                                  color: (context
                                              .read<DriverProfileBloc>()
                                              .choosenServiceLocation !=
                                          null)
                                      ? AppColors.borderColors
                                      : AppColors.borderColors),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(size.width * 0.025),
                          child: Row(
                            children: [
                              Expanded(
                                child: MyText(
                                  text: (context
                                              .read<DriverProfileBloc>()
                                              .choosenVehicleType !=
                                          null)
                                      ? context
                                          .read<DriverProfileBloc>()
                                          .vehicleType
                                          .firstWhere((e) =>
                                              e.id ==
                                              context
                                                  .read<DriverProfileBloc>()
                                                  .choosenVehicleType)
                                          .name
                                      : AppLocalizations.of(context)!
                                          .selectType,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 14,
                                        color: (context
                                                    .read<DriverProfileBloc>()
                                                    .choosenVehicleType !=
                                                null)
                                            ? Theme.of(context).primaryColorDark
                                            : Theme.of(context)
                                                .primaryColorDark,
                                      ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.05),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: (context
                                            .read<DriverProfileBloc>()
                                            .choosenServiceLocation !=
                                        null)
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).hintColor,
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
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideVehicleMake,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        enabled: context
                                .read<DriverProfileBloc>()
                                .choosenVehicleType !=
                            null,
                        hintText: 'e.g., Toyota',
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            AppImages.vehicleMakeImage,
                            width: size.width * 0.015,
                          ),
                        ),
                        controller:
                            context.read<DriverProfileBloc>().customMake,
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideVehicleModel,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        enabled: context
                            .read<DriverProfileBloc>()
                            .customMake
                            .text
                            .isNotEmpty,
                        hintText: 'e.g., Camry',
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            AppImages.vehicleModelImage,
                            width: size.width * 0.015,
                          ),
                        ),
                        controller:
                            context.read<DriverProfileBloc>().customModel,
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideModelYear,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4)
                        ],
                        enabled: context
                            .read<DriverProfileBloc>()
                            .customModel
                            .text
                            .isNotEmpty,
                        hintText: 'e.g., 2020',
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            AppImages.vehicleYearImage,
                            width: size.width * 0.015,
                          ),
                        ),
                        controller:
                            context.read<DriverProfileBloc>().vehicleYear,
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        validator: (string) {
                          if (string != null && string.length <= 3) {
                            return AppLocalizations.of(context)!.validDateValue;
                          } else if (string != null &&
                              string.length == 4 &&
                              int.parse(string) > DateTime.now().year) {
                            return AppLocalizations.of(context)!.validDateValue;
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideVehicleNumber,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: CustomTextField(
                        enabled: context
                            .read<DriverProfileBloc>()
                            .vehicleYear
                            .text
                            .isNotEmpty,
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                        hintText: 'e.g., XYZ-1234',
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            AppImages.vehicleNumberImage,
                            width: size.width * 0.015,
                          ),
                        ),
                        controller:
                            context.read<DriverProfileBloc>().vehicleNumber,
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideVehicleColor,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark),
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
                    Expanded(
                      child: CustomTextField(
                        enabled: context
                            .read<DriverProfileBloc>()
                            .vehicleNumber
                            .text
                            .isNotEmpty,
                        hintText: 'e.g., Black',
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            AppImages.vehicleColorImage,
                            width: size.width * 0.015,
                          ),
                        ),
                        controller:
                            context.read<DriverProfileBloc>().vehicleColor,
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
