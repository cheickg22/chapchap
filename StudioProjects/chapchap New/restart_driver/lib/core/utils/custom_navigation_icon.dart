import 'package:flutter/material.dart';

class NavigationIconWidget extends StatelessWidget {
  final Widget icon;
  final bool? isShadowWidget;
  final void Function()? onTap;
  const NavigationIconWidget({
    super.key,
    required this.icon,
    this.isShadowWidget = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: size.width * 0.1,
        width: size.width * 0.1,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: isShadowWidget!
                ? [
                    BoxShadow(
                        color: Theme.of(context).shadowColor,
                        spreadRadius: 1,
                        blurRadius: 1)
                  ]
                : null),
        child: Center(child: icon),
      ),
    );
  }
}
