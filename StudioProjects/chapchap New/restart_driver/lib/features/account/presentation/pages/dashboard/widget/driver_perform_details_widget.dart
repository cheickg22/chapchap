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
          return Container(
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.025),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: AppColors.borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    SizedBox(
                      width: size.width * 0.025,
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MyText(
                          text: args.driverName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColorDark),
                        ),
                        MyText(
                          text: context
                              .read<AccBloc>()
                              .driverPerformanceData!
                              .completedRequests,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 14,
                                  ),
                        )
                      ],
                    )),
                  ],
                ),
                SizedBox(
                  height: size.width * 0.025,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Add space evenly
                  children: [
                    // Booking Row
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      // width: size.width * 0.3,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).primaryColorDark),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: AppColors.primary,
                            size: size.width * 0.05,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.booking,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
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
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.025,
                    ),

                    // Distance Row
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      // width: size.width * 0.3,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).primaryColorDark),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: AppColors.primary,
                            size: size.width * 0.05,
                          ),
                          SizedBox(
                            width: size.width * 0.025,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.distance,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(width: 5),
                          MyText(
                            text:
                                '${context.read<AccBloc>().driverPerformanceData!.totalDistance} Km',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.width * 0.025,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      // width: size.width * 0.3,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).primaryColorDark),
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.money,
                            size: size.width * 0.05,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: size.width * 0.02),
                          MyText(
                            text:
                                '${userData!.currencySymbol} ${context.read<AccBloc>().driverPerformanceData!.totalEarnings}',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
