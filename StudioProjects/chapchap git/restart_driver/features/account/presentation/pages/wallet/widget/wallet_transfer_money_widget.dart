import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
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
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        filled: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                            width: 1.2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.2,
                          style: BorderStyle.solid,
                        )),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Theme.of(context).disabledColor,
                          width: 1.2,
                          style: BorderStyle.solid,
                        )),
                      ),
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                      value: context.read<AccBloc>().dropdownValue,
                      onChanged: (String? newValue) {
                        context.read<AccBloc>().add(TransferMoneySelectedEvent(
                            selectedTransferAmountMenuItem: newValue!));
                      },
                      items: context.read<AccBloc>().dropdownItems,
                    ),
                    TextFormField(
                      controller: context.read<AccBloc>().transferAmount,
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterAmount,
                          counterText: '',
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                            width: 1.2,
                            style: BorderStyle.solid,
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                            width: 1.2,
                            style: BorderStyle.solid,
                          )),
                          prefixIcon: Center(
                              child: MyText(text: userData!.currencySymbol)),
                          prefixIconConstraints:
                              BoxConstraints(maxWidth: size.width * 0.1)),
                    ),
                    TextFormField(
                      controller: context.read<AccBloc>().transferPhonenumber,
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.enterMobileNumber,
                          counterText: '',
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                            width: 1.2,
                            style: BorderStyle.solid,
                          )),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                            color: Theme.of(context).disabledColor,
                            width: 1.2,
                            style: BorderStyle.solid,
                          )),
                          prefixIcon: const Center(
                              child: Icon(Icons.phone_android, size: 20)),
                          prefixIconConstraints:
                              BoxConstraints(maxWidth: size.width * 0.1)),
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
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
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
                            height: size.width * 0.11,
                            width: size.width * 0.425,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(6)),
                            alignment: Alignment.center,
                            child: MyText(
                              text: AppLocalizations.of(context)!.transferMoney,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.white),
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
