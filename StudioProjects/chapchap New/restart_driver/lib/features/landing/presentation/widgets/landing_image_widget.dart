import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/onboarding_bloc.dart';

class LandingImageWidget extends StatelessWidget {
  final BuildContext cont;
  const LandingImageWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<OnBoardingBloc>(),
      child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
        builder: (context, state) {
          return Container(
            height: size.height * 0.5,
            width: size.width * 0.83,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10)),
            child: PageView.builder(
              controller: context.read<OnBoardingBloc>().imagePageController,
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: context.read<OnBoardingBloc>().onBoardingData.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: context
                          .read<OnBoardingBloc>()
                          .onBoardingData
                          .isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: context
                              .read<OnBoardingBloc>()
                              .onBoardingData[context
                                  .read<OnBoardingBloc>()
                                  .onBoardChangeIndex]
                              .onboardingImage,
                          width: 30,
                          height: 20,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Text(
                              "",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : null,
                );
              },
              onPageChanged: (value) {
                context
                    .read<OnBoardingBloc>()
                    .contentPageController
                    .jumpToPage(value);
                context
                    .read<OnBoardingBloc>()
                    .add(OnBoardingDataChangeEvent(currentIndex: value));
              },
            ),
          );
        },
      ),
    );
  }
}
