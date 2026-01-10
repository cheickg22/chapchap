// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/service_location_model.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class CreateTicketSheet extends StatelessWidget {
  final BuildContext cont;
  final List<TicketNamesList> ticketNamesList;
  final String requestId;
  final bool isFromReuest;
  final int? index;
  final int? historyPagenumber;

  const CreateTicketSheet(
      {super.key,
      required this.cont,
      required this.ticketNamesList,
      required this.requestId,
      required this.isFromReuest,
      this.index,
      this.historyPagenumber});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          ServiceLocationData? selectedValue;
          TicketNamesList? selectedTitle;
          try {
            selectedValue = accBloc.serviceLocations.firstWhere(
              (e) => e.name == accBloc.selectedTicketArea,
            );
          } catch (_) {
            selectedValue = null;
          }

          try {
            selectedTitle = ticketNamesList
                .firstWhere((e) => e.title == accBloc.selectedTicketTitle);
          } catch (_) {
            selectedTitle = null;
          }
          return SafeArea(
            child: Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: size.width * 0.03,
                  right: size.width * 0.03,
                  top: size.height * 0.02,
                  bottom: size.height * 0.02),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: size.width * 0.04,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.createTicket,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Column(
                      children: [
                        Row(children: [
                          RichText(
                            text: TextSpan(
                                text: AppLocalizations.of(context)!.title,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                                children: [
                                  const TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.red,
                                          fontWeight: FontWeight.bold))
                                ]),
                          ),
                        ]),
                        SizedBox(height: size.width * 0.01),
                        DropdownButtonFormField<TicketNamesList>(
                          focusColor: Theme.of(context).dividerColor,
                          dropdownColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          value: selectedTitle,
                          items: ticketNamesList
                              .map((e) => DropdownMenuItem<TicketNamesList>(
                                    value: e,
                                    child: SizedBox(
                                      width: size.width * 0.75,
                                      child: MyText(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        text: e.title,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (selected) {
                            if (selected != null) {
                              context.read<AccBloc>().add(
                                    TicketTitleChangeEvent(
                                      changedTitle: selected.title,
                                      id: selected.id,
                                    ),
                                  );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.selectTitle,
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Theme.of(context).disabledColor,
                              width: 1.2,
                              style: BorderStyle.solid,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Theme.of(context).disabledColor,
                              width: 1.2,
                              style: BorderStyle.solid,
                            )),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                        ),
                        SizedBox(height: size.width * 0.025),
                        Row(children: [
                          RichText(
                            text: TextSpan(
                                text: AppLocalizations.of(context)!.selectArea,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                                children: [
                                  const TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.red,
                                          fontWeight: FontWeight.bold))
                                ]),
                          ),
                        ]),
                        SizedBox(
                          height: size.width * 0.01,
                        ),
                        DropdownButtonFormField<ServiceLocationData>(
                          focusColor: Theme.of(context).dividerColor,
                          dropdownColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          value: selectedValue,
                          items: context.read<AccBloc>().serviceLocations.map(
                            (e) {
                              return DropdownMenuItem<ServiceLocationData>(
                                value: e,
                                child: MyText(text: e.name),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AccBloc>().add(
                                    TicketAreaChangeEvent(
                                      changedArea: value.name,
                                      id: value.id,
                                    ),
                                  );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.selectArea,
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).disabledColor,
                                width: 1.2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).disabledColor,
                                width: 1.2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.025,
                        ),
                        Row(children: [
                          RichText(
                            text: TextSpan(
                                text: AppLocalizations.of(context)!.description,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                                children: [
                                  const TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.red,
                                          fontWeight: FontWeight.bold))
                                ]),
                          ),
                        ]),
                        SizedBox(
                          height: size.width * 0.01,
                        ),
                        CustomTextField(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          controller: context
                              .read<AccBloc>()
                              .supportDescriptionController,
                          hintText:
                              AppLocalizations.of(context)!.enterDescription,
                          maxLine: 4,
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.attachments,
                              textStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                            if (context
                                .read<AccBloc>()
                                .ticketAttachments
                                .isNotEmpty)
                              InkWell(
                                onTap: () {
                                  context.read<AccBloc>().add(
                                      AddAttachmentTicketEvent(
                                          context: context));
                                },
                                child: MyText(
                                  text:
                                      "+ ${AppLocalizations.of(context)!.addMore}",
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),
                              )
                          ],
                        ),
                        InkWell(
                          onTap: context
                                      .read<AccBloc>()
                                      .ticketAttachments
                                      .length ==
                                  1
                              ? null
                              : () {
                                  context.read<AccBloc>().add(
                                      AddAttachmentTicketEvent(
                                          context: context));
                                },
                          child: Stack(
                            children: [
                              Container(
                                height: size.height * 0.06,
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  border: Border.all(
                                      color: Theme.of(context).dividerColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      image: const AssetImage(
                                        AppImages.upload,
                                      ),
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    const SizedBox(width: 10),
                                    context
                                            .read<AccBloc>()
                                            .ticketAttachments
                                            .isEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .uploadMaxFile,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              MyText(
                                                text: "(png,jpg,jpeg,pdf,doc)",
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor),
                                              ),
                                            ],
                                          )
                                        : MyText(
                                            text:
                                                '${context.read<AccBloc>().ticketAttachments.length} ${AppLocalizations.of(context)!.filesUploaded}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                  ],
                                ),
                              ),
                              if (context
                                  .read<AccBloc>()
                                  .ticketAttachments
                                  .isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 12,
                                  child: InkWell(
                                    onTap: () {
                                      context
                                          .read<AccBloc>()
                                          .add(ClearAttachmentEvent());
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.width * 0.05),
                        Center(
                          child: CustomButton(
                            buttonName:
                                AppLocalizations.of(context)!.createTicket,
                            onTap: () {
                              if ((context
                                              .read<AccBloc>()
                                              .selectedTicketTitleId !=
                                          null &&
                                      context
                                          .read<AccBloc>()
                                          .selectedTicketTitleId!
                                          .isNotEmpty) &&
                                  (context
                                              .read<AccBloc>()
                                              .selectedTicketAreaId !=
                                          null &&
                                      context
                                          .read<AccBloc>()
                                          .selectedTicketAreaId!
                                          .isNotEmpty) &&
                                  context
                                      .read<AccBloc>()
                                      .supportDescriptionController
                                      .text
                                      .isNotEmpty) {
                                context.read<AccBloc>().add(
                                      MakeTicketSubmitEvent(
                                          description: context
                                              .read<AccBloc>()
                                              .supportDescriptionController
                                              .text,
                                          titleId: context
                                              .read<AccBloc>()
                                              .selectedTicketTitleId!,
                                          serviceLocationId: context
                                              .read<AccBloc>()
                                              .selectedTicketAreaId!,
                                          attachement: context
                                              .read<AccBloc>()
                                              .ticketAttachments,
                                          requestId: requestId,
                                          isFromRequest: isFromReuest,
                                          index: index,
                                          pageNumber: historyPagenumber),
                                    );
                                Navigator.pop(context, true);
                              } else {
                                showToast(
                                    message: AppLocalizations.of(context)!
                                        .fillTheRequiredField);
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
