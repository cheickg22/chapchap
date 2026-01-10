import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/pages/wallet/page/withdraw_page.dart';
import 'package:restart_user/features/account/presentation/pages/wallet/widget/wallet_shimmer.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../auth/application/auth_bloc.dart';
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
        ..add(GetWalletHistoryListEvent(pageIndex: 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          final accBloc = context.read<AccBloc>();
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is MoneyTransferedSuccessState) {
            Navigator.pop(context);
          } else if (state is WalletPageReUpdateState) {
            accBloc.showRefresh = true;
            accBloc.add(AddMoneyWebViewUrlEvent(
                currencySymbol: state.currencySymbol,
                from: '',
                requestId: state.requestId,
                planId: '',
                money: state.money,
                url: state.url,
                userId: state.userId,
                context:context,
              ),
            );
          } else if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          } else if (state is PaymentUpdateState) {
            if (state.status) {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentSuccess,
                            fit: BoxFit.contain,
                            width: size.width * 0.5,
                          ),
                          SizedBox(height: size.width * 0.02),
                          Text(
                            AppLocalizations.of(context)!.paymentSuccess,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<AccBloc>()
                                  .add(GetWalletHistoryListEvent(pageIndex: 1));
                            },
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
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
                          Text(
                            AppLocalizations.of(context)!.paymentFailed,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.wallet,
              automaticallyImplyLeading: true,
            ),
            body: RefreshIndicator(
              onRefresh: () {
                Future<void> onrefresh() async{
                  accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));                     
                }
                return onrefresh();
              },
              child: SizedBox(
                height: size.height,
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.03),
                    if(accBloc.showRefresh)...[
                        InkWell(
                          onTap: () {
                            accBloc.showRefresh = false;
                            accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));
                          },
                          child: Column(
                            children: [
                              const Icon(Icons.refresh_outlined),
                              SizedBox(height: size.width * 0.01),
                              MyText(text: 'Refresh',
                              textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!),
                              SizedBox(height: size.width * 0.02),
                            ],
                          ),
                        )
                      ],
                    SizedBox(
                      // height: size.width * 0.4,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: size.width * 0.05,
                          top: size.width * 0.025,
                          right: size.width * 0.05,
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.only(
                                top: size.width * 0.05,
                              ),
                              child: Column(
                                children: [
                                  MyText(
                                      text: AppLocalizations.of(context)!
                                          .walletBalance,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: AppColors.white,
                                              fontSize: 20)),
                                  if (context.read<AccBloc>().isLoading &&
                                      !context.read<AccBloc>().loadMore)
                                    SizedBox(
                                      height: size.width * 0.06,
                                      width: size.width * 0.06,
                                      child: const Loader(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  if (context.read<AccBloc>().walletResponse !=
                                      null)
                                    Center(
                                      child: MyText(
                                          text:
                                              '${double.tryParse(context.read<AccBloc>().walletResponse!.walletBalance) != null ? double.tryParse(context.read<AccBloc>().walletResponse!.walletBalance)!.toStringAsFixed(2) : context.read<AccBloc>().walletResponse!.walletBalance} ${context.read<AccBloc>().walletResponse!.currencySymbol}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(color: AppColors.white)),
                                    ),
                                  SizedBox(height: size.width * 0.04),
                                  Container(
                                    width: size.width,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.01,
                                            vertical: size.width * 0.025),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                context
                                                    .read<AccBloc>()
                                                    .walletAmountController
                                                    .clear();
                                                context.read<AccBloc>().addMoney =
                                                    null;
                                                showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    enableDrag: false,
                                                    isDismissible: true,
                                                    builder: (_) {
                                                      return AddMoneyWalletWidget(
                                                          cont: context,
                                                          minWalletAmount: context
                                                              .read<AccBloc>()
                                                              .walletResponse!
                                                              .minimumAmountAddedToWallet);
                                                    });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.22,
                                                      child: MyText(
                                                          text:
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .addMoney,
                                                          maxLines: 2,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .white,
                                                                  fontSize: 14)),
                                                    ),
                                                    SizedBox(
                                                        width: size.width * 0.01),
                                                    Container(
                                                      height: size.width * 0.05,
                                                      width: size.width * 0.05,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                              color: AppColors
                                                                  .white)),
                                                      alignment: Alignment.center,
                                                      child: Icon(Icons.add,
                                                          size: size.width * 0.03,
                                                          color: AppColors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    WithdrawPage.routeName,
                                                    arguments: WithdrawPageArguments(
                                                        minWalletAmount: context
                                                            .read<AccBloc>()
                                                            .walletResponse!
                                                            .minimumAmountAddedToWallet));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: size.width * 0.22,
                                                      child: MyText(
                                                        text: AppLocalizations.of(
                                                                context)!
                                                            .withdraw,
                                                        maxLines: 2,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .white,
                                                                fontSize: 14),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: size.width * 0.05,
                                                      width: size.width * 0.05,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                              color: AppColors
                                                                  .white)),
                                                      alignment: Alignment.center,
                                                      child: Icon(
                                                          Icons.arrow_downward,
                                                          size: size.width * 0.03,
                                                          color: AppColors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (userData!
                                                    .showWalletMoneyTransferFeatureOnMobileApp ==
                                                '1')
                                              InkWell(
                                                onTap: () {
                                                  context
                                                      .read<AccBloc>()
                                                      .transferAmount
                                                      .clear();
                                                  context
                                                      .read<AccBloc>()
                                                      .transferPhonenumber
                                                      .clear();
                                                  context
                                                      .read<AccBloc>()
                                                      .dropdownValue = 'user';
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      enableDrag: false,
                                                      isDismissible: true,
                                                      builder: (_) {
                                                        return WalletTransferMoneyWidget(
                                                            cont: context);
                                                      });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 5.0),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: size.width * 0.2,
                                                        child: MyText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .transferText,
                                                            maxLines: 2,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .white,
                                                                    fontSize:
                                                                        14)),
                                                      ),
                                                      Container(
                                                        height: size.width * 0.05,
                                                        width: size.width * 0.05,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .white)),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(Icons.redo,
                                                            size:
                                                                size.width * 0.03,
                                                            color:
                                                                AppColors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: size.width,
                        padding: EdgeInsets.only(
                            left: size.width * 0.05,
                            right: size.width * 0.05,
                            bottom: size.width * 0.05),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: size.width * 0.01),
                            if (context.read<AccBloc>().walletResponse != null &&
                                context
                                    .read<AccBloc>()
                                    .walletResponse!
                                    .enableSaveCard) ...[
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, CardListWidget.routeName,
                                          arguments: PaymentMethodArguments(
                                              userData: userData!))
                                      .then(
                                    (value) {
                                      if (!context.mounted) return;
                                      context.read<AccBloc>().add(
                                          GetWalletHistoryListEvent(
                                              pageIndex: 1));
                                    },
                                  );
                                },
                                child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        size.width * 0.025,
                                        size.width * 0.03,
                                        size.width * 0.025),
                                    width: size.width,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
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
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 18,
                                            color: AppColors.white)
                                      ],
                                    )),
                              ),
                              SizedBox(height: size.width * 0.02),
                            ],
                            Row(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .recentTransactions,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color:
                                              Theme.of(context).primaryColorDark),
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.025),
                            if (context.read<AccBloc>().isLoading &&
                                context.read<AccBloc>().firstLoad)
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return ShimmerWalletHistory(size: size);
                                  },
                                ),
                              ),
                            if (context
                                .read<AccBloc>()
                                .walletHistoryList
                                .isNotEmpty) ...[
                              Expanded(
                                child: SingleChildScrollView(
                                  controller:
                                      context.read<AccBloc>().scrollController,
                                  child: Column(
                                    children: [
                                      WalletHistoryDataWidget(
                                        walletHistoryList: context
                                            .read<AccBloc>()
                                            .walletHistoryList,
                                        cont: context,
                                      ),
                                      if (context.read<AccBloc>().loadMore)
                                        Center(
                                          child: SizedBox(
                                              height: size.width * 0.08,
                                              width: size.width * 0.08,
                                              child:
                                                  const CircularProgressIndicator()),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              (context.read<AccBloc>().isLoading &&
                                      context.read<AccBloc>().firstLoad)
                                  ? const SizedBox()
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: size.width * 0.2,
                                          ),
                                          Image.asset(
                                            AppImages.sosNoData,
                                            height: size.width * 0.6,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .noWalletHistoryText,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
