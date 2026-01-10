import 'package:flutter/material.dart';

import 'common.dart';

class PickupIcon extends StatelessWidget {
  const PickupIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.green.withAlpha((0.3 * 255).toInt())),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // color: AppColors.primary,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropIcon extends StatelessWidget {
  const DropIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Icon(
        Icons.location_on_rounded,
        color: AppColors.red,
        size: 23,
      ),
    );
  }
}
