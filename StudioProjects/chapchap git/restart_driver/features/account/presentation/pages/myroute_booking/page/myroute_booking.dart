import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_snack_bar.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/enable_routebooking_model.dart';
import 'myroute_map_page.dart';

class RouteBooking extends StatelessWidget {
  static const String routeName = '/routebooking';
  const RouteBooking({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetCurrentLocationEvent(isFromRoutePage: true))
        ..add(RouteBookingInitEvent(address: userData!.myRouteAddress)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is EnableMyRouteBookingSuccessState) {
            Navigator.pop(context);
          } else if (state is MyRouteLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is MyRouteLoadingStopState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.myRouteBooking,
                automaticallyImplyLeading: true,
                onBackTap: () {
                  Navigator.pop(context, userData!);
                },
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          await Navigator.pushNamed(
                                  context, MyRouteMapWidget.routeName)
                              .then(
                            (value) {
                              if (value != null) {
                                final val = value as MyRouteModel;
                                accBloc.selectedMyRouteLatLng =
                                    LatLng(val.lat, val.lng);
                                accBloc.selectedMyRouteAddress =
                                    val.selectedAddress;
                                accBloc.add(MyRouteAddressUpdateEvent(
                                    myRouteLng: val.lng,
                                    myRouteLat: val.lat,
                                    myRouteAddress: val.selectedAddress));
                              }
                            },
                          );
                          // No need to handle result, Bloc state will update
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  accBloc.selectedMyRouteAddress.isEmpty
                                      ? AppLocalizations.of(context)!.addAddress
                                      : accBloc.selectedMyRouteAddress,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.add_location_alt_outlined),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      CustomButton(
                        width: size.width,
                        buttonName: (userData!.enableMyRouteBooking == '1')
                            ? AppLocalizations.of(context)!
                                .disableMyrouteBooking
                            : AppLocalizations.of(context)!
                                .enableMyrouteBooking,
                        buttonColor: (userData!.enableMyRouteBooking == '1')
                            ? AppColors.red
                            : AppColors.lightGreen,
                        textColor: AppColors.white,
                        isLoader: accBloc.isLoading,
                        onTap: () async {
                          if (accBloc.selectedMyRouteAddress.isNotEmpty) {
                            if (accBloc.currentLatLng != null) {
                              accBloc.add(EnableMyRouteBookingEvent(
                                isEnable:
                                    (userData!.enableMyRouteBooking == '1')
                                        ? false
                                        : true,
                                currentLat: accBloc.currentLatLng!.latitude,
                                currentLng: accBloc.currentLatLng!.longitude,
                                currentLatLng: accBloc.currentLocation,
                              ));
                            }
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .pleaseAddAddress);
                          }
                        },
                      ),
                      SizedBox(height: size.width * 0.2),
                    ],
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
