import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class ReplyContainer extends StatelessWidget {
  final Size size;
  final String id;

  const ReplyContainer({
    super.key,
    required this.size,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.25,
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.047),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.reply),
              const SizedBox(width: 8),
              MyText(
                text: AppLocalizations.of(context)!.replyText,
                textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).primaryColorDark,
                    ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.01),
          RichText(
            text: TextSpan(
              text: AppLocalizations.of(context)!.messageText,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              children: const [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.width * 0.02),
          Expanded(
            child: CustomTextField(
              controller: context.read<AccBloc>().supportMessageReplyController,
              hintText: AppLocalizations.of(context)!.enterMessage,
              maxLine: 5,
            ),
          ),
          SizedBox(height: size.width * 0.03),
          Align(
            alignment: Alignment.centerRight,
            child: BlocConsumer<AccBloc, AccState>(
              listener: (cont, state) {},
              builder: (cont, state) {
                return CustomButton(
                  buttonColor:
                      cont.read<AccBloc>().supportTicketData!.status != 3
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                  buttonName: AppLocalizations.of(context)!.send,
                  onTap: cont.read<AccBloc>().supportTicketData!.status != 3
                      ? () {
                          if (context
                              .read<AccBloc>()
                              .supportMessageReplyController
                              .text
                              .isNotEmpty) {
                            cont.read<AccBloc>().add(
                                  TicketReplyMessageEvent(
                                    context: context,
                                    id: id,
                                    messageText: context
                                        .read<AccBloc>()
                                        .supportMessageReplyController
                                        .text,
                                  ),
                                );
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .fillTheMessageField);
                          }
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
