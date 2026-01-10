// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';

import '../../../../core/utils/custom_loader.dart';
import '../../application/onboarding_bloc.dart';
import '../widgets/landing_content_widget.dart';
import '../widgets/landing_image_widget.dart';
import '../widgets/skip_button_widget.dart';

class LandingPage extends StatefulWidget {
  static const String routeName = '/landingPage';
  final LandingPageArguments args;
  const LandingPage({super.key, required this.args});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return builderList(size);
  }

  Widget builderList(Size size) {
    return BlocProvider(
      create: (context) =>
          OnBoardingBloc()..add(GetOnBoardingDataEvent(type: widget.args.type)),
      child: BlocListener<OnBoardingBloc, OnBoardingState>(
        listener: (context, state) {
          if (state is OnBoardingInitialState) {
            CustomLoader.loader(context);
          } else if (state is OnBoardingLoadingState) {
            CustomLoader.loader(context);
          } else if (state is OnBoardingSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is OnBoardingFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is SkipState) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
          builder: (context, state) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) => false,
              child: Scaffold(
                body: (context.read<OnBoardingBloc>().onBoardingData.isNotEmpty)
                    ? Stack(
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.07,
                                  vertical: size.height * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LandingImageWidget(cont: context),
                                  SizedBox(height: size.height * 0.02),
                                  LandingContentWidget(cont: context),
                                  SizedBox(height: size.height * 0.02),
                                  LandingSkipButtonWidget(cont: context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            );
          },
        ),
      ),
    );
  }
}
