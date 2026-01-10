import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/levelup/widget/level_grid_shimmer.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';

class DriverLevelsPage extends StatelessWidget {
  static const String routeName = '/driverLevelsPage';

  const DriverLevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(DriverLevelnitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
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
          if (state is DriverLevelPopupState) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertDialog(
                      content: SizedBox(
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: size.width * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyText(
                              text: state.driverLevelList.data.createdAt,
                              textStyle: const TextStyle(
                                  color: AppColors.greyHintColor),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                AppImages.successLevelPopup,
                                height: size.width * 0.3,
                                width: size.width * 0.3,
                              ),
                            ),
                            Positioned(
                              top: size.width * 0.05,
                              left: size.width * 0.2,
                              right: size.width * 0.2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Image(
                                  height: size.width * 0.20,
                                  width: size.width * 0.20,
                                  image: NetworkImage(
                                      state.driverLevelList.data.levelIcon),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.width * 0.03),
                        MyText(
                          text:
                              "${state.driverLevelList.data.levelName} ${state.driverLevelList.data.level}",
                          textStyle: const TextStyle(
                              fontSize: 16,
                              color: AppColors.yellowColor,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: size.width * 0.04,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!
                              .levelupSuccessText
                              .replaceAll(
                                  "1", "${state.driverLevelList.data.level}")
                              .replaceAll(
                                  "25", state.driverLevelList.data.totalRides)
                              .replaceAll("500",
                                  state.driverLevelList.data.totalEarnings),
                          textStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                        SizedBox(
                          height: size.width * 0.06,
                        ),
                        CustomButton(
                          borderRadius: 30,
                          buttonName: AppLocalizations.of(context)!.ok,
                          buttonColor: AppColors.primary,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  ));
                });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.levelupText,
                automaticallyImplyLeading: true,
              ),
              body: SizedBox(
                height: size.height,
                child: (context.read<AccBloc>().isLoading &&
                        context.read<AccBloc>().firstLoadLevel &&
                        !context.read<AccBloc>().loadMoreLevel)
                    ? const LevelsGridShimmer()
                    : context.read<AccBloc>().driverLevelsList.isNotEmpty
                        ? Column(
                            children: [
                              Expanded(
                                child: GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  controller: context
                                      .read<AccBloc>()
                                      .levelsScrollController,
                                  padding: const EdgeInsets.all(5),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: context
                                      .read<AccBloc>()
                                      .driverLevelsList
                                      .length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: context
                                                        .read<AccBloc>()
                                                        .driverLevelsList[index]
                                                        .levelCompleted ==
                                                    '1'
                                                ? () {
                                                    context.read<AccBloc>().add(
                                                        DriverLevelPopupEvent(
                                                            driverLevelList: context
                                                                .read<AccBloc>()
                                                                .driverLevelsList[
                                                                    index]
                                                                .levelDetails!));
                                                  }
                                                : null,
                                            child: SizedBox(
                                              height: size.width * 0.2,
                                              width: size.width * 0.2,
                                              child: Stack(
                                                children: [
                                                  Image(
                                                    image: AssetImage(context
                                                                .read<AccBloc>()
                                                                .driverLevelsList[
                                                                    index]
                                                                .levelCompleted ==
                                                            '1'
                                                        ? AppImages.levelSuccess
                                                        : AppImages
                                                            .levelLocked),
                                                  ),
                                                  context
                                                              .read<AccBloc>()
                                                              .driverLevelsList[
                                                                  index]
                                                              .levelCompleted ==
                                                          '1'
                                                      ? Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 4),
                                                            child: Image(
                                                                height:
                                                                    size.width *
                                                                        0.12,
                                                                image: NetworkImage(context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .driverLevelsList[
                                                                        index]
                                                                    .levelIcon)),
                                                          ),
                                                        )
                                                      : Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 4),
                                                            child: Image(
                                                                height:
                                                                    size.width *
                                                                        0.12,
                                                                image: const AssetImage(
                                                                    AppImages
                                                                        .lock)),
                                                          ),
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          MyText(
                                            text:
                                                "${context.read<AccBloc>().driverLevelsList[index].levelName} ${context.read<AccBloc>().driverLevelsList[index].level.toString()}",
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.yellowColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (context.read<AccBloc>().loadMoreLevel &&
                                  !context.read<AccBloc>().isLoading &&
                                  !context.read<AccBloc>().firstLoadLevel)
                                Center(
                                  child: SizedBox(
                                      height: size.width * 0.08,
                                      width: size.width * 0.08,
                                      child: const CircularProgressIndicator()),
                                ),
                            ],
                          )
                        : SizedBox(
                            height: size.width * 0.20,
                            width: size.width * 0.20,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Image(
                                    height: size.width * 0.20,
                                    width: size.width * 0.20,
                                    image:
                                        const AssetImage(AppImages.levelLocked),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * 0.054,
                                        top: size.height * 0.031),
                                    child: Image(
                                        height: size.width * 0.10,
                                        image:
                                            const AssetImage(AppImages.lock)),
                                  ),
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
