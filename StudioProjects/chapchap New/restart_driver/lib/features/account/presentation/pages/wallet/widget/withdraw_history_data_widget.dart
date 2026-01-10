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
                        final item = withdrawHistoryList[index];
                        final String status = (item['status'] ?? '').toString();
                        final String createdAt =
                            (item['created_at'] ?? '').toString();
                        final String amount =
                            (item['requested_amount'] ?? '').toString();
                        final bool isRequested =
                            status.toLowerCase() == 'requested';

                        return Padding(
                          padding: EdgeInsets.only(bottom: size.width * 0.04),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Status
                                        isRequested
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: MyText(
                                                  text: status,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        color: Colors.grey[700],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              )
                                            : MyText(
                                                text: status,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: AppColors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                        SizedBox(height: size.width * 0.01),
                                        // Date
                                        MyText(
                                          text: createdAt,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Amount
                                  MyText(
                                    text: '${userData!.currencySymbol}$amount',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.width * 0.03),
                              Divider(color: Colors.grey[300], height: 1),
                            ],
                          ),
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
