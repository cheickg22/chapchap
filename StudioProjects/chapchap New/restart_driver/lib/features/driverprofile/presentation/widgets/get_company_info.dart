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
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.provideCompanyName,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
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
                      child: CustomTextField(
                        onChange: (v) {
                          context
                              .read<DriverProfileBloc>()
                              .add(DriverUpdateEvent());
                        },
                        enabled: context
                                .read<DriverProfileBloc>()
                                .choosenServiceLocation !=
                            null,
                        hintText:
                            AppLocalizations.of(context)!.enterCompanyName,
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
                        controller:
                            context.read<DriverProfileBloc>().companyName,
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
                      text: AppLocalizations.of(context)!.provideCompanyAddress,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
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
                        controller:
                            context.read<DriverProfileBloc>().companyAddress,
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
                      text: AppLocalizations.of(context)!.provideCity,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
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
                        controller:
                            context.read<DriverProfileBloc>().companyCity,
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
                      text: AppLocalizations.of(context)!.providePostalCode,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
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
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        hintText: AppLocalizations.of(context)!.enterPostalCode,
                        keyboardType: TextInputType.number,
                        controller:
                            context.read<DriverProfileBloc>().companyPostalCode,
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
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                        child: MyText(
                      text: AppLocalizations.of(context)!.provideTaxNumber,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorDark,
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
                        contentPadding: EdgeInsets.only(
                            top: size.width * 0.035,
                            bottom: size.width * 0.035,
                            left: size.width * 0.025,
                            right: size.width * 0.025),
                        controller:
                            context.read<DriverProfileBloc>().companyTaxNumber,
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
