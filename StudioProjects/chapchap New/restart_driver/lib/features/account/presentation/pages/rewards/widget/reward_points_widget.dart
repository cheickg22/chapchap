import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';

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
              insetPadding: EdgeInsets.all(
                  size.width * 0.05), // removes default side padding
              contentPadding: EdgeInsets.all(size.width * 0.05),
              content: SizedBox(
                width: size.width,
                height: size.height * 0.32,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!
                              .redeemPointsToWallet,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!
                              .redeemRateText
                              .replaceAll(
                                  "*",
                                  userData!
                                      .loyaltyPoints!.data.conversionQuotient
                                      .toString())
                              .replaceAll("z", userData!.currencySymbol),
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: CustomTextField(
                            contentPadding: EdgeInsets.all(size.width * 0.025),
                            controller:
                                context.read<AccBloc>().rewardAmountController,
                            maxLine: 1,
                            onChange: (value) {
                              context.read<AccBloc>().addRewardMoney =
                                  int.tryParse(value);
                              double? redeemedAmount = (int.tryParse(context
                                          .read<AccBloc>()
                                          .rewardAmountController
                                          .text) ??
                                      0) /
                                  userData!
                                      .loyaltyPoints!.data.conversionQuotient;
                              context.read<AccBloc>().add(
                                  UpdateRedeemedAmountEvent(
                                      redeemedAmount: redeemedAmount));
                            },
                            keyboardType: TextInputType.number,
                            hintText: AppLocalizations.of(context)!
                                .enterPointsToRedeem,
                            hintTextStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                ),
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.borderColors, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.borderColors, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.borderColors, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.03,
                        ),
                        userData!.loyaltyPoints!.data.balanceRewardPoints > 1000
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<AccBloc>()
                                          .rewardAmountController
                                          .text = '100';
                                      context.read<AccBloc>().addRewardMoney =
                                          100;
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
                                      width: size.width * 0.23,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.borderColors,
                                              width: 1.2),
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withAlpha((0.08 * 255).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(5)),
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
                                      context.read<AccBloc>().addRewardMoney =
                                          200;
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
                                      width: size.width * 0.23,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.borderColors,
                                              width: 1.2),
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withAlpha((0.08 * 255).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(5)),
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
                                      context.read<AccBloc>().addRewardMoney =
                                          300;
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
                                      width: size.width * 0.23,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.borderColors,
                                              width: 1.2),
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withAlpha((0.08 * 255).toInt()),
                                          borderRadius:
                                              BorderRadius.circular(5)),
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
                              .replaceAll(
                                  "*",
                                  context
                                      .read<AccBloc>()
                                      .redeemedAmount
                                      .toString())
                              .replaceAll("s", userData!.currencySymbol),
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.width * 0.05),
                        CustomButton(
                          buttonName:
                              AppLocalizations.of(context)!.redeemPoints,
                          buttonColor: AppColors.primary,
                          width: size.width,
                          textSize: 18,
                          onTap: () {
                            if ((context
                                    .read<AccBloc>()
                                    .rewardAmountController
                                    .text
                                    .isEmpty &&
                                context.read<AccBloc>().addRewardMoney ==
                                    null)) {
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
                                    userData!.loyaltyPoints!.data
                                        .minimumRewardPoints) {
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
