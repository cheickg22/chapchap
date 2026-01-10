import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/invoice_page/widget/fare_breakdown_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class ReportsPage extends StatelessWidget {
  static const String routeName = '/reportsPage';
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is ReportLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is ReportSubmitState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.reportsText,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: size.width * 0.05,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.generateReport,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor),
                      ),
                      MyText(
                          text: AppLocalizations.of(context)!.from,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 14)),
                      InkWell(
                        onTap: () {
                          context.read<AccBloc>().add(ChooseDateEvent(
                              context: context, isFromDate: true));
                        },
                        child: CustomTextField(
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                          hintText: 'dd-mm-yyyy',
                          hintTextStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor),
                          enabled: false,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          controller: context.read<AccBloc>().fromDateText,
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: size.width * 0.075,
                          ),
                        ),
                      ),
                      MyText(
                          text: AppLocalizations.of(context)!.to,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 14)),
                      InkWell(
                        onTap: () {
                          context.read<AccBloc>().add(ChooseDateEvent(
                              context: context, isFromDate: false));
                        },
                        child: CustomTextField(
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                          hintText: 'dd-mm-yyyy',
                          hintTextStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor),
                          enabled: false,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: AppColors.borderColors, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          controller: context.read<AccBloc>().toDateText,
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: size.width * 0.075,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: size.width * 0.03,
                        children: [
                          CustomButton(
                              width: size.width * 0.4,
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: 8,
                              buttonColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              textColor: Theme.of(context).primaryColor,
                              buttonName: AppLocalizations.of(context)!.clear,
                              textSize: 18,
                              onTap: () {
                                context.read<AccBloc>().add(ReportClearEvent());
                              }),
                          CustomButton(
                              width: size.width * 0.4,
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: 8,
                              buttonName: AppLocalizations.of(context)!.filter,
                              textSize: 18,
                              onTap: () {
                                if (context
                                        .read<AccBloc>()
                                        .fromDateText
                                        .text
                                        .isNotEmpty &&
                                    context
                                        .read<AccBloc>()
                                        .toDateText
                                        .text
                                        .isNotEmpty) {
                                  context.read<AccBloc>().add(ReportSubmitEvent(
                                      fromDate: context
                                          .read<AccBloc>()
                                          .fromDateText
                                          .text,
                                      toDate: context
                                          .read<AccBloc>()
                                          .toDateText
                                          .text));
                                } else {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .enterRequiredField);
                                }
                              })
                        ],
                      ),
                      if (context.read<AccBloc>().reportsData != null)
                        Column(
                          spacing: size.width * 0.05,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              text:
                                  '${context.read<AccBloc>().reportsData!.fromDate} - ${context.read<AccBloc>().reportsData!.toDate}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                            MyText(
                              text:
                                  '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalCashTripAmount}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark),
                            ),
                            Container(
                              height: size.width * 0.23,
                              width: size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.cash} ${AppLocalizations.of(context)!.count}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.black)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalCashTripCount
                                                  .toString(),
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: AppColors.black)),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child:
                                        VerticalDivider(color: AppColors.black),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.wallet} ${AppLocalizations.of(context)!.count}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.black)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalWalletTripCount
                                                  .toString(),
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: AppColors.black)),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child:
                                        VerticalDivider(color: AppColors.black),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.trips} ${AppLocalizations.of(context)!.count}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.black)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalTripsCount
                                                  .toString(),
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: AppColors.black)),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            FareBreakdownWidget(
                                cont: context,
                                name:
                                    AppLocalizations.of(context)!.totalTripsKms,
                                price:
                                    '${context.read<AccBloc>().reportsData!.totalTripKms}'),
                            FareBreakdownWidget(
                                cont: context,
                                name:
                                    "${AppLocalizations.of(context)!.wallet} ${AppLocalizations.of(context)!.payment}",
                                price:
                                    '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalWalletTripAmount}'),
                            FareBreakdownWidget(
                                cont: context,
                                name:
                                    "${AppLocalizations.of(context)!.cash} ${AppLocalizations.of(context)!.payment}",
                                price:
                                    '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalCashTripAmount}'),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: size.width * 0.025,
                                  bottom: size.width * 0.025),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .totalEarnings,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: size.width * 0.04,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                      maxLines: 2,
                                    ),
                                  ),
                                  SizedBox(
                                    child: MyText(
                                      text:
                                          "${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalEarnings}",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: size.width * 0.04,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
