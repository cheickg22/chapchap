import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_header.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/subcription_list_model.dart';
import 'payment_gateway_list.dart';
import 'subscription_shimmer.dart';

class SubscriptionListWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  final String currencySymbol;
  final List<SubscriptionData> subscriptionListDatas;
  const SubscriptionListWidget(
      {super.key,
      required this.cont,
      required this.subscriptionListDatas,
      required this.currencySymbol,
      required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        final accBloc = context.read<AccBloc>();
        return subscriptionListDatas.isNotEmpty
            ? SafeArea(
                child: Column(
                  children: [
                    CustomHeader(
                      title: AppLocalizations.of(context)!.subscription,
                      automaticallyImplyLeading: true,
                      titleFontSize: 18,
                    ),
                    SizedBox(height: size.width * 0.03),
                    if (accBloc.showRefresh) ...[
                      InkWell(
                        onTap: () {
                          accBloc.showRefresh = false;
                          accBloc.add(GetWalletHistoryListEvent(pageIndex: 1));
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.refresh_outlined),
                            SizedBox(height: size.width * 0.01),
                            MyText(
                                text: AppLocalizations.of(context)!.refresh,
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall!),
                            SizedBox(height: size.width * 0.02),
                          ],
                        ),
                      )
                    ],
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .chooseYourSubscription,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subscriptionListDatas.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  context.read<AccBloc>().add(
                                        SubscriptionOnTapEvent(
                                            selectedPlanIndex: index),
                                      );
                                },
                                child: Container(
                                  width: size.width * 0.9,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  margin: EdgeInsets.only(
                                      bottom: size.width * 0.025),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: (context
                                                    .read<AccBloc>()
                                                    .choosenPlanindex ==
                                                index)
                                            ? AppColors.primary
                                            : AppColors.borderColors,
                                        width: 1.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: size.width * 0.05,
                                        width: size.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenPlanindex ==
                                                      index)
                                                  ? AppColors.primary
                                                  : Colors.black),
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: size.width * 0.03,
                                          width: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenPlanindex ==
                                                      index)
                                                  ? AppColors.primary
                                                  : Colors.transparent),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(width: size.width * 0.04),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    MyText(
                                                        text:
                                                            subscriptionListDatas[
                                                                    index]
                                                                .name
                                                                .toString(),
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                    SizedBox(
                                                      width: size.width * 0.02,
                                                    ),
                                                    MyText(
                                                      text: currencySymbol,
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.01,
                                                    ),
                                                    MyText(
                                                      text:
                                                          subscriptionListDatas[
                                                                  index]
                                                              .amount
                                                              .toString(),
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.6,
                                                  child: MyText(
                                                    text: subscriptionListDatas[
                                                            index]
                                                        .description
                                                        .toString(),
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                            size.width * 0.05,
                          ),
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .choosePaymentMethod,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                context.read<AccBloc>().add(
                                    SubscriptionPaymentOnTapEvent(
                                        selectedPayIndex: 0));
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.05,
                                    height: size.width * 0.05,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: size.width * 0.03,
                                      height: size.width * 0.03,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (context
                                                      .read<AccBloc>()
                                                      .choosenSubscriptionPayIndex ==
                                                  0)
                                              ? Theme.of(context)
                                                  .primaryColorDark
                                              : Colors.transparent),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.025,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!.card,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.025,
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                context.read<AccBloc>().add(
                                      SubscriptionPaymentOnTapEvent(
                                          selectedPayIndex: 2),
                                    );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.05,
                                    height: size.width * 0.05,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1.5,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: size.width * 0.03,
                                      height: size.width * 0.03,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (context
                                                      .read<AccBloc>()
                                                      .choosenSubscriptionPayIndex ==
                                                  2)
                                              ? Theme.of(context)
                                                  .primaryColorDark
                                              : Colors.transparent),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 0.025,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!.wallet,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.025),
                      child: CustomButton(
                        buttonName: AppLocalizations.of(context)!.confirm,
                        width: size.width,
                        textSize: 18,
                        onTap: () async {
                          if (context
                                  .read<AccBloc>()
                                  .choosenSubscriptionPayIndex ==
                              2) {
                            if (subscriptionListDatas[context
                                        .read<AccBloc>()
                                        .choosenPlanindex]
                                    .amount! >=
                                userData!.wallet!.data.amountBalance) {
                              context.read<AccBloc>().add(WalletEmptyEvent());
                            } else if (subscriptionListDatas[context
                                        .read<AccBloc>()
                                        .choosenPlanindex]
                                    .amount! <=
                                userData!.wallet!.data.amountBalance) {
                              context.read<AccBloc>().add(
                                    SubscribeToPlanEvent(
                                        paymentOpt: context
                                            .read<AccBloc>()
                                            .choosenSubscriptionPayIndex!,
                                        amount: (subscriptionListDatas[context
                                                    .read<AccBloc>()
                                                    .choosenPlanindex]
                                                .amount!)
                                            .toInt(),
                                        planId: subscriptionListDatas[context
                                                .read<AccBloc>()
                                                .choosenPlanindex]
                                            .id!),
                                  );
                            }
                          } else if (context
                                  .read<AccBloc>()
                                  .choosenSubscriptionPayIndex ==
                              0) {
                            context
                                .read<AccBloc>()
                                .walletAmountController
                                .clear();
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: false,
                                enableDrag: false,
                                isDismissible: true,
                                builder: (_) {
                                  return BlocProvider.value(
                                    value: context.read<AccBloc>(),
                                    child: PaymentGatewayListWidget(
                                      cont: context,
                                      walletPaymentGatways: context
                                          .read<AccBloc>()
                                          .walletPaymentGatways,
                                    ),
                                  );
                                });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: size.width * 0.05,
                ),
                child: SubscriptionShimmer(size: size),
              );
      }),
    );
  }
}
