import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../core/utils/custom_loader.dart';

class ChatPageWidget extends StatelessWidget {
  const ChatPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.secondary,
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<HomeBloc>().add(ChatSeenEvent());
                  context.read<HomeBloc>().add(ShowChatEvent());
                },
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size(size.width, size.width * 0.15),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyText(
                      text: userData!.onTripRequest!.userName,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: AppColors.white,
                              ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Container(
                      height: size.width * 0.13,
                      width: size.width * 0.13,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context)
                              .disabledColor
                              .withAlpha((0.2 * 255).toInt())),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: userData!.onTripRequest!.userImage,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => const Center(
                            child: Loader(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Text(""),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: size.width * 0.05),
                            Expanded(
                                child: SingleChildScrollView(
                              controller:
                                  context.read<HomeBloc>().chatScrollController,
                              child: Column(
                                children: [
                                  chatHistoryData(
                                      size, context.read<HomeBloc>().chats),
                                ],
                              ),
                            )),
                            SizedBox(height: size.width * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller:
                                        context.read<HomeBloc>().chatField,
                                    hintText: AppLocalizations.of(context)!
                                        .typeMessage,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                InkWell(
                                    onTap: () {
                                      if (context
                                          .read<HomeBloc>()
                                          .chatField
                                          .text
                                          .isNotEmpty) {
                                        context.read<HomeBloc>().add(
                                            SendChatEvent(
                                                message: context
                                                    .read<HomeBloc>()
                                                    .chatField
                                                    .text));
                                        context
                                            .read<HomeBloc>()
                                            .chatField
                                            .clear();
                                      }
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: Theme.of(context).primaryColorDark,
                                    ))
                              ],
                            ),
                            SizedBox(height: size.width * 0.1)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget chatHistoryData(Size size, List<dynamic> chatList) {
    return chatList.isNotEmpty
        ? RawScrollbar(
            radius: const Radius.circular(20),
            child: ListView.builder(
              itemCount: chatList.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<HomeBloc>().chatScrollController.animateTo(
                      context
                          .read<HomeBloc>()
                          .chatScrollController
                          .position
                          .maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                });
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: size.width * 0.01),
                      width: size.width * 0.9,
                      alignment: (chatList[index]['from_type'] != 1)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: (chatList[index]['from_type'] != 1)
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 5,
                            child: Container(
                              width: size.width * 0.5,
                              padding: EdgeInsets.all(size.width * 0.03),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: (chatList[index]['from_type'] != 1)
                                        ? Radius.circular(size.width * 0.02)
                                        : const Radius.circular(0),
                                    topRight: (chatList[index]['from_type'] !=
                                            1)
                                        ? const Radius.circular(0)
                                        : Radius.circular(size.width * 0.02),
                                    bottomRight:
                                        Radius.circular(size.width * 0.02),
                                    bottomLeft:
                                        Radius.circular(size.width * 0.02),
                                  ),
                                  color: (chatList[index]['from_type'] != 1)
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? const Color(0xffE7EDEF)
                                          : AppColors.black
                                      : const Color(0xffE7EDEF)),
                              child: MyText(
                                text: chatList[index]['message'],
                                overflow: TextOverflow.visible,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: (chatList[index]['from_type'] !=
                                                1)
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.dark)
                                                ? AppColors.black
                                                : AppColors.white
                                            : AppColors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.01,
                          ),
                          MyText(
                            text: chatList[index]['converted_created_at'],
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context).disabledColor),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          )
        : const SizedBox();
  }
}
