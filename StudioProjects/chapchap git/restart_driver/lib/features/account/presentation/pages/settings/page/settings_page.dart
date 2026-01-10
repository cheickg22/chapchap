import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/pages/settings/page/faq_page.dart';
import 'package:restart_user/features/account/presentation/pages/settings/page/map_settings.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/features/language/presentation/page/choose_language_page.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/user_choose_page.dart';
import '../../../widgets/page_options.dart';
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
                  SelectUserPage.routeName,
                  (route) => false,
                );
              }
            } else {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AuthPage.routeName, (route) => false,
                    arguments: AuthPageArguments(type: 'driver'));
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
                  PageOptions(
                    label: 'Theme',
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    showTheme: true,
                    onTap: () {},
                  ),
                  if (userData!.enableMapAppearanceChange == '1')
                    PageOptions(
                      icon: Icons.map,
                      label: AppLocalizations.of(context)!.mapAppearance,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          MapSettingsPage.routeName,
                        );
                      },
                    ),
                  PageOptions(
                    icon: Icons.question_answer,
                    label: AppLocalizations.of(context)!.faq,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FaqPage.routeName,
                      );
                    },
                  ),
                  PageOptions(
                    icon: Icons.privacy_tip,
                    label: AppLocalizations.of(context)!.privacy,
                    onTap: () async {
                      Navigator.pushNamed(context, TermsPrivacyPolicyViewPage.routeName,
                      arguments: TermsAndPrivacyPolicyArguments(isPrivacyPolicy: true));
                    },
                  ),
                  PageOptions(
                    icon: Icons.logout,
                    label: AppLocalizations.of(context)!.logout,
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
                  PageOptions(
                    icon: Icons.delete,
                    label: AppLocalizations.of(context)!.deleteAccount,
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
