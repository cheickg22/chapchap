import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WalletTransferMoneyWidget extends StatelessWidget {
  final BuildContext cont;
  const WalletTransferMoneyWidget({super.key, required this.cont});

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
              width: size.width,
              child: Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.transferMoney,
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: size.width * 0.02),
                    Text(
                      AppLocalizations.of(context)!.selectRecipientType,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: size.width * 0.04),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: size.width * 0.035,
                          horizontal: size.width * 0.035,
                        ),
                      ),
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                      value: context.read<AccBloc>().dropdownValue,
                      onChanged: (String? newValue) {
                        context.read<AccBloc>().add(TransferMoneySelectedEvent(
                            selectedTransferAmountMenuItem: newValue!));
                      },
                      items: context.read<AccBloc>().dropdownItems,
                    ),
                    SizedBox(height: size.width * 0.03),
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
                              controller:
                                  context.read<AccBloc>().transferAmount,
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
                    SizedBox(height: size.width * 0.03),
                    CustomTextField(
                      controller: context.read<AccBloc>().transferPhonenumber,
                      keyboardType: TextInputType.number,
                      filled: true,
                      borderRadius: 10,
                      hintText: AppLocalizations.of(context)!.enterMobileNumber,
                      contentPadding: EdgeInsets.all(size.width * 0.05),
                      prefixIcon: const Icon(Icons.phone_android, size: 20),
                    ),
                    SizedBox(height: size.width * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: size.width * 0.12,
                            width: size.width * 0.42,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.2),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: MyText(
                              text: AppLocalizations.of(context)!.cancel,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: AppColors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (context.read<AccBloc>().transferAmount.text ==
                                    '' ||
                                context
                                        .read<AccBloc>()
                                        .transferPhonenumber
                                        .text ==
                                    '') {
                            } else {
                              context.read<AccBloc>().add(MoneyTransferedEvent(
                                  transferAmount: context
                                      .read<AccBloc>()
                                      .transferAmount
                                      .text,
                                  role: context.read<AccBloc>().dropdownValue,
                                  transferMobile: context
                                      .read<AccBloc>()
                                      .transferPhonenumber
                                      .text));
                              // Navigator.pop(context);
                            }
                          },
                          child: Container(
                            height: size.width * 0.12,
                            width: size.width * 0.42,
                            decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1),
                                borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: MyText(
                              text: AppLocalizations.of(context)!.transferMoney,
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
