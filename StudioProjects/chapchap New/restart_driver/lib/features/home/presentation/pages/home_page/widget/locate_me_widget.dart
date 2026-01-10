import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../../../common/app_constants.dart';
import '../../../../application/home_bloc.dart';

class LocateMeWidget extends StatelessWidget {
  final BuildContext cont;
  const LocateMeWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor,
                      spreadRadius: 1,
                      blurRadius: 1)
                ]),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                PermissionStatus status = await Permission.location.status;
                if (!context.mounted) return;
                if (status.isGranted || status.isLimited) {
                  if (context.read<HomeBloc>().currentLatLng != null) {
                    if (mapType == 'google_map') {
                      if (context.read<HomeBloc>().googleMapController !=
                          null) {
                        context
                            .read<HomeBloc>()
                            .googleMapController!
                            .animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(
                                    target:
                                        context.read<HomeBloc>().currentLatLng!,
                                    zoom: 13)));
                        context.read<HomeBloc>().add(GetCurrentLocationEvent());
                      }
                    } else {
                      context.read<HomeBloc>().fmController.move(
                          fmlt.LatLng(
                              context.read<HomeBloc>().currentLatLng!.latitude,
                              context
                                  .read<HomeBloc>()
                                  .currentLatLng!
                                  .longitude),
                          13);
                    }
                    if (context.read<HomeBloc>().markers.isEmpty) {
                      context.read<HomeBloc>().streamLocation();
                    }
                  } else {
                    context.read<HomeBloc>().add(GetCurrentLocationEvent());
                  }
                } else {
                  context.read<HomeBloc>().add(GetCurrentLocationEvent());
                }
              },
              child: Container(
                height: size.width * 0.1,
                width: size.width * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Icon(
                  Icons.my_location_sharp,
                  size: size.width * 0.07,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
