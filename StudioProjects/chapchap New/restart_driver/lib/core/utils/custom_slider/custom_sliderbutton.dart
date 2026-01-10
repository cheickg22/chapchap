import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/common.dart';
import '../custom_loader.dart';
import 'custom_slider_bloc.dart';

class CustomSliderButton extends StatelessWidget {
  final String buttonName;
  final double? height;
  final double? width;
  final Color? buttonColor;
  final Color? textColor;
  final double? textSize;
  final Future<bool?> Function() onSlideSuccess;
  final bool? isLoader;
  final Widget? sliderIcon;
  final VoidCallback? onReset;

  const CustomSliderButton({
    super.key,
    required this.buttonName,
    this.height,
    this.width,
    this.buttonColor,
    this.textColor,
    this.textSize,
    required this.onSlideSuccess,
    this.isLoader = false,
    this.sliderIcon,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final buttonHeight = height ?? size.width * 0.13;
    final buttonWidth = width ?? size.width * 0.75;

    return BlocProvider(
      create: (_) => SliderButtonBloc(),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onHorizontalDragStart: isLoader == true
                ? null
                : (details) {
                    context
                        .read<SliderButtonBloc>()
                        .add(SliderDragStartEvent(0.0));
                  },
            onHorizontalDragUpdate: isLoader == true
                ? null
                : (details) {
                    context.read<SliderButtonBloc>().add(SliderDragEvent(
                          (details.localPosition.dx)
                              .clamp(0.0, buttonWidth - buttonHeight),
                        ));
                  },
            onHorizontalDragEnd: isLoader == true
                ? null
                : (details) async {
                    final currentSliderPosition =
                        context.read<SliderButtonBloc>().state.sliderPosition;

                    context.read<SliderButtonBloc>().add(SliderDragEndEvent(
                          currentSliderPosition,
                          // Move to the end
                          onSlideSuccess,
                          buttonWidth - buttonHeight,
                        ));
                  },
            child: SizedBox(
              height: buttonHeight,
              width: buttonWidth,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                        color: buttonColor ?? Theme.of(context).primaryColor),
                  ),
                  Center(
                    child: BlocBuilder<SliderButtonBloc, SliderButtonState>(
                      builder: (context, state) {
                        return Text(
                          (state.sliderPosition == buttonWidth - buttonHeight ||
                                  isLoader == true)
                              ? ''
                              : buttonName,
                          style: AppTextStyle.boldStyle().copyWith(
                            color: textColor ?? AppColors.white,
                            fontSize: textSize ?? 18,
                          ),
                        );
                      },
                    ),
                  ),
                  BlocBuilder<SliderButtonBloc, SliderButtonState>(
                    builder: (context, state) {
                      return Positioned(
                        left: isLoader == true
                            ? buttonWidth - buttonHeight
                            : (state.sliderPosition <=
                                    buttonWidth - buttonHeight)
                                ? state.sliderPosition
                                : buttonWidth - buttonHeight,
                        child: Container(
                          height: buttonHeight,
                          width: buttonHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white),
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.grey.withAlpha((0.5 * 255).toInt()),
                                AppColors.grey,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: (isLoader == true)
                                ? SizedBox(
                                    height: size.width * 0.05,
                                    width: size.width * 0.05,
                                    child: const Loader(color: AppColors.white),
                                  )
                                : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    child: sliderIcon ??
                                        Icon(
                                          Icons
                                              .keyboard_double_arrow_right_rounded,
                                          color: AppColors.white,
                                          size: size.width * 0.07,
                                        ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
