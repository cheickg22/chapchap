import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../application/acc_bloc.dart';
import '../../../../common/app_images.dart';
import '../../../../core/utils/custom_text.dart';

class TopBarDesign extends StatelessWidget {
  final String title;
  final bool isHistoryPage;
  final bool? isOngoingPage;
  final Widget? child;
  final Function()? onTap;

  const TopBarDesign(
      {super.key,
      this.child,
      required this.isHistoryPage,
      required this.title,
      this.onTap,
      this.isOngoingPage});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            // color: AppColors.commonColor,

            color: Theme.of(context).primaryColor,
            image: const DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage(AppImages.map),
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                child: SizedBox(
                  width: size.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                (onTap != null)
                                    ? Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Container(
                                          height: size.height * 0.08,
                                          width: size.width * 0.08,
                                          decoration: const BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                offset: Offset(5.0, 5.0),
                                                blurRadius: 10.0,
                                                spreadRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                              onTap: () {
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  if (onTap != null) {
                                                    onTap!();
                                                  }
                                                });
                                              },
                                              highlightColor: Theme.of(context)
                                                  .disabledColor
                                                  .withAlpha(
                                                      (0.1 * 255).toInt()),
                                              splashColor: Theme.of(context)
                                                  .disabledColor
                                                  .withAlpha(
                                                      (0.2 * 255).toInt()),
                                              hoverColor: Theme.of(context)
                                                  .disabledColor
                                                  .withAlpha(
                                                      (0.05 * 255).toInt()),
                                              child: const Icon(
                                                CupertinoIcons.back,
                                                size: 20,
                                                color: AppColors.black,
                                              )),
                                        ),
                                      )
                                    : SizedBox(
                                        width: size.width * 0.05,
                                        height: size.width * 0.15,
                                      ),
                                MyText(
                                  text: title,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                          color: AppColors.white, fontSize: 20),
                                ),
                              ],
                            ),
                            if (isHistoryPage)
                              BlocBuilder<AccBloc, AccState>(
                                builder: (context, state) {
                                  final selectedIndex = context
                                      .read<AccBloc>()
                                      .selectedHistoryType;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildTab(
                                          context,
                                          AppLocalizations.of(context)!
                                              .completed,
                                          0,
                                          selectedIndex),
                                      _buildTab(
                                          context,
                                          AppLocalizations.of(context)!
                                              .upcoming,
                                          1,
                                          selectedIndex),
                                      _buildTab(
                                          context,
                                          AppLocalizations.of(context)!
                                              .cancelled,
                                          2,
                                          selectedIndex),
                                    ],
                                  );
                                },
                              )
                            else
                              const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isHistoryPage) SizedBox(height: size.width * 0.02),
              (isOngoingPage == true)
                  ? Expanded(
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                  (context.read<AccBloc>().textDirection ==
                                          'ltr')
                                      ? 50
                                      : 0),
                              topRight: Radius.circular(
                                  (context.read<AccBloc>().textDirection ==
                                          'ltr')
                                      ? 0
                                      : 50)),
                        ),
                        child: child,
                      ),
                    )
                  : Expanded(
                      child: BlocBuilder<AccBloc, AccState>(
                        builder: (context, state) {
                          return Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                      (context.read<AccBloc>().textDirection ==
                                              'ltr')
                                          ? 50
                                          : 0),
                                  topRight: Radius.circular(
                                      (context.read<AccBloc>().textDirection ==
                                              'ltr')
                                          ? 0
                                          : 50)),
                            ),
                            child: child,
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(
      BuildContext context, String title, int index, int selectedIndex) {
    return InkWell(
      onTap: () {
        if (index != selectedIndex && !context.read<AccBloc>().isLoading) {
          context.read<AccBloc>().history.clear();
          context.read<AccBloc>().add(UpdateEvent());
          context
              .read<AccBloc>()
              .add(HistoryTypeChangeEvent(historyTypeIndex: index));
        }
      },
      child: Stack(
        children: [
          MyText(
            text: title,
            textStyle: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: AppColors.white),
          ),
          if (index == selectedIndex)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                width: 15,
                height: 2,
                color: AppColors.white.withAlpha((0.8 * 255).toInt()),
              ),
            ),
        ],
      ),
    );
  }
}
