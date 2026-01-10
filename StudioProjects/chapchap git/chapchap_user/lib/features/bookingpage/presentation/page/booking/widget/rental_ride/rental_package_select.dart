import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_divider.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';

Widget packageList(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return BlocBuilder<BookingBloc, BookingState>(builder: (context, state) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: size.width,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(child: CustomDivider()),
                  SizedBox(height: size.width * 0.05),
                  MyText(
                    text: AppLocalizations.of(context)!.selectPackage,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  if (context
                      .read<BookingBloc>()
                      .rentalPackagesList
                      .isNotEmpty) ...[
                    Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.5,
                          child: ListView.separated(
                            itemCount: context
                                .read<BookingBloc>()
                                .rentalPackagesList
                                .length,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final package = context
                                  .read<BookingBloc>()
                                  .rentalPackagesList
                                  .elementAt(index);
                              return InkWell(
                                onTap: () {
                                  context.read<BookingBloc>().add(
                                      BookingRentalPackageSelectEvent(
                                          selectedPackageIndex: index));
                                },
                                child: Container(
                                  width: size.width * 0.99,
                                  height: size.width * 0.25,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: (index ==
                                                context
                                                    .read<BookingBloc>()
                                                    .selectedPackageIndex) // Selected item at the top
                                            ? AppColors.primary
                                            : AppColors.borderColors),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.01),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // SizedBox(height: size.width * 0.01),
                                                SizedBox(
                                                  width: size.width * 0.40,
                                                  child: MyText(
                                                    text: package.packageName,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.40,
                                                  child: MyText(
                                                    text: package
                                                        .shortDescription,
                                                    maxLines: 3,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .hintColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        MyText(
                                          text:
                                              '${package.currency.toString()} ${package.minPrice!.toStringAsFixed(1)} - ${package.currency.toString()} ${package.maxPrice!.toStringAsFixed(1)}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontSize: 14,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
                            },
                          ),
                        ),
                        SizedBox(height: size.width * 0.2)
                      ],
                    ),
                  ],
                  if (context.read<BookingBloc>().rentalPackagesList.isEmpty)
                    Center(
                        child: SizedBox(
                      height: size.width * 0.5,
                      child: MyText(
                        text: AppLocalizations.of(context)!.noDataAvailable,
                      ),
                    )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            child: Container(
              width: size.width,
              height: size.width * 0.2,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      width: size.width * 0.8,
                      height: size.width * 0.12,
                      buttonName: (context
                              .read<BookingBloc>()
                              .rentalPackagesList
                              .isNotEmpty)
                          ? AppLocalizations.of(context)!.continueN
                          : 'Back to Home',
                      onTap: () {
                        if (context
                            .read<BookingBloc>()
                            .rentalPackagesList
                            .isNotEmpty) {
                          context
                              .read<BookingBloc>()
                              .add(RentalPackageConfirmEvent(
                                picklat: context
                                    .read<BookingBloc>()
                                    .pickUpAddressList
                                    .first
                                    .lat
                                    .toString(),
                                picklng: context
                                    .read<BookingBloc>()
                                    .pickUpAddressList
                                    .first
                                    .lng
                                    .toString(),
                              ));
                        } else {
                          context
                              .read<BookingBloc>()
                              .add(BookingNavigatorPopEvent());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  });
}
