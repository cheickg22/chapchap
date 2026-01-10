import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/common/local_data.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_divider.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/pages/rewards/widget/reward_page_shimmer.dart';
import 'package:restart_user/features/auth/application/auth_bloc.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          content: SizedBox(
                            width: size.width * 0.5,
                            height: size.height * 0.28,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.04,
                                  ),
                                  customRowText(
                                      context,
                                      AppLocalizations.of(context)!
                                          .howItWorksPointOne,
                                      size),
                                  customRowText(
                                      context,
                                      '${AppLocalizations.of(context)!.howItWorksPointTwo} ${AppLocalizations.of(context)!.howItWorksPointThree.replaceAll('\n', '\n')}',
                                      size),
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
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.rewardsText,
                automaticallyImplyLeading: true,
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
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                InkWell(
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: const TextStyle(
                                        color: AppColors.greyHintColor,
                                        fontSize: 14),
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
                              height: size.width * 0.2,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColorDark
                                      .withAlpha((0.5 * 255).toInt()),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image(
                                        height: size.width * 0.08,
                                        width: size.width * 0.16,
                                        image: const AssetImage(
                                            AppImages.rewardsBadge),
                                      ),
                                      MyText(
                                        text:
                                            "${AppLocalizations.of(context)!.yourPoints} : ",
                                        textStyle:
                                            const TextStyle(fontSize: 14),
                                      ),
                                      MyText(
                                        text:
                                            "${userData!.loyaltyPoints!.data.balanceRewardPoints}",
                                        textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 18,
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
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            size: 25,
                                          ),
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            SizedBox(height: size.width * 0.03),
                            MyText(
                              text: AppLocalizations.of(context)!.pointsHistory,
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: size.width * 0.03),
                            context.read<AccBloc>().driverRewardsList.isNotEmpty
                                ? Expanded(
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
                                                  Image(
                                                    image: AssetImage(context
                                                                .read<AccBloc>()
                                                                .driverRewardsList[
                                                                    index]
                                                                .isCredit ==
                                                            true
                                                        ? AppImages.giftImages
                                                        : AppImages.coinImages),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.04),
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
                                                              ? AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .rideReward
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .pointsRedeemed,
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                        MyText(
                                                          text: context
                                                              .read<AccBloc>()
                                                              .driverRewardsList[
                                                                  index]
                                                              .createdAt,
                                                          textStyle: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppColors
                                                                  .greyHintColor),
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
                                                        textStyle: TextStyle(
                                                            color: context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverRewardsList[
                                                                            index]
                                                                        .isCredit ==
                                                                    true
                                                                ? AppColors
                                                                    .green
                                                                : AppColors.red,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      MyText(
                                                        text: context
                                                            .read<AccBloc>()
                                                            .driverRewardsList[
                                                                index]
                                                            .rewardPoints
                                                            .toString(),
                                                        textStyle: TextStyle(
                                                            color: context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .driverRewardsList[
                                                                            index]
                                                                        .isCredit ==
                                                                    true
                                                                ? AppColors
                                                                    .green
                                                                : AppColors.red,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 10),
                                                child:
                                                    const HorizontalDotDividerWidget(),
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
            height: 8,
            width: 8,
            decoration: BoxDecoration(
                color: Theme.of(context).disabledColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: size.width * 0.62,
          child: MyText(
            text: text,
            maxLines: 3,
            textStyle: TextStyle(color: Theme.of(context).disabledColor),
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
  }
}
