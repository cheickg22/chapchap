import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_bloc.dart';

class UpdatePasswordPage extends StatelessWidget {
  static const String routeName = '/updatePasswordPage';
  final UpdatePasswordPageArguments arg;
  const UpdatePasswordPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is ForgotPasswordUpdateSuccessState) {
            // ignore: unused_local_variable
            final role = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.updatePassword,
                  automaticallyImplyLeading: true,
                  titleFontSize: 18,
                  textColor: Theme.of(context).primaryColorDark,
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: context.read<AuthBloc>().formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .enterNewPassword,
                                textAlign: TextAlign.center,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: 16),
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            MyText(
                              text: AppLocalizations.of(context)!.password,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                            ),
                            SizedBox(height: size.width * 0.02),
                            buildPasswordField(context, size),
                            SizedBox(height: size.width * 0.02),
                            SizedBox(height: size.width * 0.1),
                            buildButton(context),
                            SizedBox(height: size.width * 0.3),
                          ],
                        ),
                      ),
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

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.change,
        borderRadius: 10,
        textSize: 16,
        width: MediaQuery.sizeOf(context).width,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () async {
          // ignore: unused_local_variable
          final role = await AppSharedPreference.getUserType();
          if (!context.mounted) return;
          context.read<AuthBloc>().add(
                UpdatePasswordEvent(
                    isLoginByEmail: arg.isLoginByEmail,
                    password: context.read<AuthBloc>().rPasswordController.text,
                    emailOrMobile: arg.emailOrMobile,
                    role: context.read<AuthBloc>().loginAs),
              );
        },
      ),
    );
  }

  Widget buildPasswordField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rPasswordController,
      contentPadding: EdgeInsets.all(size.width * 0.025),
      borderRadius: 10,
      filled: true,
      obscureText: !context.read<AuthBloc>().showPassword,
      hintText: AppLocalizations.of(context)!.enterYourPassword,
      suffixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(ShowPasswordIconEvent(
              showPassword: context.read<AuthBloc>().showPassword));
        },
        child: !context.read<AuthBloc>().showPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: Theme.of(context).hintColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility,
                  color: Theme.of(context).hintColor,
                ),
              ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterYourPassword;
        } else if (value.length < 8) {
          return AppLocalizations.of(context)!.minimumCharacRequired;
        } else {
          return null;
        }
      },
    );
  }
}
