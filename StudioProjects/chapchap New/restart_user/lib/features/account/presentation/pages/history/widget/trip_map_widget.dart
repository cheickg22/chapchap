import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../../common/common.dart';
import '../../../../application/acc_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

class TripMapWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripMapWidget({super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return (context.read<AccBloc>().mapType == 'google_map')
              ? GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    context.read<AccBloc>().googleMapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(AppConstants.currentLocations.latitude,
                        AppConstants.currentLocations.longitude),
                    zoom: 4.0,
                  ),
                  zoomControlsEnabled: false,
                  polylines: context.read<AccBloc>().polyline,
                  markers: Set<Marker>.from(context.read<AccBloc>().markers),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 11),
                  buildingsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                )
              : fm.FlutterMap(
                  mapController: context.read<AccBloc>().fmController,
                  options: fm.MapOptions(
                      initialCenter: fmlt.LatLng(
                          double.parse(arg.historyData.dropLat),
                          double.parse(arg.historyData.dropLng)),
                      initialZoom: 10,
                      onTap: (P, L) {}),
                  children: [
                    fm.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.example.com',
                    ),
                    if (context.read<AccBloc>().fmpoly.isNotEmpty)
                      fm.PolylineLayer(
                        polylines: [
                          fm.Polyline(
                              points: context.read<AccBloc>().fmpoly,
                              color: Theme.of(context).primaryColor,
                              strokeWidth: 4),
                        ],
                      ),
                    fm.MarkerLayer(markers: [
                      fm.Marker(
                          width: 250,
                          height: 60,
                          alignment: Alignment.center,
                          point: fmlt.LatLng(
                              double.parse(arg.historyData.pickLat),
                              double.parse(arg.historyData.pickLng)),
                          child: Image.asset(
                            AppImages.pickupIcon,
                            height: 50,
                            fit: BoxFit.contain,
                          )),
                      if (arg.historyData.requestStops == null &&
                          arg.historyData.dropLat != 'null')
                        fm.Marker(
                            width: 250,
                            height: 60,
                            alignment: Alignment.center,
                            point: fmlt.LatLng(
                                double.parse(arg.historyData.dropLat),
                                double.parse(arg.historyData.dropLng)),
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 50,
                            )),
                      if ((arg.historyData.requestStops != null))
                        for (var i = 0;
                            i < arg.historyData.requestStops!.data.length;
                            i++)
                          fm.Marker(
                              width: 250,
                              height: 60,
                              alignment: Alignment.center,
                              point: fmlt.LatLng(
                                  double.parse(arg.historyData.requestStops!
                                      .data[i].latitude
                                      .toString()),
                                  double.parse(arg.historyData.requestStops!
                                      .data[i].longitude
                                      .toString())),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 50,
                              ))
                    ])
                  ],
                );
        },
      ),
    );
  }
}
