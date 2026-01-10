import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../application/acc_bloc.dart';

class IncentiveDateWidget extends StatelessWidget {
  final BuildContext cont;
  const IncentiveDateWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return SizedBox(
            height: size.width * 0.20,
            child: BlocBuilder<AccBloc, AccState>(
              builder: (context, state) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  controller: context.read<AccBloc>().incentiveScrollController,
                  physics: const PageScrollPhysics(),
                  itemCount: context.read<AccBloc>().incentiveDates.length,
                  itemBuilder: (context, index) {
                    final incentiveDate =
                        context.read<AccBloc>().incentiveDates[index].date;
                    final day =
                        context.read<AccBloc>().incentiveDates[index].day;
                    final formattedDate = context
                        .read<AccBloc>()
                        .formatDateBasedOnIndex(incentiveDate,
                            context.read<AccBloc>().choosenIncentiveData);
                    // Parse the API date into DateTime
                    final apiDate =
                        context.read<AccBloc>().choosenIncentiveData == 0
                            ? DateFormat("dd-MMM-yy").parse(incentiveDate)
                            : DateFormat('dd').parse(formattedDate);
                    final today = DateTime.now();

                    // Only check if the date is after today when choosenIncentiveData == 0
                    final isAfterToday =
                        context.read<AccBloc>().choosenIncentiveData == 0
                            ? apiDate.isAfter(today)
                            : false;

                    final isSelectedDate =
                        context.read<AccBloc>().selectedDate == formattedDate;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        InkWell(
                          onTap: isAfterToday &&
                                  context
                                          .read<AccBloc>()
                                          .choosenIncentiveData ==
                                      0
                              ? null // Disable tap for dates after today
                              : () {
                                  // Update the selected date when tapping on a new date
                                  context.read<AccBloc>().selectedDate =
                                      formattedDate;
                                  context.read<AccBloc>().add(
                                        SelectIncentiveDateEvent(
                                          selectedDate: formattedDate,
                                          isSelected: true,
                                          choosenIndex: context
                                              .read<AccBloc>()
                                              .choosenIncentiveData,
                                        ),
                                      );
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            height: size.width * 0.086,
                            width: size.width * 0.086,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelectedDate
                                  ? Theme.of(context)
                                      .primaryColorDark
                                      .withAlpha((0.5 * 255).toInt())
                                  : Colors.transparent,
                              border: Border.all(
                                color: isAfterToday &&
                                        context
                                                .read<AccBloc>()
                                                .choosenIncentiveData ==
                                            0
                                    ? Colors.transparent
                                    : Theme.of(context)
                                        .primaryColorDark
                                        .withAlpha((0.5 * 255).toInt()),
                              ),
                              boxShadow: isSelectedDate
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withAlpha((0.2 * 255).toInt()),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              formattedDate,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: context
                                                .read<AccBloc>()
                                                .choosenIncentiveData ==
                                            0
                                        ? 16
                                        : 9,
                                    color: isAfterToday &&
                                            context
                                                    .read<AccBloc>()
                                                    .choosenIncentiveData ==
                                                0
                                        ? Theme.of(context)
                                            .disabledColor // Grey text for disabled dates
                                        : isSelectedDate
                                            ? Theme.of(context)
                                                .scaffoldBackgroundColor
                                            : Theme.of(context)
                                                .primaryColorDark,
                                    fontWeight: isSelectedDate
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(width: size.width * 0.038),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
