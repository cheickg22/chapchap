import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/driver_profile_bloc.dart';

class GetCompanyInfo extends StatelessWidget {
  final BuildContext cont;
  const GetCompanyInfo({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value:cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return Column(
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
                                  .choosenServiceLocation !=
                              null)
                          ? AppColors.black
                          : AppColors.black.withAlpha((0.5 * 255).toInt()),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideCompanyName,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 15,
                                color: (context
                                            .read<DriverProfileBloc>()
                                            .choosenServiceLocation !=
                                        null)
                                    ? AppColors.blackText
                                    : AppColors.black.withAlpha((0.5 * 255).toInt()),
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
                        for (var i = 0; i < 15; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 3,
                            width: 1,
                            color: (context
                                    .read<DriverProfileBloc>()
                                    .companyName
                                    .text
                                    .isNotEmpty)
                                ? AppColors.darkGrey
                                : AppColors.black.withAlpha((0.5 * 255).toInt()),
                          )
                      ],
                    ),
                    SizedBox(width: size.width * 0.07),
                    Expanded(
                      child: CustomTextField(
                        // maxLength: 4,
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        // keyboardType: TextInputType.number,
                        enabled: context
                                .read<DriverProfileBloc>()
                                .choosenServiceLocation !=
                            null,
                        hintText:
                            AppLocalizations.of(context)!.enterCompanyName,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.blackText,
                            ),
                        controller:
                            context.read<DriverProfileBloc>().companyName,
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
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark,
                      size: size.width * 0.07,
                      color: (context
                              .read<DriverProfileBloc>()
                              .companyName
                              .text
                              .isNotEmpty)
                          ? AppColors.black
                          : AppColors.black.withAlpha((0.5 * 255).toInt()),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideCompanyAddress,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 15,
                                color: (context
                                        .read<DriverProfileBloc>()
                                        .companyName
                                        .text
                                        .isNotEmpty)
                                    ? AppColors.blackText
                                    : AppColors.black.withAlpha((0.5 * 255).toInt()),
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
                    SizedBox(
                      width: size.width * 0.025,
                    ),
                    Column(
                      children: [
                        for (var i = 0; i < 15; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 3,
                            width: 1,
                            color: (context
                                    .read<DriverProfileBloc>()
                                    .companyAddress
                                    .text
                                    .isNotEmpty)
                                ? AppColors.darkGrey
                                : AppColors.black.withAlpha((0.5 * 255).toInt()),
                          )
                      ],
                    ),
                    SizedBox(width: size.width * 0.07),
                    Expanded(
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        enabled: context
                            .read<DriverProfileBloc>()
                            .companyName
                            .text
                            .isNotEmpty,
                        hintText:
                            AppLocalizations.of(context)!.enterCompanyAddress,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.blackText,
                            ),
                        controller:
                            context.read<DriverProfileBloc>().companyAddress,
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
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark,
                      size: size.width * 0.07,
                      color: (context
                              .read<DriverProfileBloc>()
                              .companyAddress
                              .text
                              .isNotEmpty)
                          ? AppColors.black
                          : AppColors.black.withAlpha((0.5 * 255).toInt()),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideCity,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 15,
                                color: (context
                                        .read<DriverProfileBloc>()
                                        .companyAddress
                                        .text
                                        .isNotEmpty)
                                    ? AppColors.blackText
                                    : AppColors.black.withAlpha((0.5 * 255).toInt()),
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
                        for (var i = 0; i < 15; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 3,
                            width: 1,
                            color: (context
                                    .read<DriverProfileBloc>()
                                    .companyCity
                                    .text
                                    .isNotEmpty)
                                ? AppColors.darkGrey
                                : AppColors.black.withAlpha((0.5 * 255).toInt()),
                          )
                      ],
                    ),
                    SizedBox(width: size.width * 0.07),
                    Expanded(
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        enabled: context
                            .read<DriverProfileBloc>()
                            .companyAddress
                            .text
                            .isNotEmpty,
                        hintText: AppLocalizations.of(context)!.enterCity,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.blackText,
                            ),
                        controller:
                            context.read<DriverProfileBloc>().companyCity,
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
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark,
                      size: size.width * 0.07,
                      color: (context
                              .read<DriverProfileBloc>()
                              .companyCity
                              .text
                              .isNotEmpty)
                          ? AppColors.black
                          : AppColors.black.withAlpha((0.5 * 255).toInt()),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.providePostalCode,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 15,
                                color: (context
                                        .read<DriverProfileBloc>()
                                        .companyCity
                                        .text
                                        .isNotEmpty)
                                    ? AppColors.blackText
                                    : AppColors.black.withAlpha((0.5 * 255).toInt()),
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
                        for (var i = 0; i < 15; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 3,
                            width: 1,
                            color: (context
                                    .read<DriverProfileBloc>()
                                    .companyPostalCode
                                    .text
                                    .isNotEmpty)
                                ? AppColors.darkGrey
                                : AppColors.black.withAlpha((0.5 * 255).toInt()),
                          )
                      ],
                    ),
                    SizedBox(width: size.width * 0.07),
                    Expanded(
                      child: CustomTextField(
                        enabled: context
                            .read<DriverProfileBloc>()
                            .companyCity
                            .text
                            .isNotEmpty,
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.blackText,
                            ),
                        hintText: AppLocalizations.of(context)!.enterPostalCode,
                        keyboardType: TextInputType.number,
                        controller:
                            context.read<DriverProfileBloc>().companyPostalCode,
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
                        validator: (string) {
                          if (string != null && string.length > 8) {
                            return AppLocalizations.of(context)!
                                .validPostalCode;
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
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.check_mark,
                      size: size.width * 0.07,
                      color: (context
                              .read<DriverProfileBloc>()
                              .companyPostalCode
                              .text
                              .isNotEmpty)
                          ? AppColors.black
                          : AppColors.black.withAlpha((0.5 * 255).toInt()),
                    ),
                    SizedBox(width: size.width * 0.025),
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideTaxNumber,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 15,
                                color: (context
                                        .read<DriverProfileBloc>()
                                        .companyPostalCode
                                        .text
                                        .isNotEmpty)
                                    ? AppColors.blackText
                                    : AppColors.black.withAlpha((0.5 * 255).toInt()),
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
                    SizedBox(
                      width: size.width * 0.025,
                    ),
                    Column(
                      children: [
                        for (var i = 0; i < 15; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            height: 3,
                            width: 1,
                            color: Colors.transparent,
                          )
                      ],
                    ),
                    SizedBox(width: size.width * 0.07),
                    Expanded(
                      child: CustomTextField(
                        enabled: context
                            .read<DriverProfileBloc>()
                            .companyPostalCode
                            .text
                            .isNotEmpty,
                        hintText: AppLocalizations.of(context)!.enterTaxNumer,
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                              color: AppColors.blackText,
                            ),
                        controller:
                            context.read<DriverProfileBloc>().companyTaxNumber,
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
