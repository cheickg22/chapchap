import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/network/network.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/functions.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class HighDemandAreaWidget extends StatelessWidget {
  final String zoneName;
  final LatLng zoneLatLng;
  final int endTimestamp;
  final HomeBloc homeBloc;
  const HighDemandAreaWidget(
      {super.key,
      required this.zoneName,
      required this.zoneLatLng,
      required this.endTimestamp,
      required this.homeBloc});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final dist = calculateDistance(
              lat1: homeBloc.currentLatLng!.latitude,
              lon1: homeBloc.currentLatLng!.longitude,
              lat2: zoneLatLng.latitude,
              lon2: zoneLatLng.longitude,
              unit: userData?.distanceUnit ?? 'km');
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
              endTimestamp * 1000,
              isUtc: true);

          Timer endTime = Timer.periodic(const Duration(minutes: 1), (t) {
            homeBloc.add(UpdateEvent());
          });
          if (date.difference(DateTime.now().toUtc()).inMinutes < 1) {
            endTime.cancel();
            Navigator.pop(context);
          } else if (!homeBloc.showDemandArea) {
            endTime.cancel();
            Navigator.pop(context);
          }
          return SafeArea(
            child: Container(
              height: size.width * 0.8,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.width * 0.05),
                    MyText(
                      text: AppLocalizations.of(context)!.highDemandArea,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.width * 0.03),
                    MyText(
                      text: AppLocalizations.of(context)!.endsInMins.replaceAll(
                          '**',
                          date
                              .difference(DateTime.now().toUtc())
                              .inMinutes
                              .toString()),
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    SizedBox(height: size.width * 0.04),
                    SizedBox(
                      width: size.width * 0.9,
                      child: InkWell(
                        onTap: () {
                          if (userData!.enableWazeMap == '0') {
                            homeBloc.add(OpenAnotherFeatureEvent(
                                value:
                                    '${ApiEndpoints.openMap}${zoneLatLng.latitude},${zoneLatLng.longitude}'));
                          } else {
                            homeBloc.add(
                                NavigationTypeEvent(isMapNavigation: false));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyText(
                                    text: zoneName,
                                    textStyle:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 5,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                MyText(
                                  text:
                                      '${dist.toStringAsFixed(2)} ${userData?.distanceUnit ?? 'KM'}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: size.width * 0.02),
                                const Icon(Icons.arrow_forward_ios, size: 18)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (homeBloc.navigationType1 == true) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.all(size.width * 0.02),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).shadowColor,
                                        spreadRadius: 1,
                                        blurRadius: 1)
                                  ]),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      homeBloc.add(OpenAnotherFeatureEvent(
                                          value:
                                              '${ApiEndpoints.openMap}${zoneLatLng.latitude},${zoneLatLng.longitude}'));
                                    },
                                    child: SizedBox(
                                      width: size.width * 0.07,
                                      child: Image.asset(
                                        AppImages.googleMaps,
                                        height: size.width * 0.07,
                                        width: 200,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  InkWell(
                                    onTap: () async {
                                      var browseUrl =
                                          'https://waze.com/ul?ll=${zoneLatLng.latitude},${zoneLatLng.longitude}&navigate=yes';
                                      if (browseUrl.isNotEmpty) {
                                        await launchUrl(Uri.parse(browseUrl));
                                      } else {
                                        throw 'Could not launch $browseUrl';
                                      }
                                    },
                                    child: SizedBox(
                                      width: size.width * 0.07,
                                      child: Image.asset(
                                        AppImages.wazeMap,
                                        height: size.width * 0.07,
                                        width: 200,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
