// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../bookingpage/presentation/page/booking/page/booking_page.dart';
import '../../../bookingpage/presentation/page/invoice/page/invoice_page.dart';
import '../../../loading/application/loader_bloc.dart';
import '../../application/home_bloc.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../domain/models/stop_address_model.dart';
import '../widgets/get_location_permission.dart';
import '../widgets/home_body_widget.dart';
import '../widgets/home_page_shimmer.dart';
import '../widgets/send_receive_delivery.dart';
import 'confirm_location_page.dart';
import 'destination_page.dart';
import 'on_going_rides.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (HomeBloc().nearByVechileSubscription != null) {
        HomeBloc().nearByVechileSubscription?.pause();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (HomeBloc().nearByVechileSubscription != null) {
        HomeBloc().nearByVechileSubscription?.resume();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (HomeBloc().nearByVechileSubscription != null) {
      HomeBloc().nearByVechileSubscription?.cancel();
      HomeBloc().nearByVechileSubscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return builderWidget(size);
  }

  Widget builderWidget(Size size) {
    return BlocProvider(
      create: (context) => HomeBloc()
        ..add(GetDirectionEvent())
        ..add(GetRideModulesEvent())
        ..add(GetUserDetailsEvent()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          final homeBloc = context.read<HomeBloc>();
          if (state is VechileStreamMarkerState) {
            if (homeBloc.nearByVechileSubscription == null) {
              homeBloc.nearByVechileCheckStream(context, this);
            }
          } else if (state is UpdateZoneLocationState) {
            if (homeBloc.mapType == 'google_map') {
              context.read<LoaderBloc>().add(GoogleUpdateUserLocationEvent());
            } else {
              context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            }
          } else if (state is LogoutState) {
            if (homeBloc.nearByVechileSubscription != null) {
              homeBloc.nearByVechileSubscription?.cancel();
              homeBloc.nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
                context, LoginPage.routeName, (route) => false);
            await AppSharedPreference.setLoginStatus(false);
          } else if (state is GetLocationPermissionState) {
            showDialog(
              context: context,
              builder: (_) {
                return GetLocationPermissionWidget(cont: context);
              },
            );
          } else if (state is NavigateToOnGoingRidesPageState) {
            Navigator.pushNamed(context, OnGoingRidesPage.routeName,
                    arguments: OnGoingRidesPageArguments(
                        userData: homeBloc.userData!,
                        mapType: homeBloc.mapType))
                .then(
              (value) {
                if (!context.mounted) return;
                homeBloc.add(GetUserDetailsEvent());
              },
            );
          } else if (state is UserOnTripState &&
              state.tripData.acceptedAt == '') {
            if (homeBloc.nearByVechileSubscription != null) {
              homeBloc.nearByVechileSubscription?.cancel();
              homeBloc.nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              BookingPage.routeName,
              (route) => false,
              arguments: BookingPageArguments(
                picklat: state.tripData.pickLat,
                picklng: state.tripData.pickLng,
                droplat: state.tripData.dropLat,
                droplng: state.tripData.dropLng,
                pickupAddressList: homeBloc.pickupAddressList,
                stopAddressList: homeBloc.stopAddressList,
                userData: homeBloc.userData!,
                transportType: state.tripData.transportType,
                polyString: state.tripData.polyLine,
                distance: (double.parse(state.tripData.totalDistance) * 1000)
                    .toString(),
                duration: state.tripData.totalTime.toString(),
                isRentalRide: state.tripData.isRental,
                isWithoutDestinationRide: ((state.tripData.dropLat.isEmpty &&
                            state.tripData.dropLng.isEmpty) &&
                        !state.tripData.isRental)
                    ? true
                    : false,
                isOutstationRide: state.tripData.isOutStation == "1",
                mapType: homeBloc.mapType,
              ),
            );
          } else if (state is DeliverySelectState) {
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: false,
              isScrollControlled: true,
              builder: (_) {
                return SendOrReceiveDelivery(cont: context);
              },
            );
          } else if (state is DestinationSelectState) {
            Navigator.pushNamed(
              context,
              DestinationPage.routeName,
              arguments: DestinationPageArguments(
                  title: 'Taxi',
                  pickupAddress: homeBloc.currentLocation,
                  pickupLatLng: homeBloc.currentLatLng,
                  dropAddress: state.dropAddress,
                  dropLatLng: state.dropLatLng,
                  userData: homeBloc.userData!,
                  pickUpChange: state.isPickupChange,
                  transportType: state.transportType,
                  isOutstationRide: false,
                  mapType: homeBloc.mapType),
            );
          } else if (state is OutStationSelectState) {
            Navigator.pushNamed(
              context,
              DestinationPage.routeName,
              arguments: DestinationPageArguments(
                title: homeBloc.selectedServiceType!.transportType == 'taxi'
                    ? 'Taxi'
                    : 'Delivery',
                pickupAddress: homeBloc.currentLocation,
                pickupLatLng: homeBloc.currentLatLng,
                userData: homeBloc.userData!,
                pickUpChange: false,
                transportType: homeBloc.transportType,
                isOutstationRide: true,
                mapType: homeBloc.mapType,
              ),
            );
          } else if (state is ConfirmRideAddressState ||
              state is RecentSearchPlaceSelectState) {
            if (homeBloc.pickupAddressList.isNotEmpty &&
                homeBloc.stopAddressList.length == 1) {
              if (homeBloc.nearByVechileSubscription != null) {
                homeBloc.nearByVechileSubscription?.cancel();
                homeBloc.nearByVechileSubscription = null;
              }
              Navigator.pushNamed(
                context,
                BookingPage.routeName,
                arguments: BookingPageArguments(
                    picklat: context
                        .read<HomeBloc>()
                        .pickupAddressList
                        .first
                        .lat
                        .toString(),
                    picklng: context
                        .read<HomeBloc>()
                        .pickupAddressList
                        .first
                        .lng
                        .toString(),
                    droplat: context
                        .read<HomeBloc>()
                        .stopAddressList
                        .last
                        .lat
                        .toString(),
                    droplng: context
                        .read<HomeBloc>()
                        .stopAddressList
                        .last
                        .lng
                        .toString(),
                    userData: homeBloc.userData!,
                    transportType: (state is RecentSearchPlaceSelectState)
                        ? state.transportType
                        : homeBloc.transportType,
                    pickupAddressList: homeBloc.pickupAddressList,
                    stopAddressList: homeBloc.stopAddressList,
                    polyString: '',
                    distance: '',
                    duration: '',
                    isOutstationRide: false,
                    mapType: homeBloc.mapType),
              ).then(
                (value) {
                  if (!context.mounted) return;
                  homeBloc.stopAddressList.clear();
                },
              );
            } else {
              homeBloc.stopAddressList.clear();
            }
          } else if (state is RentalSelectState) {
            Navigator.pushNamed(context, ConfirmLocationPage.routeName,
                arguments: ConfirmLocationPageArguments(
                  userData: homeBloc.userData!,
                  isPickupEdit: true,
                  isOutstationRide: false,
                  isEditAddress: false,
                  mapType: homeBloc.mapType,
                  // transportType: '',
                  transportType: homeBloc.transportType,
                )).then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  if (homeBloc.nearByVechileSubscription != null) {
                    homeBloc.nearByVechileSubscription?.cancel();
                    homeBloc.nearByVechileSubscription = null;
                  }
                  homeBloc.pickupAddressList.clear();
                  final add = value as AddressModel;
                  homeBloc.pickupAddressList.add(add);
                  Navigator.pushNamed(
                    context,
                    BookingPage.routeName,
                    arguments: BookingPageArguments(
                        picklat: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lat
                            .toString(),
                        picklng: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lng
                            .toString(),
                        droplat: '',
                        droplng: '',
                        userData: homeBloc.userData!,
                        transportType: homeBloc.transportType,
                        pickupAddressList: homeBloc.pickupAddressList,
                        stopAddressList: [],
                        polyString: '',
                        distance: '',
                        duration: '',
                        mapType: homeBloc.mapType,
                        isOutstationRide: false,
                        isRentalRide: true),
                  );
                }
              },
            );
          } else if (state is RideWithoutDestinationState) {
            Navigator.pushNamed(context, ConfirmLocationPage.routeName,
                arguments: ConfirmLocationPageArguments(
                  userData: homeBloc.userData!,
                  isPickupEdit: true,
                  isEditAddress: false,
                  isOutstationRide: false,
                  mapType: homeBloc.mapType,
                  transportType: homeBloc.transportType,
                )).then(
              (value) {
                if (!context.mounted) return;
                if (value != null) {
                  if (homeBloc.nearByVechileSubscription != null) {
                    homeBloc.nearByVechileSubscription?.cancel();
                    homeBloc.nearByVechileSubscription = null;
                  }
                  homeBloc.pickupAddressList.clear();
                  final add = value as AddressModel;
                  homeBloc.pickupAddressList.add(add);
                  Navigator.pushNamed(
                    context,
                    BookingPage.routeName,
                    arguments: BookingPageArguments(
                        picklat: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lat
                            .toString(),
                        picklng: context
                            .read<HomeBloc>()
                            .pickupAddressList[0]
                            .lng
                            .toString(),
                        droplat: '',
                        droplng: '',
                        userData: homeBloc.userData!,
                        transportType: 'taxi',
                        pickupAddressList: homeBloc.pickupAddressList,
                        stopAddressList: [],
                        polyString: '',
                        distance: '',
                        duration: '',
                        mapType: homeBloc.mapType,
                        isRentalRide: false,
                        isOutstationRide: false,
                        isWithoutDestinationRide: true),
                  );
                }
              },
            );
          } else if (state is UserOnTripState) {
            if (homeBloc.nearByVechileSubscription != null) {
              homeBloc.nearByVechileSubscription?.cancel();
              homeBloc.nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
                context, BookingPage.routeName, (route) => false,
                arguments: BookingPageArguments(
                    picklat: state.tripData.pickLat,
                    picklng: state.tripData.pickLng,
                    droplat: state.tripData.dropLat,
                    droplng: state.tripData.dropLng,
                    pickupAddressList: homeBloc.pickupAddressList,
                    stopAddressList: homeBloc.stopAddressList,
                    userData: homeBloc.userData!,
                    transportType: state.tripData.transportType,
                    polyString: state.tripData.polyLine,
                    distance:
                        (double.parse(state.tripData.totalDistance) * 1000)
                            .toString(),
                    duration: state.tripData.totalTime.toString(),
                    requestId: state.tripData.id,
                    mapType: homeBloc.mapType,
                    isOutstationRide: state.tripData.isOutStation == "1"));
          } else if (state is UserTripSummaryState) {
            if (homeBloc.nearByVechileSubscription != null) {
              homeBloc.nearByVechileSubscription?.cancel();
              homeBloc.nearByVechileSubscription = null;
            }
            Navigator.pushNamedAndRemoveUntil(
              context,
              InvoicePage.routeName,
              (route) => false,
              arguments: InvoicePageArguments(
                  requestData: state.requestData,
                  requestBillData: state.requestBillData,
                  driverData: state.driverData,
                  rideRepository: state.rideRepository),
            );
          } else if (state is ServiceNotAvailableState) {
            homeBloc.stopAddressList.clear();
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                          alignment: homeBloc.textDirection == 'rtl'
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.cancel_outlined,
                                  color: Theme.of(context).primaryColor))),
                      Center(
                        child: MyText(text: state.message, maxLines: 4),
                      ),
                    ],
                  ),
                  actions: [
                    Center(
                      child: CustomButton(
                        buttonName: AppLocalizations.of(context)!.okText,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                );
              },
            );
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final homeBloc = context.read<HomeBloc>();
            if (homeBloc.mapType == 'google_map') {
              if (Theme.of(context).brightness == Brightness.dark) {
                if (homeBloc.googleMapController != null) {
                  if (context.mounted) {
                    homeBloc.googleMapController!
                        .setMapStyle(homeBloc.darkMapString);
                  }
                }
              } else {
                if (homeBloc.googleMapController != null) {
                  if (context.mounted) {
                    homeBloc.googleMapController!
                        .setMapStyle(homeBloc.lightMapString);
                  }
                }
              }
            }

            return PopScope(
              canPop: true,
              child: Directionality(
                textDirection: homeBloc.textDirection == 'rtl'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Scaffold(
                  body: (homeBloc.userData != null &&
                          ((homeBloc.userData!.onTripRequest == null ||
                                  homeBloc.userData!.onTripRequest == "") ||
                              (homeBloc.userData!.metaRequest == null ||
                                  homeBloc.userData!.metaRequest == "")))
                      ? HomeBodyWidget(home: homeBloc)
                      : HomePageShimmer(size: size),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
