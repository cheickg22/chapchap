import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';

class FleetNotAssignedWidget extends StatelessWidget {
  final BuildContext cont;
  const FleetNotAssignedWidget({super.key,required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
    width: size.width * 0.32,
    height: size.width * 0.11,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: AppColors.white,
    ),
    child: Row(
      children: [
        Container(
          height: size.width * 0.09,
          width: size.width * 0.09,
            padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Image(
              image: const AssetImage(AppImages.lock),
            height: size.width * 0.08,
            width: size.width * 0.08,
          ),
        ),
        SizedBox(
          width: size.width * 0.2,
          child: MyText(
            text: AppLocalizations.of(context)!.fleetsUnassigned,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        )
      ],
    ),
  );

  }
}