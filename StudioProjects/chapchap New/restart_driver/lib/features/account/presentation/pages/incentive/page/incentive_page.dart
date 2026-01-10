import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/incentive_date_widget.dart';
import '../widget/upcoming_incentives_widget.dart';

class IncentivePage extends StatelessWidget {
  static const String routeName = '/incentivePage';

  const IncentivePage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetIncentiveEvent(
            type: userData!.availableIncentive == '0' ||
                    userData?.availableIncentive == '2'
                ? 0
                : 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is IncentiveLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is ShowErrorState) {
            showToast(message: state.message);
          }

          if (state is IncentiveLoadingStopState) {
            CustomLoader.dismiss(context);
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.incentives,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: SafeArea(
                  child: Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    Column(
                      children: [
                        userData?.availableIncentive == '2'
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.borderColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: size.width * 0.15,
                                padding: EdgeInsets.all(size.width * 0.0125),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (context
                                                .read<AccBloc>()
                                                .choosenIncentiveData !=
                                            0) {
                                          context
                                              .read<AccBloc>()
                                              .add(GetIncentiveEvent(type: 0));
                                        }
                                      },
                                      child: Container(
                                          width: size.width * 0.42,
                                          decoration: BoxDecoration(
                                            color: (context
                                                        .read<AccBloc>()
                                                        .choosenIncentiveData ==
                                                    0)
                                                ? AppColors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .dailyCaps,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontSize: 16,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .choosenIncentiveData ==
                                                          0)
                                                      ? AppColors.hintColorGrey
                                                      : Theme.of(context)
                                                          .hintColor,
                                                ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (context
                                                .read<AccBloc>()
                                                .choosenIncentiveData !=
                                            1) {
                                          context
                                              .read<AccBloc>()
                                              .add(GetIncentiveEvent(type: 1));
                                        }
                                      },
                                      child: Container(
                                          width: size.width * 0.42,
                                          decoration: BoxDecoration(
                                            color: (context
                                                        .read<AccBloc>()
                                                        .choosenIncentiveData ==
                                                    1)
                                                ? AppColors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .weeklyCaps,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  fontSize: 16,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .choosenIncentiveData ==
                                                          1)
                                                      ? AppColors.hintColorGrey
                                                      : Theme.of(context)
                                                          .hintColor,
                                                ),
                                          )),
                                    ),
                                  ],
                                ),
                              )
                            : userData?.availableIncentive == '0'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .dailyCaps,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                        ),
                                      ),
                                    ],
                                  )
                                : userData?.availableIncentive == '1'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .weeklyCaps,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(
                                                    fontSize: 18,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        SizedBox(
                          height: size.width * 0.185,
                          child: IncentiveDateWidget(cont: context),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        if (context.read<AccBloc>().selectedIncentiveHistory !=
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
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                  text:
                                      "${AppLocalizations.of(context)!.earnUptoText} ${userData!.currencySymbol} ${context.read<AccBloc>().selectedIncentiveHistory!.earnUpto}",
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
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
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(
                                  height: size.width * 0.02,
                                ),
                                Container(
                                  height: size.height * 0.05,
                                  width: size.width * 0.8,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Center(
                                    child: MyText(
                                      text: context
                                              .read<AccBloc>()
                                              .selectedIncentiveHistory!
                                              .upcomingIncentives
                                              .any((element) =>
                                                  element.isCompleted == false)
                                          ? AppLocalizations.of(context)!
                                              .missedIncentiveText
                                          : AppLocalizations.of(context)!
                                              .earnedIncentiveText,
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
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                    (context.read<AccBloc>().incentiveHistory.isNotEmpty &&
                            context.read<AccBloc>().incentiveDates.isNotEmpty)
                        ? Expanded(
                            child: BlocBuilder<AccBloc, AccState>(
                              builder: (context, state) {
                                if (state is ShowUpcomingIncentivesState) {
                                  return ShowUpcomingIncentivesWidget(
                                      cont: context,
                                      upcomingIncentives:
                                          state.upcomingIncentives);
                                }
                                return Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .selectDateForIncentives,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .incentiveEmptyText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              )));
        }),
      ),
    );
  }
}
