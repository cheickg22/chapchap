import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              color: Theme.of(context).scaffoldBackgroundColor,
              height: size.height * 0.35,
              width: size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: size.width * 0.05,
                              left: size.width * 0.05,
                              right: size.width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .additionalCharges,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                                // textStyle: AppTextStyle.boldStyle().copyWith(
                                //   // color: AppColors.primary,
                                //   fontSize: 16,
                                // ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.cancel_outlined),
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        // SizedBox(height: size.width * 0.05),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            spacing: size.width * 0.02,
                            children: [
                              CustomTextField(
                                controller: context
                                    .read<HomeBloc>()
                                    .additionalChargeDetailText,
                                keyboardType: TextInputType.text,
                                hintText:
                                    AppLocalizations.of(context)!.chargeDetails,
                                contentPadding:
                                    EdgeInsets.all(size.width * 0.025),
                              ),
                              SizedBox(
                                height: size.width * 0.005,
                              ),
                              CustomTextField(
                                controller: context
                                    .read<HomeBloc>()
                                    .additionalChargeAmountText,
                                keyboardType: TextInputType.number,
                                hintText:
                                    AppLocalizations.of(context)!.enterAmount,
                                contentPadding:
                                    EdgeInsets.all(size.width * 0.025),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                              ),
                              SizedBox(
                                height: size.width * 0.02,
                              ),
                              CustomButton(
                                  borderRadius: 10,
                                  // height: size.width * 0.1,
                                  width: size.width,
                                  buttonName:
                                      AppLocalizations.of(context)!.confirm,
                                  textSize: 18,
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
                        ),
                      ],
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
