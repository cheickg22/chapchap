import 'package:flutter/material.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/bidding_ride/bidding_ride_list_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class BiddingRidePage extends StatelessWidget {
  final BuildContext cont;
  const BiddingRidePage({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.biddingRides,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: BiddingRideListWidget(cont: cont),
      ),
    );
  }
}
