import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class DriverPerformDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  final DriverDashboardArguments args;
  const DriverPerformDetailsWidget(
      {super.key, required this.cont, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return SizedBox(
            width: size.width * 0.9,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: size.width * 0.15,
                  width: size.width * 0.15,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(args.profile),
                          fit: BoxFit.cover)),
                ),
                SizedBox(width: size.width * 0.025),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: MyText(
                            text: args.driverName,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                          )),
                          MyText(
                            text: context
                                .read<AccBloc>()
                                .driverPerformanceData!
                                .completedRequests,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: AppColors.darkGrey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      SizedBox(height: size.width * 0.022),
                      Container(
                        height: size.width * 0.155,
                        width: size.width * 0.72,
                        color: Theme.of(context)
                            .primaryColorDark
                            .withAlpha((0.2 * 255).toInt()),
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.02),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Booking Row
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .booking,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          ),
                                          const SizedBox(width: 5),
                                          MyText(
                                            text: context
                                                .read<AccBloc>()
                                                .driverPerformanceData!
                                                .totalTrips
                                                .toString(),
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Divider
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.015),
                                child: Container(
                                  height: size.width * 0.076,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right:
                                          BorderSide(color: AppColors.darkGrey),
                                    ),
                                  ),
                                ),
                              ),
                              // Distance Row
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .distance,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400),
                                          ),
                                          const SizedBox(width: 5),
                                          MyText(
                                            text:
                                                '${context.read<AccBloc>().driverPerformanceData!.totalDistance} Km',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Divider
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.015),
                                child: Container(
                                  height: size.width * 0.076,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      right:
                                          BorderSide(color: AppColors.darkGrey),
                                    ),
                                  ),
                                ),
                              ),
                              // Earnings Row
                              Row(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.money,
                                            size: size.width * 0.05,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          const SizedBox(width: 1),
                                          MyText(
                                            text:
                                                '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.totalEarnings}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
