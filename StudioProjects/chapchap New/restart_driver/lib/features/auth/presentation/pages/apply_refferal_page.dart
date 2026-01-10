import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_bloc.dart';

class ApplyRefferalPage extends StatelessWidget {
  static const String routeName = '/applyRefferalPage';
  const ApplyRefferalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is ReferralSuccessState) {
            Navigator.pushNamedAndRemoveUntil(
                context,
                DriverProfilePage.routeName,
                arguments: VehicleUpdateArguments(
                  from: '',
                ),
                (route) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.applyReferal,
                titleFontSize: 18,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.width * 0.05),
                      MyText(
                          text: AppLocalizations.of(context)!.referral,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14)),
                      SizedBox(height: size.width * 0.025),
                      CustomTextField(
                        controller:
                            context.read<AuthBloc>().rReferralCodeController,
                        contentPadding: EdgeInsets.all(size.width * 0.025),
                        filled: true,
                        hintText:
                            AppLocalizations.of(context)!.enterReferralCode,
                        hintTextStyle: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.borderColors, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: size.width * 0.1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomButton(
                            buttonName: AppLocalizations.of(context)!.skip,
                            width: size.width * 0.4,
                            textSize: 16,
                            onTap: () {
                              context
                                  .read<AuthBloc>()
                                  .add(ReferralEvent(referralCode: 'Skip'));
                            },
                          ),
                          CustomButton(
                            buttonName: AppLocalizations.of(context)!.apply,
                            isLoader: context.read<AuthBloc>().isLoading,
                            width: size.width * 0.4,
                            textSize: 16,
                            onTap: () {
                              context.read<AuthBloc>().add(ReferralEvent(
                                  referralCode: context
                                      .read<AuthBloc>()
                                      .rReferralCodeController
                                      .text));
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: size.width * 0.05),
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
