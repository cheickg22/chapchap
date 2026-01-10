import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_background.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../landing/presentation/page/landing_page.dart';

class SelectUserPage extends StatelessWidget {
  static const String routeName = '/selectUserpage';

  const SelectUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UpdateLoginAsState) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              LandingPage.routeName,
              (route) => false,
              arguments: LandingPageArguments(
                type: context.read<AuthBloc>().choosenLoginAs,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SafeArea(
              top: true,
              bottom: true,
              child: Scaffold(
                body: CustomBackground(
                  child: Column(
                    children: [
                      Image.asset(
                        AppImages.loginAs,
                        width: size.width,
                        height: size.width,
                        fit: BoxFit.fitWidth,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: size.width * 0.9,
                        child: MyText(
                          text:
                              '${AppLocalizations.of(context)!.selectAccountType} :',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: AppColors.blackText,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppColors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context.read<AuthBloc>().add(
                                        ChooseLoginAsEvent(loginAs: 'driver'));
                                  },
                                  child: Ink(
                                    padding: EdgeInsets.all(size.width * 0.05),
                                    width: size.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.black.withAlpha(
                                                (0.5 * 255).toInt())),
                                        color: (context
                                                    .read<AuthBloc>()
                                                    .choosenLoginAs ==
                                                'driver')
                                            ? AppColors.black
                                                .withAlpha((0.1 * 255).toInt())
                                            : Colors.transparent),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .driver,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          AppColors.blackText,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.9,
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .driverSubHeading,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color:
                                                            AppColors.blackText,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        )),
                                        const SizedBox(width: 20),
                                        Container(
                                          height: size.width * 0.06,
                                          width: size.width * 0.06,
                                          decoration: BoxDecoration(
                                              color: AppColors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: const Offset(0, 1),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                )
                                              ]),
                                          child: (context
                                                      .read<AuthBloc>()
                                                      .choosenLoginAs ==
                                                  'driver')
                                              ? Icon(
                                                  Icons.done,
                                                  color: AppColors.primary,
                                                  size: size.width * 0.04,
                                                )
                                              : Container(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Material(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: AppColors.black
                                      .withAlpha((0.2 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context.read<AuthBloc>().add(
                                        ChooseLoginAsEvent(loginAs: 'owner'));
                                  },
                                  child: Ink(
                                    padding: EdgeInsets.all(size.width * 0.05),
                                    width: size.width * 0.9,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.black.withAlpha(
                                                (0.5 * 255).toInt())),
                                        color: (context
                                                    .read<AuthBloc>()
                                                    .choosenLoginAs ==
                                                'owner')
                                            ? AppColors.black
                                                .withAlpha((0.1 * 255).toInt())
                                            : Colors.transparent),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .owner,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color:
                                                          AppColors.blackText,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: size.width * 0.9,
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .ownerSubHeading,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        color:
                                                            AppColors.blackText,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        )),
                                        const SizedBox(width: 20),
                                        Container(
                                          height: size.width * 0.06,
                                          width: size.width * 0.06,
                                          decoration: BoxDecoration(
                                              color: AppColors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: const Offset(0, 1),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  color: Theme.of(context)
                                                      .shadowColor,
                                                )
                                              ]),
                                          child: (context
                                                      .read<AuthBloc>()
                                                      .choosenLoginAs ==
                                                  'owner')
                                              ? Icon(
                                                  Icons.done,
                                                  color: AppColors.primary,
                                                  size: size.width * 0.04,
                                                )
                                              : Container(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                          buttonName:
                              "${AppLocalizations.of(context)!.continueText} ${(context.read<AuthBloc>().choosenLoginAs.isNotEmpty) ? context.read<AuthBloc>().choosenLoginAs == 'driver' ? AppLocalizations.of(context)!.driver : AppLocalizations.of(context)!.owner : ''}",
                          onTap: () {
                            if (context
                                .read<AuthBloc>()
                                .choosenLoginAs
                                .isNotEmpty) {
                              context.read<AuthBloc>().add(UpdateLoginAsEvent(
                                  loginAs:
                                      context.read<AuthBloc>().choosenLoginAs));
                            } else {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .pleaseSelectUserTypeText);
                            }
                          }),
                      const SizedBox(
                        height: 20,
                      ),
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
