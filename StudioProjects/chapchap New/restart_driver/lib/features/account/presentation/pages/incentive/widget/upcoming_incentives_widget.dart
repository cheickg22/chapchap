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

  const ShowUpcomingIncentivesWidget({
    super.key,
    required this.cont,
    required this.upcomingIncentives,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final incentives = context
              .read<AccBloc>()
              .selectedIncentiveHistory!
              .upcomingIncentives;

          return Container(
            margin: EdgeInsets.only(top: size.width * 0.05),
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(color: AppColors.borderColor, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: ListView.builder(
                itemCount: incentives.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: size.height * 0.05),
                itemBuilder: (context, index) {
                  final item = incentives[index];
                  final isCompleted = item.isCompleted;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * 0.33,
                        child: Column(
                          children: [
                            Container(
                              height: size.width * 0.05,
                              width: size.width * 0.05,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: isCompleted
                                      ? AppColors.green
                                      : AppColors.red,
                                ),
                              ),
                            ),
                            if (index != incentives.length - 1)
                              SizedBox(
                                height: size.height * 0.1,
                                child: VerticalDivider(
                                  color: isCompleted
                                      ? AppColors.green
                                      : AppColors.red,
                                  thickness: 2,
                                  width: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * 0.3,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: size.width * 0.04,
                            bottom: size.width * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width * 0.635,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.45,
                                      child: MyText(
                                        text:
                                            "${AppLocalizations.of(context)!.completeText} ${item.rideCount}",
                                        maxLines: 2,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                    ),
                                    MyText(
                                      text:
                                          "${userData!.currencySymbol} ${item.incentiveAmount}",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 16,
                                            color: isCompleted
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              SizedBox(
                                width: size.width * 0.635,
                                child: MyText(
                                  text: isCompleted
                                      ? AppLocalizations.of(context)!
                                          .acheivedTargetText
                                      : AppLocalizations.of(context)!
                                          .missedTargetText,
                                  maxLines: 3,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        color: isCompleted
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
