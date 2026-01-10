import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/page/withdraw_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/widget/wallet_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/add_money_wallet.dart';
import '../widget/card_list_widget.dart';
import '../widget/wallet_history_data_widget.dart';
import '../widget/wallet_transfer_money_widget.dart';

class WalletHistoryPage extends StatelessWidget {
  static const String routeName = '/walletHistory';

  const WalletHistoryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetWalletInitEvent())
        ..add(GetWalletHistoryListEvent(pageIndex: 1))
        ..add(CardListEvent())
        ..add(GetWithdrawInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          final accBloc = context.read<AccBloc>();
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is MoneyTransferedSuccessState) {
            Navigator.pop(context);
          } else if (state is WalletPageReUpdateState) {
            accBloc.showRefresh = true;
            Navigator.of(context, rootNavigator: true).popUntil((route) =>
                route.isFirst ||
                route.settings.name == WalletHistoryPage.routeName);
            accBloc.add(
              AddMoneyWebViewUrlEvent(
                currencySymbol: state.currencySymbol,
                from: '',
                requestId: state.requestId,
                planId: '',
                money: state.money,
                url: state.url,
                userId: state.userId,
                context: context,
              ),
            );
          } else if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          } else if (state is PaymentUpdateState) {
            Navigator.of(context, rootNavigator: true).popUntil((route) =>
                route.isFirst ||
                route.settings.name == WalletHistoryPage.routeName);
            if (state.status) {
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                      WalletHistoryPage.routeName, (route) => false);
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentFail,
                            fit: BoxFit.contain,
                            width: size.width * 0.4,
                          ),
                          SizedBox(height: size.width * 0.02),
                          MyText(
                            text: AppLocalizations.of(context)!.paymentFailed,
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          CustomButton(
                            buttonName: AppLocalizations.of(context)!.ok,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            width: size.width * 0.4,
                            height: size.width * 0.12,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          } else if (state is BankUpdateSuccessState) {
            context.read<AccBloc>().add(GetWithdrawInitEvent());
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.wallet,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: RefreshIndicator(
                onRefresh: () {
                  Future<void> onrefresh() async {
                    accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));
                  }

                  return onrefresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minHeight: size.height),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Refresh Button
                        if (accBloc.showRefresh)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.03),
                              child: InkWell(
                                onTap: () {
                                  accBloc.showRefresh = false;
                                  accBloc.add(
                                      GetWalletHistoryListEvent(pageIndex: 1));
                                },
                                child: Column(
                                  children: [
                                    const Icon(Icons.refresh_outlined,
                                        size: 28),
                                    SizedBox(height: size.width * 0.01),
                                    MyText(
                                      text:
                                          AppLocalizations.of(context)!.refresh,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Wallet Balance Card
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            size.width * 0.04,
                            size.width * 0.02,
                            size.width * 0.04,
                            size.width * 0.04,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(size.width * 0.05),
                            child: Column(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .walletBalance,
                                  textStyle: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: size.width * 0.02),
                                if (context.read<AccBloc>().isLoading &&
                                    !context.read<AccBloc>().loadMore)
                                  SizedBox(
                                    height: size.width * 0.08,
                                    width: size.width * 0.08,
                                    child: const CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                if (context.read<AccBloc>().walletResponse !=
                                    null)
                                  MyText(
                                    text:
                                        '${context.read<AccBloc>().walletResponse!.currencySymbol} ${double.tryParse(context.read<AccBloc>().walletResponse!.walletBalance) != null ? double.tryParse(context.read<AccBloc>().walletResponse!.walletBalance)!.toStringAsFixed(2) : context.read<AccBloc>().walletResponse!.walletBalance}',
                                    textStyle: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                SizedBox(height: size.width * 0.05),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            size.width * 0.04,
                            size.width * 0.02,
                            size.width * 0.04,
                            size.width * 0.04,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  context: context,
                                  label: AppLocalizations.of(context)!.addMoney,
                                  onPressed: () {
                                    context
                                        .read<AccBloc>()
                                        .walletAmountController
                                        .clear();
                                    context.read<AccBloc>().addMoney = null;
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      isDismissible: true,
                                      useSafeArea: true,
                                      backgroundColor: AppColors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                      ),
                                      builder: (_) {
                                        return FractionallySizedBox(
                                          heightFactor: 1.0,
                                          child: AddMoneyWalletWidget(
                                            cont: context,
                                            minWalletAmount: context
                                                .read<AccBloc>()
                                                .walletResponse!
                                                .minimumAmountAddedToWallet,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Expanded(
                                child: _buildActionButton(
                                  context: context,
                                  label: AppLocalizations.of(context)!.withdraw,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      WithdrawPage.routeName,
                                      arguments: WithdrawPageArguments(
                                        minWalletAmount: context
                                            .read<AccBloc>()
                                            .walletResponse!
                                            .minimumAmountAddedToWallet,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (userData!
                                      .showWalletMoneyTransferFeatureOnMobileApp ==
                                  '1') ...[
                                SizedBox(width: size.width * 0.02),
                                Expanded(
                                  child: _buildActionButton(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .transferText,
                                    onPressed: () {
                                      context
                                          .read<AccBloc>()
                                          .transferAmount
                                          .clear();
                                      context
                                          .read<AccBloc>()
                                          .transferPhonenumber
                                          .clear();
                                      context.read<AccBloc>().dropdownValue =
                                          'user';
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        enableDrag: false,
                                        isDismissible: true,
                                        builder: (_) {
                                          return WalletTransferMoneyWidget(
                                              cont: context);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Saved Cards Section
                        if (context.read<AccBloc>().walletResponse != null &&
                            context
                                .read<AccBloc>()
                                .walletResponse!
                                .enableSaveCard)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .savedCards,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                    ),
                                    if (context
                                        .read<AccBloc>()
                                        .savedCardsList
                                        .isNotEmpty)
                                      IconButton(
                                        icon:
                                            const Icon(Icons.arrow_forward_ios),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            CardListWidget.routeName,
                                            arguments: PaymentMethodArguments(
                                                userData: userData!),
                                          ).then((value) {
                                            if (!context.mounted) return;
                                            context.read<AccBloc>().add(
                                                GetWalletHistoryListEvent(
                                                    pageIndex: 1));
                                            context
                                                .read<AccBloc>()
                                                .add(CardListEvent());
                                          });
                                        },
                                      )
                                  ],
                                ),
                                SizedBox(height: size.width * 0.03),
                                if (context
                                    .read<AccBloc>()
                                    .savedCardsList
                                    .isEmpty) ...[
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        CardListWidget.routeName,
                                        arguments: PaymentMethodArguments(
                                            userData: userData!),
                                      ).then((value) {
                                        if (!context.mounted) return;
                                        context.read<AccBloc>().add(
                                            GetWalletHistoryListEvent(
                                                pageIndex: 1));
                                        context
                                            .read<AccBloc>()
                                            .add(CardListEvent());
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.04),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.borderColor),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: Theme.of(context).hintColor,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 16),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .noCardsAdded,
                                            textAlign: TextAlign.center,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          CustomButton(
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .addACard,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                CardListWidget.routeName,
                                                arguments:
                                                    PaymentMethodArguments(
                                                        userData: userData!),
                                              ).then((value) {
                                                if (!context.mounted) return;
                                                context.read<AccBloc>().add(
                                                    GetWalletHistoryListEvent(
                                                        pageIndex: 1));
                                                context
                                                    .read<AccBloc>()
                                                    .add(CardListEvent());
                                              });
                                            },
                                            width: size.width,
                                            buttonColor: AppColors.primary,
                                            textColor: AppColors.white,
                                            textSize: 16,
                                            borderRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: context
                                        .read<AccBloc>()
                                        .savedCardsList
                                        .length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: size.width * 0.02),
                                    itemBuilder: (context, index) {
                                      final card = context
                                          .read<AccBloc>()
                                          .savedCardsList
                                          .elementAt(index);
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                  AppImages.simCard,
                                                  height: size.width * 0.1,
                                                  width: size.width * 0.1,
                                                ),
                                                Image.asset(
                                                  (card.cardType
                                                          .toLowerCase()
                                                          .contains('visa'))
                                                      ? AppImages.visa
                                                      : (card.cardType
                                                              .toLowerCase()
                                                              .contains(
                                                                  'eftpos'))
                                                          ? AppImages.eftpos
                                                          : (card.cardType
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      'american'))
                                                              ? AppImages
                                                                  .americanExpress
                                                              : (card.cardType
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          'jcb'))
                                                                  ? AppImages
                                                                      .jcb
                                                                  : (card.cardType
                                                                          .toLowerCase()
                                                                          .contains(
                                                                              'discover || dinners'))
                                                                      ? AppImages
                                                                          .discover
                                                                      : AppImages
                                                                          .master,
                                                  height: size.width * 0.1,
                                                  width: size.width * 0.2,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: size.width * 0.04),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyText(
                                                  text:
                                                      '**** **** **** ${card.lastNumber}',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: AppColors.white,
                                                        fontSize:
                                                            size.width * 0.06,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),

                        // Recent Transactions Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.width * 0.02),
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .recentTransactions,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                          ),
                        ),

                        // Transaction List
                        if (context.read<AccBloc>().isLoading &&
                            context.read<AccBloc>().firstLoad)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return ShimmerWalletHistory(size: size);
                            },
                          )
                        else if (context
                            .read<AccBloc>()
                            .walletHistoryList
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                WalletHistoryDataWidget(
                                  walletHistoryList:
                                      context.read<AccBloc>().walletHistoryList,
                                  cont: context,
                                ),
                                if (context.read<AccBloc>().loadMore)
                                  Padding(
                                    padding: EdgeInsets.all(size.width * 0.04),
                                    child: const CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          )
                        else
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.2),
                              child: Column(
                                children: [
                                  Image.asset(
                                    AppImages.noWalletHistoryImage,
                                    height: size.width * 0.5,
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .noWalletHistory,
                                    textStyle: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Payment Methods Section
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .paymentMethods,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                              ),
                              SizedBox(height: size.width * 0.03),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Builder(
                                    builder: (_) {
                                      final bankDetails =
                                          context.read<AccBloc>().bankDetails;
                                      final hasAny = bankDetails
                                          .where((e) =>
                                              e['driver_bank_info']['data']
                                                  .toString() !=
                                              '[]')
                                          .isNotEmpty;
                                      if (bankDetails.isEmpty || !hasAny) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.account_balance_outlined,
                                              size: 48,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                            SizedBox(height: size.width * 0.03),
                                            SizedBox(
                                              width: size.width * 0.8,
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .noPaymentMethodLink,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: bankDetails.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: size.width * 0.02),
                                        itemBuilder: (_, i) {
                                          final bank = bankDetails.elementAt(i);
                                          final hasData =
                                              bank['driver_bank_info']['data']
                                                      .toString() !=
                                                  '[]';
                                          return InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                context,
                                                WithdrawPage.routeName,
                                                arguments:
                                                    WithdrawPageArguments(
                                                  minWalletAmount: context
                                                      .read<AccBloc>()
                                                      .walletResponse!
                                                      .minimumAmountAddedToWallet,
                                                  initialBankIndex: i,
                                                  openEdit: hasData,
                                                ),
                                              ).then((_) {
                                                if (!context.mounted) return;
                                                context.read<AccBloc>().add(
                                                    GetWithdrawInitEvent());
                                              });
                                            },
                                            child: Container(
                                              width: size.width * 0.9,
                                              margin: EdgeInsets.only(
                                                  bottom: size.width * 0.025),
                                              padding: EdgeInsets.all(
                                                  size.width * 0.05),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Theme.of(context)
                                                    .disabledColor
                                                    .withAlpha(
                                                        (0.3 * 255).toInt()),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: MyText(
                                                      text: bank['method_name'],
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                  ),
                                                  MyText(
                                                    text: hasData
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .textView
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .textAdd,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: size.width * 0.03),
                              BlocBuilder<AccBloc, AccState>(
                                builder: (context, state) {
                                  final acc = context.read<AccBloc>();
                                  final hasAnyLinked = acc.bankDetails.any(
                                      (e) =>
                                          e['driver_bank_info']['data']
                                              .toString() !=
                                          '[]');
                                  if (hasAnyLinked) {
                                    return const SizedBox.shrink();
                                  }
                                  void showMethodsSheet() {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (_) {
                                        return BlocBuilder<AccBloc, AccState>(
                                          builder: (_, state) {
                                            return SafeArea(
                                              child: Container(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                width: size.width,
                                                padding: EdgeInsets.all(
                                                    size.width * 0.05),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.9,
                                                      child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .paymentMethods,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.width * 0.05),
                                                    if (context
                                                        .read<AccBloc>()
                                                        .bankDetails
                                                        .isNotEmpty)
                                                      ListView.builder(
                                                        itemCount: context
                                                            .read<AccBloc>()
                                                            .bankDetails
                                                            .length,
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemBuilder: (_, i) {
                                                          final bank = context
                                                              .read<AccBloc>()
                                                              .bankDetails
                                                              .elementAt(i);
                                                          final hasData =
                                                              bank['driver_bank_info']
                                                                          [
                                                                          'data']
                                                                      .toString() !=
                                                                  '[]';
                                                          return InkWell(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              Navigator
                                                                  .pushNamed(
                                                                context,
                                                                WithdrawPage
                                                                    .routeName,
                                                                arguments:
                                                                    WithdrawPageArguments(
                                                                  minWalletAmount: context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .walletResponse!
                                                                      .minimumAmountAddedToWallet,
                                                                  initialBankIndex:
                                                                      i,
                                                                  openEdit:
                                                                      hasData,
                                                                ),
                                                              ).then((result) {
                                                                if (!context
                                                                    .mounted)
                                                                  return;
                                                                acc.add(
                                                                    GetWithdrawInitEvent());
                                                                if (result ==
                                                                    true) {
                                                                  // After successful update, re-open sheet to reflect changes
                                                                  WidgetsBinding
                                                                      .instance
                                                                      .addPostFrameCallback(
                                                                          (_) {
                                                                    showMethodsSheet();
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.9,
                                                              margin: EdgeInsets.only(
                                                                  bottom: size
                                                                          .width *
                                                                      0.025),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      size.width *
                                                                          0.05),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor
                                                                    .withAlpha((0.3 *
                                                                            255)
                                                                        .toInt()),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        MyText(
                                                                      text: bank[
                                                                          'method_name'],
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge!
                                                                          .copyWith(
                                                                            color:
                                                                                Theme.of(context).primaryColorDark,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  MyText(
                                                                    text: hasData
                                                                        ? AppLocalizations.of(context)!
                                                                            .textView
                                                                        : AppLocalizations.of(context)!
                                                                            .textAdd,
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                          color:
                                                                              Theme.of(context).primaryColorDark,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    SizedBox(
                                                        height:
                                                            size.width * 0.08),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }

                                  return CustomButton(
                                    buttonName: AppLocalizations.of(context)!
                                        .linkBankAccount,
                                    onTap: () {
                                      final banks = acc.bankDetails;
                                      if (banks.isEmpty) {
                                        acc.add(GetWithdrawInitEvent());
                                        return;
                                      }
                                      showMethodsSheet();
                                    },
                                    width: double.infinity,
                                    height: size.width * 0.12,
                                    buttonColor: const Color(0xFF0D47A1),
                                    textColor: AppColors.white,
                                    textSize: 16,
                                    borderRadius: 8,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFF0F2FF),
        foregroundColor: AppColors.white,
        side: const BorderSide(color: Color(0xFFF0F2FF), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
