import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/notification_card_widget.dart';
import '../widget/notification_page_shimmer.dart';

class NotificationPage extends StatelessWidget {
  static const String routeName = '/notification';

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(NotificationGetEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is NotificationDeletedSuccess) {
            Navigator.of(context).pop();
            context.read<AccBloc>().add(NotificationGetEvent());
          } else if (state is NotificationClearedSuccess) {
            context.read<AccBloc>().add(NotificationGetEvent());
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Directionality(
            textDirection: context.read<AccBloc>().textDirection == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.notifications,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (context.read<AccBloc>().isLoading) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                              ),
                              child: NotificationShimmer(size: size),
                            );
                          } else if (context
                                  .read<AccBloc>()
                                  .notificationDatas
                                  .isEmpty &&
                              !context.read<AccBloc>().isLoading) {
                            return Center(
                                child: Padding(
                              padding: const EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.notificationsNoData),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .noNotification,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .disabledColor
                                                .withAlpha((0.8 * 255).toInt()),
                                            fontSize: 18),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ));
                          }
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: size.height * 0.03, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext _) {
                                          return BlocProvider.value(
                                              value: BlocProvider.of<AccBloc>(
                                                  context),
                                              child: CustomDoubleButtonDialoge(
                                                title: AppLocalizations.of(
                                                        context)!
                                                    .clearNotifications,
                                                content: AppLocalizations.of(
                                                        context)!
                                                    .clearNotificationsText,
                                                yesBtnName: AppLocalizations.of(
                                                        context)!
                                                    .confirm,
                                                noBtnName: AppLocalizations.of(
                                                        context)!
                                                    .cancel,
                                                yesBtnFunc: () {
                                                  context.read<AccBloc>().add(
                                                      ClearAllNotificationsEvent());
                                                  Navigator.pop(context);
                                                },
                                                noBtnFunc: () {
                                                  Navigator.pop(context);
                                                },
                                              ));
                                        },
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.clearAll,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (index <
                              context.read<AccBloc>().notificationDatas.length +
                                  1) {
                            final datum = context
                                .read<AccBloc>()
                                .notificationDatas[index - 1];
                            return NotificationCardWidget(
                                cont: context, notificationData: datum);
                          } else {
                            return null;
                          }
                        },
                        childCount:
                            context.read<AccBloc>().notificationDatas.length +
                                1,
                      ),
                    ),
                  ),
                  if (context.read<AccBloc>().notificationPaginations != null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination !=
                          null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .currentPage <
                          context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .totalPages)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.width * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                if (context
                                        .read<AccBloc>()
                                        .notificationPaginations!
                                        .pagination
                                        .currentPage <
                                    context
                                        .read<AccBloc>()
                                        .notificationPaginations!
                                        .pagination
                                        .totalPages) {
                                  context.read<AccBloc>().add(
                                      NotificationGetEvent(
                                          pageNumber: context
                                                  .read<AccBloc>()
                                                  .notificationPaginations!
                                                  .pagination
                                                  .currentPage +
                                              1));
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.02),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3))),
                                child: Row(
                                  children: [
                                    MyText(
                                      text: 'load more',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                          ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_circle_outlined,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
