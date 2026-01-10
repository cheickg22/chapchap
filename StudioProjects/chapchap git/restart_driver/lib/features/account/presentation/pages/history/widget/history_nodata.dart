import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';

class HistoryNodataWidget extends StatelessWidget {
  const HistoryNodataWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.historyNoData),
          const SizedBox(height: 10),
          MyText(
            text: AppLocalizations.of(context)!.noHistoryAvail,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).disabledColor, fontSize: 18),
          ),
          MyText(
            text: AppLocalizations.of(context)!.makeNewBookingToView,
            maxLines: 2,
            textAlign: TextAlign.center,
            textStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).disabledColor, fontSize: 16),
          ),
        ],
      ),
    ));
  }
}
