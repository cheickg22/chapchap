import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';
import '../../../../../../../core/utils/custom_timer.dart';

class BiddingTimerWidget extends StatelessWidget {
  final BuildContext cont;
  const BiddingTimerWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            height: size.height,
            width: size.width,
            color: Colors.transparent.withAlpha((0.4 * 255).toInt()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.8,
                  padding: EdgeInsets.all(size.width * 0.06),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.white),
                  child: Column(
                    children: [
                      SizedBox(height: size.width * 0.03),
                      SizedBox(
                          width: size.width * 0.8,
                          child: MyText(
                              text: AppLocalizations.of(context)!
                                  .waitingForUserResponse)),
                      SizedBox(height: size.width * 0.05),
                      if (DateTime.now()
                              .difference(DateTime.fromMillisecondsSinceEpoch(
                                  context.read<HomeBloc>().waitingList[0]
                                          ['drivers']['driver_${userData!.id}']
                                      ['bid_time']))
                              .inSeconds <
                          int.parse(userData!
                              .maximumTimeForFindDriversForBittingRide))
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              painter: CustomTimer(
                                width: size.width * 0.01,
                                color: AppColors.white,
                                backgroundColor: AppColors.primary,
                                values: (DateTime.now()
                                            .difference(DateTime.fromMillisecondsSinceEpoch(
                                                context.read<HomeBloc>().waitingList[0]['drivers']
                                                        ['driver_${userData!.id}']
                                                    ['bid_time']))
                                            .inSeconds <
                                        int.parse(userData!
                                            .maximumTimeForFindDriversForBittingRide))
                                    ? 1 -
                                        ((int.parse(userData!.maximumTimeForFindDriversForBittingRide) -
                                                DateTime.now()
                                                    .difference(DateTime.fromMillisecondsSinceEpoch(context.read<HomeBloc>().waitingList[0]['drivers']['driver_${userData!.id}']['bid_time']))
                                                    .inSeconds) /
                                            int.parse(userData!.maximumTimeForFindDriversForBittingRide))
                                    : 1,
                              ),
                              child: Container(
                                height: size.width * 0.2,
                                width: size.width * 0.2,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: MyText(
                                text :'${(int.parse(userData!.maximumTimeForFindDriversForBittingRide) - DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(context.read<HomeBloc>().waitingList[0]['drivers']['driver_${userData!.id}']['bid_time'])).inSeconds).clamp(0, int.parse(userData!.maximumTimeForFindDriversForBittingRide))} s',
                                textStyle: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
