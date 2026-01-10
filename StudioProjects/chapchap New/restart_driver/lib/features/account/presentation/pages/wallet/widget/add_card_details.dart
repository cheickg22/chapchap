import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

Widget addCardDetails(BuildContext context, Size size) {
  return BlocBuilder<AccBloc, AccState>(
    builder: (context, state) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Padding(
            padding: EdgeInsets.only(
                left: 16.0,
                right: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.width * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.enterCardDetails,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
                SizedBox(height: size.width * 0.05),
                CardFormField(
                    controller: context.read<AccBloc>().cardFormEditController,
                    enablePostalCode: true,
                    onCardChanged: (card) {
                      if (card != null && card.complete) {
                        context.read<AccBloc>().cardDetails = card;
                      }
                    },
                    style: CardFormStyle(
                      borderRadius: 2,
                      borderWidth: 0,
                      fontSize: 14,
                      textColor: Theme.of(context).primaryColorDark,
                      textErrorColor: AppColors.errorLight,
                      placeholderColor: Theme.of(context).disabledColor,
                      cursorColor: Theme.of(context).primaryColor,
                    )),
                CustomButton(
                  width: size.width,
                  buttonName: AppLocalizations.of(context)!.saveCard,
                  isLoader: context.read<AccBloc>().isLoading,
                  onTap: () {
                    if (context.read<AccBloc>().cardDetails != null &&
                        context.read<AccBloc>().cardDetails!.complete == true) {
                      context
                          .read<AccBloc>()
                          .add(AddCardDetailsEvent(context: context));
                    } else {
                      showToast(
                          message: AppLocalizations.of(context)!
                              .enterTheCredentials);
                    }
                  },
                ),
                SizedBox(height: size.width * 0.1),
              ],
            ),
          ),
        ),
      );
    },
  );
}
