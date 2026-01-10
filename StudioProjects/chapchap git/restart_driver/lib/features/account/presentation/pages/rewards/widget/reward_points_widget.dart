import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class RewardPointsWidget extends StatelessWidget {
  final BuildContext cont;
  const RewardPointsWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return AlertDialog(
              content: SizedBox(
            width: size.width,
            height: size.height * 0.38,
            child: Stack(
              children: [
                Column(
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.redeemPointsToWallet,
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    MyText(
                      text: AppLocalizations.of(context)!
                          .redeemRateText
                          .replaceAll(
                              "*",
                              userData!.loyaltyPoints!.data.conversionQuotient
                                  .toString())
                          .replaceAll("z", userData!.currencySymbol),
                      textStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.greyHintColor,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Container(
                      height: size.width * 0.142,
                      width: size.width * 0.6,
                      alignment: Alignment.center,
                      child: TextField(
                        controller:
                            context.read<AccBloc>().rewardAmountController,
                        onChanged: (value) {
                          context.read<AccBloc>().addRewardMoney =
                              int.tryParse(value);
                          double? redeemedAmount = (int.tryParse(context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text) ??
                                  0) /
                              userData!.loyaltyPoints!.data.conversionQuotient;
                          context.read<AccBloc>().add(UpdateRedeemedAmountEvent(
                              redeemedAmount: redeemedAmount));
                        },
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.03,
                    ),
                    userData!.loyaltyPoints!.data.balanceRewardPoints > 1000
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text = '100';
                                  context.read<AccBloc>().addRewardMoney = 100;
                                  context.read<AccBloc>().add(
                                      UpdateRedeemedAmountEvent(
                                          redeemedAmount: (context
                                                  .read<AccBloc>()
                                                  .addRewardMoney) /
                                              userData!.loyaltyPoints!.data
                                                  .conversionQuotient));
                                },
                                child: Container(
                                  height: size.width * 0.08,
                                  width: size.width * 0.17,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).disabledColor,
                                          width: 1.2),
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.08 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(30)),
                                  alignment: Alignment.center,
                                  child: const MyText(text: '100'),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.05,
                              ),
                              InkWell(
                                onTap: () {
                                  context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text = '200';
                                  context.read<AccBloc>().addRewardMoney = 200;
                                  context.read<AccBloc>().add(
                                      UpdateRedeemedAmountEvent(
                                          redeemedAmount: (context
                                                  .read<AccBloc>()
                                                  .addRewardMoney) /
                                              userData!.loyaltyPoints!.data
                                                  .conversionQuotient));
                                },
                                child: Container(
                                  height: size.width * 0.08,
                                  width: size.width * 0.17,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).disabledColor,
                                          width: 1.2),
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.08 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(30)),
                                  alignment: Alignment.center,
                                  child: const MyText(text: '200'),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.05,
                              ),
                              InkWell(
                                onTap: () {
                                  context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text = '300';
                                  context.read<AccBloc>().addRewardMoney = 300;
                                  context.read<AccBloc>().add(
                                      UpdateRedeemedAmountEvent(
                                          redeemedAmount: (context
                                                  .read<AccBloc>()
                                                  .addRewardMoney) /
                                              userData!.loyaltyPoints!.data
                                                  .conversionQuotient));
                                },
                                child: Container(
                                  height: size.width * 0.08,
                                  width: size.width * 0.17,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Theme.of(context).disabledColor,
                                          width: 1.2),
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.08 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(30)),
                                  alignment: Alignment.center,
                                  child: const MyText(text: '300'),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    MyText(
                      text: AppLocalizations.of(context)!
                          .redeemedAmount
                          .replaceAll("*",
                              context.read<AccBloc>().redeemedAmount.toString())
                          .replaceAll("s", userData!.currencySymbol),
                      textStyle: const TextStyle(
                          fontSize: 16,
                          color: AppColors.greyHintColor,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.width * 0.05),
                    CustomButton(
                      buttonName: AppLocalizations.of(context)!.redeemPoints,
                      buttonColor: AppColors.primary,
                      onTap: () {
                        if ((context
                                .read<AccBloc>()
                                .rewardAmountController
                                .text
                                .isEmpty &&
                            context.read<AccBloc>().addRewardMoney == null)) {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .enterRequiredField);
                        } else if (context
                                .read<AccBloc>()
                                .rewardAmountController
                                .text
                                .isNotEmpty &&
                            int.tryParse(context
                                    .read<AccBloc>()
                                    .rewardAmountController
                                    .text)! <
                                userData!
                                    .loyaltyPoints!.data.minimumRewardPoints) {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .rewardsGreaterText);
                        } else {
                          Navigator.of(context).pop();
                          context.read<AccBloc>().add(RedeemPointsEvent(
                              amount: context
                                  .read<AccBloc>()
                                  .rewardAmountController
                                  .text));

                          context
                              .read<AccBloc>()
                              .rewardAmountController
                              .clear();
                        }
                      },
                    ),
                    SizedBox(
                      height: size.width * 0.01,
                    ),
                  ],
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
