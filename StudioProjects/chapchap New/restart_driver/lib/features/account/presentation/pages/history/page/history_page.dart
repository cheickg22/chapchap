import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history/page/trip_summary_history.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history/widget/history_card_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
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
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
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
              // backgroundColor: const Color(0xFFF8F9FA),
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.history,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: Column(
                children: [
                  // Modern Tab Section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: AppColors.black.withOpacity(0.05),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Row(
                      children: [
                        _buildModernTab(
                            context,
                            AppLocalizations.of(context)!.completed,
                            0,
                            selectedIndex),
                        _buildModernTab(
                            context,
                            AppLocalizations.of(context)!.upcoming,
                            1,
                            selectedIndex),
                        _buildModernTab(
                            context,
                            AppLocalizations.of(context)!.cancelled,
                            2,
                            selectedIndex),
                      ],
                    ),
                  ),

                  // Content Section
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  return const SizedBox(height: 8);
                                } else if (index <
                                    context.read<AccBloc>().history.length +
                                        1) {
                                  final history = context
                                      .read<AccBloc>()
                                      .history[index - 1];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () {
                                        if (history.laterRide == true) {
                                          Navigator.pushNamed(
                                            context,
                                            HistoryTripSummaryPage.routeName,
                                            arguments: TripHistoryPageArguments(
                                                historyData: history,
                                                isSupportTicketEnabled:
                                                    args.isSupportTicketEnabled,
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
                                            HistoryTripSummaryPage.routeName,
                                            arguments: TripHistoryPageArguments(
                                                historyData: history,
                                                historyIndex: index - 1,
                                                isSupportTicketEnabled:
                                                    args.isSupportTicketEnabled,
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
                                                          history.isCancelled !=
                                                                  1
                                                              ? 'is_completed=1'
                                                              : 'is_cancelled=1',
                                                      pageNumber: context
                                                          .read<AccBloc>()
                                                          .historyPaginations!
                                                          .pagination
                                                          .currentPage,
                                                      historyIndex: index - 1),
                                                );
                                            context
                                                .read<AccBloc>()
                                                .add(UpdateEvent());
                                          });
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.black
                                                  .withOpacity(0.06),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: HistoryCardWidget(
                                            cont: context, history: history),
                                      ),
                                    ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              child: Center(
                                child: InkWell(
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColor,
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .loadMore,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.white,
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 16),
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

  Widget _buildModernTab(
      BuildContext context, String title, int index, int selectedIndex) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index != selectedIndex && !context.read<AccBloc>().isLoading) {
            context.read<AccBloc>().history.clear();
            context.read<AccBloc>().add(UpdateEvent());
            context
                .read<AccBloc>()
                .add(HistoryTypeChangeEvent(historyTypeIndex: index));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? Theme.of(context).primaryColor : AppColors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: MyText(
              text: title,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : Theme.of(context).hintColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
