import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class AdditionalChargeWidget extends StatelessWidget {
  const AdditionalChargeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: Container(
                  color:Theme.of(context).scaffoldBackgroundColor,
                  height: size.height * 0.35,
                  width: size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width * 0.05,
                              right: size.width * 0.05,
                              top: size.width * 0.02,
                              bottom: size.width * 0.02),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: size.width * 0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!.additionalCharges,
                                    textStyle: AppTextStyle.boldStyle().copyWith(
                                      color: AppColors.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(Icons.cancel_outlined),
                                  )
                                ],
                              ),
                              SizedBox(height: size.width * 0.03),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                spacing: size.width * 0.02,
                                children: [
                                  Container(
                                    height: size.width * 0.12,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CustomTextField(
                                      controller: context
                                          .read<HomeBloc>()
                                          .additionalChargeDetailText,
                                      keyboardType: TextInputType.text,
                                      hintText:
                                          AppLocalizations.of(context)!.chargeDetails,
                                    ),
                                  ),
                                  Container(
                                    height: size.width * 0.12,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: CustomTextField(
                                      controller: context
                                          .read<HomeBloc>()
                                          .additionalChargeAmountText,
                                      keyboardType: TextInputType.number,
                                      hintText: AppLocalizations.of(context)!.enterAmount,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                      ],
                                    ),
                                  ),
                                  CustomButton(
                                      borderRadius: 15,
                                      height: size.width * 0.1,
                                      buttonName: AppLocalizations.of(context)!.confirm,
                                      onTap: () {
                                        if (userData!.onTripRequest != null &&
                                            context
                                                .read<HomeBloc>()
                                                .additionalChargeAmountText
                                                .text
                                                .isNotEmpty &&
                                            context
                                                .read<HomeBloc>()
                                                .additionalChargeDetailText
                                                .text
                                                .isNotEmpty) {
                                          context.read<HomeBloc>().add(
                                              AdditionalChargeOnTapEvent(
                                                  amount: context
                                                      .read<HomeBloc>()
                                                      .additionalChargeAmountText
                                                      .text,
                                                  chargeDetails: context
                                                      .read<HomeBloc>()
                                                      .additionalChargeDetailText
                                                      .text,
                                                  requestId:
                                                      userData!.onTripRequest!.id));
                                          Navigator.pop(context);
                                        } else {
                                          showToast(
                                              message: AppLocalizations.of(context)!
                                                  .fillTheDetails);
                                        }
                                      }),
                                      SizedBox(height: size.width * 0.1),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ),
        );
      },
    );
  }
}
