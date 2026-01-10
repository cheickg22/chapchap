import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_header.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/rewards/widget/reward_page_shimmer.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/reward_points_widget.dart';

class RewardsPage extends StatelessWidget {
  static const String routeName = '/driverRewardsPage';

  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(DriverRewardInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UpdateRedeemedAmountState) {
            context.read<AccBloc>().redeemedAmount = state.redeemedAmount!;
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
          if (state is HowItWorksState) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) {
                  return BlocProvider.value(
                    value: context.read<AccBloc>(),
                    child: BlocBuilder<AccBloc, AccState>(
                      builder: (context, state) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          contentPadding: EdgeInsets.all(size.width * 0.05),
                          content: SizedBox(
                            width: size.width * 0.5,
                            height: size.height * 0.28,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.04,
                                  ),
                                  customRowText(
                                      context,
                                      AppLocalizations.of(context)!
                                          .howItWorksPointOne,
                                      size),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  customRowText(
                                      context,
                                      '${AppLocalizations.of(context)!.howItWorksPointTwo} ${AppLocalizations.of(context)!.howItWorksPointThree.replaceAll('\n', '\n')}',
                                      size),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  customRowText(
                                      context,
                                      AppLocalizations.of(context)!
                                          .howItWorksPointFour
                                          .replaceAll('\n', '\n'),
                                      size),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                });
          }
          if (state is DriverRewardPointsState) {
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                      value: context.read<AccBloc>(),
                      child: RewardPointsWidget(cont: context));
                });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomHeader(
                title: AppLocalizations.of(context)!.rewardsText,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              body: Container(
                  height: size.height,
                  padding: const EdgeInsets.all(20),
                  child: (context.read<AccBloc>().isLoading &&
                          context.read<AccBloc>().firstLoadReward &&
                          !context.read<AccBloc>().loadMoreReward)
                      ? const RewardsShimmer()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .myRewardsText,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 18,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                ),
                                InkWell(
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 14,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                  onTap: () {
                                    context
                                        .read<AccBloc>()
                                        .add(HowItWorksEvent());
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: size.width * 0.03),
                            Container(
                              padding: EdgeInsets.all(size.width * 0.05),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        AppImages.rewardImage,
                                        width: size.width * 0.1,
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      MyText(
                                        text:
                                            "${AppLocalizations.of(context)!.yourPoints} : ",
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      MyText(
                                        text:
                                            "${userData!.loyaltyPoints!.data.balanceRewardPoints}",
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  userData!.loyaltyPoints!.data
                                              .enableRewardConversation ==
                                          "1"
                                      ? InkWell(
                                          onTap: () {
                                            context
                                                .read<AccBloc>()
                                                .rewardAmountController
                                                .clear();
                                            context
                                                .read<AccBloc>()
                                                .addRewardMoney = null;
                                            context
                                                .read<AccBloc>()
                                                .add(DriverRewardPointsEvent());
                                          },
                                          child: Icon(
                                            CupertinoIcons.forward,
                                            color: Theme.of(context).hintColor,
                                            size: 25,
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.025),
                            MyText(
                              text: AppLocalizations.of(context)!.pointsHistory,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                            ),
                            SizedBox(height: size.width * 0.025),
                            context.read<AccBloc>().driverRewardsList.isNotEmpty
                                ? Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.borderColor),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.separated(
                                              controller: context
                                                  .read<AccBloc>()
                                                  .rewardsScrollController,
                                              itemCount: context
                                                  .read<AccBloc>()
                                                  .driverRewardsList
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  children: [
                                                    Container(
                                                      height: size.width * 0.1,
                                                      width: size.width * 0.1,
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: AppColors
                                                                  .grey),
                                                      alignment:
                                                          Alignment.center,
                                                      child: context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .driverRewardsList[
                                                                      index]
                                                                  .isCredit ==
                                                              true
                                                          ? Image.asset(
                                                              AppImages
                                                                  .giftImage,
                                                              width:
                                                                  size.width *
                                                                      0.065,
                                                            )
                                                          : Image.asset(
                                                              AppImages
                                                                  .minzImage,
                                                              width:
                                                                  size.width *
                                                                      0.065,
                                                            ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.025),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyText(
                                                            text: context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverRewardsList[
                                                                            index]
                                                                        .isCredit ==
                                                                    true
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .rideReward
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .pointsRedeemed,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 16,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                ),
                                                          ),
                                                          MyText(
                                                            text: context
                                                                .read<AccBloc>()
                                                                .driverRewardsList[
                                                                    index]
                                                                .createdAt,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 12,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .hintColor,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        MyText(
                                                          text: context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .driverRewardsList[
                                                                          index]
                                                                      .isCredit ==
                                                                  true
                                                              ? "+ "
                                                              : "- ",
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                    color: context.read<AccBloc>().driverRewardsList[index].isCredit ==
                                                                            true
                                                                        ? AppColors
                                                                            .green
                                                                        : AppColors
                                                                            .red,
                                                                  ),
                                                        ),
                                                        MyText(
                                                          text: context
                                                              .read<AccBloc>()
                                                              .driverRewardsList[
                                                                  index]
                                                              .rewardPoints
                                                              .toString(),
                                                          textStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        18,
                                                                    color: context.read<AccBloc>().driverRewardsList[index].isCredit ==
                                                                            true
                                                                        ? AppColors
                                                                            .green
                                                                        : AppColors
                                                                            .red,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return Container(
                                                  padding: EdgeInsets.only(
                                                      top: size.width * 0.025,
                                                      bottom:
                                                          size.width * 0.025),
                                                  child: Container(
                                                    height: size.width * 0.002,
                                                    width: size.width,
                                                    color:
                                                        AppColors.borderColors,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          if (context
                                                  .read<AccBloc>()
                                                  .loadMoreReward &&
                                              !context
                                                  .read<AccBloc>()
                                                  .isLoading &&
                                              !context
                                                  .read<AccBloc>()
                                                  .firstLoadReward)
                                            Center(
                                              child: SizedBox(
                                                  height: size.width * 0.08,
                                                  width: size.width * 0.08,
                                                  child:
                                                      const CircularProgressIndicator()),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(50),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                                AppImages.noRewardsImage),
                                            SizedBox(
                                              height: size.width * 0.05,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .noRewardsTopText,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.03,
                                            ),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .noRewardSubText,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withAlpha((0.8 * 255)
                                                            .toInt()),
                                                  ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        )),
            );
          },
        ),
      ),
    );
  }

  Row customRowText(BuildContext context, String text, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Container(
            height: size.width * 0.04,
            width: size.width * 0.04,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.2, color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: size.width * 0.62,
          child: MyText(
            text: text,
            maxLines: 3,
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).primaryColorDark, fontSize: 16),
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
  }
}
