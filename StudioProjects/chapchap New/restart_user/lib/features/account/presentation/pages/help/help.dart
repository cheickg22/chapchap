import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/admin_chat/page/admin_chat.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/support_ticket.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/menu_options.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../../../common/common.dart';
import '../../../../../../l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  static const String routeName = '/helpPage';
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is DeleteAccountSuccess) {
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
          final accBloc = context.read<AccBloc>();
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Help Center',
              automaticallyImplyLeading: true,
              titleFontSize: 18,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03),
                  // if (context
                  //                             .read<AccBloc>()
                  //                             .userData!
                  //                             .enableSupportTicketFeature ==
                  //                         '1')
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
                      final userData = accBloc.userData;
                      if (userData == null) {
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        AdminChat.routeName,
                        arguments: AdminChatPageArguments(userData: userData),
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
