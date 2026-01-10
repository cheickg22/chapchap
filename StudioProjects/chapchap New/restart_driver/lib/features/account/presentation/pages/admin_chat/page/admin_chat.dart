import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../application/acc_bloc.dart';
import '../widget/chat_history_widget.dart';

class AdminChat extends StatelessWidget {
  static const String routeName = '/adminchat';

  const AdminChat({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetUserDetailsEvent())
        ..add(GetAdminChatHistoryListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.adminChat,
              automaticallyImplyLeading: true,
              titleFontSize: 18,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      controller: context.read<AccBloc>().scroolController,
                      child: Column(
                        children: [
                          AdminChatHistoryWidget(
                              cont: context,
                              adminChatList:
                                  context.read<AccBloc>().adminChatList),
                        ],
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: size.width * 0.020),
                      padding: EdgeInsets.fromLTRB(
                          size.width * 0.025, 0, size.width * 0.025, 0),
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.borderColors, width: 1.2),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: size.width * 0.7,
                            child: TextField(
                              style: const TextStyle(
                                  // color: AppColors.black,
                                  decoration: TextDecoration.none),
                              controller: context.read<AccBloc>().adminchatText,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    AppLocalizations.of(context)!.typeMessage,
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                if (context
                                    .read<AccBloc>()
                                    .adminchatText
                                    .text
                                    .isNotEmpty) {
                                  context.read<AccBloc>().add(
                                      SendAdminMessageEvent(
                                          newChat:
                                              context
                                                      .read<AccBloc>()
                                                      .adminChatList
                                                      .isEmpty
                                                  ? '0'
                                                  : '1',
                                          message:
                                              context
                                                  .read<AccBloc>()
                                                  .adminchatText
                                                  .text,
                                          chatId: context
                                                  .read<AccBloc>()
                                                  .adminChatList
                                                  .isEmpty
                                              ? ""
                                              : context
                                                  .read<AccBloc>()
                                                  .adminChatList[0]
                                                  .conversationId));
                                  context.read<AccBloc>().adminchatText.clear();
                                }
                              },
                              child: const Icon(
                                Icons.send,
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
