import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/common/local_data.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/extensions.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';

class LeaderboardPage extends StatelessWidget {
  static const String routeName = '/leaderboardPage';
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(GetLeaderBoardEvent(type: 0)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is LeaderBoardLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is UserUnauthenticatedState) {
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
          }
          if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }

          if (state is LeaderBoardLoadingStopState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              body: SizedBox(
                height: size.height - size.width * 0.2,
                width: size.width,
                child: Column(
                  children: [
                    Container(
                      width: size.width,
                      padding: EdgeInsets.all(size.width * 0.05),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25)),
                          color: AppColors.secondary),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.paddingOf(context).top +
                                size.width * 0.05,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.leaderboard,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    fontSize: 18,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * 0.04,
                          ),
                          if (context.read<AccBloc>().leaderBoardData != null &&
                              context
                                  .read<AccBloc>()
                                  .leaderBoardData!
                                  .isNotEmpty)
                            Container(
                              width: size.width * 0.07,
                              height: size.width * 0.07,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    AppImages.leaderBoardCrown,
                                  ),
                                ),
                              ),
                            ),
                          if (context.read<AccBloc>().leaderBoardData != null &&
                              context
                                  .read<AccBloc>()
                                  .leaderBoardData!
                                  .isNotEmpty)
                            Stack(
                              children: [
                                SizedBox(
                                  width: size.width * 0.8,
                                  height: size.width * 0.45,
                                ),
                                if (context.read<AccBloc>().leaderBoardData !=
                                        null &&
                                    context
                                        .read<AccBloc>()
                                        .leaderBoardData!
                                        .isNotEmpty)
                                  Positioned(
                                      left: size.width * 0.3,
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: size.width *
                                                        (0.07 / 2)),
                                                width: size.width * 0.2,
                                                height: size.width * 0.2,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Container(
                                                  width: size.width * 0.18,
                                                  height: size.width * 0.18,
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .leaderBoardData![
                                                                      0]
                                                                  .profile),
                                                          fit: BoxFit.cover)),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 0,
                                                  left: size.width * (0.14 / 2),
                                                  child: Container(
                                                    width: size.width * 0.07,
                                                    height: size.width * 0.07,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: AppColors
                                                                .white),
                                                    alignment: Alignment.center,
                                                    child: MyText(
                                                      text: '1',
                                                      textStyle: Theme.of(
                                                              context)
                                                          .textTheme
                                                          .headlineLarge!
                                                          .copyWith(
                                                              fontSize: 16,
                                                              color: AppColors
                                                                  .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * 0.025,
                                          ),
                                          SizedBox(
                                            width: size.width * 0.2,
                                            child: Column(
                                              children: [
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .leaderBoardData![0]
                                                      .driverName,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineLarge!
                                                      .copyWith(
                                                          fontSize: 16,
                                                          color:
                                                              AppColors.white,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                                MyText(
                                                  text: context
                                                              .read<AccBloc>()
                                                              .choosenLeaderboardData ==
                                                          0
                                                      ? "${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![0].commission}"
                                                      : "${context.read<AccBloc>().leaderBoardData![0].trips} ${AppLocalizations.of(context)!.trips}",
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineLarge!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.white,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      size.width * (0.07 / 2)),
                                              width: size.width * 0.2,
                                              height: size.width * 0.2,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: AppColors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: (context
                                                              .read<AccBloc>()
                                                              .leaderBoardData !=
                                                          null &&
                                                      context
                                                              .read<AccBloc>()
                                                              .leaderBoardData!
                                                              .length >=
                                                          2)
                                                  ? Container(
                                                      width: size.width * 0.18,
                                                      height: size.width * 0.18,
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor,
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .leaderBoardData![
                                                                      1]
                                                                  .profile),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    )
                                                  : Container(
                                                      width: size.width * 0.15,
                                                      height: size.width * 0.15,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .question_mark_outlined,
                                                        color: Theme.of(context)
                                                            .disabledColor,
                                                      )),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                left: size.width * (0.14 / 2),
                                                child: Container(
                                                  width: size.width * 0.07,
                                                  height: size.width * 0.07,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.white),
                                                  alignment: Alignment.center,
                                                  child: MyText(
                                                    text: '2',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .headlineLarge!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ))
                                          ],
                                        ),
                                        SizedBox(
                                          height: size.width * 0.025,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: Column(
                                            children: [
                                              MyText(
                                                text: (context
                                                                .read<AccBloc>()
                                                                .leaderBoardData !=
                                                            null &&
                                                        context
                                                                .read<AccBloc>()
                                                                .leaderBoardData!
                                                                .length >=
                                                            2)
                                                    ? context
                                                        .read<AccBloc>()
                                                        .leaderBoardData![1]
                                                        .driverName
                                                    : '',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                              MyText(
                                                text: (context
                                                                .read<AccBloc>()
                                                                .leaderBoardData !=
                                                            null &&
                                                        context
                                                                .read<AccBloc>()
                                                                .leaderBoardData!
                                                                .length >=
                                                            2)
                                                    ? context
                                                                .read<AccBloc>()
                                                                .choosenLeaderboardData ==
                                                            0
                                                        ? "${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![1].commission}"
                                                        : "${context.read<AccBloc>().leaderBoardData![1].trips} ${AppLocalizations.of(context)!.trips}"
                                                    : "",
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      size.width * (0.07 / 2)),
                                              width: size.width * 0.2,
                                              height: size.width * 0.2,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: AppColors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: (context
                                                              .read<AccBloc>()
                                                              .leaderBoardData !=
                                                          null &&
                                                      context
                                                              .read<AccBloc>()
                                                              .leaderBoardData!
                                                              .length >=
                                                          3)
                                                  ? Container(
                                                      width: size.width * 0.18,
                                                      height: size.width * 0.18,
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor,
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: NetworkImage(context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .leaderBoardData![
                                                                      2]
                                                                  .profile),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    )
                                                  : Container(
                                                      width: size.width * 0.15,
                                                      height: size.width * 0.15,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                          Icons
                                                              .question_mark_outlined,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor)),
                                            ),
                                            Positioned(
                                                bottom: 0,
                                                left: size.width * (0.14 / 2),
                                                child: Container(
                                                  width: size.width * 0.07,
                                                  height: size.width * 0.07,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              AppColors.white),
                                                  alignment: Alignment.center,
                                                  child: MyText(
                                                    text: '3',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .headlineLarge!
                                                        .copyWith(
                                                            fontSize: 16,
                                                            color:
                                                                AppColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ))
                                          ],
                                        ),
                                        SizedBox(
                                          height: size.width * 0.025,
                                        ),
                                        SizedBox(
                                          width: size.width * 0.2,
                                          child: Column(
                                            children: [
                                              MyText(
                                                text: (context
                                                                .read<AccBloc>()
                                                                .leaderBoardData !=
                                                            null &&
                                                        context
                                                                .read<AccBloc>()
                                                                .leaderBoardData!
                                                                .length >=
                                                            3)
                                                    ? context
                                                        .read<AccBloc>()
                                                        .leaderBoardData![2]
                                                        .driverName
                                                    : '',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                              MyText(
                                                text: (context
                                                                .read<AccBloc>()
                                                                .leaderBoardData !=
                                                            null &&
                                                        context
                                                                .read<AccBloc>()
                                                                .leaderBoardData!
                                                                .length >=
                                                            3)
                                                    ? context
                                                                .read<AccBloc>()
                                                                .choosenLeaderboardData ==
                                                            0
                                                        ? "${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![2].commission}"
                                                        : "${context.read<AccBloc>().leaderBoardData![2].trips} ${AppLocalizations.of(context)!.trips}"
                                                    : '',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: AppColors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          SizedBox(
                            height: size.width * 0.025,
                          ),
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (context
                                            .read<AccBloc>()
                                            .choosenLeaderboardData !=
                                        0) {
                                      context
                                          .read<AccBloc>()
                                          .add(GetLeaderBoardEvent(type: 0));
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.45,
                                    padding: EdgeInsets.all(size.width * 0.05),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: (context
                                                            .read<AccBloc>()
                                                            .choosenLeaderboardData ==
                                                        0)
                                                    ? AppColors.primary
                                                    : Colors.transparent))),
                                    alignment: Alignment.center,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .earnings,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headlineLarge!
                                          .copyWith(
                                              fontSize: 16,
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenLeaderboardData ==
                                                      0)
                                                  ? AppColors.primary
                                                  : AppColors.white,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (context
                                            .read<AccBloc>()
                                            .choosenLeaderboardData !=
                                        1) {
                                      context
                                          .read<AccBloc>()
                                          .add(GetLeaderBoardEvent(type: 1));
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.45,
                                    padding: EdgeInsets.all(size.width * 0.05),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: (context
                                                            .read<AccBloc>()
                                                            .choosenLeaderboardData ==
                                                        1)
                                                    ? AppColors.primary
                                                    : Colors.transparent))),
                                    alignment: Alignment.center,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!.trips,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headlineLarge!
                                          .copyWith(
                                              fontSize: 16,
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenLeaderboardData ==
                                                      1)
                                                  ? AppColors.primary
                                                  : AppColors.white,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    (context.read<AccBloc>().leaderBoardData != null &&
                            context
                                .read<AccBloc>()
                                .leaderBoardData!
                                .isNotEmpty &&
                            context.read<AccBloc>().leaderBoardData!.length > 3)
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 3;
                                      i <
                                          context
                                              .read<AccBloc>()
                                              .leaderBoardData!
                                              .length;
                                      i++)
                                    Container(
                                      margin:
                                          EdgeInsets.all(size.width * 0.025),
                                      padding: EdgeInsets.fromLTRB(
                                          size.width * 0.05,
                                          size.width * 0.030,
                                          size.width * 0.05,
                                          size.width * 0.030),
                                      width: size.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width * 0.1,
                                            height: size.width * 0.1,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: NetworkImage(context
                                                        .read<AccBloc>()
                                                        .leaderBoardData![i]
                                                        .profile),
                                                    fit: BoxFit.cover)),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.025,
                                          ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: context
                                                    .read<AccBloc>()
                                                    .leaderBoardData![i]
                                                    .driverName,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              SizedBox(
                                                height: size.width * 0.010,
                                              ),
                                              MyText(
                                                text: (context
                                                            .read<AccBloc>()
                                                            .choosenLeaderboardData ==
                                                        0)
                                                    ? '${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![i].commission}'
                                                    : '${context.read<AccBloc>().leaderBoardData![i].trips} ${AppLocalizations.of(context)!.trips}',
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .headlineLarge!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .greyHeader,
                                                        fontWeight:
                                                            FontWeight.normal),
                                              )
                                            ],
                                          )),
                                          MyText(
                                            text: (i + 1).toString(),
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .headlineLarge!
                                                .copyWith(
                                                    fontSize: 24,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                    height: size.width * 0.25,
                                  )
                                ],
                              ),
                            ),
                          )
                        : ((context.read<AccBloc>().leaderBoardData != null &&
                                context
                                    .read<AccBloc>()
                                    .leaderBoardData!
                                    .isEmpty))
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.leaderBoardEmpty,
                                    width: 200,
                                    height: 200,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .noDataLeaderBoard,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .addRankingText,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                        ),
                                  ),
                                ],
                              )
                            : (context.read<AccBloc>().leaderBoardData !=
                                        null &&
                                    context
                                        .read<AccBloc>()
                                        .leaderBoardData!
                                        .isNotEmpty &&
                                    context
                                            .read<AccBloc>()
                                            .leaderBoardData!
                                            .length <=
                                        3)
                                ? Container(
                                    margin: EdgeInsets.all(size.width * 0.025),
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        size.width * 0.030,
                                        size.width * 0.05,
                                        size.width * 0.030),
                                    height: size.width * 0.2,
                                    width: size.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              spreadRadius: 1,
                                              blurRadius: 1)
                                        ]),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: size.width * 0.1,
                                          height: size.width * 0.1,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          child: Container(
                                            width: size.width * 0.1,
                                            height: size.width * 0.1,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage(AppImages
                                                        .defaultProfile),
                                                    fit: BoxFit.cover)),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.025,
                                        ),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text: '- -',
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: size.width * 0.010,
                                            ),
                                            MyText(
                                              text: "?",
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color:
                                                          AppColors.greyHeader,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            )
                                          ],
                                        )),
                                        MyText(
                                          text: "4",
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .copyWith(
                                                  fontSize: 24,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
