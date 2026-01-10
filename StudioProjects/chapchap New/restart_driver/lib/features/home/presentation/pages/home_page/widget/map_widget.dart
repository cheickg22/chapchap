import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/bidding_ride/bidding_request_widget.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/bidding_ride/bidding_ride_page.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/on_ride/on_ride_widget.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/accept_reject_widget.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/outstation_request_page.dart';
import 'package:restart_tagxi/features/account/data/repository/acc_api.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/instand_ride/avatar_glow.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;
import 'bidding_ride/bidding_timer_widget.dart';
import 'instand_ride/auto_search_places.dart';
import 'earnings_widget.dart';
import 'locate_me_widget.dart';
import 'map_appbar_widget.dart';
import 'on_ride/cancel_reason_widget.dart';
import 'on_ride/navigation_widget.dart';
import 'on_ride/onride_slider_button_widget.dart';
import 'on_ride/signature_get_widget.dart';
import 'outstation_ride_list_widget.dart';
import 'peak_zone_widget.dart';
import 'quick_action_widget.dart';
import 'on_ride/sos_widget.dart';
import 'vehicles_status_widget.dart';

class MapWidget extends StatelessWidget {
  final BuildContext cont;

  const MapWidget({super.key, required this.cont});

  void _handleBiddingRideNavigation(BuildContext context, HomeBloc homeBloc) {
    final shouldOpenBiddingPage = homeBloc.showBiddingPage &&
        !homeBloc.isBiddingPageRouteActive &&
        !homeBloc.showOutstationWidget &&
        !homeBloc.visibleOutStation;

    if (shouldOpenBiddingPage) {
      homeBloc.isBiddingPageRouteActive = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BiddingRidePage(cont: cont)))
          .then((_) {
        homeBloc.isBiddingPageRouteActive = false;
        if (homeBloc.showBiddingPage) {
          homeBloc.showBiddingPage = false;
          homeBloc.add(UpdateEvent());
        }
      });
    } else if (!homeBloc.showBiddingPage && homeBloc.isBiddingPageRouteActive) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          homeBloc.bidRideTop ??= (size.height) - (size.height * 0.67);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleBiddingRideNavigation(context, homeBloc);
          });
          return Stack(
            children: [
              if (homeBloc.currentLatLng != null) ...[
                (mapType == 'google_map')
                    ? _GoogleMapWidget(size: size, homeBloc: homeBloc)
                    : BlocProvider<HomeBloc>.value(
                        value: homeBloc,
                        child: _FlutterMapWidget(homeBloc),
                      ),
              ],
              if (homeBloc.showGetDropAddress && homeBloc.polyline.isEmpty) ...[
                BlocProvider<HomeBloc>.value(
                  value: homeBloc,
                  child: const _DropAddressView(),
                ),
                if (homeBloc.confirmPinAddress)
                  BlocProvider<HomeBloc>.value(
                    value: homeBloc,
                    child: _ConfirmPinAddressView(homeBloc),
                  ),
              ],
              if (homeBloc.autoSuggestionSearching ||
                  homeBloc.autoCompleteAddress.isNotEmpty)
                BlocProvider<HomeBloc>.value(
                  value: homeBloc,
                  child: const _AutoSuggestionView(),
                ),
              if (homeBloc.choosenRide != null)
                BlocProvider<HomeBloc>.value(
                  value: homeBloc,
                  child: _RideView(homeBloc),
                ),
              if (userData != null && userData!.role == 'owner') ...[
                Positioned(
                    top: size.height * 0.06,
                    child: VehicleStatusWidget(cont: context)),
              ],
              if (userData != null &&
                  userData!.role == 'driver' &&
                  userData!.metaRequest == null &&
                  userData!.onTripRequest == null)
                Positioned(top: 0, child: MapAppBarWidget(cont: context)),
              if (homeBloc.autoSuggestionSearching == false &&
                  homeBloc.autoCompleteAddress.isEmpty)
                BlocProvider<HomeBloc>.value(
                  value: homeBloc,
                  child: _AutoCompletionEmptyView(homeBloc),
                ),
              if (userData != null &&
                  userData!.role == 'driver' &&
                  userData!.metaRequest == null &&
                  userData!.onTripRequest == null &&
                  homeBloc.choosenRide == null &&
                  homeBloc.showGetDropAddress == false)
                DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.25,
                  maxChildSize: 1.0,
                  builder: (context, scrollController) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return NotificationListener<
                            DraggableScrollableNotification>(
                          onNotification: (notification) {
                            double currentSize = notification.extent;

                            // Determine widget based on height threshold
                            if (currentSize >= 0.6) {
                              homeBloc.animatedWidget =
                                  QuickActionsWidget(cont: cont);
                            } else {
                              homeBloc.animatedWidget =
                                  EarningsWidget(cont: cont);
                            }

                            // Update the bottom size in the Bloc
                            homeBloc.bottomSize = currentSize * size.height;

                            // Trigger a state update
                            homeBloc.add(UpdateEvent());
                            return true;
                          },
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(size.width * 0.1),
                                topRight: Radius.circular(size.width * 0.1),
                              ),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(size.width * 0.1),
                                topRight: Radius.circular(size.width * 0.1),
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: const ClampingScrollPhysics(),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: homeBloc.animatedWidget ??
                                      EarningsWidget(cont: cont),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              if (userData != null &&
                  homeBloc.isBiddingEnabled &&
                  homeBloc.choosenRide == null &&
                  userData!.onTripRequest == null &&
                  userData!.metaRequest == null &&
                  homeBloc.showGetDropAddress == false &&
                  userData!.active &&
                  homeBloc.bottomSize < size.height * 0.5)
                AnimatedPositioned(
                  right: 0,
                  top: homeBloc.bidRideTop,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: size.width * 0.05),
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
                          onTap: () {
                            if (homeBloc.bidRideTop ==
                                (size.height) - (size.height * 0.67)) {
                              homeBloc.bidRideTop =
                                  MediaQuery.paddingOf(context).top +
                                      size.width * 0.05;
                            } else {
                              homeBloc.bidRideTop =
                                  (size.height) - (size.height * 0.67);
                            }
                            homeBloc.add(UpdateEvent());
                            context
                                .read<HomeBloc>()
                                .add(ShowBiddingPageEvent());
                          },
                          child: Container(
                            height: size.width * 0.1,
                            width: size.width * 0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.biddingCar,
                              width: size.width * 0.07,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (homeBloc.showGetDropAddress)
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: size.width * 0.5,
                    padding: EdgeInsets.all(size.width * 0.05),
                    width: size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MyText(
                          text: homeBloc.dropAddress,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 4,
                        ),
                        SizedBox(height: size.width * 0.05),
                        CustomButton(
                            buttonName:
                                AppLocalizations.of(context)!.confirmLocation,
                            onTap: () {
                              context
                                  .read<HomeBloc>()
                                  .add(GetEtaRequestEvent());
                            })
                      ],
                    ),
                  ),
                ),
              if (userData != null &&
                  (userData!.metaRequest != null ||
                      state is ShowAcceptRejectState))
                Positioned(bottom: 0, child: AcceptRejectWidget(cont: context)),
              if (homeBloc.choosenRide != null)
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                    child: Column(
                      children: [
                        if (homeBloc.choosenRide != null &&
                            homeBloc.isOutstationRide &&
                            homeBloc.outStationList.isNotEmpty)
                          OutstationRequestWidget(bloc: homeBloc),
                        if (homeBloc.choosenRide != null &&
                            homeBloc.isNormalBidRide &&
                            homeBloc.rideList.isNotEmpty)
                          BiddingRequestWidget(bloc: homeBloc),
                      ],
                    ),
                  ),
                ),
              if (userData != null &&
                  (userData!.onTripRequest != null &&
                      userData!.metaRequest == null))
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        DraggableScrollableSheet(
                          initialChildSize:
                              (userData?.onTripRequest!.arrivedAt == null)
                                  ? 0.32
                                  : 0.38, // Start at half screen
                          minChildSize:
                              (userData?.onTripRequest!.arrivedAt == null)
                                  ? 0.32
                                  : 0.38, // Minimum height
                          maxChildSize: 0.80,
                          builder: (BuildContext ctx,
                              ScrollController scrollController) {
                            return Container(
                              height: size.height,
                              width: size.width,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(30)),
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: (userData != null &&
                                        userData?.onTripRequest != null)
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(30)),
                                        child: OnRideWidget(cont: context),
                                      )
                                    : Container(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: OnrideCustomSliderButtonWidget(size: size),
                        ),
                      ],
                    ),
                  ),
                ),
              if (homeBloc.visibleOutStation && userData!.active)
                Positioned(child: BiddingOutStationListWidget(cont: context)),
              // bidding timer widget
              if (homeBloc.waitingList.isNotEmpty &&
                  !homeBloc.showOutstationWidget)
                Positioned(top: 0, child: BiddingTimerWidget(cont: context)),
              // Showing cancel reasons
              if (homeBloc.showCancelReason == true)
                Positioned(top: 0, child: CancelReasonWidget(cont: context)),
              // Showing signature field
              if (homeBloc.showSignature == true)
                Positioned(top: 0, child: SignatureGetWidget(cont: context)),
            ],
          );
        },
      ),
    );
  }
}

class _GoogleMapWidget extends StatelessWidget {
  const _GoogleMapWidget({
    required this.size,
    required this.homeBloc,
  });

  final Size size;
  final HomeBloc homeBloc;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      key: const PageStorageKey('goole_map'),
      padding: EdgeInsets.fromLTRB(
          size.width * 0.05,
          (homeBloc.choosenRide != null || homeBloc.showGetDropAddress)
              ? size.width * 0.15 + MediaQuery.paddingOf(context).top
              : size.width * 0.05 + MediaQuery.paddingOf(context).top,
          size.width * 0.05,
          (userData != null &&
                  (userData!.metaRequest != null ||
                      userData!.onTripRequest != null ||
                      homeBloc.choosenRide != null ||
                      homeBloc.showGetDropAddress))
              ? size.width
              : size.width * 0.05),
      gestureRecognizers: {
        Factory<PanGestureRecognizer>(
          () => PanGestureRecognizer(),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        homeBloc.googleMapController = controller;
        homeBloc.add(SetMapStyleEvent(context: context));
      },
      compassEnabled: false,
      initialCameraPosition: (homeBloc.initialCameraPosition != null)
          ? homeBloc.initialCameraPosition!
          : CameraPosition(
              target: homeBloc.currentLatLng ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
      onCameraMove: (CameraPosition position) {
        homeBloc.mapPoint = position.target;
      },
      onCameraIdle: () {
        if (homeBloc.showGetDropAddress &&
            homeBloc.mapPoint != null &&
            homeBloc.autoCompleteAddress.isEmpty &&
            homeBloc.polyline.isEmpty) {
          homeBloc.confirmPinAddress = true;
          homeBloc.add(UpdateEvent());
        } else if (homeBloc.showGetDropAddress &&
            homeBloc.mapPoint != null &&
            homeBloc.autoCompleteAddress.isNotEmpty &&
            !homeBloc.confirmPinAddress) {
          homeBloc.add(ClearAutoCompleteEvent());
        }
      },
      markers: Set<Marker>.from(homeBloc.markers),
      minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
      buildingsEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled:
          (userData != null && userData!.role == 'owner') ? true : false,
      myLocationButtonEnabled: false,
      polylines: homeBloc.polyline,
      polygons: (homeBloc.showPeakZones &&
              !homeBloc.showGetDropAddress &&
              homeBloc.polygons.isNotEmpty &&
              userData != null &&
              userData!.role != 'owner' &&
              userData!.enablePeakZoneFeature &&
              (userData!.metaRequest == null &&
                  userData!.onTripRequest == null))
          ? homeBloc.polygons
          : {},
    );
  }
}

class _AutoCompletionEmptyView extends StatelessWidget {
  final HomeBloc homeBloc;
  const _AutoCompletionEmptyView(this.homeBloc);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
        right: (homeBloc.textDirection == 'rtl') ? null : size.width * 0.05,
        left: (homeBloc.textDirection == 'ltr') ? null : size.width * 0.05,
        bottom: (userData != null &&
                homeBloc.showGetDropAddress == false &&
                userData!.metaRequest == null &&
                userData!.onTripRequest == null &&
                userData!.role == 'driver')
            ? size.width * 0.75
            : size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (userData != null &&
                userData!.metaRequest == null &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.isTripStart == 1)
              SosWidget(cont: context),
            if (userData != null &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.sharedRide == true) ...[
              SizedBox(height: size.width * 0.025),
              SizedBox(
                width: size.width,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.09),
                    child: _AcceptedRidesButton(cont: context),
                  ),
                ),
              ),
            ],
            if (userData != null &&
                userData!.metaRequest == null &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.acceptedAt != null &&
                userData!.onTripRequest!.dropAddress != null &&
                userData!.onTripRequest!.requestStops.isEmpty)
              NavigationWidget(cont: context),
            SizedBox(height: size.width * 0.025),
            if (!homeBloc.showGetDropAddress &&
                userData != null &&
                userData!.role != 'owner' &&
                userData!.active &&
                userData!.available &&
                userData!.enablePeakZoneFeature &&
                (userData!.metaRequest == null &&
                    userData!.onTripRequest == null) &&
                homeBloc.showPeakZoneButton)
              PeakZoneWidget(cont: context),
            SizedBox(height: size.width * 0.025),
            LocateMeWidget(cont: context),
          ],
        ));
  }
}

class _AcceptedRidesButton extends StatelessWidget {
  final BuildContext cont;
  const _AcceptedRidesButton({required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = cont.read<HomeBloc>();
    return Container(
      margin: EdgeInsets.only(right: size.width * 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          homeBloc.add(GetUserDetailsEvent());
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => BlocProvider.value(
              value: homeBloc,
              child: const _AcceptedRidesSheet(),
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
          alignment: Alignment.center,
          child: Icon(
            Icons.people_alt,
            size: size.width * 0.06,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }
}

class _AcceptedRidesSheet extends StatefulWidget {
  const _AcceptedRidesSheet();
  @override
  State<_AcceptedRidesSheet> createState() => _AcceptedRidesSheetState();
}

class _AcceptedRidesSheetState extends State<_AcceptedRidesSheet> {
  late Future<List<Map<String, dynamic>>> _onTripFuture;

  @override
  void initState() {
    super.initState();
    _onTripFuture = _fetchOnTripRides();
  }

  Future<List<Map<String, dynamic>>> _fetchOnTripRides() async {
    final resp = await AccApi().getHistoryApi('on_trip=1', pageNo: '1');
    final data = resp.data;
    final List rides =
        (data is Map && data['data'] is List) ? data['data'] : [];
    final onGoingRides = rides.where((ride) {
      final isCompleted =
          ride['is_completed'] == 1 || ride['is_completed'] == true;
      final isCancelled =
          ride['is_cancelled'] == 1 || ride['is_cancelled'] == true;
      return !isCompleted && !isCancelled;
    }).toList();

    return onGoingRides.map<Map<String, dynamic>>((raw) {
      final user =
          (raw['userDetail'] != null && raw['userDetail']['data'] != null)
              ? raw['userDetail']['data']
              : {};
      return {
        'is_current': true,
        'request_id':
            raw['request_number']?.toString() ?? raw['id']?.toString() ?? '',
        'user_name': user['name']?.toString() ?? 'Unknown',
        'user_img': user['profile_picture']?.toString() ?? '',
        'ratings': (user['rating'] != null) ? user['rating'].toString() : null,
        'completed_ride_count': user['completed_ride_count'],
        'currency': raw['requested_currency_symbol']?.toString() ?? '',
        'price': (raw['request_eta_amount'] != null)
            ? raw['request_eta_amount'].toString()
            : '',
        'pick_address': raw['pick_address']?.toString() ?? '',
        'drop_address': raw['drop_address']?.toString() ?? '',
        'transport_type': raw['transport_type']?.toString() ?? '',
        'goods': raw['goods_type']?.toString() ?? '',
        'is_out_station':
            (raw['is_out_station'] == 1 || raw['is_out_station'] == true),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // final homeBloc = context.read<HomeBloc>();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: size.width * 0.05,
          right: size.width * 0.05,
          top: size.width * 0.04,
          bottom: MediaQuery.viewInsetsOf(context).bottom + size.width * 0.05,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _onTripFuture,
          builder: (context, snapshot) {
            final rides = snapshot.data ?? [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.onGoingRides,
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (snapshot.connectionState == ConnectionState.done)
                          MyText(
                            text:
                                '${userData?.occupiedSeats} ${AppLocalizations.of(context)!.seatsTaken}',
                            textStyle:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.02),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Center(
                      child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: const CircularProgressIndicator(),
                  ))
                else if (snapshot.hasError)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).cardColor,
                    ),
                    child: MyText(
                      text: 'Failed to load rides',
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else if (rides.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).cardColor,
                    ),
                    child: MyText(
                      text: 'No accepted rides',
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else ...[
                  if (rides.length > 1)
                    Container(
                      padding: EdgeInsets.all(size.width * 0.03),
                      margin: EdgeInsets.only(bottom: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: size.width * 0.045,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: MyText(
                              text:
                                  ' ${AppLocalizations.of(context)!.activeRidesMessage.replaceAll('2', '${rides.length}')}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rides.map((ride) {
                          final current = userData?.onTripRequest;
                          final String id =
                              ride['request_id']?.toString() ?? '';
                          final String reqNum =
                              ride['request_number']?.toString() ?? '';
                          final bool isSelected = current != null &&
                              (id == current.id ||
                                  id == current.requestNumber ||
                                  reqNum == current.requestNumber);
                          return InkWell(
                            onTap: () {
                              final bloc = context.read<HomeBloc>();
                              bloc.add(SelectOnTripRideEvent(
                                  requestId: id.isNotEmpty ? id : reqNum));
                              Navigator.of(context).pop();
                            },
                            child: _buildRideCard(
                                context, size, ride, true, isSelected),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, Size size,
      Map<String, dynamic> ride, bool isCurrent, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.03),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection/status badge
          if (isSelected)
            Container(
              margin: EdgeInsets.only(bottom: size.width * 0.02),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.025,
                vertical: size.width * 0.01,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: size.width * 0.035,
                    color: Colors.white,
                  ),
                  SizedBox(width: size.width * 0.01),
                  MyText(
                    text: AppLocalizations.of(context)!.currentTrip,
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          // Header with user info and price
          Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.05,
                backgroundImage: (ride['user_img'] != null &&
                        ride['user_img'].toString().isNotEmpty)
                    ? NetworkImage(ride['user_img'])
                    : null,
                child: (ride['user_img'] == null ||
                        ride['user_img'].toString().isEmpty)
                    ? Icon(Icons.person, size: size.width * 0.05)
                    : null,
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: ride['user_name']?.toString() ?? 'Unknown',
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: 1,
                    ),
                    if (ride['ratings'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: size.width * 0.035,
                            color: Colors.amber,
                          ),
                          SizedBox(width: size.width * 0.01),
                          MyText(
                            text: ride['ratings'].toString(),
                            textStyle: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyText(
                    text: '${ride['currency']} ${ride['price']}',
                    textStyle:
                        Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.width * 0.025),

          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: size.width * 0.025),

          // Pickup location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.trip_origin,
                size: size.width * 0.04,
                color: Colors.green,
              ),
              SizedBox(width: size.width * 0.02),
              Expanded(
                child: MyText(
                  text: ride['pick_address']?.toString() ?? 'N/A',
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                ),
              ),
            ],
          ),

          // Drop location
          if (ride['drop_address'] != null &&
              ride['drop_address'].toString().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: size.width * 0.025),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: size.width * 0.04,
                    color: Colors.red,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: MyText(
                      text: ride['drop_address'].toString(),
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RideView extends StatelessWidget {
  final HomeBloc homeBloc;
  const _RideView(this.homeBloc);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + size.width * 0.05,
      left: size.width * 0.05,
      child: Container(
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
          onTap: () {
            homeBloc.add(RemoveChoosenRideEvent());
          },
          child: Container(
            height: size.width * 0.1,
            width: size.width * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back,
              size: size.width * 0.07,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoSuggestionView extends StatelessWidget {
  const _AutoSuggestionView();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      child: AutoSearchPlacesWidget(cont: context),
    );
  }
}

class _ConfirmPinAddressView extends StatelessWidget {
  final HomeBloc homeBloc;
  const _ConfirmPinAddressView(this.homeBloc);

  @override
  Widget build(BuildContext context1) {
    final size = MediaQuery.sizeOf(context1);
    return Positioned(
      // top: (size.height - size.width) / 2,
      top: size.width * 0.23 + MediaQuery.paddingOf(context1).top,
      right: size.width * 0.38,
      child: Container(
        height: size.height * 0.8,
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.only(bottom: size.width * 0.6 + 25),
            child: Row(
              children: [
                CustomButton(
                    height: size.width * 0.08,
                    width: size.width * 0.25,
                    onTap: () {
                      homeBloc.confirmPinAddress = false;
                      homeBloc.add(UpdateEvent());
                      if (homeBloc.mapPoint != null) {
                        homeBloc.add(GeocodingLatLngEvent(
                            lat: homeBloc.mapPoint!.latitude,
                            lng: homeBloc.mapPoint!.longitude));
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
        top: size.height * 0.4,
        child: Center(
          child: SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AvatarGlow(
                    glowRadiusFactor: 1.0,
                    glowColor: AppColors.primary,
                    child: Container(
                      margin: EdgeInsets.only(bottom: size.width * 0.075),
                      child: Image.asset(
                        AppImages.pickupIcon,
                        width: size.width * 0.12,
                        height: size.width * 0.12,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}

class _FlutterMapWidget extends StatelessWidget {
  final HomeBloc homeBloc;
  const _FlutterMapWidget(this.homeBloc);

  @override
  Widget build(BuildContext context1) {
    return fm.FlutterMap(
      mapController: homeBloc.fmController,
      options: fm.MapOptions(
          onMapEvent: (v) {
            if (v.source == fm.MapEventSource.dragEnd ||
                v.source == fm.MapEventSource.mapController) {
              if (homeBloc.showGetDropAddress &&
                  homeBloc.autoCompleteAddress.isEmpty &&
                  homeBloc.fmpoly.isEmpty) {
                homeBloc.add(GeocodingLatLngEvent(
                    lat: v.camera.center.latitude,
                    lng: v.camera.center.longitude));
              } else if (homeBloc.showGetDropAddress &&
                  homeBloc.mapPoint != null &&
                  homeBloc.autoCompleteAddress.isNotEmpty) {
                homeBloc.add(ClearAutoCompleteEvent());
              }
            }
          },
          initialCenter: fmlt.LatLng(homeBloc.currentLatLng!.latitude,
              homeBloc.currentLatLng!.longitude),
          initialZoom: 16,
          onTap: (P, L) {}),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: AppConstants.packageName,
        ),
        if (homeBloc.showPeakZones &&
            !homeBloc.showGetDropAddress &&
            homeBloc.polygons.isNotEmpty &&
            userData != null &&
            userData!.role != 'owner' &&
            (userData!.metaRequest == null && userData!.onTripRequest == null))
          fm.PolygonLayer(
            polygons: List.generate(
              homeBloc.polygons.length,
              (index) {
                return fm.Polygon(
                    points: List.generate(
                      homeBloc.polygons.elementAt(index).points.length,
                      (ind) {
                        return fmlt.LatLng(
                            homeBloc.polygons
                                .elementAt(index)
                                .points
                                .elementAt(ind)
                                .latitude,
                            homeBloc.polygons
                                .elementAt(index)
                                .points
                                .elementAt(ind)
                                .longitude);
                      },
                    ),
                    color: Colors.red.withAlpha((0.2 * 255).toInt()),
                    borderStrokeWidth: 2,
                    borderColor: Colors.red);
              },
            ),
          ),
        if (homeBloc.fmpoly.isNotEmpty)
          fm.PolylineLayer(
            polylines: [
              fm.Polyline(
                  points: homeBloc.fmpoly,
                  color: Theme.of(context1).primaryColor,
                  strokeWidth: 4),
            ],
          ),
        if (userData != null && userData!.role == 'owner')
          fm.MarkerLayer(
            markers: List.generate(homeBloc.markers.length, (index) {
              final marker = homeBloc.markers.elementAt(index);
              return fm.Marker(
                point: fmlt.LatLng(
                    marker.position.latitude, marker.position.longitude),
                alignment: Alignment.topCenter,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(marker.rotation / 360),
                  child: Image.asset(
                    (marker.markerId.value
                                .toString()
                                .replaceAll('MarkerId(', '')
                                .replaceAll(')', '')
                                .split('_')[3] ==
                            'car')
                        ? (marker.markerId.value
                                    .toString()
                                    .replaceAll('MarkerId(', '')
                                    .replaceAll(')', '')
                                    .split('_')[2] ==
                                '1')
                            ? AppImages.carOnline
                            : (marker.markerId.value
                                        .toString()
                                        .replaceAll('MarkerId(', '')
                                        .replaceAll(')', '')
                                        .split('_')[2] ==
                                    '2')
                                ? AppImages.carOffline
                                : AppImages.carOnride
                        : (marker.markerId.value
                                    .toString()
                                    .replaceAll('MarkerId(', '')
                                    .replaceAll(')', '')
                                    .split('_')[3] ==
                                'motor_bike')
                            ? (marker.markerId.value
                                        .toString()
                                        .replaceAll('MarkerId(', '')
                                        .replaceAll(')', '')
                                        .split('_')[2] ==
                                    '1')
                                ? AppImages.bikeOnline
                                : (marker.markerId.value
                                            .toString()
                                            .replaceAll('MarkerId(', '')
                                            .replaceAll(')', '')
                                            .split('_')[2] ==
                                        '2')
                                    ? AppImages.bikeOffline
                                    : AppImages.bikeOnride
                            : (marker.markerId.value
                                        .toString()
                                        .replaceAll('MarkerId(', '')
                                        .replaceAll(')', '')
                                        .split('_')[2] ==
                                    '1')
                                ? AppImages.deliveryOnline
                                : (marker.markerId.value
                                            .toString()
                                            .replaceAll('MarkerId(', '')
                                            .replaceAll(')', '')
                                            .split('_')[2] ==
                                        '2')
                                    ? AppImages.deliveryOffline
                                    : AppImages.deliveryOnride,
                    width: 16,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    },
                  ),
                ),
              );
            }),
          ),
        if (userData != null && userData!.role != 'owner')
          fm.MarkerLayer(markers: [
            if (homeBloc.currentLatLng != null)
              fm.Marker(
                point: fmlt.LatLng(homeBloc.currentLatLng!.latitude,
                    homeBloc.currentLatLng!.longitude),
                alignment: Alignment.topCenter,
                child: Image.asset(
                  (userData!.vehicleTypeIcon.toString().contains('truck'))
                      ? AppImages.truck
                      : userData!.vehicleTypeIcon
                              .toString()
                              .contains('motor_bike')
                          ? AppImages.bikeOffline
                          : userData!.vehicleTypeIcon
                                  .toString()
                                  .contains('auto')
                              ? AppImages.auto
                              : userData!.vehicleTypeIcon
                                      .toString()
                                      .contains('lcv')
                                  ? AppImages.lcv
                                  : userData!.vehicleTypeIcon
                                          .toString()
                                          .contains('ehcv')
                                      ? AppImages.ehcv
                                      : userData!.vehicleTypeIcon
                                              .toString()
                                              .contains('hatchback')
                                          ? AppImages.hatchBack
                                          : userData!.vehicleTypeIcon
                                                  .toString()
                                                  .contains('hcv')
                                              ? AppImages.hcv
                                              : userData!.vehicleTypeIcon
                                                      .toString()
                                                      .contains('mcv')
                                                  ? AppImages.mcv
                                                  : userData!.vehicleTypeIcon
                                                          .toString()
                                                          .contains('luxury')
                                                      ? AppImages.luxury
                                                      : userData!
                                                              .vehicleTypeIcon
                                                              .toString()
                                                              .contains(
                                                                  'premium')
                                                          ? AppImages.premium
                                                          : userData!
                                                                  .vehicleTypeIcon
                                                                  .toString()
                                                                  .contains(
                                                                      'suv')
                                                              ? AppImages.suv
                                                              : (userData!
                                                                      .vehicleTypeIcon
                                                                      .toString()
                                                                      .contains(
                                                                          'car'))
                                                                  ? AppImages
                                                                      .car
                                                                  : '',
                  width: 16,
                  height: 30,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox();
                  },
                ),
              ),
            if ((userData != null && userData!.metaRequest != null) ||
                (userData != null && userData!.onTripRequest != null))
              (userData != null && userData!.metaRequest != null)
                  ? fm.Marker(
                      width: 100,
                      height: 20,
                      alignment: Alignment.topCenter,
                      point: fmlt.LatLng(userData!.metaRequest!.pickLat,
                          userData!.metaRequest!.pickLng),
                      child: Image.asset(
                        AppImages.pickupIcon,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    )
                  : fm.Marker(
                      width: 100,
                      height: 30,
                      alignment: Alignment.topCenter,
                      point: fmlt.LatLng(userData!.onTripRequest!.pickLat,
                          userData!.onTripRequest!.pickLng),
                      child: Image.asset(
                        AppImages.pickupIcon,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
            if ((userData != null &&
                    userData!.metaRequest != null &&
                    userData!.metaRequest!.dropAddress != null &&
                    userData!.metaRequest!.requestStops.isEmpty) ||
                (userData != null &&
                    userData!.onTripRequest != null &&
                    userData!.onTripRequest!.dropAddress != null &&
                    userData!.onTripRequest!.requestStops.isEmpty))
              (userData != null &&
                      userData!.metaRequest != null &&
                      userData!.metaRequest!.dropAddress != null)
                  ? fm.Marker(
                      width: 100,
                      height: 30,
                      alignment: Alignment.topCenter,
                      point: fmlt.LatLng(userData!.metaRequest!.dropLat!,
                          userData!.metaRequest!.dropLng!),
                      child: Image.asset(
                        AppImages.dropIcon,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    )
                  : fm.Marker(
                      width: 100,
                      height: 30,
                      alignment: Alignment.topCenter,
                      point: fmlt.LatLng(userData!.onTripRequest!.dropLat!,
                          userData!.onTripRequest!.dropLng!),
                      child: Image.asset(
                        AppImages.dropIcon,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
            if ((userData != null &&
                userData!.metaRequest != null &&
                userData!.metaRequest!.requestStops.isNotEmpty))
              for (var i = 0;
                  i < userData!.metaRequest!.requestStops.length;
                  i++)
                fm.Marker(
                  width: 100,
                  height: 30,
                  alignment: Alignment.center,
                  point: fmlt.LatLng(
                      userData!.metaRequest!.requestStops[i]['latitude'],
                      userData!.metaRequest!.requestStops[i]['longitude']),
                  child: Image.asset(
                    (i == 0)
                        ? AppImages.stopOne
                        : (i == 1)
                            ? AppImages.stopTwo
                            : (i == 2)
                                ? AppImages.stopThree
                                : AppImages.stopFour,
                    height: 15,
                    width: 15,
                    fit: BoxFit.contain,
                  ),
                ),
            if (userData != null &&
                userData!.onTripRequest != null &&
                userData!.onTripRequest!.requestStops.isNotEmpty)
              for (var i = 0;
                  i < userData!.onTripRequest!.requestStops.length;
                  i++)
                fm.Marker(
                  width: 100,
                  height: 30,
                  alignment: Alignment.center,
                  point: fmlt.LatLng(
                      userData!.onTripRequest!.requestStops[i]['latitude'],
                      userData!.onTripRequest!.requestStops[i]['longitude']),
                  child: Image.asset(
                    (i == 0)
                        ? AppImages.stopOne
                        : (i == 1)
                            ? AppImages.stopTwo
                            : (i == 2)
                                ? AppImages.stopThree
                                : AppImages.stopFour,
                    height: 15,
                    width: 15,
                    fit: BoxFit.contain,
                  ),
                ),
          ]),
        if (userData != null &&
            userData!.role != 'owner' &&
            ((userData != null && userData!.metaRequest != null) ||
                (userData != null && userData!.onTripRequest != null)) &&
            homeBloc.markers.any((element) =>
                element.markerId.value.toString().contains('distance')))
          fm.MarkerLayer(
            markers: List.generate(1, (index) {
              final marker = homeBloc.markers.firstWhere((element) =>
                  element.markerId.value.toString().contains('distance'));
              return fm.Marker(
                point: fmlt.LatLng(
                    marker.position.latitude, marker.position.longitude),
                alignment: Alignment.bottomCenter,
                height: 50,
                width: 100,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(
                    ((marker.rotation.isNaN || marker.rotation.isInfinite)
                            ? 0.0
                            : marker.rotation) /
                        360,
                  ),
                  child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(color: AppColors.primary, width: 1)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5)),
                                  color: AppColors.primary),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyText(
                                    text: homeBloc.fmDistance,
                                    textStyle: AppTextStyle.normalStyle()
                                        .copyWith(
                                            color: ThemeData.light()
                                                .scaffoldBackgroundColor,
                                            fontSize: 12),
                                  ),
                                  MyText(
                                    text: userData!.distanceUnit,
                                    textStyle: AppTextStyle.normalStyle()
                                        .copyWith(
                                            color: ThemeData.light()
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
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomRight: Radius.circular(5)),
                                    color: ThemeData.light()
                                        .scaffoldBackgroundColor),
                                child: MyText(
                                  text: ((homeBloc.fmDuration) > 60)
                                      ? '${(homeBloc.fmDuration / 60).toStringAsFixed(1)} hrs'
                                      : '${homeBloc.fmDuration.toStringAsFixed(0)} mins',
                                  textStyle: AppTextStyle.normalStyle()
                                      .copyWith(
                                          color: AppColors.primary,
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
    );
  }
}
