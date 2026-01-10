import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../common/common.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_navigation_icon.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'bottom_sheet_widget.dart';
import 'banner_widget.dart';

class HomeBodyWidget extends StatelessWidget {
  final HomeBloc home;

  const HomeBodyWidget({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    return BlocProvider.value(
      value: home,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          return Stack(
            children: [
              // The map and other widgets
              SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    (homeBloc.mapType == 'google_map')
                        // GOOGLE MAP
                        ? SizedBox(
                            height: size.height,
                            width: size.width,
                            child: GoogleMap(
                              mapType: homeBloc.selectedMapType,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                if (homeBloc.googleMapController == null) {
                                  homeBloc.add(GoogleControllAssignEvent(
                                      controller: controller,
                                      isFromHomePage: true,
                                      isEditAddress: false,
                                      latlng: homeBloc.currentLatLng));
                                } else {
                                  homeBloc.add(
                                      LocateMeEvent(mapType: homeBloc.mapType));
                                }
                              },
                              padding: EdgeInsets.only(
                                  bottom: screenWidth + size.width * 0.01),
                              initialCameraPosition: CameraPosition(
                                target: homeBloc.currentLatLng,
                                zoom: 15.0,
                              ),
                              onTap: (argument) {
                                homeBloc.currentLatLng = argument;
                                if (homeBloc.googleMapController != null) {
                                  homeBloc.googleMapController!.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: argument, zoom: 15)));
                                }
                              },
                              onCameraMoveStarted: () {
                                homeBloc.setDragging(true);

                                homeBloc.isCameraMoveComplete = true;
                              },
                              onCameraMove: (CameraPosition? position) {
                                if (position != null) {
                                  if (!context.mounted) return;
                                  homeBloc.currentLatLng = position.target;
                                }
                              },
                              onCameraIdle: () {
                                homeBloc.setDragging(false);
                                if (homeBloc.isCameraMoveComplete) {
                                  if (homeBloc.pickupAddressList.isEmpty) {
                                    homeBloc.add(UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: homeBloc.currentLatLng,
                                        mapType: homeBloc.mapType));
                                  } else {
                                    homeBloc.confirmPinAddress = true;
                                    homeBloc.add(UpdateEvent());
                                  }
                                }
                              },
                              markers: homeBloc.markerList.isNotEmpty
                                  ? Set.from(homeBloc.markerList)
                                  : {},
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(13, 20),
                              buildingsEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                            ),
                          ) // OPEN STREET MAP
                        : SizedBox(
                            height: size.height * 0.55,
                            width: size.width,
                            child: fm.FlutterMap(
                              mapController: homeBloc.fmController,
                              options: fm.MapOptions(
                                onTap: (tapPosition, latLng) {
                                  homeBloc.currentLatLng =
                                      LatLng(latLng.latitude, latLng.longitude);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (homeBloc.fmController != null) {
                                      homeBloc.fmController!.move(latLng, 15);
                                    }
                                  });
                                  homeBloc.add(
                                    UpdateLocationEvent(
                                      isFromHomePage: true,
                                      latLng: homeBloc.currentLatLng,
                                      mapType: homeBloc.mapType,
                                    ),
                                  );
                                },
                                onMapEvent: (v) async {
                                  if (v.source ==
                                      fm.MapEventSource.nonRotatedSizeChange) {
                                    homeBloc.fmLatLng = fmlt.LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.currentLatLng = LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.add(
                                      UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: homeBloc.currentLatLng,
                                        mapType: homeBloc.mapType,
                                      ),
                                    );
                                  }
                                  if (v.source == fm.MapEventSource.onDrag) {
                                    homeBloc.currentLatLng = LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.add(UpdateEvent());
                                  }
                                  if (v.source == fm.MapEventSource.dragEnd) {
                                    homeBloc.add(
                                      UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude),
                                        mapType: homeBloc.mapType,
                                      ),
                                    );
                                  }
                                },
                                onPositionChanged: (p, l) async {
                                  if (l == false) {
                                    homeBloc.currentLatLng = LatLng(
                                        p.center.latitude, p.center.longitude);
                                    homeBloc.add(UpdateEvent());
                                  }
                                },
                                initialCenter: fmlt.LatLng(
                                    homeBloc.currentLatLng.latitude,
                                    homeBloc.currentLatLng.longitude),
                                initialZoom: 16,
                                minZoom: 13,
                                maxZoom: 20,
                              ),
                              children: [
                                fm.TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'app.example.com',
                                ),
                                fm.MarkerLayer(
                                  markers: homeBloc.markerList
                                      .asMap()
                                      .map(
                                        (k, value) {
                                          final marker =
                                              homeBloc.markerList.elementAt(k);
                                          return MapEntry(
                                            k,
                                            fm.Marker(
                                              alignment: Alignment.topCenter,
                                              point: fmlt.LatLng(
                                                  marker.position.latitude,
                                                  marker.position.longitude),
                                              child: RotationTransition(
                                                turns: AlwaysStoppedAnimation(
                                                    marker.rotation / 360),
                                                child: Image.asset(
                                                  (marker.markerId.value
                                                          .toString()
                                                          .contains('truck'))
                                                      ? AppImages.truck
                                                      : marker.markerId.value
                                                              .toString()
                                                              .contains(
                                                                  'motor_bike')
                                                          ? AppImages.bike
                                                          : marker.markerId
                                                                  .value
                                                                  .toString()
                                                                  .contains(
                                                                      'auto')
                                                              ? AppImages.auto
                                                              : marker.markerId
                                                                      .value
                                                                      .toString()
                                                                      .contains(
                                                                          'lcv')
                                                                  ? AppImages
                                                                      .lcv
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
                                                                              .contains('hatchback')
                                                                          ? AppImages.hatchBack
                                                                          : marker.markerId.value.toString().contains('hcv')
                                                                              ? AppImages.hcv
                                                                              : marker.markerId.value.toString().contains('mcv')
                                                                                  ? AppImages.mcv
                                                                                  : marker.markerId.value.toString().contains('luxury')
                                                                                      ? AppImages.luxury
                                                                                      : marker.markerId.value.toString().contains('premium')
                                                                                          ? AppImages.premium
                                                                                          : marker.markerId.value.toString().contains('suv')
                                                                                              ? AppImages.suv
                                                                                              : AppImages.car,
                                                  width: 16,
                                                  height: 25,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      .values
                                      .toList(),
                                ),
                                const fm.RichAttributionWidget(
                                  attributions: [],
                                ),
                              ],
                            ),
                          ),

                    // Marker in the center of the screen
                    Positioned(
                      child: Container(
                        height: size.height * 0.8,
                        width: size.width * 1,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: screenWidth * 0.6 + size.width * 0.06),
                          child: Image.asset(
                            AppImages.confirmationPin,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                          ),
                        ),
                      ),
                    ),

                    if (homeBloc.confirmPinAddress)
                      Positioned(
                        top: screenWidth * 0.09,
                        right: screenWidth * 0.38,
                        child: Container(
                          height: size.height * 0.8,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: screenWidth * 0.6 + size.width * 0.06),
                            child: Row(
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    return homeBloc.isDragging
                                        ? CustomButton(
                                            buttonColor: Theme.of(context)
                                                .disabledColor
                                                .withAlpha((0.5 * 255).toInt()),
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {},
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .pickMeHere,
                                          )
                                        : CustomButton(
                                            buttonColor:
                                                Theme.of(context).primaryColor,
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {
                                              homeBloc.confirmPinAddress =
                                                  false;
                                              if (homeBloc
                                                      .nearByVechileSubscription ==
                                                  null) {
                                                homeBloc
                                                    .nearByVechileCheckStream(
                                                        context, this);
                                              }
                                              homeBloc.add(
                                                UpdateLocationEvent(
                                                  isFromHomePage: true,
                                                  latLng:
                                                      homeBloc.currentLatLng,
                                                  mapType: homeBloc.mapType,
                                                ),
                                              );
                                            },
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .confirm,
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Locate Me
              Positioned(
                bottom: size.height * 0.57,
                right: size.width * 0.03,
                child: Column(
                  children: [
                    if (homeBloc.mapType == 'google_map')
                      PopupMenuButton<MapType>(
                        color: AppColors.white,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Icon(Icons.layers, color: Colors.black),
                        ),
                        onSelected: (mapType) {
                          homeBloc.add(UpdateMapTypeEvent(mapType));
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: MapType.normal,
                              child: MyText(
                                  text: AppLocalizations.of(context)!.normal)),
                          PopupMenuItem(
                              value: MapType.satellite,
                              child: MyText(
                                  text:
                                      AppLocalizations.of(context)!.satellite)),
                          PopupMenuItem(
                            value: MapType.terrain,
                            child: MyText(
                                text: AppLocalizations.of(context)!.terrain),
                          ),
                          PopupMenuItem(
                            value: MapType.hybrid,
                            child: MyText(
                                text: AppLocalizations.of(context)!.hybrid),
                          ),
                        ],
                      ),
                    SizedBox(height: size.width * 0.02),
                    InkWell(
                      onTap: () {
                        // Remove confirmPinAddress for envato code
                        homeBloc.confirmPinAddress = false;
                        if (homeBloc.nearByVechileSubscription == null) {
                          homeBloc.nearByVechileCheckStream(context, this);
                        }
                        homeBloc.add(LocateMeEvent(mapType: homeBloc.mapType));
                      },
                      child: Container(
                        height: size.width * 0.11,
                        width: size.width * 0.11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            width: 1.2,
                            color:
                                AppColors.black.withAlpha((0.8 * 255).toInt()),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.my_location,
                            size: size.width * 0.05,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Navigation and location bar
              SafeArea(
                bottom: false,
                top: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      NavigationIconWidget(
                        icon: InkWell(
                          onTap: () {
                            if (homeBloc.userData != null) {
                              Navigator.pushNamed(
                                      context, AccountPage.routeName,
                                      arguments: AccountPageArguments(
                                          userData: homeBloc.userData!))
                                  .then(
                                (value) {
                                  if (!context.mounted) return;
                                  homeBloc.add(GetDirectionEvent());
                                  if (value != null) {
                                    homeBloc.userData = value as UserDetail;
                                    homeBloc.add(UpdateEvent());
                                  }
                                },
                              );
                            }
                          },
                          child: Icon(Icons.menu,
                              size: 20,
                              color: Theme.of(context).primaryColorDark),
                        ),
                        isShadowWidget: true,
                      ),
                      SizedBox(width: size.width * 0.03),
                      InkWell(
                        onTap: () {
                          homeBloc.add(DestinationSelectEvent(
                              isPickupChange: true,
                              transportType:
                                  homeBloc.selectedServiceType!.transportType));
                        },
                        child: Container(
                          width: size.width * 0.78,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            // boxShadow: [
                            //   BoxShadow(
                            //       blurRadius: 3,
                            //       spreadRadius: 2,
                            //       color: Theme.of(context).shadowColor)
                            // ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 6),
                            child: Row(
                              children: [
                                const PickupIcon(),
                                SizedBox(width: size.width * 0.01),
                                SizedBox(
                                  width: size.width * 0.63,
                                  child: MyText(
                                      text: homeBloc.currentLocation,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Icon(Icons.edit_outlined,
                                    size: 18,
                                    color: Theme.of(context).disabledColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (homeBloc.isSheetAtTop == false &&
                  homeBloc.userData != null &&
                  homeBloc.userData!.bannerImage != null &&
                  homeBloc.userData!.bannerImage.data.isNotEmpty)
                Positioned(
                  bottom: size.height * 0.44,
                  left: 16,
                  right: 16,
                  child: BannerWidget(cont: context),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    double sheetSize = homeBloc.sheetSize;
                    double minChildSize = homeBloc.minChildSize; // Bottom
                    double midChildSize = homeBloc.midChildSize; // Midpoint
                    double maxChildSize = homeBloc.maxChildSize; // Top
                    double currentSize = sheetSize;
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        final dragAmount = details.primaryDelta ?? 0;

                        currentSize =
                            (currentSize - dragAmount / context.size!.height)
                                .clamp(minChildSize, maxChildSize);
                        homeBloc.add(UpdateScrollPositionEvent(currentSize));
                      },
                      onVerticalDragEnd: (details) {
                        // If scrolling up, snap to the top or midpoint
                        if (details.velocity.pixelsPerSecond.dy < 0) {
                          currentSize = currentSize >= midChildSize
                              ? maxChildSize
                              : midChildSize;
                        } else {
                          // If scrolling down, skip the midpoint and go directly to the bottom
                          currentSize = minChildSize;
                        }

                        homeBloc.add(UpdateScrollPositionEvent(currentSize));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height:
                            MediaQuery.of(context).size.height * currentSize,
                        curve: Curves.easeInOut,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: homeBloc.serviceAvailable
                                ? BottomSheetWidget(home: homeBloc)
                                : Column(
                                    children: [
                                      SizedBox(height: size.width * 0.03),
                                      Image.asset(AppImages.noDataFound,
                                          height: size.width * 0.5,
                                          width: size.width),
                                      SizedBox(height: size.width * 0.02),
                                      MyText(
                                          text: AppLocalizations.of(context)!
                                              .serviceNotAvailable)
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                    // },);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
