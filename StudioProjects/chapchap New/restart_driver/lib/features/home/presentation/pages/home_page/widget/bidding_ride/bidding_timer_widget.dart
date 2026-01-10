import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';
import '../../../../../../../core/utils/custom_timer.dart';

class BiddingTimerWidget extends StatefulWidget {
  final BuildContext cont;
  const BiddingTimerWidget({super.key, required this.cont});

  @override
  State<BiddingTimerWidget> createState() => _BiddingTimerWidgetState();
}

class _BiddingTimerWidgetState extends State<BiddingTimerWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          final bidStart = DateTime.fromMillisecondsSinceEpoch(homeBloc
              .waitingList[0]['drivers']['driver_${userData!.id}']['bid_time']);
          final maxSeconds =
              int.parse(userData!.maximumTimeForFindDriversForBittingRide);
          final elapsed = DateTime.now().difference(bidStart).inSeconds;
          final isTimerActive = elapsed < maxSeconds;

          if (!isTimerActive) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (homeBloc.waitingList.isNotEmpty) {
                homeBloc.waitingList.clear();
                homeBloc.add(RequestTimerEvent());
              }
            });
            return const SizedBox.shrink();
          }

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
                      if (isTimerActive)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              painter: CustomTimer(
                                width: size.width * 0.01,
                                color: AppColors.white,
                                backgroundColor: AppColors.primary,
                                values: 1 -
                                    ((maxSeconds -
                                            elapsed.clamp(0, maxSeconds)) /
                                        maxSeconds),
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
                                text:
                                    '${(maxSeconds - elapsed).clamp(0, maxSeconds)} s',
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
