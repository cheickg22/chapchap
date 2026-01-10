// ignore_for_file: unused_element_parameter, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import 'payment_gatewaylist_widget.dart';
import 'package:restart_tagxi/common/common.dart';
import '../../../../../../core/utils/custom_button.dart';

class AddMoneyWalletWidget extends StatelessWidget {
  final BuildContext cont;
  final String minWalletAmount;
  const AddMoneyWalletWidget(
      {super.key, required this.cont, required this.minWalletAmount});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<AccBloc>(),
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final acc = context.read<AccBloc>();
            return Scaffold(
              // backgroundColor: AppColors.white,
              appBar: AppBar(
                // backgroundColor: AppColors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).hintColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  AppLocalizations.of(context)!.addMoney,
                  style: TextStyle(
                    // color: AppColors.black,
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.12),
                      // Amount display
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: acc.walletAmountController,
                        builder: (_, value, __) {
                          final text = value.text.isEmpty ? '0' : value.text;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userData!.currencySymbol,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: size.height * 0.08),
                      // Next button
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: acc.walletAmountController,
                        builder: (_, value, __) {
                          final bool hasAmount =
                              value.text.isNotEmpty && value.text != '0';
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: CustomButton(
                              buttonName: AppLocalizations.of(context)!.next,
                              height: 52,
                              width: double.infinity,
                              borderRadius: 12,
                              buttonColor: hasAmount
                                  ? AppColors.primary
                                  : const Color.fromARGB(255, 158, 169, 241),
                              textColor: AppColors.white,
                              textSize: 16,
                              onTap: hasAmount
                                  ? () {
                                      if (acc.walletAmountController.text
                                              .isNotEmpty &&
                                          acc.addMoney != null) {
                                        final confirmPayment =
                                            cont.read<AccBloc>();
                                        final list = cont
                                            .read<AccBloc>()
                                            .walletPaymentGatways;
                                        final currency =
                                            acc.walletResponse!.currencySymbol;
                                        final money = acc.addMoney.toString();
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          backgroundColor: AppColors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(16)),
                                          ),
                                          builder: (_) {
                                            return FractionallySizedBox(
                                              heightFactor: 1.0,
                                              child: BlocProvider.value(
                                                value: confirmPayment,
                                                child: PaymentGatewaylistWidget(
                                                  cont: context,
                                                  currencySymbol: currency,
                                                  amount: money,
                                                  walletPaymentGatways: list,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Keypad
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final row in const [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                            ['.', '0']
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (final key in row)
                                    _KeyButton(
                                      label: key,
                                      onTap: () {
                                        final current =
                                            acc.walletAmountController.text;

                                        // Handle decimal point
                                        if (key == '.') {
                                          // Only add decimal if there isn't one already
                                          if (!current.contains('.')) {
                                            final next = current.isEmpty
                                                ? '0.'
                                                : (current + '.');
                                            acc.walletAmountController.text =
                                                next;
                                            acc.addMoney =
                                                double.tryParse(next);
                                          }
                                          return;
                                        }

                                        // Handle numbers
                                        final next = (current == '0')
                                            ? key
                                            : (current + key);
                                        acc.walletAmountController.text = next;
                                        acc.addMoney = double.tryParse(next);
                                      },
                                    ),
                                  if (row.length == 2)
                                    _KeyButton(
                                      icon: Icons.backspace_outlined,
                                      onTap: () {
                                        final current =
                                            acc.walletAmountController.text;
                                        if (current.isEmpty) return;
                                        final next = current.substring(
                                            0, current.length - 1);
                                        acc.walletAmountController.text = next;
                                        acc.addMoney = double.tryParse(
                                            next.isEmpty ? '0' : next);
                                      },
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}

// Simple keypad button used above
class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  const _KeyButton({super.key, this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size.width * 0.22,
        height: size.width * 0.16,
        decoration: BoxDecoration(
          // color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: AppColors.black)
            : Text(
                label ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
      ),
    );
  }
}
