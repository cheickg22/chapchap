import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/presentation/pages/history/page/trip_summary_history.dart';
import 'package:restart_user/features/account/presentation/pages/history/widget/history_card_shimmer.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/history_card_widget.dart';
import '../widget/history_nodata.dart';

class HistoryPage extends StatelessWidget {
  static const String routeName = '/historyPage';
  final HistoryAccountPageArguments args;

  const HistoryPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(HistoryGetEvent(
            historyFilter:
                args.isFrom == 'account' ? 'is_completed=1' : 'is_later=1',
            typeIndex: args.isFrom == 'account' ? 0 : 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          } else if (state is HistoryTypeChangeState) {
            String filter;
            switch (state.selectedHistoryType) {
              case 0:
                filter = 'is_completed=1';
                break;
              case 1:
                filter = 'is_later=1';
                break;
              case 2:
                filter = 'is_cancelled=1';
                break;
              default:
                filter = '';
            }
            context.read<AccBloc>().add(HistoryGetEvent(historyFilter: filter));
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final selectedIndex = context.read<AccBloc>().selectedHistoryType;
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.history,
                automaticallyImplyLeading: true,
              ),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTab(
                            context,
                            AppLocalizations.of(context)!.completed,
                            0,
                            selectedIndex),
                        _buildTab(
                            context,
                            AppLocalizations.of(context)!.upcoming,
                            1,
                            selectedIndex),
                        _buildTab(
                            context,
                            AppLocalizations.of(context)!.cancelled,
                            2,
                            selectedIndex),
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  const Divider(
                    height: 1,
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (context.read<AccBloc>().isLoading) {
                                  return HistoryShimmer(size: size);
                                }
                                if (context.read<AccBloc>().history.isEmpty) {
                                  return const HistoryNodataWidget();
                                }
                                if (index == 0) {
                                  return SizedBox(
                                    height: size.width * 0.02,
                                  );
                                } else if (index <
                                    context.read<AccBloc>().history.length +
                                        1) {
                                  final history = context
                                      .read<AccBloc>()
                                      .history[index - 1];
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: Column(children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              if (history.laterRide == true) {
                                                Navigator.pushNamed(
                                                  context,
                                                  HistoryTripSummaryPage
                                                      .routeName,
                                                  arguments: TripHistoryPageArguments(
                                                      historyData: history,
                                                      isSupportTicketEnabled: args.isSupportTicketEnabled,
                                                      historyIndex: index - 1,
                                                      pageNumber: context
                                                          .read<AccBloc>()
                                                          .historyPaginations!
                                                          .pagination
                                                          .currentPage),
                                                ).then((value) {
                                                  if (!context.mounted) {
                                                    return;
                                                  }
                                                  context
                                                      .read<AccBloc>()
                                                      .history
                                                      .clear();
                                                  context
                                                      .read<AccBloc>()
                                                      .add(UpdateEvent());
                                                  context.read<AccBloc>().add(
                                                      HistoryGetEvent(
                                                          historyFilter:
                                                              'is_later=1'));
                                                  context
                                                      .read<AccBloc>()
                                                      .add(UpdateEvent());
                                                });
                                              } else {
                                                Navigator.pushNamed(
                                                  context,
                                                  HistoryTripSummaryPage
                                                      .routeName,
                                                  arguments: TripHistoryPageArguments(
                                                      historyData: history,
                                                      historyIndex: index - 1,
                                                      isSupportTicketEnabled: args.isSupportTicketEnabled,
                                                      pageNumber: context
                                                          .read<AccBloc>()
                                                          .historyPaginations!
                                                          .pagination
                                                          .currentPage),
                                                ).then((value) {
                                                  if (!context.mounted) {
                                                    return;
                                                  }
                                                  context.read<AccBloc>().add(
                                                        HistoryGetEvent(
                                                            historyFilter:
                                                                  history.isCancelled != 1 
                                                                    ? 'is_completed=1'
                                                                    : 'is_cancelled=1',
                                                            pageNumber: context
                                                                .read<AccBloc>()
                                                                .historyPaginations!
                                                                .pagination
                                                                .currentPage,
                                                            historyIndex:
                                                                index - 1),
                                                      );
                                                  context
                                                      .read<AccBloc>()
                                                      .add(UpdateEvent());
                                                });
                                              }
                                            },
                                            child: HistoryCardWidget(
                                                cont: context,
                                                history: history),
                                          ),
                                        ),
                                      ])),
                                    ],
                                  );
                                } else {
                                  return null;
                                }
                              },
                              childCount:
                                  context.read<AccBloc>().history.length + 1,
                            ),
                          ),
                        ),
                        if (context.read<AccBloc>().historyPaginations !=
                                null &&
                            context
                                    .read<AccBloc>()
                                    .historyPaginations!
                                    .pagination !=
                                null &&
                            context
                                    .read<AccBloc>()
                                    .historyPaginations!
                                    .pagination
                                    .currentPage <
                                context
                                    .read<AccBloc>()
                                    .historyPaginations!
                                    .pagination
                                    .totalPages &&
                            (state is HistoryDataSuccessState ||
                                state is HistoryTypeChangeState))
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.02),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (context
                                              .read<AccBloc>()
                                              .historyPaginations!
                                              .pagination
                                              .currentPage <
                                          context
                                              .read<AccBloc>()
                                              .historyPaginations!
                                              .pagination
                                              .totalPages) {
                                        context.read<AccBloc>().add(
                                            HistoryGetEvent(
                                                pageNumber: context
                                                        .read<AccBloc>()
                                                        .historyPaginations!
                                                        .pagination
                                                        .currentPage +
                                                    1,
                                                historyFilter: (context
                                                            .read<AccBloc>()
                                                            .selectedHistoryType ==
                                                        0)
                                                    ? "is_completed=1"
                                                    : (context
                                                                .read<AccBloc>()
                                                                .selectedHistoryType ==
                                                            1)
                                                        ? "is_later=1"
                                                        : "is_cancelled=1"));
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(3))),
                                      child: Row(
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .loadMore,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorLight,
                                                ),
                                          ),
                                          Icon(
                                            Icons
                                                .arrow_drop_down_circle_outlined,
                                            color: Theme.of(context)
                                                .primaryColorLight,
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(
      BuildContext context, String title, int index, int selectedIndex) {
    return GestureDetector(
      onTap: () {
        if (index != selectedIndex && !context.read<AccBloc>().isLoading) {
          context.read<AccBloc>().history.clear();
          context.read<AccBloc>().add(UpdateEvent());
          context
              .read<AccBloc>()
              .add(HistoryTypeChangeEvent(historyTypeIndex: index));
        }
      },
      child: MyText(
        text: title,
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: index == selectedIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }
}
