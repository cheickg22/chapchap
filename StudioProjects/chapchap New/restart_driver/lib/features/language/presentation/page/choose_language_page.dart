import 'package:flutter/material.dart';
import 'package:restart_tagxi/app/localization.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_button.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../loading/presentation/loader.dart';
import '../../application/language_bloc.dart';
import '../widget/language_list_widget.dart';

class ChooseLanguagePage extends StatelessWidget {
  static const String routeName = '/chooseLanguage';
  final ChangeLanguageArguments? args;

  const ChooseLanguagePage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return builderList(size);
  }

  Widget builderList(Size size) {
    return BlocProvider(
      create: (context) => LanguageBloc()
        ..add(LanguageInitialEvent())
        ..add(LanguageGetEvent(from: args != null ? args!.from : 0)),
      child: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageInitialState) {
            CustomLoader.loader(context);
          } else if (state is LanguageLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LanguageSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LanguageFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is LanguageAlreadySelectedState) {
            context.read<LocalizationBloc>().add(LocalizationInitialEvent(
                isDark: Theme.of(context).brightness == Brightness.dark,
                locale: Locale(context.read<LanguageBloc>().choosedLanguage)));
            if (args == null || args!.from == 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoaderPage.routeName, (route) => false);
            }
          } else if (state is LanguageUpdateState) {
            if (args == null || args!.from == 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoaderPage.routeName, (route) => false);
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return PopScope(
              canPop: (args != null && args!.from == 1) ? true : false,
              child: Scaffold(
                appBar: CustomAppBar(
                  title: (args != null && args!.from == 1)
                      ? AppLocalizations.of(context)!.changeLanguage
                      : AppLocalizations.of(context)!.chooseLanguage,
                  automaticallyImplyLeading:
                      (args != null && args!.from == 1) ? true : false,
                  textColor: Theme.of(context).primaryColorDark,
                  titleFontSize: 18,
                  onBackTap: () {
                    Navigator.of(context).pop();
                    context.read<LocalizationBloc>().add(
                        LocalizationInitialEvent(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            locale: Locale(
                                context.read<LanguageBloc>().choosedLanguage)));
                  },
                ),
                body:
                    (context.read<LanguageBloc>().choosedLanguage.isNotEmpty &&
                            (args == null))
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.loader,
                                  width: size.width * 0.51,
                                  height: size.height * 0.51,
                                )
                              ],
                            ),
                          )
                        // ignore: avoid_unnecessary_containers
                        : Container(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(height: size.width * 0.03),
                                  LanguageListWidget(
                                      languageList: AppConstants.languageList,
                                      cont: context),
                                  SizedBox(height: size.width * 0.05),
                                  Center(
                                    child: CustomButton(
                                      buttonName:
                                          // AppLocalizations.of(context)!.select,
                                          AppLocalizations.of(context)!.confirm,
                                      textSize: 18,
                                      // height: size.width * 0.15,
                                      width: size.width,
                                      onTap: () async {
                                        final selectedIndex = context
                                            .read<LanguageBloc>()
                                            .selectedIndex;
                                        context.read<LanguageBloc>().add(
                                            LanguageSelectUpdateEvent(
                                                selectedLanguage: AppConstants
                                                    .languageList
                                                    .elementAt(selectedIndex)
                                                    .lang));
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
