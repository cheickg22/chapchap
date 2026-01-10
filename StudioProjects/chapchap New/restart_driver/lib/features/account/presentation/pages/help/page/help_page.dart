import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../widgets/menu_options.dart';
import '../../admin_chat/page/admin_chat.dart';
import '../../support_ticket/page/support_ticket.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = '/helpPage';
  const HelpPage({super.key});

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
              title: AppLocalizations.of(context)!.help,
              automaticallyImplyLeading: true,
              titleFontSize: 18,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03),
                  if (userData!.enableSupportTicketFeature == '1')
                    MenuOptions(
                        label: AppLocalizations.of(context)!.supportTicket,
                        icon: Icons.support,
                        onTap: () {
                          Navigator.pushNamed(
                              context, SupportTicketPage.routeName,
                              arguments: SupportTicketPageArguments(
                                  isFromRequest: false, requestId: ''));
                        }),
                  MenuOptions(
                    icon: Icons.chat,
                    label: AppLocalizations.of(context)!.chatWithUs,
                    onTap: () {
                      Navigator.pushNamed(context, AdminChat.routeName);
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
