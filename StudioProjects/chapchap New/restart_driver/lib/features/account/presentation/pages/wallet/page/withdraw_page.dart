import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/widget/wallet_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../widget/withdraw_history_data_widget.dart';
import '../widget/withdraw_money_wallet_widget.dart';

class WithdrawPage extends StatelessWidget {
  static const String routeName = '/withdrawPage';
  final WithdrawPageArguments arg;
  const WithdrawPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(GetWithdrawInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is WithdrawDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is WithdrawDataLoadingStopState) {
            CustomLoader.dismiss(context);
            final acc = context.read<AccBloc>();
            if (arg.initialBankIndex != null &&
                arg.initialBankIndex! >= 0 &&
                acc.bankDetails.isNotEmpty &&
                arg.initialBankIndex! < acc.bankDetails.length &&
                acc.addBankInfo == false &&
                acc.editBank == false) {
              final idx = arg.initialBankIndex!;
              final hasData =
                  acc.bankDetails[idx]['driver_bank_info']['data'].toString() !=
                      '[]';
              final openEdit = arg.openEdit == true;
              if (openEdit && hasData) {
                acc.add(EditBankEvent(choosen: idx));
              } else {
                acc.add(AddBankEvent(choosen: idx));
              }
            }
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          } else if (state is BankUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.paymentMethodSuccess)),
            );
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final acc = context.read<AccBloc>();
          if (arg.initialBankIndex != null &&
              acc.bankDetails.isNotEmpty &&
              arg.initialBankIndex! >= 0 &&
              arg.initialBankIndex! < acc.bankDetails.length &&
              acc.addBankInfo == false &&
              acc.editBank == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (acc.addBankInfo || acc.editBank) return;
              final idx = arg.initialBankIndex!;
              final hasData =
                  acc.bankDetails[idx]['driver_bank_info']['data'].toString() !=
                      '[]';
              final openEdit = arg.openEdit == true;
              if (openEdit && hasData) {
                acc.add(EditBankEvent(choosen: idx));
              } else {
                acc.add(AddBankEvent(choosen: idx));
              }
            });
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.recentWithdrawal,
              automaticallyImplyLeading: true,
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Wallet Balance Card
                      Container(
                        margin: EdgeInsets.all(size.width * 0.04),
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.width * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.walletBalance,
                              textStyle: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: size.width * 0.02),
                            if (context.read<AccBloc>().isWithdrawLoading &&
                                !context.read<AccBloc>().loadWithdrawMore)
                              SizedBox(
                                height: size.width * 0.08,
                                width: size.width * 0.08,
                                child: const CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            if (context.read<AccBloc>().withdrawResponse !=
                                null)
                              MyText(
                                text:
                                    '${userData!.currencySymbol}${context.read<AccBloc>().withdrawResponse!.walletBalance.toString()}',
                                textStyle: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: size.width * 0.04),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  // backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) {
                                    return BlocBuilder<AccBloc, AccState>(
                                      builder: (_, state) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            // color: AppColors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(24),
                                            ),
                                          ),
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Container(
                                                  width: 40,
                                                  height: 4,
                                                  margin: EdgeInsets.only(
                                                      bottom:
                                                          size.width * 0.04),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                  ),
                                                ),
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .paymentMethods,
                                                textStyle: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.04),
                                              if (context
                                                  .read<AccBloc>()
                                                  .bankDetails
                                                  .isNotEmpty)
                                                ListView.builder(
                                                  itemCount: context
                                                      .read<AccBloc>()
                                                      .bankDetails
                                                      .length,
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: EdgeInsets.zero,
                                                  itemBuilder: (_, i) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        (context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .bankDetails[
                                                                        i][
                                                                        'driver_bank_info']
                                                                        ['data']
                                                                    .toString() ==
                                                                '[]')
                                                            ? context
                                                                .read<AccBloc>()
                                                                .add(
                                                                    AddBankEvent(
                                                                        choosen:
                                                                            i))
                                                            : context
                                                                .read<AccBloc>()
                                                                .add(
                                                                    EditBankEvent(
                                                                        choosen:
                                                                            i));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: size.width *
                                                                0.03),
                                                        padding: EdgeInsets.all(
                                                            size.width * 0.04),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: MyText(
                                                                text: context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .bankDetails[i]
                                                                    [
                                                                    'method_name'],
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                            MyText(
                                                              text: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .bankDetails[
                                                                              i]
                                                                              [
                                                                              'driver_bank_info']
                                                                              [
                                                                              'data']
                                                                          .toString() ==
                                                                      '[]')
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .textAdd
                                                                  : AppLocalizations.of(
                                                                          context)!
                                                                      .textView,
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            const Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                size: 14,
                                                                color: AppColors
                                                                    .primary),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              SizedBox(
                                                  height: size.width * 0.04),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * 0.03),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .updatePaymentMethod,
                                    textStyle: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Recent Withdrawal Section
                      Expanded(
                        child: Container(
                          width: size.width,
                          padding: EdgeInsets.fromLTRB(
                            size.width * 0.04,
                            size.width * 0.05,
                            size.width * 0.04,
                            size.width * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .recentWithdrawal,
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              SizedBox(height: size.width * 0.04),
                              if (context.read<AccBloc>().isWithdrawLoading &&
                                  context.read<AccBloc>().firstWithdrawLoad)
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: 8,
                                    itemBuilder: (context, index) {
                                      return ShimmerWalletHistory(size: size);
                                    },
                                  ),
                                ),
                              if (context.read<AccBloc>().isWithdrawLoading ==
                                  false) ...[
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: context
                                        .read<AccBloc>()
                                        .scrollController,
                                    child: Column(
                                      children: [
                                        WithdrawHistoryDataWidget(
                                          withdrawHistoryList: context
                                              .read<AccBloc>()
                                              .withdrawData,
                                          cont: context,
                                        ),
                                        if (context
                                            .read<AccBloc>()
                                            .loadWithdrawMore)
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.width * 0.04),
                                              child: SizedBox(
                                                height: size.width * 0.06,
                                                width: size.width * 0.06,
                                                child:
                                                    const CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.width * 0.02),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04),
                                  child: CustomButton(
                                    buttonName: AppLocalizations.of(context)!
                                        .requestWithdraw,
                                    width: double.infinity,
                                    borderRadius: 12,
                                    buttonColor: AppColors.primary,
                                    textColor: AppColors.white,
                                    textSize: 16,
                                    onTap: () {
                                      if (context
                                          .read<AccBloc>()
                                          .bankDetails
                                          .where((e) =>
                                              e['driver_bank_info']['data']
                                                  .toString() !=
                                              '[]')
                                          .isNotEmpty) {
                                        context
                                            .read<AccBloc>()
                                            .withdrawAmountController
                                            .clear();
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (builder) {
                                            return WithdrawMoneyWalletWidget(
                                              cont: context,
                                              minWalletAmount:
                                                  arg.minWalletAmount,
                                            );
                                          },
                                        );
                                      } else {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          // backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) {
                                            return BlocBuilder<AccBloc,
                                                AccState>(
                                              builder: (_, state) {
                                                return Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    // color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(24),
                                                      topRight:
                                                          Radius.circular(24),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.05),
                                                  child: SafeArea(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: 40,
                                                            height: 4,
                                                            margin: EdgeInsets.only(
                                                                bottom:
                                                                    size.width *
                                                                        0.04),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[300],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
                                                            ),
                                                          ),
                                                        ),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .paymentMethods,
                                                          textStyle: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark),
                                                        ),
                                                        SizedBox(
                                                            height: size.width *
                                                                0.04),
                                                        if (context
                                                            .read<AccBloc>()
                                                            .bankDetails
                                                            .isNotEmpty)
                                                          ListView.builder(
                                                            itemCount: context
                                                                .read<AccBloc>()
                                                                .bankDetails
                                                                .length,
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemBuilder:
                                                                (_, i) {
                                                              final bank = context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .bankDetails
                                                                  .elementAt(i);
                                                              return InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .add(AddBankEvent(
                                                                          choosen:
                                                                              i));
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets.only(
                                                                      bottom: size
                                                                              .width *
                                                                          0.03),
                                                                  padding: EdgeInsets
                                                                      .all(size
                                                                              .width *
                                                                          0.04),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        100],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            MyText(
                                                                          text:
                                                                              bank['method_name'],
                                                                          textStyle:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                AppColors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      MyText(
                                                                        text: (bank['driver_bank_info']['data'].toString() ==
                                                                                '[]')
                                                                            ? AppLocalizations.of(context)!.textAdd
                                                                            : AppLocalizations.of(context)!.textView,
                                                                        textStyle:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              AppColors.primary,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      const Icon(
                                                                          Icons
                                                                              .arrow_forward_ios,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              AppColors.primary),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: size.width * 0.02),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bank Details Overlay
                  if (context.read<AccBloc>().addBankInfo ||
                      (context.read<AccBloc>().editBank))
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.05),
                        height: size.height,
                        width: size.width,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Column(
                          children: [
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyText(
                                    text: context.read<AccBloc>().editBank
                                        ? AppLocalizations.of(context)!
                                            .editBankDetails
                                        : AppLocalizations.of(context)!
                                            .bankDetails,
                                    textStyle: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.08)
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            SizedBox(
                              height: size.height * 0.6,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (context
                                        .read<AccBloc>()
                                        .choosenBankList
                                        .isNotEmpty)
                                      ListView.builder(
                                        itemCount: context
                                            .read<AccBloc>()
                                            .choosenBankList
                                            .length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: size.width * 0.04),
                                              SizedBox(
                                                width: size.width * 0.9,
                                                child: MyText(
                                                  text: context
                                                          .read<AccBloc>()
                                                          .choosenBankList[
                                                      index]['placeholder'],
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.02),
                                              SizedBox(
                                                width: size.width * 0.9,
                                                child: CustomTextField(
                                                  keyboardType: context
                                                                  .read<AccBloc>()
                                                                  .choosenBankList[index]
                                                              [
                                                              'input_field_type'] ==
                                                          "text"
                                                      ? TextInputType.text
                                                      : TextInputType.number,
                                                  controller: context
                                                      .read<AccBloc>()
                                                      .bankDetailsText[index],
                                                  hintText: context
                                                          .read<AccBloc>()
                                                          .choosenBankList[
                                                      index]['placeholder'],
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            AppColors.primary,
                                                        width: 2),
                                                  ),
                                                  disabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      if (context.read<AccBloc>().editBank) {
                                        context
                                            .read<AccBloc>()
                                            .add(EditBankEvent(choosen: null));
                                      } else {
                                        context
                                            .read<AccBloc>()
                                            .add(AddBankEvent(choosen: null));
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: size.width * 0.04),
                                      side: const BorderSide(
                                          color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: MyText(
                                      text:
                                          AppLocalizations.of(context)!.cancel,
                                      textStyle: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Expanded(
                                  child: CustomButton(
                                    buttonName:
                                        AppLocalizations.of(context)!.confirm,
                                    borderRadius: 12,
                                    buttonColor: AppColors.primary,
                                    textColor: AppColors.white,
                                    textSize: 16,
                                    height: size.width * 0.12,
                                    onTap: () {
                                      Map body = {
                                        "method_id": context
                                            .read<AccBloc>()
                                            .choosenBankList[0]['method_id'],
                                      };

                                      for (var i = 0;
                                          i <
                                              context
                                                  .read<AccBloc>()
                                                  .choosenBankList
                                                  .length;
                                          i++) {
                                        if ((context
                                                        .read<AccBloc>()
                                                        .choosenBankList[i]
                                                            ['is_required']
                                                        .toString() ==
                                                    '1' &&
                                                context
                                                    .read<AccBloc>()
                                                    .bankDetailsText[i]
                                                    .text
                                                    .isNotEmpty) ||
                                            context
                                                .read<AccBloc>()
                                                .bankDetailsText[i]
                                                .text
                                                .isNotEmpty) {
                                          body["${context.read<AccBloc>().choosenBankList[i]['input_field_name']}"] =
                                              context
                                                  .read<AccBloc>()
                                                  .bankDetailsText[i]
                                                  .text;
                                        } else if (context
                                                .read<AccBloc>()
                                                .choosenBankList[i]
                                                    ['is_required']
                                                .toString() ==
                                            '1') {
                                          showToast(
                                              message:
                                                  AppLocalizations.of(context)!
                                                      .enterRequiredField);
                                          return;
                                        }
                                      }
                                      context.read<AccBloc>().add(
                                          UpdateBankDetailsEvent(body: body));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
