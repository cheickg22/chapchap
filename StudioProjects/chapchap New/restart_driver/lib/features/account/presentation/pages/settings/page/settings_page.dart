import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings/page/faq_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings/page/map_settings.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../widgets/menu_options.dart';
import 'terms_privacy_policy_view_page.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settingsPage';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is LogoutSuccess) {
            bool userTypeStatus = await AppSharedPreference.getUserTypeStatus();
            if (userTypeStatus) {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginPage.routeName,
                  (route) => false,
                );
              }
            } else {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginPage.routeName,
                  (route) => false,
                );
              }
            }

            await AppSharedPreference.logoutRemove();
          } else if (state is DeleteAccountSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, ChooseLanguagePage.routeName, (route) => false,
                arguments: ChangeLanguageArguments(from: 0));
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          } else if (state is DeleteAccountFailureState) {
            Navigator.of(context).pop(); // Dismiss the dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.settings,
              automaticallyImplyLeading: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03),
                  MenuOptions(
                    label: AppLocalizations.of(context)!.theme,
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    showTheme: true,
                    onTap: () {},
                  ),
                  if (userData!.enableMapAppearanceChange == '1')
                    MenuOptions(
                      label: AppLocalizations.of(context)!.mapAppearance,
                      // icon: Icons.map,
                      imagePath: AppImages.mapImage,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          MapSettingsPage.routeName,
                        );
                      },
                    ),
                  MenuOptions(
                    label: AppLocalizations.of(context)!.faq,
                    // icon: Icons.question_answer,
                    imagePath: AppImages.messageSquare,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FaqPage.routeName,
                      );
                    },
                  ),
                  MenuOptions(
                    label: AppLocalizations.of(context)!.privacy,
                    // icon: Icons.privacy_tip,
                    imagePath: AppImages.shield,
                    onTap: () {
                      Navigator.pushNamed(
                          context, TermsPrivacyPolicyViewPage.routeName,
                          arguments: TermsAndPrivacyPolicyArguments(
                              isPrivacyPolicy: true));
                    },
                  ),
                  MenuOptions(
                    label: AppLocalizations.of(context)!.logout,
                    // icon: Icons.logout,
                    imagePath: AppImages.logOut,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext _) {
                          return BlocProvider.value(
                            value: BlocProvider.of<AccBloc>(context),
                            child: CustomDoubleButtonDialoge(
                              title: AppLocalizations.of(context)!.comeBackSoon,
                              content: AppLocalizations.of(context)!.logoutSure,
                              noBtnName: AppLocalizations.of(context)!.no,
                              yesBtnName: AppLocalizations.of(context)!.yes,
                              yesBtnFunc: () {
                                context.read<AccBloc>().add(LogoutEvent());
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  MenuOptions(
                    label: AppLocalizations.of(context)!.deleteAccount,
                    imagePath: AppImages.trash,
                    textColor: const Color(0xFFDC3545),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext _) {
                          return BlocProvider.value(
                            value: BlocProvider.of<AccBloc>(context),
                            child: CustomSingleButtonDialoge(
                              title: userData!.isDeletedAt.isEmpty
                                  ? '${AppLocalizations.of(context)!.deleteAccount} ?'
                                  : AppLocalizations.of(context)!.deleteAccount,
                              content: userData!.isDeletedAt.isEmpty
                                  ? AppLocalizations.of(context)!.deleteText
                                  : userData!.isDeletedAt,
                              btnName: userData!.isDeletedAt.isEmpty
                                  ? AppLocalizations.of(context)!.deleteAccount
                                  : AppLocalizations.of(context)!.ok,
                              btnColor: AppColors.errorLight,
                              isLoader: context.read<AccBloc>().isLoading,
                              onTap: () {
                                if (userData!.isDeletedAt.isEmpty) {
                                  context
                                      .read<AccBloc>()
                                      .add(DeleteAccountEvent());
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
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
