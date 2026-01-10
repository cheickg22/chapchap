import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common/common.dart';
import 'custom_loader.dart';

class CustomButton extends StatelessWidget {
  final String buttonName;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? buttonColor;
  final Color? textColor;
  final double? textSize;
  final Function()? onTap;
  final bool? isLoader;
  final bool? isLoaderShowWithText;
  final bool? isSlider;
  final Border? border;

  const CustomButton({
    super.key,
    required this.buttonName,
    this.height,
    this.width,
    this.borderRadius,
    this.buttonColor,
    this.textColor,
    this.textSize,
    required this.onTap,
    this.isLoader = false,
    this.isLoaderShowWithText = false,
    this.isSlider = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      onPressed: (isLoader != null && !isLoader!) ? onTap : null,
      child: Container(
        height: height ?? size.width * 0.1,
        width: width ?? size.width * 0.5,
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.buttonColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 5),
          border: border ?? Border.all(color: Colors.transparent, width: 0),
        ),
        child: Center(
          child: (!isLoader!)
              ? Text(
                  textAlign: TextAlign.center,
                  buttonName,
                  style: AppTextStyle.boldStyle().copyWith(
                    color: textColor ?? AppColors.buttonTextColor,
                    fontSize: textSize ?? 20,
                  ),
                  maxLines: 2,
                )
              : (!isLoaderShowWithText!)
                  ? SizedBox(
                      height: size.width * 0.05,
                      width: size.width * 0.05,
                      child: const Loader(
                        color: AppColors.buttonTextColor,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonName,
                          style: AppTextStyle.boldStyle().copyWith(
                            color: textColor ?? AppColors.buttonTextColor,
                            fontSize: textSize ?? 20,
                          ),
                        ),
                        SizedBox(
                          height: size.width * 0.04,
                          width: size.width * 0.04,
                          child: const Loader(
                            color: AppColors.buttonTextColor,
                          ),
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
