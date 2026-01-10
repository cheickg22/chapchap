import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/features/home/presentation/pages/invoice_page/page/invoice_page.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/map_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../../core/services/bubble_service.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../account/presentation/pages/account_page.dart';
import '../../../../../account/presentation/pages/earnings/page/earnings_page.dart';
import '../../../../../account/presentation/pages/leaderboard/page/leaderboard_page.dart';
import '../../../../../account/presentation/pages/dashboard/page/owner_dashboard.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../../application/home_bloc.dart';
import '../../../../../../common/common.dart';
import '../widget/bottom_navigationbar_widget.dart';
import '../widget/high_demand_area_widget.dart';
import '../widget/on_ride/additional_charge_widget.dart';
import '../widget/on_ride/chat_page_widget.dart';
import '../widget/instand_ride/instant_ride_details.dart';
import '../widget/my_service_types.dart';
import '../widget/on_ride/ride_otp_widget.dart';
import '../widget/instand_ride/select_goods_type.dart';
import '../widget/on_ride/show_stops_widget.dart';
import '../widget/show_subscription_widget.dart';
import '../widget/on_ride/upload_shipment_proof.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homePage';
  final HomePageArguments? args;
  const HomePage({super.key, this.args});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (showBubbleIcon && Platform.isAndroid) {
        if (userData != null && userData!.active) {
          HomeBloc().startBubbleHead();
        }
      }
      if (HomeBloc().rideStream != null) {
        HomeBloc().rideStream?.pause();
      }
      if (HomeBloc().rideAddStream != null) {
        HomeBloc().rideAddStream?.pause();
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (showBubbleIcon && Platform.isAndroid) {
        HomeBloc().stopBubbleHead();
      }
      if (HomeBloc().rideStream != null) {
        HomeBloc().rideStream?.resume();
      }
      if (HomeBloc().rideAddStream != null) {
        HomeBloc().rideAddStream?.resume();
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
    HomeBloc().rideStream?.cancel();
    HomeBloc().requestStream?.cancel();
    HomeBloc().rideAddStream?.cancel();
    HomeBloc().bidRequestStream?.cancel();
    HomeBloc().googleMapController?.dispose();
    HomeBloc().animationController?.dispose();
    HomeBloc().ownersDriver?.cancel();
    HomeBloc().fmController.dispose();
    HomeBloc().searchController.dispose();
    HomeBloc().pickupAddressController.dispose();
    HomeBloc().reviewController.dispose();
    HomeBloc().dropAddressController.dispose();
    HomeBloc().rideOtp.dispose();
    HomeBloc().chatField.dispose();
    HomeBloc().cancelReasonText.dispose();
    HomeBloc().bidRideAmount.dispose();
    HomeBloc().outstationRideAmount.dispose();
    HomeBloc().instantUserName.dispose();
    HomeBloc().instantUserMobile.dispose();
    HomeBloc().pricePerDistance.dispose();
    HomeBloc().goodsSizeText.dispose();
    HomeBloc().rideRepository.dispose();
    HomeBloc().chatScrollController.dispose();
    HomeBloc().currentPosition?.cancel();
    HomeBloc().waitingTimer?.cancel();
    HomeBloc().biddingRideTimer?.cancel();
    HomeBloc().activeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return builderWidget(size);
  }

  Widget builderWidget(Size size) {
    return BlocProvider(
      create: (context) => HomeBloc()
        ..add(GetDirectionEvent(vsync: this))
        ..add(GetUserDetailsEvent())
        ..add(GetPreferencesDetailsEvent()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          final homeBloc = context.read<HomeBloc>();
          if (state is HomeDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is HomeDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          } else if (state is GetLocationPermissionState) {
            showDialog(
              context: context,
              builder: (_) {
                return showGetLocationPermissionDialog(context, homeBloc);
              },
            );
          } else if (state is GetOverlayPermissionState) {
            homeBloc.isOverlayAllowClicked = false;
            showDialog(
              context: context,
              builder: (_) {
                return showGetOverlayPermissionDialog(context, homeBloc);
              },
            ).then(
              (value) async {
                if (Platform.isAndroid) {
                  final perm1 = await NativeService().checkPermission();
                  if (perm1) {
                    AppSharedPreference.setBubbleSettingStatus(true);
                    showBubbleIcon = true;
                    WakelockPlus.enable();
                  }
                }
              },
            );
          } else if (state is ShowChooseStopsState) {
            showModalBottomSheet(
                isDismissible: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                isScrollControlled: true,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: const ShowStopsWidgets(),
                  );
                });
          } else if (state is InstantEtaSuccessState) {
            await showModalBottomSheet(
                isDismissible: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                isScrollControlled: true,
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: const InstantRideDetailsWidget(),
                  );
                });
            if (userData!.onTripRequest == null) {
              if (!context.mounted) return;
              homeBloc.polyline.clear();
              homeBloc.markers.removeWhere(
                  (element) => element.markerId != const MarkerId('my_loc'));
              homeBloc.add(UpdateEvent());
            }
          } else if (state is OutstationSuccessState) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: MyText(
                      text: AppLocalizations.of(context)!.success,
                      textStyle: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: 16),
                    ),
                    content: MyText(
                      text: AppLocalizations.of(context)!.outStationSuccess,
                      maxLines: 5,
                      textStyle: Theme.of(context).textTheme.bodyMedium!,
                    ),
                    actions: [
                      CustomButton(
                          width: size.width * 0.8,
                          buttonName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            Navigator.pop(context);
                            homeBloc.add(UpdateEvent());
                          })
                    ],
                  );
                });
          } else if (state is ShowImagePickState &&
              userData!.onTripRequest == null) {
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                context: context,
                builder: (builder) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: const UploadShipmentProofWidget(),
                  );
                });
          } else if (state is GetGoodsSuccessState) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                barrierColor: Theme.of(context).shadowColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                builder: (_) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: const SelectGoodsTypeWidget(),
                  );
                });
          } else if (state is AdditionalChargeState) {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                builder: (_) {
                  return BlocProvider.value(
                    value: homeBloc,
                    child: const AdditionalChargeWidget(),
                  );
                });
          } else if (state is InstantRideSuccessState) {
            if (userData!.onTripRequest!.transportType == 'taxi') {
              Navigator.pop(context);
            } else {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            }
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          } else if (state is ShowSubVehicleTypesState) {
            if (userData!.subVehicleType != null) {
              showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (_) {
                    return BlocProvider.value(
                        value: homeBloc, child: const MyServiceTypeWidget());
                  });
            }
          } else if (state is ImageCaptureSuccessState) {
            homeBloc.add(UpdateEvent());
          } else if (state is EnableBiddingSettingsState ||
              state is EnableBubbleSettingsState) {
            homeBloc.add(UpdateEvent());
          } else if (state is RideStartSuccessState) {
            if (homeBloc.showImagePick || homeBloc.showOtp) {
              Navigator.pop(context);
            }
          } else if (state is ServiceNotAvailableState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (cc) {
                return CustomSingleButtonDialoge(
                  title: 'Alert',
                  content: state.message,
                  btnName: AppLocalizations.of(context)!.ok,
                  onTap: () {
                    Navigator.pop(cc);
                    homeBloc.showGetDropAddress = true;
                    homeBloc.polylist.clear();
                    homeBloc.polyline.clear();
                    homeBloc.fmpoly.clear();
                    homeBloc.markers.removeWhere((element) =>
                        element.markerId != const MarkerId('my_loc'));
                    homeBloc.add(UpdateEvent());
                  },
                );
              },
            );
          } else if (state is ShowZoneNavigationState) {
            showModalBottomSheet(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                context: context,
                builder: (_) {
                  return HighDemandAreaWidget(
                      zoneName: state.zoneName,
                      zoneLatLng: state.zoneLatLng,
                      endTimestamp: state.endTimestamp,
                      homeBloc: homeBloc);
                });
          }

          if (!context.mounted) return;
          if (state is SearchTimerUpdateStatus &&
              homeBloc.timer < 1 &&
              homeBloc.waitingList.isEmpty) {
            homeBloc.searchTimer?.cancel();
            homeBloc.searchTimer = null;
            if (userData!.metaRequest != null) {
              homeBloc.add(AcceptRejectEvent(
                  requestId: userData!.metaRequest!.id, status: 0));
            }
          }

          if (state is VehicleNotUpdatedState) {
            if (homeBloc.vehicleNotUpdated == true &&
                (userData!.role == 'driver' || userData!.role == 'owner') &&
                userData!.approve == false) {
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  DriverProfilePage.routeName,
                  arguments: VehicleUpdateArguments(
                    from: '',
                  ),
                  (route) => false);
            }
          } else if (state is ShowChatState && homeBloc.showChat) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                          value: homeBloc,
                          child: const ChatPageWidget(),
                        )));
          } else if ((state is ShowOtpState && homeBloc.showOtp) ||
              ((state is ShowImagePickState && homeBloc.showImagePick) &&
                  userData!.onTripRequest != null) ||
              (state is ShowImagePickState &&
                  userData!.onTripRequest == null &&
                  homeBloc.showImagePick)) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RideOtpWidget(cont: context))).then(
              (value) {
                if (value != null) {
                  userData = value as UserDetail;
                }
                if (!context.mounted) return;
                homeBloc.add(UpdateEvent());
              },
            );
          }

          if (widget.args == null &&
              homeBloc.isSubscriptionShown == false &&
              subscriptionSkip == false &&
              userData != null &&
              userData!.hasSubscription == true &&
              userData!.approve == true &&
              userData!.isSubscribed == false &&
              (userData!.driverMode == 'subscription' ||
                  userData!.driverMode == 'both')) {
            homeBloc.isSubscriptionShown = true;
            showModalBottomSheet(
                constraints: BoxConstraints(
                  maxHeight: size.width * 0.8,
                ),
                isDismissible: false,
                isScrollControlled: false,
                enableDrag: false,
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                    value: homeBloc,
                    child: const ShowSubscriptionWidget(),
                  );
                });
          }

          if (homeBloc.isUserCancelled) {
            homeBloc.isUserCancelled = false;
            if (homeBloc.showImagePick || homeBloc.showOtp) {
              Navigator.pop(context);
            }
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return showUserCancelledDialog(context, size, homeBloc);
                });
          }

          if (homeBloc.bidDeclined) {
            homeBloc.bidDeclined = false;
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) {
                  return showUserBidDeclinedDialog(context, size, homeBloc);
                });
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previousState, currentState) {
            return ((previousState.runtimeType != currentState.runtimeType));
          },
          builder: (context, state) {
            final homeBloc = context.read<HomeBloc>();
            if (homeBloc.choosenMenu == 0) {
              if (mapType == 'google_map' &&
                  homeBloc.choosenMenu == 0 &&
                  (userData != null &&
                      (userData!.onTripRequest == null ||
                          userData!.onTripRequest!.isCompleted == 0))) {
                context
                    .read<HomeBloc>()
                    .add(SetMapStyleEvent(context: context));
              }
            }
            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, _) {
                if (homeBloc.addReview) {
                  homeBloc.add(AddReviewEvent());
                }
              },
              child: SafeArea(
                bottom: true,
                top: false,
                child: Material(
                  child: Directionality(
                    textDirection: homeBloc.textDirection == 'ltr'
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: ((userData == null ||
                              userData!.onTripRequest == null ||
                              userData!.onTripRequest!.isCompleted == 0))
                          ? Stack(
                              children: [
                                (homeBloc.choosenMenu == 0)
                                    ? MapWidget(cont: context)
                                    : (homeBloc.choosenMenu == 1)
                                        ? (userData!.role == 'driver')
                                            ? LeaderboardPage(
                                                args: LeaderBoardArguments(
                                                    from: ''),
                                              )
                                            : OwnerDashboard(
                                                args: OwnerDashboardArguments(
                                                    from: 'home'),
                                              )
                                        : (context
                                                    .read<HomeBloc>()
                                                    .choosenMenu ==
                                                2)
                                            ? const EarningsPage()
                                            : AccountPage(
                                                arg: AccountPageArguments(
                                                    userData: userData!),
                                              ),
                              ],
                            )
                          : InvoicePage(
                              cont: context,
                              repository: homeBloc.rideRepository,
                            ),
                      bottomNavigationBar: (homeBloc.choosenRide == null &&
                              (userData == null ||
                                  userData!.onTripRequest == null &&
                                      userData!.metaRequest == null) &&
                              homeBloc.showGetDropAddress == false)
                          ? BottomNavigationbarWidget(cont: context)
                          : null,
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

Widget showUserBidDeclinedDialog(
    BuildContext context, Size size, HomeBloc homeBloc) {
  return AlertDialog(
    title: MyText(
      text: AppLocalizations.of(context)!.userDeclinedBid,
      textStyle:
          Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 16),
    ),
    content: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.white),
      padding: const EdgeInsets.all(10),
      child: MyText(
        text: AppLocalizations.of(context)!.userDeclinedBidDesc,
        maxLines: 5,
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontSize: 16,
            ),
      ),
    ),
    actions: [
      CustomButton(
          width: size.width * 0.8,
          buttonName: AppLocalizations.of(context)!.ok,
          onTap: () {
            homeBloc.isUserCancelled = false;
            Navigator.pop(context);
          })
    ],
  );
}

Widget showUserCancelledDialog(
    BuildContext context, Size size, HomeBloc homeBloc) {
  return AlertDialog(
    title: MyText(
      text: AppLocalizations.of(context)!.userCancelledRide,
      textStyle:
          Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 16),
    ),
    content: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: MyText(
        text: AppLocalizations.of(context)!.userCancelledDesc,
        maxLines: 5,
        textStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontSize: 16,
            ),
      ),
    ),
    actions: [
      CustomButton(
          width: size.width * 0.8,
          buttonName: AppLocalizations.of(context)!.ok,
          onTap: () {
            homeBloc.add(GetUserDetailsEvent());
            homeBloc.isUserCancelled = false;
            Navigator.pop(context);
          })
    ],
  );
}

Widget showGetLocationPermissionDialog(
    BuildContext context, HomeBloc homeBloc) {
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
                    color: Theme.of(context).primaryColorDark))),
        MyText(text: AppLocalizations.of(context)!.locationAccess, maxLines: 4),
      ],
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              await openAppSettings();
            },
            child: MyText(
                text: AppLocalizations.of(context)!.openSetting,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.w600)),
          ),
          InkWell(
            onTap: () async {
              PermissionStatus status = await Permission.location.status;
              if (status.isGranted || status.isLimited) {
                if (!context.mounted) return;
                Navigator.pop(context);
                homeBloc.add(GetCurrentLocationEvent());
              } else {
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: MyText(
                text: AppLocalizations.of(context)!.done,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      )
    ],
  );
}

Widget showGetOverlayPermissionDialog(BuildContext context, HomeBloc homeBloc) {
  return BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
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
                        color: Theme.of(context).primaryColorDark))),
            MyText(
                text: AppLocalizations.of(context)!.overlayPermission,
                maxLines: 4),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: MyText(
                    text: AppLocalizations.of(context)!.decline,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.w600)),
              ),
              InkWell(
                onTap: () async {
                  homeBloc.isOverlayAllowClicked = true;
                  homeBloc.add(UpdateEvent());
                  if (Platform.isAndroid) {
                    final status = await NativeService().checkPermission();
                    if (!status) {
                      await NativeService().askPermission();
                    } else {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  }
                },
                child: MyText(
                    text: homeBloc.isOverlayAllowClicked
                        ? AppLocalizations.of(context)!.continueText
                        : AppLocalizations.of(context)!.allow,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          )
        ],
      );
    },
  );
}
