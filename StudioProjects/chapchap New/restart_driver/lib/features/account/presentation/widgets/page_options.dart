import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/app/localization.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import '../../../../common/local_data.dart';

class PageOptions extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool? showTheme;
  final bool? showroute;
  final bool? showrouteValue;

  const PageOptions({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.showTheme = false,
    this.showroute = false,
    this.showrouteValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: size.width * 0.03,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          minHeight: size.height * 0.06,
        ),
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.white
                        : AppColors.black,
                  ),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: label,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w400),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          MyText(
                            text: subtitle!,
                            textStyle:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 12,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showTheme!)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Transform.scale(
                  scaleX: size.width * 0.0025,
                  scaleY: size.width * 0.0024,
                  child: Switch(
                    value: context.read<AccBloc>().isDarkTheme,
                    activeColor: Theme.of(context).primaryColorDark,
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: AppColors.white,
                    activeThumbImage: const AssetImage(AppImages.sun),
                    inactiveThumbImage: const AssetImage(AppImages.moon),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) async {
                      context.read<AccBloc>().isDarkTheme = value;
                      final locale =
                          await AppSharedPreference.getSelectedLanguageCode();
                      if (!context.mounted) return;
                      context.read<LocalizationBloc>().add(
                          LocalizationInitialEvent(
                              isDark: value, locale: Locale(locale)));
                    },
                  ),
                ),
              ),
            if (showroute!)
              Switch(
                value: showrouteValue!,
                activeColor: Theme.of(context).primaryColorDark,
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: AppColors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: null, // disables the switch if false
              ),
            if (!showTheme! && !showroute!)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }
}
