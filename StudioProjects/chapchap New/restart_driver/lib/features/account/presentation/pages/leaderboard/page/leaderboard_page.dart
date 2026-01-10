import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/utils/custom_header.dart';
import '../../../../../auth/presentation/pages/login_page.dart';

class LeaderboardPage extends StatelessWidget {
  static const String routeName = '/leaderboardPage';
  final LeaderBoardArguments? args;
  const LeaderboardPage({super.key, this.args});

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
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
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
              appBar: CustomHeader(
                title: AppLocalizations.of(context)!.leaderboard,
                automaticallyImplyLeading: false,
                titleFontSize: 18,
                textColor: Theme.of(context).primaryColorDark,
              ),
              body: (context.read<AccBloc>().leaderBoardData != null &&
                      context.read<AccBloc>().leaderBoardData!.isNotEmpty)
                  ? Column(
                      children: [
                        SizedBox(
                          height: size.width * 0.025,
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: AppColors.borderColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(size.width * 0.0125),
                            margin: EdgeInsets.only(
                                left: size.width * 0.05,
                                right: size.width * 0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    width: size.width * 0.38,
                                    padding: EdgeInsets.all(size.width * 0.025),
                                    decoration: BoxDecoration(
                                      color: (context
                                                  .read<AccBloc>()
                                                  .choosenLeaderboardData ==
                                              0)
                                          ? AppColors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .earnings,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontSize: 16,
                                            color: (context
                                                        .read<AccBloc>()
                                                        .choosenLeaderboardData ==
                                                    0)
                                                ? AppColors.hintColorGrey
                                                : Theme.of(context).hintColor,
                                          ),
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
                                    width: size.width * 0.38,
                                    padding: EdgeInsets.all(size.width * 0.025),
                                    decoration: BoxDecoration(
                                      color: (context
                                                  .read<AccBloc>()
                                                  .choosenLeaderboardData ==
                                              1)
                                          ? AppColors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: MyText(
                                      text: AppLocalizations.of(context)!.trips,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontSize: 16,
                                            color: (context
                                                        .read<AccBloc>()
                                                        .choosenLeaderboardData ==
                                                    1)
                                                ? AppColors.hintColorGrey
                                                : Theme.of(context).hintColor,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: size.width * 0.025,
                        ),
                        SizedBox(
                          height: size.height * 0.65,
                          width: size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  margin: EdgeInsets.only(
                                      left: size.width * 0.05,
                                      right: size.width * 0.05),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.borderColor)),
                                  child: Column(
                                    children: [
                                      if (context
                                                  .read<AccBloc>()
                                                  .leaderBoardData !=
                                              null &&
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
                                            if (context
                                                        .read<AccBloc>()
                                                        .leaderBoardData !=
                                                    null &&
                                                context
                                                    .read<AccBloc>()
                                                    .leaderBoardData!
                                                    .isNotEmpty)
                                              Positioned(
                                                  left: size.width * 0.3,
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        AppImages.crown,
                                                        width:
                                                            size.width * 0.075,
                                                        height:
                                                            size.width * 0.075,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                bottom: size
                                                                        .width *
                                                                    (0.07 / 2)),
                                                            width: size.width *
                                                                0.2,
                                                            height: size.width *
                                                                0.2,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: AppColors
                                                                  .white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.18,
                                                              height:
                                                                  size.width *
                                                                      0.18,
                                                              decoration: BoxDecoration(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .scaffoldBackgroundColor,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .leaderBoardData![
                                                                              0]
                                                                          .profile),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                            ),
                                                          ),
                                                          Positioned(
                                                              bottom: 0,
                                                              left: size.width *
                                                                  (0.14 / 2),
                                                              child: Container(
                                                                width:
                                                                    size.width *
                                                                        0.08,
                                                                height:
                                                                    size.width *
                                                                        0.08,
                                                                decoration: const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: AppColors
                                                                        .white),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    Container(
                                                                  width:
                                                                      size.width *
                                                                          0.07,
                                                                  height:
                                                                      size.width *
                                                                          0.07,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: MyText(
                                                                    text: '1',
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headlineLarge!
                                                                        .copyWith(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                AppColors.white,
                                                                            fontWeight: FontWeight.w600),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ))
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.025,
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.2,
                                                        child: Column(
                                                          children: [
                                                            MyText(
                                                              text: context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .leaderBoardData![
                                                                      0]
                                                                  .driverName,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            MyText(
                                                              text: context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .choosenLeaderboardData ==
                                                                      0
                                                                  ? "${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![0].commission}"
                                                                  : "${context.read<AccBloc>().leaderBoardData![0].trips} ${AppLocalizations.of(context)!.trips}",
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                            Positioned(
                                                // top: size.width*0.1,
                                                left: 0,
                                                bottom: 0,
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      AppImages.crown,
                                                      width: size.width * 0.075,
                                                      height:
                                                          size.width * 0.075,
                                                      fit: BoxFit.contain,
                                                      color: AppColors
                                                          .borderColors,
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: size
                                                                      .width *
                                                                  (0.07 / 2)),
                                                          width:
                                                              size.width * 0.2,
                                                          height:
                                                              size.width * 0.2,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .leaderBoardData !=
                                                                      null &&
                                                                  context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .leaderBoardData!
                                                                          .length >=
                                                                      2)
                                                              ? Container(
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  height:
                                                                      size.width *
                                                                          0.18,
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .scaffoldBackgroundColor,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(context
                                                                              .read<AccBloc>()
                                                                              .leaderBoardData![1]
                                                                              .profile),
                                                                          fit: BoxFit.cover)),
                                                                )
                                                              : Container(
                                                                  width:
                                                                      size.width *
                                                                          0.15,
                                                                  height:
                                                                      size.width *
                                                                          0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .question_mark_outlined,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .disabledColor,
                                                                  )),
                                                        ),
                                                        Positioned(
                                                            bottom: 0,
                                                            left: size.width *
                                                                (0.14 / 2),
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.08,
                                                              height:
                                                                  size.width *
                                                                      0.08,
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: AppColors
                                                                      .white),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                width:
                                                                    size.width *
                                                                        0.07,
                                                                height:
                                                                    size.width *
                                                                        0.07,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: '2',
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headlineLarge!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              16,
                                                                          color: AppColors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.2,
                                                      child: Column(
                                                        children: [
                                                          MyText(
                                                            text: (context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData !=
                                                                        null &&
                                                                    context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData!
                                                                            .length >=
                                                                        2)
                                                                ? context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .leaderBoardData![
                                                                        1]
                                                                    .driverName
                                                                : '',
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          MyText(
                                                            text: (context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData !=
                                                                        null &&
                                                                    context
                                                                            .read<
                                                                                AccBloc>()
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
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 12,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            Positioned(
                                                bottom: -1,
                                                right: 0,
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      AppImages.crown,
                                                      width: size.width * 0.075,
                                                      height:
                                                          size.width * 0.075,
                                                      fit: BoxFit.contain,
                                                      color: AppColors
                                                          .borderColors,
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: size
                                                                      .width *
                                                                  (0.07 / 2)),
                                                          width:
                                                              size.width * 0.2,
                                                          height:
                                                              size.width * 0.2,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: (context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .leaderBoardData !=
                                                                      null &&
                                                                  context
                                                                          .read<
                                                                              AccBloc>()
                                                                          .leaderBoardData!
                                                                          .length >=
                                                                      3)
                                                              ? Container(
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  height:
                                                                      size.width *
                                                                          0.18,
                                                                  decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .scaffoldBackgroundColor,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(context
                                                                              .read<AccBloc>()
                                                                              .leaderBoardData![2]
                                                                              .profile),
                                                                          fit: BoxFit.cover)),
                                                                )
                                                              : Container(
                                                                  width:
                                                                      size.width *
                                                                          0.15,
                                                                  height:
                                                                      size.width *
                                                                          0.15,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    shape: BoxShape
                                                                        .circle,
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
                                                            left: size.width *
                                                                (0.14 / 2),
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.08,
                                                              height:
                                                                  size.width *
                                                                      0.08,
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: AppColors
                                                                      .white),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Container(
                                                                width:
                                                                    size.width *
                                                                        0.07,
                                                                height:
                                                                    size.width *
                                                                        0.07,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: '3',
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .headlineLarge!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              16,
                                                                          color: AppColors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ))
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * 0.025,
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.2,
                                                      child: Column(
                                                        children: [
                                                          MyText(
                                                            text: (context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData !=
                                                                        null &&
                                                                    context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData!
                                                                            .length >=
                                                                        3)
                                                                ? context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .leaderBoardData![
                                                                        2]
                                                                    .driverName
                                                                : '',
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          MyText(
                                                            text: (context
                                                                            .read<
                                                                                AccBloc>()
                                                                            .leaderBoardData !=
                                                                        null &&
                                                                    context
                                                                            .read<
                                                                                AccBloc>()
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
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 12,
                                                                ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                (context.read<AccBloc>().leaderBoardData !=
                                            null &&
                                        context
                                            .read<AccBloc>()
                                            .leaderBoardData!
                                            .isNotEmpty &&
                                        context
                                                .read<AccBloc>()
                                                .leaderBoardData!
                                                .length >
                                            3)
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left: size.width * 0.05,
                                            right: size.width * 0.05),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                                  padding: EdgeInsets.all(
                                                      size.width * 0.05),
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                    bottom: (i ==
                                                            context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .leaderBoardData!
                                                                    .length -
                                                                1)
                                                        ? BorderSide.none
                                                        : const BorderSide(
                                                            width: 1,
                                                            color: AppColors
                                                                .borderColor),
                                                  )),
                                                  child: Row(
                                                    children: [
                                                      MyText(
                                                        text:
                                                            (i + 1).toString(),
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 20,
                                                                ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.05,
                                                      ),
                                                      Container(
                                                        width: size.width * 0.1,
                                                        height:
                                                            size.width * 0.1,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image: DecorationImage(
                                                                image: NetworkImage(context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .leaderBoardData![
                                                                        i]
                                                                    .profile),
                                                                fit: BoxFit
                                                                    .cover)),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.025,
                                                      ),
                                                      Expanded(
                                                          child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyText(
                                                            text: context
                                                                .read<AccBloc>()
                                                                .leaderBoardData![
                                                                    i]
                                                                .driverName,
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                  fontSize: 16,
                                                                  // color: AppColors.white,
                                                                ),
                                                          ),
                                                        ],
                                                      )),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          MyText(
                                                            text: (context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .choosenLeaderboardData ==
                                                                    0)
                                                                ? '${userData!.currencySymbol} ${context.read<AccBloc>().leaderBoardData![i].commission}'
                                                                : '${context.read<AccBloc>().leaderBoardData![i].trips} ${AppLocalizations.of(context)!.trips}',
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                          ),
                                                          MyText(
                                                            text:
                                                                '${context.read<AccBloc>().leaderBoardData![i].totalRides} ${AppLocalizations.of(context)!.rides}',
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor),
                                                          ),
                                                        ],
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
                                    : ((context
                                                    .read<AccBloc>()
                                                    .leaderBoardData !=
                                                null &&
                                            context
                                                .read<AccBloc>()
                                                .leaderBoardData!
                                                .isEmpty))
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .noDataLeaderBoard,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                              ),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .addRankingText,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : (context
                                                        .read<AccBloc>()
                                                        .leaderBoardData !=
                                                    null &&
                                                context
                                                    .read<AccBloc>()
                                                    .leaderBoardData!
                                                    .isNotEmpty &&
                                                context
                                                        .read<AccBloc>()
                                                        .leaderBoardData!
                                                        .length >=
                                                    4)
                                            ? Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.025),
                                                margin: EdgeInsets.only(
                                                    left: size.width * 0.05,
                                                    right: size.width * 0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: AppColors
                                                            .borderColor)),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: size.width * 0.15,
                                                      child: Row(
                                                        children: [
                                                          MyText(
                                                            text: "4",
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headlineLarge!
                                                                .copyWith(
                                                                    fontSize:
                                                                        24,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.025,
                                                          ),
                                                          Container(
                                                            width: size.width *
                                                                0.1,
                                                            height: size.width *
                                                                0.1,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white),
                                                            child: Container(
                                                              width:
                                                                  size.width *
                                                                      0.1,
                                                              height:
                                                                  size.width *
                                                                      0.1,
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: DecorationImage(
                                                                      image: AssetImage(
                                                                          AppImages
                                                                              .defaultProfile),
                                                                      fit: BoxFit
                                                                          .cover)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.025,
                                                          ),
                                                          Expanded(
                                                              child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              MyText(
                                                                text: '- -',
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headlineLarge!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.010,
                                                              ),
                                                              MyText(
                                                                text: "?",
                                                                textStyle: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .headlineLarge!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            16,
                                                                        color: AppColors
                                                                            .greyHeader,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                              )
                                                            ],
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                            text:
                                AppLocalizations.of(context)!.noDataLeaderBoard,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.addRankingText,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                          ),
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
