import 'package:flutter/material.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/utils/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool centerTitle;
  final bool? automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.backgroundColor = AppColors.secondary,
    this.textColor = AppColors.white,
    this.centerTitle = true,
    this.automaticallyImplyLeading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      backgroundColor: backgroundColor,
      title: MyText(
        text: title,
        textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: centerTitle,
      leading: (automaticallyImplyLeading != null && automaticallyImplyLeading!)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: onBackTap ?? () => Navigator.of(context).pop(),
            )
          : const SizedBox(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
