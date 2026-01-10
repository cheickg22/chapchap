import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/walletpage_model.dart';

class PaymentGatewayListWidget extends StatelessWidget {
  final BuildContext cont;
  final List<PaymentGateway> walletPaymentGatways;
  const PaymentGatewayListWidget(
      {super.key, required this.cont, required this.walletPaymentGatways});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        return walletPaymentGatways.isNotEmpty
            ? SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: walletPaymentGatways.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
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
                                        width: size.width * 0.9,
                                        padding:
                                            EdgeInsets.all(size.width * 0.02),
                                        margin: EdgeInsets.only(
                                            bottom: size.width * 0.025),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColors)),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  if (walletPaymentGatways[index]
                                                      .isCard)
                                                    (walletPaymentGatways[index]
                                                            .image
                                                            .toLowerCase()
                                                            .toString()
                                                            .contains('visa'))
                                                        ? Image.asset(
                                                            AppImages.visa,
                                                            height: size.width *
                                                                0.1,
                                                            width: size.width *
                                                                0.08,
                                                          )
                                                        : (walletPaymentGatways[
                                                                    index]
                                                                .image
                                                                .toLowerCase()
                                                                .toString()
                                                                .contains(
                                                                    'eftpos'))
                                                            ? Image.asset(
                                                                AppImages
                                                                    .eftpos,
                                                                height:
                                                                    size.width *
                                                                        0.1,
                                                                width:
                                                                    size.width *
                                                                        0.08,
                                                              )
                                                            : (walletPaymentGatways[
                                                                        index]
                                                                    .image
                                                                    .toLowerCase()
                                                                    .toString()
                                                                    .contains(
                                                                        'american'))
                                                                ? Image.asset(
                                                                    AppImages
                                                                        .americanExpress,
                                                                    height:
                                                                        size.width *
                                                                            0.1,
                                                                    width: size
                                                                            .width *
                                                                        0.08,
                                                                  )
                                                                : (walletPaymentGatways[index]
                                                                        .image
                                                                        .toLowerCase()
                                                                        .toString()
                                                                        .contains(
                                                                            'jcb'))
                                                                    ? Image
                                                                        .asset(
                                                                        AppImages
                                                                            .jcb,
                                                                        height: size.width *
                                                                            0.1,
                                                                        width: size.width *
                                                                            0.08,
                                                                      )
                                                                    : (walletPaymentGatways[index]
                                                                            .image
                                                                            .toLowerCase()
                                                                            .toString()
                                                                            .contains(
                                                                                'discover || dinners'))
                                                                        ? Image
                                                                            .asset(
                                                                            AppImages.discover,
                                                                            height:
                                                                                size.width * 0.1,
                                                                            width:
                                                                                size.width * 0.08,
                                                                          )
                                                                        : Image.asset(
                                                                            AppImages.master,
                                                                            height: size.width * 0.1,
                                                                            width: size.width * 0.08),
                                                  if (!walletPaymentGatways[
                                                          index]
                                                      .isCard)
                                                    CachedNetworkImage(
                                                      imageUrl:
                                                          walletPaymentGatways[
                                                                  index]
                                                              .image,
                                                      width: 30,
                                                      height: 40,
                                                      fit: BoxFit.contain,
                                                      placeholder:
                                                          (context, url) =>
                                                              const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Center(
                                                        child: Text(
                                                          "",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        size.width * 0.01),
                                                  ),
                                                  MyText(
                                                      text: walletPaymentGatways[
                                                                  index]
                                                              .isCard
                                                          ? '**** **** **** ${walletPaymentGatways[index].gateway}'
                                                          : walletPaymentGatways[
                                                                  index]
                                                              .gateway
                                                              .toString(),
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: size.width * 0.05,
                                              height: size.width * 0.05,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      width: 1.5,
                                                      color: Theme.of(context)
                                                          .primaryColorDark)),
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: size.width * 0.03,
                                                height: size.width * 0.03,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenPaymentIndex ==
                                                            index)
                                                        ? Theme.of(context)
                                                            .primaryColorDark
                                                        : Colors.transparent),
                                              ),
                                            )
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
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: CustomButton(
                          buttonName: AppLocalizations.of(context)!.pay,
                          width: size.width,
                          textSize: 18,
                          onTap: () async {
                            if (!walletPaymentGatways[context
                                    .read<AccBloc>()
                                    .choosenPaymentIndex!]
                                .isCard) {
                              context
                                  .read<AccBloc>()
                                  .add(WalletPageReUpdateEvent(
                                    currencySymbol: context
                                        .read<AccBloc>()
                                        .walletResponse!
                                        .currencySymbol,
                                    from: '2',
                                    requestId: '',
                                    planId: context
                                        .read<AccBloc>()
                                        .subscriptionList[context
                                            .read<AccBloc>()
                                            .choosenPlanindex]
                                        .id!
                                        .toString(),
                                    money: context
                                        .read<AccBloc>()
                                        .addMoneySubscription
                                        .toString(),
                                    url: walletPaymentGatways[context
                                            .read<AccBloc>()
                                            .choosenPaymentIndex!]
                                        .url,
                                    userId: userData!.userId.toString(),
                                  ));
                            } else {
                              context.read<AccBloc>().add(AddMoneyFromCardEvent(
                                  planId: context
                                      .read<AccBloc>()
                                      .subscriptionList[context
                                          .read<AccBloc>()
                                          .choosenPlanindex]
                                      .id!
                                      .toString(),
                                  amount: context
                                      .read<AccBloc>()
                                      .addMoneySubscription
                                      .toString(),
                                  cardToken: walletPaymentGatways[context
                                          .read<AccBloc>()
                                          .choosenPaymentIndex!]
                                      .url));
                            }
                            Navigator.pop(context);
                          }),
                    ),
                    // SizedBox(
                    //   height: size.width * 0.1,
                    // )
                  ],
                ),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                  Center(
                    child:
                        MyText(text: AppLocalizations.of(context)!.noDataFound),
                  ),
                ],
              );
      }),
    );
  }
}
