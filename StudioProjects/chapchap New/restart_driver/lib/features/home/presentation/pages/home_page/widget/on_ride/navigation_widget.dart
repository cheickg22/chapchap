// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../application/home_bloc.dart';

class NavigationWidget extends StatelessWidget {
  final BuildContext cont;
  const NavigationWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = cont.read<HomeBloc>();
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Row(
            children: [
              SizedBox(width: size.width * 0.01),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).shadowColor,
                          spreadRadius: 1,
                          blurRadius: 1)
                    ]),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => BlocProvider.value(
                        value: homeBloc,
                        child: SizedBox(
                          width: size.width,
                          height: size.width,
                          child: Column(
                            children: [
                              SizedBox(
                                height: size.width * 0.05,
                              ),
                              MyText(
                                  text: 'Choose Map',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                              const Divider(),
                              InkWell(
                                onTap: () async {
                                  if (userData!.onTripRequest!.isTripStart ==
                                      0) {
                                    // context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                                    //     value:
                                    //         '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                                    if (context
                                            .read<HomeBloc>()
                                            .currentLatLng !=
                                        null) {
                                      final latLng = context
                                          .read<HomeBloc>()
                                          .currentLatLng!;

                                      final Uri googleMapsUri = Uri.parse(
                                          'https://www.google.com/maps/dir/?api=1'
                                          '&origin=${latLng.latitude},${latLng.longitude}'
                                          '&destination=${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}');

                                      if (await canLaunchUrl(googleMapsUri)) {
                                        await launchUrl(
                                          googleMapsUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        throw 'Could not launch Google Maps';
                                      }
                                    }
                                  } else {
                                    String wayPoint = '';

                                    final stops =
                                        userData!.onTripRequest!.requestStops;

                                    if (stops.isNotEmpty) {
                                      for (var i = 0; i < stops.length; i++) {
                                        final lat = stops[i]['latitude'];
                                        final lng = stops[i]['longitude'];
                                        final way = '$lat,$lng';

                                        if (wayPoint.isEmpty) {
                                          wayPoint = way;
                                        } else {
                                          wayPoint = '$wayPoint|$way';
                                        }
                                      }
                                    }

                                    final current =
                                        context.read<HomeBloc>().currentLatLng;

                                    if (current != null) {
                                      final Uri googleMapsUri = Uri.parse(
                                          'https://www.google.com/maps/dir/?api=1'
                                          '&origin=${current.latitude},${current.longitude}'
                                          '&destination=${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}'
                                          '${wayPoint.isNotEmpty ? '&waypoints=$wayPoint' : ''}');

                                      if (await canLaunchUrl(googleMapsUri)) {
                                        await launchUrl(
                                          googleMapsUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        throw 'Could not launch Google Maps';
                                      }
                                    }
                                  }
                                  context.read<HomeBloc>().navigationType =
                                      false;
                                  context.read<HomeBloc>().add(UpdateEvent());
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      size.width * 0.05,
                                      size.width * 0.025,
                                      size.width * 0.05,
                                      size.width * 0.025),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.07,
                                        child: Image.asset(
                                          AppImages.googleMaps,
                                          height: size.width * 0.07,
                                          width: 200,
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      MyText(
                                          text: 'Google Map',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark))
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.width * 0.025,
                              ),
                              InkWell(
                                onTap: () async {
                                  var browseUrl = (userData!
                                              .onTripRequest!.isTripStart ==
                                          0)
                                      ? 'https://waze.com/ul?ll=${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}&navigate=yes'
                                      : 'https://waze.com/ul?ll=${userData!.onTripRequest!.dropLat},${userData!.onTripRequest!.dropLng}&navigate=yes';
                                  if (browseUrl.isNotEmpty) {
                                    await launchUrl(Uri.parse(browseUrl));
                                  } else {
                                    throw 'Could not launch $browseUrl';
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      size.width * 0.05,
                                      size.width * 0.025,
                                      size.width * 0.05,
                                      size.width * 0.025),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.07,
                                        child: Image.asset(
                                          AppImages.wazeMap,
                                          height: size.width * 0.07,
                                          width: 200,
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      MyText(
                                          text: 'Waze Map',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Icon(
                      Icons.near_me_rounded,
                      size: size.width * 0.07,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
