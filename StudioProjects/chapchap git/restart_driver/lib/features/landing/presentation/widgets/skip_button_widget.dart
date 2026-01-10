import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/onboarding_bloc.dart';

class LandingSkipButtonWidget extends StatelessWidget {
  final BuildContext cont;
  const LandingSkipButtonWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<OnBoardingBloc>(),
      child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
        builder: (context, state) {
          return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            buttonName: (context.read<OnBoardingBloc>().onBoardChangeIndex ==
                    context.read<OnBoardingBloc>().onBoardingData.length - 1)
                ? '${AppLocalizations.of(context)!.continueText} '
                : '${AppLocalizations.of(context)!.skip} ',
            onTap: () => context.read<OnBoardingBloc>().add(SkipEvent()),
            textSize: 12,
            width: size.width * 0.2,
            height: size.width * 0.08,
            borderRadius: 20,
            buttonColor: (context.read<OnBoardingBloc>().onBoardChangeIndex ==
                    context.read<OnBoardingBloc>().onBoardingData.length - 1)
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColorLight,
          ),
        ],
      );
    
          },
      ),
    );
  }
}
