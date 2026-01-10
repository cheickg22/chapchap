import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/avatar_glow.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';

class BookingMapWidget extends StatelessWidget {
  final BuildContext cont;
  final String mapType;
  const BookingMapWidget(
      {super.key, required this.cont, required this.mapType});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final bookingBloc = context.read<BookingBloc>();
          return (mapType == 'google_map')
              // Google Map
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: size.height,
                      width: size.width,
                      child: BlocBuilder<BookingBloc, BookingState>(
                        builder: (_, state) {
                          // Stop the animation if requestData is not null
                          if (bookingBloc.requestData != null) {
                            bookingBloc.animationController?.stop();
                            bookingBloc.animationController = null;
                          }
                          return AnimatedBuilder(
                            animation: bookingBloc.animation!,
                            builder: (_, child) {
                              return GoogleMap(
                                mapType: bookingBloc.selectedMapType,
                                padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05,
                                  (bookingBloc.requestData != null)
                                      ? size.width * 0.10 +
                                          MediaQuery.of(context).padding.top
                                      : size.width * 0.05 +
                                          MediaQuery.of(context).padding.top,
                                  size.width * 0.05,
                                  size.width * 0.8,
                                ),
                                gestureRecognizers: {
                                  Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer(),
                                  ),
                                },
                                onMapCreated: (GoogleMapController controller) {
                                  bookingBloc.googleMapController = controller;
                                },
                                compassEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    AppConstants.currentLocations.latitude,
                                    AppConstants.currentLocations.longitude,
                                  ),
                                  zoom: 15.0,
                                ),
                                minMaxZoomPreference:
                                    const MinMaxZoomPreference(0, 20),
                                buildingsEnabled: false,
                                zoomControlsEnabled: false,
                                myLocationEnabled: (bookingBloc
                                            .isNormalRideSearching ||
                                        bookingBloc.isBiddingRideSearching ||
                                        (bookingBloc.requestData != null))
                                    ? false
                                    : true,
                                myLocationButtonEnabled: false,
                                markers: (bookingBloc.isNormalRideSearching ||
                                        bookingBloc.isBiddingRideSearching)
                                    ? {}
                                    : Set.from(bookingBloc.markerList),
                                polylines: (bookingBloc.isNormalRideSearching ||
                                        bookingBloc.isBiddingRideSearching)
                                    ? {}
                                    : (bookingBloc.requestData != null)
                                        ? bookingBloc.polylines
                                        : {
                                            Polyline(
                                              polylineId:
                                                  const PolylineId('greyRoute'),
                                              points: context
                                                  .read<BookingBloc>()
                                                  .polylist,
                                              color: Colors.grey,
                                              width: 5,
                                            ),
                                            Polyline(
                                              polylineId: const PolylineId(
                                                  'animatedRoute'),
                                              points: bookingBloc
                                                  .getGoogleMapAnimatedPolyline(
                                                      bookingBloc.polylist,
                                                      bookingBloc
                                                          .animation!.value),
                                              color: AppColors.blue,
                                              width: 5,
                                            ),
                                          },
                                rotateGesturesEnabled:
                                    (bookingBloc.isNormalRideSearching ||
                                            bookingBloc.isBiddingRideSearching)
                                        ? false
                                        : true,
                                zoomGesturesEnabled:
                                    (bookingBloc.isNormalRideSearching ||
                                            bookingBloc.isBiddingRideSearching)
                                        ? false
                                        : true,
                                scrollGesturesEnabled:
                                    (bookingBloc.isNormalRideSearching ||
                                            bookingBloc.isBiddingRideSearching)
                                        ? false
                                        : true,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (bookingBloc.isNormalRideSearching ||
                        bookingBloc.isBiddingRideSearching)
                      Positioned(
                        top: size.width * 0.65,
                        child: AvatarGlow(
                          glowColor: AppColors.green,
                          glowRadiusFactor: 2.5,
                          glowCount: 8,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 25),
                            child: Image.asset(
                              AppImages.confirmationPin,
                              height: 30,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              // Flutter Map
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: size.height,
                      width: size.width,
                      child: fm.FlutterMap(
                        mapController: bookingBloc.fmController,
                        options: fm.MapOptions(
                          onTap: (tapPosition, latLng) {},
                          onMapEvent: (v) async {},
                          onPositionChanged: (p, l) async {},
                          initialCenter: fmlt.LatLng(
                              AppConstants.currentLocations.latitude,
                              AppConstants.currentLocations.longitude),
                          initialZoom: 16,
                          minZoom: 5,
                          maxZoom: 20,
                        ),
                        children: [
                          fm.TileLayer(
                            urlTemplate: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/{z}/{x}/{y}@4x.png'
                                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c', 'd', 'e'],
                            userAgentPackageName: 'app.example.com',
                          ),
                          // Grey background polyline
                          if (!bookingBloc.isNormalRideSearching &&
                              !bookingBloc.isBiddingRideSearching &&
                              bookingBloc.requestData == null &&
                              bookingBloc.fmpoly.isNotEmpty) ...[
                            fm.PolylineLayer(
                              polylines: [
                                fm.Polyline(
                                  points: bookingBloc.fmpoly,
                                  color: Theme.of(context).dividerColor,
                                  // Grey polyline as background
                                  strokeWidth: 4,
                                ),
                              ],
                            ),
                            AnimatedBuilder(
                              animation: bookingBloc.animation!,
                              builder: (context, child) {
                                final fmpoly = bookingBloc.fmpoly;
                                final animatedPoints =
                                    bookingBloc.getFlutterMapAnimatedPolyline(
                                        fmpoly, bookingBloc.animation!.value);
                                // Stop the animation if requestData is not null
                                if (bookingBloc.requestData != null) {
                                  bookingBloc.animationController?.stop();
                                }
                                return (animatedPoints.isNotEmpty)
                                    ? fm.PolylineLayer(
                                        polylines: [
                                          fm.Polyline(
                                            points: animatedPoints,
                                            color: AppColors
                                                .blue, // animated polyline
                                            strokeWidth: 6,
                                          ),
                                        ],
                                      )
                                    : Container();
                              },
                            ),
                          ],
                          if (!bookingBloc.isNormalRideSearching &&
                              !bookingBloc.isBiddingRideSearching &&
                              bookingBloc.requestData != null &&
                              bookingBloc.fmpoly.isNotEmpty)
                            fm.PolylineLayer(
                              polylines: [
                                fm.Polyline(
                                  points: bookingBloc.fmpoly,
                                  color: AppColors.blue,
                                  strokeWidth: 6,
                                ),
                              ],
                            ),
                          const fm.RichAttributionWidget(attributions: []),
                          if (!bookingBloc.isNormalRideSearching &&
                              !bookingBloc.isBiddingRideSearching)
                            fm.MarkerLayer(
                              markers: List.generate(
                                  bookingBloc.markerList.length, (index) {
                                final marker =
                                    bookingBloc.markerList.elementAt(index);
                                return fm.Marker(
                                  point: fmlt.LatLng(marker.position.latitude,
                                      marker.position.longitude),
                                  alignment: Alignment.topCenter,
                                  child: RotationTransition(
                                    turns: AlwaysStoppedAnimation(
                                      ((marker.rotation.isNaN ||
                                                  marker.rotation.isInfinite)
                                              ? 0.0
                                              : marker.rotation) /
                                          360,
                                    ),
                                    child: Image.asset(
                                      marker.markerId.value.toString() == 'pick'
                                          ? AppImages.pickPin
                                          : (marker.markerId.value.toString() ==
                                                      'drop' ||
                                                  marker.markerId.value
                                                      .toString()
                                                      .contains('drop'))
                                              ? AppImages.dropPin
                                              : (marker.markerId.value
                                                      .toString()
                                                      .contains('truck'))
                                                  ? AppImages.truck
                                                  : marker.markerId.value
                                                          .toString()
                                                          .contains(
                                                              'motor_bike')
                                                      ? AppImages.bike
                                                      : marker.markerId.value
                                                              .toString()
                                                              .contains('auto')
                                                          ? AppImages.auto
                                                          : marker.markerId
                                                                  .value
                                                                  .toString()
                                                                  .contains(
                                                                      'lcv')
                                                              ? AppImages.lcv
                                                              : marker.markerId
                                                                      .value
                                                                      .toString()
                                                                      .contains(
                                                                          'ehcv')
                                                                  ? AppImages
                                                                      .ehcv
                                                                  : marker.markerId
                                                                          .value
                                                                          .toString()
                                                                          .contains(
                                                                              'hatchback')
                                                                      ? AppImages
                                                                          .hatchBack
                                                                      : marker.markerId
                                                                              .value
                                                                              .toString()
                                                                              .contains('hcv')
                                                                          ? AppImages.hcv
                                                                          : marker.markerId.value.toString().contains('mcv')
                                                                              ? AppImages.mcv
                                                                              : marker.markerId.value.toString().contains('luxury')
                                                                                  ? AppImages.luxury
                                                                                  : marker.markerId.value.toString().contains('premium')
                                                                                      ? AppImages.premium
                                                                                      : marker.markerId.value.toString().contains('suv')
                                                                                          ? AppImages.suv
                                                                                          : (marker.markerId.value.toString().contains('car'))
                                                                                              ? AppImages.car
                                                                                              : '',
                                      width: 16,
                                      height: 30,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                          if (!bookingBloc.isNormalRideSearching &&
                              !bookingBloc.isBiddingRideSearching &&
                              bookingBloc.markerList.any((element) => element
                                  .markerId.value
                                  .toString()
                                  .contains('distance')))
                            fm.MarkerLayer(
                              markers: List.generate(1, (index) {
                                final marker = bookingBloc.markerList
                                    .firstWhere((element) => element
                                        .markerId.value
                                        .toString()
                                        .contains('distance'));
                                return fm.Marker(
                                  point: fmlt.LatLng(marker.position.latitude,
                                      marker.position.longitude),
                                  alignment: Alignment.bottomCenter,
                                  height: 50,
                                  width: 100,
                                  child: RotationTransition(
                                    turns: AlwaysStoppedAnimation(
                                      ((marker.rotation.isNaN ||
                                                  marker.rotation.isInfinite)
                                              ? 0.0
                                              : marker.rotation) /
                                          360,
                                    ),
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          height: 40,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: AppColors.primary,
                                                  width: 1)),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(5),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5)),
                                                    color: AppColors.primary),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    MyText(
                                                      text: bookingBloc
                                                          .fmDistance,
                                                      textStyle: AppTextStyle
                                                              .normalStyle()
                                                          .copyWith(
                                                              color: ThemeData
                                                                      .light()
                                                                  .scaffoldBackgroundColor,
                                                              fontSize: 12),
                                                    ),
                                                    MyText(
                                                      text: bookingBloc
                                                          .userData!
                                                          .distanceUnit,
                                                      textStyle: AppTextStyle
                                                              .normalStyle()
                                                          .copyWith(
                                                              color: ThemeData
                                                                      .light()
                                                                  .scaffoldBackgroundColor,
                                                              fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              topRight: Radius
                                                                  .circular(5),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                      color: ThemeData.light()
                                                          .scaffoldBackgroundColor),
                                                  child: MyText(
                                                    text: ((bookingBloc
                                                                .fmDuration) >
                                                            60)
                                                        ? '${(bookingBloc.fmDuration / 60).toStringAsFixed(0)} hrs'
                                                        : '${bookingBloc.fmDuration.toStringAsFixed(0)} mins',
                                                    textStyle: AppTextStyle
                                                            .normalStyle()
                                                        .copyWith(
                                                            color: AppColors
                                                                .primary,
                                                            fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                    if (bookingBloc.isNormalRideSearching ||
                        bookingBloc.isBiddingRideSearching)
                      Positioned(
                        top: size.width * 0.65,
                        child: AvatarGlow(
                          glowColor: AppColors.green,
                          glowRadiusFactor: 2.5,
                          glowCount: 8,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 25),
                            child: Image.asset(
                              AppImages.confirmationPin,
                              height: 30,
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
