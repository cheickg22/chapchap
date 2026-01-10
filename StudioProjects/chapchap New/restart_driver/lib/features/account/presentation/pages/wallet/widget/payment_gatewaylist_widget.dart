import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/walletpage_model.dart';

class PaymentGatewaylistWidget extends StatelessWidget {
  final BuildContext cont;
  final String currencySymbol;
  final String amount;
  final List<PaymentGateway> walletPaymentGatways;
  const PaymentGatewaylistWidget(
      {super.key,
      required this.cont,
      required this.walletPaymentGatways,
      required this.currencySymbol,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return walletPaymentGatways.isNotEmpty
          ? Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.selectPaymentMethod,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: SafeArea(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.width * 0.05),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: MyText(
                          text:
                              AppLocalizations.of(context)!.choosePaymentMethod,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                      Expanded(
                        child: ListView.builder(
                          itemCount: walletPaymentGatways.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                            return Column(
                              children: [
                                (walletPaymentGatways[index].enabled == true)
                                    ? InkWell(
                                        onTap: () {
                                          context.read<AccBloc>().add(
                                              PaymentOnTapEvent(
                                                  selectedPaymentIndex: index));
                                        },
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.04),
                                          margin: EdgeInsets.only(
                                              bottom: size.width * 0.03),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                width: (context
                                                            .read<AccBloc>()
                                                            .choosenPaymentIndex ==
                                                        index)
                                                    ? 1
                                                    : 1.5,
                                                color: (context
                                                            .read<AccBloc>()
                                                            .choosenPaymentIndex ==
                                                        index)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : AppColors.borderColor),
                                          ),
                                          child: Row(
                                            children: [
                                              // Icon/Image Container
                                              Container(
                                                width: size.width * 0.12,
                                                height: size.width * 0.12,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.all(
                                                    size.width * 0.02),
                                                child: walletPaymentGatways[
                                                            index]
                                                        .isCard
                                                    ? _getCardImage(
                                                        walletPaymentGatways[
                                                                index]
                                                            .image,
                                                        size)
                                                    : CachedNetworkImage(
                                                        imageUrl:
                                                            walletPaymentGatways[
                                                                    index]
                                                                .image,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.payment,
                                                                size: 24),
                                                      ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.04),
                                              // Payment Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text:
                                                          walletPaymentGatways[
                                                                  index]
                                                              .gateway
                                                              .toString(),
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                              ),
                                                    ),
                                                    if (walletPaymentGatways[
                                                            index]
                                                        .isCard)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top:
                                                                    size.width *
                                                                        0.01),
                                                        child: MyText(
                                                          text:
                                                              'Ends in **** ${walletPaymentGatways[index].gateway.toString().substring(walletPaymentGatways[index].gateway.toString().length - 4)}',
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color: AppColors
                                                                        .hintColor,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              // Radio Button
                                              Container(
                                                width: size.width * 0.06,
                                                height: size.width * 0.06,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .choosenPaymentIndex ==
                                                          index)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    width: 2,
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenPaymentIndex ==
                                                            index)
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .disabledColor
                                                            .withAlpha(
                                                                (0.5 * 255)
                                                                    .toInt()),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: (context
                                                            .read<AccBloc>()
                                                            .choosenPaymentIndex ==
                                                        index)
                                                    ? Container(
                                                        width:
                                                            size.width * 0.03,
                                                        height:
                                                            size.width * 0.03,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          },
                        ),
                      ),
                      Center(
                        child: CustomButton(
                          buttonName:
                              AppLocalizations.of(context)!.continueText,
                          width: size.width,
                          onTap: () {
                            if (!walletPaymentGatways[context
                                    .read<AccBloc>()
                                    .choosenPaymentIndex!]
                                .isCard) {
                              context.read<AccBloc>().add(
                                    WalletPageReUpdateEvent(
                                      currencySymbol: currencySymbol,
                                      from: '',
                                      requestId: '',
                                      planId: '',
                                      money: amount,
                                      url: walletPaymentGatways[context
                                              .read<AccBloc>()
                                              .choosenPaymentIndex!]
                                          .url,
                                      userId: userData!.userId.toString(),
                                    ),
                                  );
                            } else {
                              context.read<AccBloc>().add(AddMoneyFromCardEvent(
                                  amount: context
                                      .read<AccBloc>()
                                      .addMoney
                                      .toString(),
                                  cardToken: walletPaymentGatways[context
                                          .read<AccBloc>()
                                          .choosenPaymentIndex!]
                                      .url));
                            }
                            //  Navigator.push(context, MaterialPageRoute(builder: (context) =>  const WalletHistoryPage()));
                          },
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox();
    });
  }

  Widget _getCardImage(String imageString, Size size) {
    final imageLower = imageString.toLowerCase();

    if (imageLower.contains('visa')) {
      return Image.asset(AppImages.visa, fit: BoxFit.contain);
    } else if (imageLower.contains('eftpos')) {
      return Image.asset(AppImages.eftpos, fit: BoxFit.contain);
    } else if (imageLower.contains('american')) {
      return Image.asset(AppImages.americanExpress, fit: BoxFit.contain);
    } else if (imageLower.contains('jcb')) {
      return Image.asset(AppImages.jcb, fit: BoxFit.contain);
    } else if (imageLower.contains('discover') ||
        imageLower.contains('dinners')) {
      return Image.asset(AppImages.discover, fit: BoxFit.contain);
    } else {
      return Image.asset(AppImages.master, fit: BoxFit.contain);
    }
  }
}
