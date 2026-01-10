import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class SupportReplyMessageList extends StatelessWidget {
  final Size size;
  const SupportReplyMessageList({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AccBloc>();
    final replyMessages = bloc.replyMessages;
    final supportTicketData = bloc.supportTicketData!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.047),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: replyMessages.isNotEmpty
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
      ),
      width: size.width * 0.9,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: replyMessages.length,
            itemBuilder: (context, index) {
              final message = replyMessages[index];
              final isUser = message.senderId == supportTicketData.usersId;
              final profilePicture = isUser
                  ? supportTicketData.user.profilePicture
                  : (supportTicketData.adminDetails != null)
                      ? supportTicketData.adminDetails!.profilePicture
                      : supportTicketData.user.profilePicture;
              final senderName = isUser
                  ? supportTicketData.user.name
                  : (supportTicketData.adminDetails != null)
                      ? supportTicketData.adminDetails!.firstName
                      : supportTicketData.user.name;
              return Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(profilePicture),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                MyText(
                                  text: senderName,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: size.width * 0.02,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.2 * 255).toInt())),
                                  child: MyText(
                                    text: isUser
                                        ? AppLocalizations.of(context)!.user
                                        : AppLocalizations.of(context)!.admin,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.2 * 255).toInt()),
                                    size: 15),
                                SizedBox(
                                  width: size.width * 0.01,
                                ),
                                MyText(
                                  text: message.convertedCreatedAt ?? '',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: size.width * 0.02),
                    MyText(
                      text: message.message!
                          .replaceAll('<p>', '')
                          .replaceAll('</p>', ''),
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).disabledColor),
                      maxLines: 6,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Column(
              children: [
                SizedBox(height: size.width * 0.03),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9.0),
                  child: Divider(),
                ),
                SizedBox(
                  height: size.width * 0.03,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
