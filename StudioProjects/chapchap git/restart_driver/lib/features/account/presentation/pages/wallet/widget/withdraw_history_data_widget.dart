import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WithdrawHistoryDataWidget extends StatelessWidget {
  final BuildContext cont;
  final List withdrawHistoryList;
  const WithdrawHistoryDataWidget(
      {super.key, required this.cont, required this.withdrawHistoryList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return withdrawHistoryList.isNotEmpty
              ? Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: RawScrollbar(
                    radius: const Radius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: withdrawHistoryList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              width: size.width,
                              height: size.width * 0.175,
                              margin:
                                  EdgeInsets.only(bottom: size.width * 0.030),
                              padding: EdgeInsets.all(size.width * 0.025),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 0.5,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.5 * 255).toInt())),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText(
                                            text: withdrawHistoryList[index]
                                                ['status'],
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        MyText(
                                            text: withdrawHistoryList[index]
                                                ['created_at'],
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      MyText(
                                          text:
                                              '${userData!.currencySymbol} ${withdrawHistoryList[index]['requested_amount'].toString()}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: AppColors.green,
                                                  fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.walletNoData,
                          height: size.width * 0.6,
                          width: 200,
                        ),
                        const SizedBox(height: 10),
                        MyText(
                          text: AppLocalizations.of(context)!.noPaymentHistory,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Theme.of(context).disabledColor),
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.bookingRideText,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
