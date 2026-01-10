import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class BottomNavigationbarWidget extends StatelessWidget {
  final BuildContext cont;
  const BottomNavigationbarWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return SizedBox(
            height: size.width * 0.2,
            child: Container(
              margin: const EdgeInsets.only(top: 1),
              height: size.width * 0.2 - 1,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).shadowColor,
                        spreadRadius: 2,
                        blurRadius: 1)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.read<HomeBloc>().choosenMenu != 0) {
                        context.read<HomeBloc>().add(ChangeMenuEvent(menu: 0));
                        context.read<HomeBloc>().add(GetUserDetailsEvent());
                      }
                    },
                    child: SizedBox(
                      height: size.width * 0.2,
                      width: size.width * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.home,
                            height: size.width * 0.07,
                            color: (context.read<HomeBloc>().choosenMenu == 0)
                                ? AppColors.primary
                                : AppColors.hintColor,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.home,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      (context.read<HomeBloc>().choosenMenu ==
                                              0)
                                          ? AppColors.primary
                                          : AppColors.hintColor,
                                  fontSize: 12,
                                ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (userData != null &&
                      ((userData!.role == 'driver' &&
                              userData!.enableLeaderboardFeature) ||
                          userData!.role != 'driver'))
                    InkWell(
                        onTap: () {
                          if (context.read<HomeBloc>().choosenMenu != 1) {
                            context
                                .read<HomeBloc>()
                                .add(ChangeMenuEvent(menu: 1));
                            context.read<HomeBloc>().add(GetUserDetailsEvent());
                          }
                        },
                        child: SizedBox(
                          height: size.width * 0.2,
                          width: size.width * 0.25,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.award,
                                height: size.width * 0.07,
                                color:
                                    (context.read<HomeBloc>().choosenMenu == 1)
                                        ? AppColors.primary
                                        : AppColors.hintColor,
                              ),
                              MyText(
                                text: (userData!.role == 'driver')
                                    ? AppLocalizations.of(context)!.leaderboard
                                    : AppLocalizations.of(context)!.dashboard,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: (context
                                                    .read<HomeBloc>()
                                                    .choosenMenu ==
                                                1)
                                            ? AppColors.primary
                                            : AppColors.hintColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        )),
                  InkWell(
                      onTap: () {
                        if (context.read<HomeBloc>().choosenMenu != 2) {
                          context
                              .read<HomeBloc>()
                              .add(ChangeMenuEvent(menu: 2));
                          context.read<HomeBloc>().add(GetUserDetailsEvent());
                        }
                      },
                      child: SizedBox(
                        height: size.width * 0.2,
                        width: size.width * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.dollarSign,
                              height: size.width * 0.07,
                              color: (context.read<HomeBloc>().choosenMenu == 2)
                                  ? AppColors.primary
                                  : AppColors.hintColor,
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!.earnings,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: (context
                                                  .read<HomeBloc>()
                                                  .choosenMenu ==
                                              2)
                                          ? AppColors.primary
                                          : AppColors.hintColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        if (context.read<HomeBloc>().choosenMenu != 3) {
                          context
                              .read<HomeBloc>()
                              .add(ChangeMenuEvent(menu: 3));
                          context.read<HomeBloc>().add(GetUserDetailsEvent());
                        }
                      },
                      child: SizedBox(
                        height: size.width * 0.2,
                        width: size.width * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppImages.user,
                              height: size.width * 0.07,
                              color: (context.read<HomeBloc>().choosenMenu == 3)
                                  ? AppColors.primary
                                  : AppColors.hintColor,
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!.accounts,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        (context.read<HomeBloc>().choosenMenu ==
                                                3)
                                            ? AppColors.primary
                                            : AppColors.hintColor,
                                    fontSize: 12,
                                  ),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
