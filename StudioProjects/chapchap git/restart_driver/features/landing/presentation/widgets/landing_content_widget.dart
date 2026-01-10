import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/custom_text.dart';
import '../../application/onboarding_bloc.dart';

class LandingContentWidget extends StatelessWidget {
  final BuildContext cont;
  const LandingContentWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<OnBoardingBloc>(),
      child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(
                height: size.height * 0.18,
                width: size.width,
                child: PageView.builder(
                  controller:
                      context.read<OnBoardingBloc>().contentPageController,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      context.read<OnBoardingBloc>().onBoardingData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyText(
                          text: context
                              .read<OnBoardingBloc>()
                              .onBoardingData[index]
                              .title
                              .toUpperCase(),
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: size.height * 0.02),
                        MyText(
                          text: context
                              .read<OnBoardingBloc>()
                              .onBoardingData[index]
                              .description,
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                        ),
                      ],
                    );
                  },
                  onPageChanged: (value) {
                    context
                        .read<OnBoardingBloc>()
                        .imagePageController
                        .jumpToPage(value);
                    context
                        .read<OnBoardingBloc>()
                        .add(OnBoardingDataChangeEvent(currentIndex: value));
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  context.read<OnBoardingBloc>().onBoardingData.length,
                  (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 5),
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context
                                      .read<OnBoardingBloc>()
                                      .onBoardChangeIndex ==
                                  index
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).splashColor),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
