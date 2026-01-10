import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../application/home_bloc.dart';

class PeakZoneWidget extends StatelessWidget {
  final BuildContext cont;
  const PeakZoneWidget({super.key, required this.cont});

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
                if (!context.read<HomeBloc>().showPeakZones) {
                  context.read<HomeBloc>().showPeakZones = true;
                  context.read<HomeBloc>().add(GetPeakZoneEvent());
                } else {
                  context.read<HomeBloc>().showPeakZones = false;
                  context.read<HomeBloc>().peakZoneZoomedOut =
                      false; // Reset zoom flag
                  context.read<HomeBloc>().zoneStreamRemove?.cancel();
                  context.read<HomeBloc>().zoneStreamRemove = null;
                  context.read<HomeBloc>().polygons.removeWhere((element) =>
                      element.polygonId.value.contains('peakzone_'));
                  context.read<HomeBloc>().polyline.removeWhere((element) =>
                      element.polylineId.value.contains('peakzone_'));
                  context.read<HomeBloc>().add(UpdateEvent());
                }
              },
              child: Container(
                height: size.width * 0.1,
                width: size.width * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: !context.read<HomeBloc>().showPeakZones
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).primaryColor,
                ),
                child: Icon(
                  Icons.flash_on,
                  size: size.width * 0.07,
                  color: !context.read<HomeBloc>().showPeakZones
                      ? Theme.of(context).primaryColorDark
                      : AppColors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
