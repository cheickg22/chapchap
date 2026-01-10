import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/history_card_shimmer.dart';
import '../../outstation/widget/outstation_offered_page.dart';
import '../widget/history_card_widget.dart';
import '../widget/history_nodata.dart';
import 'trip_summary_history.dart';
import '../../../../../moov_money/presentation/pages/moov_money_request_details_page.dart';
import '../../../../../moov_money/presentation/pages/moov_money_transaction_completed_page.dart';
import '../../../../../moov_money/presentation/pages/moov_money_transaction_cancelled_page.dart';
import '../../../../../moov_money/presentation/pages/moov_money_transaction_failed_page.dart';

class HistoryPage extends StatelessWidget {
  static const String routeName = '/historyPage';
  final HistoryPageArguments arg;
  const HistoryPage({super.key,required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(HistoryPageInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is HistoryDataSuccessState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.history,
                  automaticallyImplyLeading: true,
                  onBackTap: () {
                    Navigator.of(context).pop();
                    context.read<AccBloc>().scrollController.dispose();
                  },
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.1,
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildTab(
                                  context: context,
                                  title:
                                      AppLocalizations.of(context)!.completed,
                                  index: 0,
                                  selectedIndex: context
                                      .read<AccBloc>()
                                      .selectedHistoryType),
                              _buildTab(
                                  context: context,
                                  title: AppLocalizations.of(context)!.upcoming,
                                  index: 1,
                                  selectedIndex: context
                                      .read<AccBloc>()
                                      .selectedHistoryType),
                              _buildTab(
                                  context: context,
                                  title: AppLocalizations.of(context)!.cancelled,
                                  index: 2,
                                  selectedIndex: context
                                      .read<AccBloc>()
                                      .selectedHistoryType),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                        controller: context.read<AccBloc>().scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: size.width * 0.03),
                              if (context.read<AccBloc>().isLoading &&
                                  context.read<AccBloc>().firstLoad)
                                HistoryShimmer(size: size),
                              if (!context.read<AccBloc>().isLoading &&
                                  context.read<AccBloc>().historyList.isEmpty)
                                const HistoryNodataWidget(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        context.read<AccBloc>().historyList.length,
                                    itemBuilder: (_, index) {
                                      final history = context
                                          .read<AccBloc>()
                                          .historyList
                                          .elementAt(index);
                                      return Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(bottom: 5),
                                            child: InkWell(
                                                onTap: () {
                                                  // Vérifier si c'est une demande MoovMoney
                                                  // Plusieurs façons de détecter MoovMoney:
                                                  final isMoovMoney = history.transportType.toLowerCase() == 'moov_money' ||
                                                                      history.transportType.toLowerCase() == 'moov money' ||
                                                                      history.transportType.toLowerCase().contains('moov') ||
                                                                      history.vehicleTypeName.toLowerCase().contains('moov') ||
                                                                      history.requestNumber.toUpperCase().startsWith('MM-');
                                                  
                                                  print('🔍 ========== CLIC SUR HISTORIQUE ==========');
                                                  print('   📋 ID: ${history.id}');
                                                  print('   🚗 Transport Type: "${history.transportType}"');
                                                  print('   🚙 Vehicle Type: "${history.vehicleTypeName}"');
                                                  print('   🔢 Request Number: "${history.requestNumber}"');
                                                  print('   📍 Pick Address: "${history.pickAddress}"');
                                                  print('   📍 Drop Address: "${history.dropAddress}"');
                                                  print('   💰 Payment Type: "${history.paymentType}"');
                                                  print('   ✅ isMoovMoney: $isMoovMoney');
                                                  print('==========================================');
                                                  
                                                  // Si c'est MoovMoney, naviguer vers la page appropriée
                                                  if (isMoovMoney) {
                                                    final isCompleted = history.isCompleted == 1;
                                                    final isCancelled = history.isCancelled == 1;
                                                    
                                                    Widget targetPage;
                                                    String pageName;
                                                    
                                                    if (isCompleted) {
                                                      targetPage = MoovMoneyTransactionCompletedPage(requestId: history.id);
                                                      pageName = 'MoovMoneyTransactionCompletedPage';
                                                    } else if (isCancelled) {
                                                      targetPage = MoovMoneyTransactionCancelledPage(requestId: history.id);
                                                      pageName = 'MoovMoneyTransactionCancelledPage';
                                                    } else {
                                                      targetPage = MoovMoneyRequestDetailsPage(requestId: history.id);
                                                      pageName = 'MoovMoneyRequestDetailsPage';
                                                    }
                                                    
                                                    print('   → ✅ Navigation vers $pageName');
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage));
                                                    return;
                                                  }
                                                  
                                                  print('   → ❌ Navigation vers HistoryTripSummaryPage (commande normale)');
                                                  
                                                  if (history.isLater == true &&
                                                      history.isCancelled != 1) {
                                                    if (history.isOutStation == 1 &&
                                                        history.driverDetail ==
                                                            null) {
                                                      Navigator.pushNamed(
                                                          context,
                                                          OutStationOfferedPage
                                                              .routeName,
                                                          arguments:
                                                              OutStationOfferedPageArguments(
                                                            requestId: history.id,
                                                            currencySymbol: history
                                                                .requestedCurrencySymbol ?? '',
                                                            dropAddress:
                                                                history.dropAddress,
                                                            pickAddress:
                                                                history.pickAddress,
                                                            updatedAt: history
                                                                .tripStartTimeWithDate,
                                                            offeredFare: history
                                                                .offerredRideFare
                                                                .toString(),
                                                            // userData: context
                                                            //     .read<AccBloc>()
                                                            //     .userData!
                                                          )).then(
                                                        (value) {
                                                          if (!context.mounted) {
                                                            return;
                                                          }
                                                          context
                                                              .read<AccBloc>()
                                                              .historyList
                                                              .clear();
                                                          context
                                                              .read<AccBloc>()
                                                              .add(HistoryGetEvent(
                                                                  historyFilter:
                                                                      'is_later=1'));
                                                        },
                                                      );
                                                    } else {
                                                      Navigator.pushNamed(
                                                        context,
                                                        HistoryTripSummaryPage
                                                            .routeName,
                                                        arguments: TripHistoryPageArguments(
                                                            historyData: history,
                                                            historyIndex: index,
                                                            isSupportTicketEnabled: arg.isSupportTicketEnabled,
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
                                                            .historyList
                                                            .clear();
                                                        context.read<AccBloc>().add(
                                                              HistoryGetEvent(
                                                                  historyFilter:
                                                                      history.isCancelled != 1
              ? "is_completed=1"
              : "is_cancelled=1",

                                                                      pageNumber: context.read<AccBloc>().historyPaginations!.pagination.currentPage),
                                                            );
                                                        context
                                                            .read<AccBloc>()
                                                            .add(AccUpdateEvent());
                                                      });
                                                    }
                                                  } else {
                                                    Navigator.pushNamed(
                                                      context,
                                                      HistoryTripSummaryPage
                                                          .routeName,
                                                      arguments: TripHistoryPageArguments(
                                                          historyData: history,
                                                          historyIndex: index,
                                                          isSupportTicketEnabled: arg.isSupportTicketEnabled,
                                                          pageNumber: context
                                                              .read<AccBloc>()
                                                              .historyPaginations!
                                                              .pagination
                                                              .currentPage),
                                                    ).then((value) {
                                                      if (!context.mounted) return;
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
                                                                    .currentPage),
                                                          );
                                                      context
                                                          .read<AccBloc>()
                                                          .add(AccUpdateEvent());
                                                    });
                                                  }
                                                },
                                                child: HistoryCardWidget(
                                                    cont: context,
                                                    history: history)),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (context
                                      .read<AccBloc>()
                                      .walletHistoryList
                                      .isNotEmpty &&
                                  context.read<AccBloc>().loadMore)
                                Center(
                                  child: SizedBox(
                                      height: size.width * 0.08,
                                      width: size.width * 0.08,
                                      child: const CircularProgressIndicator()),
                                ),
                              SizedBox(height: size.width * 0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(
      {required BuildContext context,
      required String title,
      required int index,
      required int selectedIndex}) {
    return InkWell(
      onTap: () {
        if (index != selectedIndex &&
            (!context.read<AccBloc>().isLoading &&
                !context.read<AccBloc>().loadMore)) {
          context.read<AccBloc>().historyList.clear();
          context.read<AccBloc>().add(AccUpdateEvent());
          context
              .read<AccBloc>()
              .add(HistoryTypeChangeEvent(historyTypeIndex: index));
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: MyText(
                text: title,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(
                      color: (index == selectedIndex) 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).primaryColorDark),
              ),
        ),
      ),
    );
  }
}
