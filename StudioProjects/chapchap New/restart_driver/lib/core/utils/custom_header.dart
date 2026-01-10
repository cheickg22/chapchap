import 'package:flutter/material.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool centerTitle;
  final bool? automaticallyImplyLeading;
  final Widget? titleIcon;
  final double? titleFontSize;

  const CustomHeader({
    super.key,
    required this.title,
    this.onBackTap,
    // this.backgroundColor = AppColors.secondary,
    this.backgroundColor,
    // this.textColor = AppColors.white,
    this.textColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading,
    this.titleIcon,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTextColor =
        textColor ?? Theme.of(context).textTheme.titleLarge!.color;
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const Border(
        bottom: BorderSide(
          color: AppColors.grey, // change color here
          width: 1, // thickness
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titleIcon != null) ...[
            titleIcon!,
            const SizedBox(width: 8),
          ],
          MyText(
            text: title,
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: resolvedTextColor,
                  // fontWeight: FontWeight.bold,
                  fontSize: titleFontSize ??
                      Theme.of(context).textTheme.titleLarge!.fontSize,
                ),
          ),
        ],
      ),
      centerTitle: centerTitle,
      leading: (automaticallyImplyLeading != null && automaticallyImplyLeading!)
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
              onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            )
          : const SizedBox(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
