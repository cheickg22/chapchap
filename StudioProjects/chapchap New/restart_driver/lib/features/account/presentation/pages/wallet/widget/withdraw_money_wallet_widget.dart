import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WithdrawMoneyWalletWidget extends StatelessWidget {
  final BuildContext cont;
  final String minWalletAmount;
  const WithdrawMoneyWalletWidget(
      {super.key, required this.cont, required this.minWalletAmount});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return SafeArea(
            child: Container(
              padding: MediaQuery.viewInsetsOf(context),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * 0.05),
                      topRight: Radius.circular(size.width * 0.05))),
              child: Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: size.width * 0.128,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1.2,
                              color: Theme.of(context).disabledColor)),
                      child: Row(
                        children: [
                          Container(
                            width: size.width * 0.15,
                            height: size.width * 0.128,
                            decoration: BoxDecoration(
                                borderRadius:
                                    (context.read<AccBloc>().textDirection ==
                                            'ltr')
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          )
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12)),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                            alignment: Alignment.center,
                            child: MyText(
                                text: userData!.currencySymbol.toString()),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Container(
                            height: size.width * 0.128,
                            width: size.width * 0.6,
                            alignment: Alignment.center,
                            child: TextField(
                              controller: context
                                  .read<AccBloc>()
                                  .withdrawAmountController,
                              onChanged: (value) {
                                context.read<AccBloc>().addMoney =
                                    int.parse(value);
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: AppLocalizations.of(context)!
                                      .enterAmount),
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            context
                                    .read<AccBloc>()
                                    .withdrawAmountController
                                    .text =
                                double.parse(minWalletAmount).toString();
                            context.read<AccBloc>().addMoney =
                                double.parse(minWalletAmount);
                          },
                          child: Container(
                            height: size.width * 0.11,
                            width: size.width * 0.17,
                            // width: size.width *
                            //     0.275,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).disabledColor,
                                    width: 1.2),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                                text:
                                    '${userData!.currencySymbol.toString()} ${double.parse(minWalletAmount)}'),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        InkWell(
                          onTap: () {
                            context
                                    .read<AccBloc>()
                                    .withdrawAmountController
                                    .text =
                                (double.parse(minWalletAmount) * 2).toString();
                            context.read<AccBloc>().addMoney =
                                double.parse(minWalletAmount) * 2;
                          },
                          child: Container(
                            height: size.width * 0.11,
                            width: size.width * 0.17,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).disabledColor,
                                    width: 1.2),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                                text:
                                    '${userData!.currencySymbol.toString()} ${double.parse(minWalletAmount) * 2}'),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        InkWell(
                          onTap: () {
                            context
                                    .read<AccBloc>()
                                    .withdrawAmountController
                                    .text =
                                (double.parse(minWalletAmount) * 3).toString();
                            context.read<AccBloc>().addMoney =
                                double.parse(minWalletAmount) * 3;
                          },
                          child: Container(
                            height: size.width * 0.11,
                            width: size.width * 0.17,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).disabledColor,
                                    width: 1.2),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                                text:
                                    '${userData!.currencySymbol.toString()} ${double.parse(minWalletAmount) * 3}'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: size.width * 0.11,
                            width: size.width * 0.425,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.2),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                              text: AppLocalizations.of(context)!.cancel,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if (context
                                    .read<AccBloc>()
                                    .withdrawAmountController
                                    .text
                                    .isNotEmpty &&
                                double.parse(context
                                        .read<AccBloc>()
                                        .withdrawResponse!
                                        .walletBalance) >=
                                    double.parse(context
                                        .read<AccBloc>()
                                        .withdrawAmountController
                                        .text)) {
                              context.read<AccBloc>().add(RequestWithdrawEvent(
                                  amount: context
                                      .read<AccBloc>()
                                      .withdrawAmountController
                                      .text));
                            } else {
                              context.showSnackBar(
                                  color: AppColors.red,
                                  message: AppLocalizations.of(context)!
                                      .insufficientWithdraw);
                            }
                          },
                          child: Container(
                            height: size.width * 0.11,
                            width: size.width * 0.425,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                              text: AppLocalizations.of(context)!.withdraw,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
