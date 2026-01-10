import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/expired_sec_widget.dart';
import '../widget/no_subscription_widget.dart';
import '../widget/subscription_list_widget.dart';
import '../widget/success_sec_widget.dart';

class SubscriptionPage extends StatelessWidget {
  static const String routeName = '/subscriptionPage';
  final SubscriptionPageArguments args;
  const SubscriptionPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetSubscriptionListEvent())
        ..add(GetWalletHistoryListEvent(pageIndex: 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          final accBloc = context.read<AccBloc>();
          if (state is SubscriptionPayLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is SubscriptionPayLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is SubscriptionPaySuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is WalletEmptyState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .lowWalletBalanceForSubscription),
              ),
            );
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
          if (state is WalletPageReUpdateState) {
            accBloc.showRefresh = true;
            accBloc.add(
              AddMoneyWebViewUrlEvent(
                currencySymbol: state.currencySymbol,
                from: '2',
                requestId: state.requestId,
                money: state.money,
                planId: state.planId,
                url: state.url,
                userId: state.userId,
                context: context,
              ),
            );
          }
          if (state is PaymentUpdateState) {
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
                                  .add(AccGetUserDetailsEvent());
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
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () {
                  Future<void> onrefresh() async {
                    accBloc.add(AccGetUserDetailsEvent());
                  }

                  return onrefresh();
                },
                child: (userData != null &&
                        userData!.subscription == null &&
                        !context.read<AccBloc>().isPlansChooseds)
                    ? NoSubscriptionWidget(
                        cont: context, isFromAccPage: args.isFromAccPage)
                    : ((userData != null && userData!.isSubscribed!) ||
                            (context.read<AccBloc>().subscriptionSuccessData !=
                                    null &&
                                context
                                        .read<AccBloc>()
                                        .subscriptionSuccessData!
                                        .isSubscribed ==
                                    '1'))
                        ? SuccessSecWidget(
                            cont: context, isFromAccPage: args.isFromAccPage)
                        : (userData != null && !userData!.hasSubscription!) ||
                                context.read<AccBloc>().isPlansChooseds
                            ? SubscriptionListWidget(
                                cont: context,
                                isFromAccPage: args.isFromAccPage,
                                currencySymbol: userData!.currencySymbol,
                                subscriptionListDatas:
                                    context.read<AccBloc>().subscriptionList)
                            : (userData != null && userData!.isExpired!) &&
                                    !context.read<AccBloc>().isPlansChooseds
                                ? ExpiredSecWidget(
                                    // cont: context,
                                    isFromAccPage: args.isFromAccPage,
                                    accBloc: context.read<AccBloc>(),
                                  )
                                : SubscriptionListWidget(
                                    cont: context,
                                    isFromAccPage: args.isFromAccPage,
                                    currencySymbol: userData!.currencySymbol,
                                    subscriptionListDatas: context
                                        .read<AccBloc>()
                                        .subscriptionList),
              ),
            ),
          );
        }),
      ),
    );
  }
}
