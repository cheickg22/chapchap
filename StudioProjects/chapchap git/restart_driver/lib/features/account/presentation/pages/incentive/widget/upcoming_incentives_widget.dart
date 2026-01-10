import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/incentive_model.dart';

class ShowUpcomingIncentivesWidget extends StatelessWidget {
  final BuildContext cont;
  final List<UpcomingIncentive> upcomingIncentives;
  const ShowUpcomingIncentivesWidget(
      {super.key, required this.cont, required this.upcomingIncentives});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border:
                  Border.all(color: Theme.of(context).scaffoldBackgroundColor),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.03,
                      size.height * 0.08,
                      size.width * 0.03,
                      size.height * 0.02,
                    ),
                    child: Container(
                      height: size.width * 1.27,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              if (context
                                      .read<AccBloc>()
                                      .selectedIncentiveHistory !=
                                  null)
                                Container(
                                  height: size.width * 0.4,
                                  width: size.width,
                                  decoration: BoxDecoration(
                                    color: context
                                            .read<AccBloc>()
                                            .selectedIncentiveHistory!
                                            .upcomingIncentives
                                            .any((element) =>
                                                element.isCompleted == false)
                                        ? AppColors.red
                                        : AppColors.green,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                        text:
                                            "${AppLocalizations.of(context)!.earnUptoText} ${userData!.currencySymbol} ${context.read<AccBloc>().selectedIncentiveHistory!.earnUpto}",
                                        textStyle: const TextStyle(
                                            fontSize: 25,
                                            color: AppColors.white),
                                      ),
                                      SizedBox(
                                        height: size.width * 0.02,
                                      ),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .byCompletingRideText
                                            .replaceAll(
                                                "12",
                                                context
                                                    .read<AccBloc>()
                                                    .selectedIncentiveHistory!
                                                    .totalRides
                                                    .toString()),
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.white),
                                      ),
                                      SizedBox(
                                        height: size.width * 0.02,
                                      ),
                                      Container(
                                        height: size.height * 0.04,
                                        width: size.width * 0.7,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        child: Center(
                                          child: MyText(
                                            text: context
                                                    .read<AccBloc>()
                                                    .selectedIncentiveHistory!
                                                    .upcomingIncentives
                                                    .any((element) =>
                                                        element.isCompleted ==
                                                        false)
                                                ? AppLocalizations.of(context)!
                                                    .missedIncentiveText
                                                : AppLocalizations.of(context)!
                                                    .earnedIncentiveText,
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                color: context
                                                        .read<AccBloc>()
                                                        .selectedIncentiveHistory!
                                                        .upcomingIncentives
                                                        .any((element) =>
                                                            element
                                                                .isCompleted ==
                                                            false)
                                                    ? AppColors.red
                                                    : AppColors.green),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          // SizedBox(
                          //   height: size.width * 0.03,
                          // ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0, 0, 8, 0),
                            child: SizedBox(
                              height: size.width * 0.8,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: context
                                      .read<AccBloc>()
                                      .selectedIncentiveHistory!
                                      .upcomingIncentives
                                      .length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.width * 0.05,
                                              width: size.width * 0.05,
                                              decoration: BoxDecoration(
                                                color: context
                                                        .read<AccBloc>()
                                                        .selectedIncentiveHistory!
                                                        .upcomingIncentives[
                                                            index]
                                                        .isCompleted
                                                    ? AppColors.green
                                                    : AppColors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0),
                                              child: SizedBox(
                                                width: size.width * 0.7,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text:
                                                              "${AppLocalizations.of(context)!.completeText} ${context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].rideCount}",
                                                          maxLines: 2,
                                                          textStyle: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .selectedIncentiveHistory!
                                                                    .upcomingIncentives[
                                                                        index]
                                                                    .isCompleted
                                                                ? Colors.green
                                                                    .shade700
                                                                : Colors.red
                                                                    .shade700,
                                                          ),
                                                        ),
                                                        MyText(
                                                          text:
                                                              "${userData!.currencySymbol} ${context.read<AccBloc>().selectedIncentiveHistory!.upcomingIncentives[index].incentiveAmount}",
                                                          textStyle: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .selectedIncentiveHistory!
                                                                    .upcomingIncentives[
                                                                        index]
                                                                    .isCompleted
                                                                ? Colors.green
                                                                    .shade700
                                                                : Colors.red
                                                                    .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      context
                                                              .read<AccBloc>()
                                                              .selectedIncentiveHistory!
                                                              .upcomingIncentives[
                                                                  index]
                                                              .isCompleted
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .acheivedTargetText
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .missedTargetText,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (upcomingIncentives.indexOf(context
                                                .read<AccBloc>()
                                                .selectedIncentiveHistory!
                                                .upcomingIncentives[index]) !=
                                            upcomingIncentives.length - 1)
                                          Container(
                                            height: size.height * 0.08,
                                            padding: const EdgeInsets.only(
                                                bottom: 3),
                                            child: VerticalDivider(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              thickness: 1,
                                              width: 20,
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                            ),
                          )
                        ],
                      ),
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
