import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_divider.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';
import 'eta_list_view_widget.dart';
import 'rental_ride/rental_eta_list_view.dart';

class RidePreviewWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;

  const RidePreviewWidget({super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: !context.read<BookingBloc>().showBiddingVehicles
                      ? size.width * 0.05
                      : size.width * 0.05,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CustomDivider()),
                  ],
                ),
                SizedBox(height: size.width * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.only(
                        top: size.width * 0.025, bottom: size.width * 0.025),
                    child: Column(
                      children: [
                        ListView.builder(
                          itemCount: arg.pickupAddressList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(5),
                          itemBuilder: (context, index) {
                            final address =
                                arg.pickupAddressList.elementAt(index);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.018),
                                  child: const PickupIcon(),
                                ),
                                Expanded(
                                  child: MyText(
                                    text: address.address,
                                    maxLines: 2,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontSize: 13),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (arg.stopAddressList.isNotEmpty) ...[
                          ListView.separated(
                            itemCount: arg.stopAddressList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(5),
                            itemBuilder: (context, index) {
                              final address =
                                  arg.stopAddressList.elementAt(index);
                              return Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.015),
                                    child: const DropIcon(),
                                  ),
                                  Expanded(
                                    child: MyText(
                                      text: address.address,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                indent: size.width * 0.073,
                                endIndent: size.width * 0.01,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withAlpha((0.4 * 255).toInt()),
                              );
                            },
                          ),
                          SizedBox(height: size.width * 0.03),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!context.read<BookingBloc>().isRentalRide &&
                    context.read<BookingBloc>().etaDetailsList.isNotEmpty) ...[
                  EtaListViewWidget(cont: context, arg: arg, thisValue: this),
                ],
                if (context.read<BookingBloc>().isRentalRide &&
                    context
                        .read<BookingBloc>()
                        .rentalEtaDetailsList
                        .isNotEmpty) ...[
                  SizedBox(height: size.width * 0.02),
                  RentalEtaListViewWidget(
                      cont: context, arg: arg, thisValue: this),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
