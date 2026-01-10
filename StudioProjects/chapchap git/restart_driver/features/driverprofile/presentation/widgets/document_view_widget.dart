import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/custom_textfield.dart';
import 'package:restart_user/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

class DocumentViewWidget extends StatelessWidget {
  final BuildContext cont;
  const DocumentViewWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return context.read<DriverProfileBloc>().neededDocuments.isEmpty
              ? const SizedBox()
              : Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  height: size.height,
                  width: size.width,
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.paddingOf(context).top),
                      SizedBox(
                        width: size.width * 0.9,
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  context
                                      .read<DriverProfileBloc>()
                                      .add(ChooseDocumentEvent(id: null));
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  size: size.width * 0.07,
                                  color: AppColors.blackText,
                                )),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                              child: MyText(
                                text: context
                                    .read<DriverProfileBloc>()
                                    .neededDocuments
                                    .firstWhere((e) =>
                                        e.id ==
                                        context
                                            .read<DriverProfileBloc>()
                                            .choosenDocument)
                                    .name,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      color: AppColors.blackText,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: size.width * 0.1),
                              Container(
                                height: size.width * 0.5,
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.darkGrey),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments
                                            .firstWhere((e) =>
                                                e.id ==
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .choosenDocument)
                                            .document!['data']['document'],
                                      ),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(
                                height: context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments
                                            .firstWhere((e) =>
                                                e.id ==
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .choosenDocument)
                                            .isFrontAndBack ==
                                        true
                                    ? size.width * 0.05
                                    : size.width * 0,
                              ),
                              (context
                                              .read<DriverProfileBloc>()
                                              .neededDocuments
                                              .firstWhere((e) =>
                                                  e.id ==
                                                  context
                                                      .read<DriverProfileBloc>()
                                                      .choosenDocument)
                                              .isFrontAndBack ==
                                          true &&
                                      context
                                              .read<DriverProfileBloc>()
                                              .neededDocuments
                                              .firstWhere((e) =>
                                                  e.id ==
                                                  context
                                                      .read<DriverProfileBloc>()
                                                      .choosenDocument)
                                              .document!['data']['back_document'] !=
                                          null)
                                  ? Container(
                                      height: size.width * 0.5,
                                      width: size.width * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: AppColors.darkGrey),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                              context
                                                      .read<DriverProfileBloc>()
                                                      .neededDocuments
                                                      .firstWhere((e) =>
                                                          e.id ==
                                                          context
                                                              .read<
                                                                  DriverProfileBloc>()
                                                              .choosenDocument)
                                                      .document!['data']
                                                  ['back_document'],
                                            ),
                                            fit: BoxFit.cover),
                                      ),
                                    )
                                  : const SizedBox(),
                              if (context
                                  .read<DriverProfileBloc>()
                                  .neededDocuments
                                  .firstWhere((e) =>
                                      e.id ==
                                      context
                                          .read<DriverProfileBloc>()
                                          .choosenDocument)
                                  .hasIdNumer)
                                Column(
                                  children: [
                                    SizedBox(height: size.width * 0.07),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .yourId,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                    Container(
                                      color: AppColors.darkGrey
                                          .withAlpha((0.1 * 255).toInt()),
                                      child: CustomTextField(
                                        readOnly: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                        hintTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.black.withAlpha(
                                                  (0.5 * 255).toInt()),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        hintText: context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments
                                            .firstWhere((e) =>
                                                e.id ==
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .choosenDocument)
                                            .document!['data']
                                                ['identify_number']
                                            .toString(),
                                      ),
                                    )
                                  ],
                                ),
                              if (context
                                  .read<DriverProfileBloc>()
                                  .neededDocuments
                                  .firstWhere((e) =>
                                      e.id ==
                                      context
                                          .read<DriverProfileBloc>()
                                          .choosenDocument)
                                  .hasExpiryDate)
                                Column(
                                  children: [
                                    SizedBox(height: size.width * 0.07),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .expiryDate,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                    Container(
                                      color: AppColors.darkGrey
                                          .withAlpha((0.1 * 255).toInt()),
                                      child: CustomTextField(
                                        readOnly: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                        hintTextStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 16,
                                              color: AppColors.blackText,
                                            ),
                                        enabled: false,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        hintText: context
                                            .read<DriverProfileBloc>()
                                            .neededDocuments
                                            .firstWhere((e) =>
                                                e.id ==
                                                context
                                                    .read<DriverProfileBloc>()
                                                    .choosenDocument)
                                            .document!['data']['expiry_date']
                                            .toString(),
                                      ),
                                    )
                                  ],
                                ),
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (context
                          .read<DriverProfileBloc>()
                          .neededDocuments
                          .firstWhere((e) =>
                              e.id ==
                              context.read<DriverProfileBloc>().choosenDocument)
                          .isEditable)
                        CustomButton(
                            buttonName: AppLocalizations.of(context)!.edit,
                            onTap: () {
                              context
                                  .read<DriverProfileBloc>()
                                  .add(EnableEditEvent(isEditable: true));
                            })
                    ],
                  ),
                );
        },
      ),
    );
  }
}
