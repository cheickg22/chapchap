// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../common/app_constants.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/enable_routebooking_model.dart';
import '../widgets/myroute_search_places.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

class MyRouteMapWidget extends StatelessWidget {
  static const String routeName = '/myRouteMapWidget';
  const MyRouteMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetCurrentLocationEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            return SafeArea(
              child: Scaffold(
                body: Stack(
                  children: [
                    if (accBloc.currentLatLng != null) ...[
                      (mapType == 'google_map')
                          ? _GoogleMapWidget(size: size, accBloc: accBloc)
                          : BlocProvider<AccBloc>.value(
                              value: accBloc,
                              child: _FlutterMapWidget(accBloc),
                            ),
                    ],
                    BlocProvider<AccBloc>.value(
                      value: accBloc,
                      child: const _DropAddressView(),
                    ),
                    if (accBloc.confirmPinAddress)
                      BlocProvider<AccBloc>.value(
                        value: accBloc,
                        child: _ConfirmPinAddressView(accBloc),
                      ),
                    if (accBloc.autoSuggestionSearching ||
                        accBloc.autoCompleteAddress.isNotEmpty)
                      BlocProvider<AccBloc>.value(
                        value: accBloc,
                        child: const _AutoSuggestionView(),
                      ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              child: CustomTextField(
                                controller: accBloc.searchController,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                filled: true,
                                hintText:
                                    AppLocalizations.of(context)!.searchPlace,
                                onChange: (v) {
                                  accBloc.debouncer.run(() {
                                    if (v.length >= 4) {
                                      if (accBloc.currentLatLng != null) {
                                        accBloc.add(
                                            AccGetAutoCompleteAddressEvent(
                                                searchText: v));
                                      } else {
                                        accBloc
                                            .add(AccGetCurrentLocationEvent());
                                      }
                                    } else if (v.isEmpty) {
                                      accBloc.add(AccClearAutoCompleteEvent());
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyText(
                          text: accBloc.selectedMyRouteAddress,
                          maxLines: 4,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: size.width * 0.03),
                        CustomButton(
                          buttonName:
                              AppLocalizations.of(context)!.confirmLocation,
                          width: size.width,
                          textSize: 18,
                          isLoader: accBloc.isLoading,
                          onTap: () {
                            Navigator.pop(
                                context,
                                MyRouteModel(
                                    selectedAddress:
                                        accBloc.selectedMyRouteAddress,
                                    lat:
                                        accBloc.selectedMyRouteLatLng!.latitude,
                                    lng: accBloc
                                        .selectedMyRouteLatLng!.longitude));
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GoogleMapWidget extends StatelessWidget {
  const _GoogleMapWidget({
    required this.size,
    required this.accBloc,
  });

  final Size size;
  final AccBloc accBloc;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      padding: EdgeInsets.only(top: size.width * 0.1),
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        accBloc.googleMapController = controller;
        if (Theme.of(context).brightness == Brightness.dark) {
          if (accBloc.googleMapController != null) {
            if (context.mounted) {
              accBloc.googleMapController!.setMapStyle(accBloc.darkMapString);
            }
          }
        } else {
          if (accBloc.googleMapController != null) {
            if (context.mounted) {
              accBloc.googleMapController!.setMapStyle(accBloc.lightMapString);
            }
          }
        }
        accBloc.googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(target: accBloc.currentLatLng!, zoom: 15)));
        accBloc.add(UpdateEvent());
      },
      compassEnabled: false,
      initialCameraPosition: (accBloc.initialCameraPosition != null)
          ? accBloc.initialCameraPosition!
          : CameraPosition(
              target: accBloc.currentLatLng ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
      onCameraMove: (CameraPosition position) {
        accBloc.mapPoint = position.target;
      },
      onCameraIdle: () {
        if (accBloc.mapPoint != null && accBloc.autoCompleteAddress.isEmpty) {
          accBloc.confirmPinAddress = true;
          accBloc.add(UpdateEvent());
        } else if (accBloc.mapPoint != null &&
            accBloc.autoCompleteAddress.isNotEmpty &&
            !accBloc.confirmPinAddress) {
          accBloc.add(AccClearAutoCompleteEvent());
        }
      },
      markers: Set<Marker>.from(accBloc.markers),
      minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
      buildingsEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

class _FlutterMapWidget extends StatelessWidget {
  final AccBloc accBloc;
  const _FlutterMapWidget(this.accBloc);

  @override
  Widget build(BuildContext context1) {
    return fm.FlutterMap(
      mapController: accBloc.fmController,
      options: fm.MapOptions(
          onMapEvent: (v) {
            if (v.source == fm.MapEventSource.dragEnd ||
                v.source == fm.MapEventSource.mapController) {
              if (accBloc.showGetDropAddress &&
                  accBloc.autoCompleteAddress.isEmpty &&
                  accBloc.fmpoly.isEmpty) {
                accBloc.add(AccGeocodingLatLngEvent(
                    lat: v.camera.center.latitude,
                    lng: v.camera.center.longitude));
              } else if (accBloc.showGetDropAddress &&
                  accBloc.mapPoint != null &&
                  accBloc.autoCompleteAddress.isNotEmpty) {
                accBloc.add(AccClearAutoCompleteEvent());
              }
            }
          },
          initialCenter: fmlt.LatLng(accBloc.currentLatLng!.latitude,
              accBloc.currentLatLng!.longitude),
          initialZoom: 16,
          onTap: (P, L) {}),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: AppConstants.packageName,
        ),
      ],
    );
  }
}

class _ConfirmPinAddressView extends StatelessWidget {
  final AccBloc accBloc;
  const _ConfirmPinAddressView(this.accBloc);

  @override
  Widget build(BuildContext context1) {
    final size = MediaQuery.sizeOf(context1);
    return Positioned(
      top: size.height * 0.42,
      right: size.width * 0.38,
      child: SizedBox(
        child: Padding(
            padding: EdgeInsets.only(bottom: size.width * 0.6),
            child: Row(
              children: [
                CustomButton(
                    height: size.width * 0.08,
                    width: size.width * 0.25,
                    onTap: () {
                      accBloc.confirmPinAddress = false;
                      accBloc.add(UpdateEvent());
                      if (accBloc.mapPoint != null) {
                        accBloc.add(AccGeocodingLatLngEvent(
                            lat: accBloc.mapPoint!.latitude,
                            lng: accBloc.mapPoint!.longitude));
                      }
                    },
                    textSize: 12,
                    buttonName: AppLocalizations.of(context1)!.confirm)
              ],
            )),
      ),
    );
  }
}

class _DropAddressView extends StatelessWidget {
  const _DropAddressView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
        child: Center(
      child: SizedBox(
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Image.asset(
                  AppImages.pickupIcon,
                  width: size.width * 0.12,
                  height: size.width * 0.12,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          )),
    ));
  }
}

class _AutoSuggestionView extends StatelessWidget {
  const _AutoSuggestionView();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      child: MyRouteAutoSearchPlacesWidget(cont: context),
    );
  }
}
