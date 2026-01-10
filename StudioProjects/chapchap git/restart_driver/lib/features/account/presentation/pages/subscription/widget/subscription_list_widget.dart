import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
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
                    Padding(
                      padding: EdgeInsets.all(
                        size.width * 0.05,
                      ),
                      child: Row(
                        children: [
                          (isFromAccPage)
                              ? InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: size.width * 0.07,
                                    color: AppColors.black,
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.subscription,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 18, color: AppColors.blackText),
                          ),
                        ],
                      ),
                    ),
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
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .chooseYourSubscription,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: AppColors.blackText),
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
                                  padding: EdgeInsets.all(size.width * 0.03),
                                  margin: EdgeInsets.only(
                                      bottom: size.width * 0.025),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: size.width * 0.05,
                                        height: size.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1.5,
                                              color: AppColors.black),
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: size.width * 0.03,
                                          height: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenPlanindex ==
                                                      index)
                                                  ? AppColors.black
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
                                                        textStyle: Theme
                                                                .of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .blackText,
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
                                                              color: AppColors
                                                                  .blackText,
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
                                                              color: AppColors
                                                                  .blackText,
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
                                                            color: AppColors
                                                                .blackText),
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
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackText),
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
                                      border:
                                          Border.all(color: AppColors.black),
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
                                              ? AppColors.black
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
                                        .headlineMedium!
                                        .copyWith(
                                            fontSize: 18,
                                            color: AppColors.blackText),
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
                                          width: 1.5, color: AppColors.black),
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
                                              ? AppColors.black
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
                                        .headlineMedium!
                                        .copyWith(
                                            fontSize: 18,
                                            color: AppColors.blackText),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * 0.06,
                    ),
                    CustomButton(
                      buttonName: AppLocalizations.of(context)!.confirm,
                      onTap: () async {
                        if (context
                                .read<AccBloc>()
                                .choosenSubscriptionPayIndex ==
                            2) {
                          if (subscriptionListDatas[
                                      context.read<AccBloc>().choosenPlanindex]
                                  .amount! >=
                              userData!.wallet!.data.amountBalance) {
                            context.read<AccBloc>().add(WalletEmptyEvent());
                          } else if (subscriptionListDatas[
                                      context.read<AccBloc>().choosenPlanindex]
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
