import 'package:flutter/material.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/view_ticket_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class TicketCard extends StatelessWidget {
  final Size size;
  final TicketData ticketData;
  final bool isFromViewPage;
  const TicketCard(
      {super.key,
      required this.size,
      required this.ticketData,
      required this.isFromViewPage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ViewTicketPage.routeName,
          arguments: ViewTicketPageArguments(
              isViewTicketPage: true,
              ticketId: ticketData.ticketId,
              id: ticketData.id),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.047),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        width: size.width * 0.9,
        // height: size.width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              width: size.width * 0.9,
              // height: size.width * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .disabledColor
                    .withAlpha((0.07 * 255).toInt()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.ticketId,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Theme.of(context).disabledColor),
                      ),
                      MyText(
                        text: " ${ticketData.ticketId}",
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.title,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Theme.of(context).disabledColor),
                      ),
                      SizedBox(
                        width: size.width * 0.75,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: MyText(
                            text: " ${ticketData.ticketTitle.title}",
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark),
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isFromViewPage
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.assignTo,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                            SizedBox(
                              width: size.width * 0.75,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: MyText(
                                  text: " ${ticketData.assignTo}",
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                  maxLines: 3,
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          text: AppLocalizations.of(context)!.supportType,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).disabledColor)),
                      MyText(
                        text: ticketData.supportType,
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        color: ticketData.status == 1
                            ? AppColors.blue
                            : ticketData.status == 2
                                ? AppColors.orange
                                : AppColors.red),
                    child: MyText(
                      text: ticketData.status == 1
                          ? AppLocalizations.of(context)!.pending
                          : ticketData.status == 2
                              ? AppLocalizations.of(context)!.acknowledged
                              : AppLocalizations.of(context)!.closed,
                      textStyle: const TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
