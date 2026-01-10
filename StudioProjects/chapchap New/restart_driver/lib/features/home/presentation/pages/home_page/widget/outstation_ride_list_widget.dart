import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/pickup_icon.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/functions.dart';

class BiddingOutStationListWidget extends StatelessWidget {
  final BuildContext cont;
  const BiddingOutStationListWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color.fromARGB(66, 27, 24, 24),
                      offset: Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12)),
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  Container(
                    height: size.width * 0.21,
                    color: AppColors.primary,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: size.height * 0.07,
                            width: size.width * 0.07,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(5.0, 5.0),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                            child: InkWell(
                                onTap: () {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    if (!context.mounted) return;
                                    context.read<HomeBloc>().add(
                                        ShowoutsationpageEvent(
                                            isVisible: false));
                                  });
                                },
                                highlightColor: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.1 * 255).toInt()),
                                splashColor: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.2 * 255).toInt()),
                                hoverColor: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.05 * 255).toInt()),
                                child: const Icon(
                                  CupertinoIcons.back,
                                  size: 20,
                                  color: AppColors.black,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.outStation,
                          textStyle:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontSize: 18,
                                    color: AppColors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: size.width * 0.05),
                        SizedBox(
                          width: size.width * 0.9,
                          child: MyText(
                              text: AppLocalizations.of(context)!.rides,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child:
                                (context
                                        .read<HomeBloc>()
                                        .outStationList
                                        .isNotEmpty)
                                    ? Column(
                                        children: context
                                            .read<HomeBloc>()
                                            .outStationList
                                            .asMap()
                                            .map((key, value) {
                                              List stops = [];
                                              if (context
                                                          .read<HomeBloc>()
                                                          .outStationList[key]
                                                      ['trip_stops'] !=
                                                  'null') {
                                                stops = jsonDecode(context
                                                        .read<HomeBloc>()
                                                        .outStationList[key]
                                                    ['trip_stops']);
                                              }
                                              double dist = calculateDistance(
                                                lat1: context
                                                    .read<HomeBloc>()
                                                    .currentLatLng!
                                                    .latitude,
                                                lon1: context
                                                    .read<HomeBloc>()
                                                    .currentLatLng!
                                                    .longitude,
                                                lat2: context
                                                        .read<HomeBloc>()
                                                        .outStationList[key]
                                                    ['pick_lat'],
                                                lon2: context
                                                        .read<HomeBloc>()
                                                        .outStationList[key]
                                                    ['pick_lng'],
                                                unit: userData?.distanceUnit ??
                                                    'km',
                                              );
                                              return MapEntry(
                                                  key,
                                                  InkWell(
                                                    onTap: () {
                                                      context.read<HomeBloc>().add(ShowBidRideEvent(
                                                          id: context.read<HomeBloc>().outStationList[key]
                                                              ['request_id'],
                                                          pickLat: context
                                                                  .read<HomeBloc>()
                                                                  .outStationList[key]
                                                              ['pick_lat'],
                                                          pickLng: context
                                                                  .read<HomeBloc>()
                                                                  .outStationList[key]
                                                              ['pick_lng'],
                                                          dropLat: context
                                                                  .read<HomeBloc>()
                                                                  .outStationList[key]
                                                              ['drop_lat'],
                                                          dropLng: context
                                                                  .read<HomeBloc>()
                                                                  .outStationList[key]
                                                              ['drop_lng'],
                                                          stops: stops,
                                                          pickAddress: context
                                                                  .read<HomeBloc>()
                                                                  .outStationList[key]
                                                              ['pick_address'],
                                                          dropAddress: context.read<HomeBloc>().outStationList[key]['drop_address'],
                                                          acceptedRideFare: context.read<HomeBloc>().outStationList[key]['base_price'],
                                                          polyString: context.read<HomeBloc>().outStationList[key]['polyline'] ?? '',
                                                          distance: context.read<HomeBloc>().outStationList[key]['distance'],
                                                          duration: context.read<HomeBloc>().outStationList[key]['duration'] ?? '0',
                                                          isOutstationRide: true,
                                                          isNormalBidRide: false));
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * 0.05),
                                                      margin: EdgeInsets.only(
                                                          bottom: size.width *
                                                              0.05),
                                                      width: size.width * 0.9,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: AppColors
                                                              .secondary
                                                              .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt()),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Theme.of(
                                                                        context)
                                                                    .shadowColor,
                                                                offset:
                                                                    const Offset(
                                                                        0, 0),
                                                                blurRadius: 1,
                                                                spreadRadius: 1)
                                                          ]),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            width: size.width *
                                                                0.9,
                                                            child: Row(
                                                              children: [
                                                                const PickupIcon(),
                                                                SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          0.025,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        MyText(
                                                                  text: context
                                                                          .read<
                                                                              HomeBloc>()
                                                                          .outStationList[key]
                                                                      [
                                                                      'pick_address'],
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                ))
                                                              ],
                                                            ),
                                                          ),
                                                          (stops.isEmpty)
                                                              ? Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.03,
                                                                    ),
                                                                    SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.8,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const DropIcon(),
                                                                          SizedBox(
                                                                            width:
                                                                                size.width * 0.025,
                                                                          ),
                                                                          Expanded(
                                                                              child: MyText(
                                                                            text:
                                                                                context.read<HomeBloc>().outStationList[key]['drop_address'],
                                                                            textStyle:
                                                                                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                                                                          ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : (stops.isNotEmpty)
                                                                  ? Column(
                                                                      children: [
                                                                        for (var i =
                                                                                0;
                                                                            i < stops.length;
                                                                            i++)
                                                                          SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: size.width * 0.03,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: size.width * 0.8,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      const DropIcon(),
                                                                                      SizedBox(
                                                                                        width: size.width * 0.025,
                                                                                      ),
                                                                                      Expanded(
                                                                                          child: MyText(
                                                                                        text: stops[i]['address'],
                                                                                        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                                                                                      ))
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                      ],
                                                                    )
                                                                  : Container(),
                                                          SizedBox(
                                                            height: size.width *
                                                                0.05,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width:
                                                                    size.width *
                                                                        0.1,
                                                                height:
                                                                    size.width *
                                                                        0.1,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image: NetworkImage(context.read<HomeBloc>().outStationList[key]
                                                                            [
                                                                            'user_img']),
                                                                        fit: BoxFit
                                                                            .cover)),
                                                              ),
                                                              SizedBox(
                                                                  width: size
                                                                          .width *
                                                                      0.025),
                                                              Expanded(
                                                                  child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  MyText(
                                                                    text: context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .outStationList[key]['user_name'],
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                            fontSize:
                                                                                16),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.star,
                                                                            size:
                                                                                12.5,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                          MyText(
                                                                            text:
                                                                                '${context.read<HomeBloc>().outStationList[key]['ratings']}',
                                                                            textStyle:
                                                                                Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      if (context.read<HomeBloc>().outStationList[key]['completed_ride_count'] !=
                                                                              '0' &&
                                                                          context.read<HomeBloc>().outStationList[key]['completed_ride_count'] !=
                                                                              0)
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(width: 5),
                                                                            Container(
                                                                              width: 1,
                                                                              height: 20,
                                                                              color: Theme.of(context).disabledColor.withAlpha((0.5 * 255).toInt()),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            MyText(
                                                                              text: '${context.read<HomeBloc>().outStationList[key]['completed_ride_count']} ${AppLocalizations.of(context)!.trips}',
                                                                              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.05,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  MyText(
                                                                      text: context.read<HomeBloc>().outStationList[
                                                                              key]
                                                                          [
                                                                          'start_date'],
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyLarge!
                                                                          .copyWith(
                                                                              fontSize: 12)),
                                                                  context.read<HomeBloc>().outStationList[key]
                                                                              [
                                                                              'trip_type'] ==
                                                                          'Round Trip'
                                                                      ? MyText(
                                                                          text: context.read<HomeBloc>().outStationList[key]
                                                                              [
                                                                              'return_date'],
                                                                          textStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyLarge!
                                                                              .copyWith(fontSize: 12))
                                                                      : const SizedBox()
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: size.width *
                                                                0.05,
                                                          ),
                                                          if (context.read<HomeBloc>().outStationList[
                                                                          key][
                                                                      "is_pet_available"] ==
                                                                  true ||
                                                              context.read<HomeBloc>().outStationList[
                                                                          key][
                                                                      "is_luggage_available"] ==
                                                                  true)
                                                            Column(
                                                              children: [
                                                                SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        0.02),
                                                                SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          0.9,
                                                                  child: Row(
                                                                    children: [
                                                                      MyText(
                                                                          text:
                                                                              '${AppLocalizations.of(context)!.preferences} :- ',
                                                                          textStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyMedium!
                                                                              .copyWith(color: Theme.of(context).primaryColor)),
                                                                      if (context
                                                                              .read<HomeBloc>()
                                                                              .outStationList[key]["is_pet_available"] ==
                                                                          true)
                                                                        Icon(
                                                                          Icons
                                                                              .pets,
                                                                          size: size.width *
                                                                              0.05,
                                                                          color:
                                                                              Theme.of(context).primaryColorDark,
                                                                        ),
                                                                      if (context
                                                                              .read<HomeBloc>()
                                                                              .outStationList[key]["is_luggage_available"] ==
                                                                          true)
                                                                        Icon(
                                                                          Icons
                                                                              .luggage,
                                                                          size: size.width *
                                                                              0.05,
                                                                          color:
                                                                              Theme.of(context).primaryColorDark,
                                                                        )
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        0.02),
                                                              ],
                                                            ),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.8,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        MyText(
                                                                            text:
                                                                                '${context.read<HomeBloc>().outStationList[key]['currency']} ${context.read<HomeBloc>().outStationList[key]['price']}',
                                                                            textStyle:
                                                                                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16, color: AppColors.green)),
                                                                        SizedBox(
                                                                          width:
                                                                              size.width * 0.04,
                                                                        ),
                                                                        MyText(
                                                                            text:
                                                                                '${(dist).toStringAsFixed(2)} ${userData?.distanceUnit.toUpperCase() ?? 'KM'} ${AppLocalizations.of(context)!.away}',
                                                                            textStyle:
                                                                                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16)),
                                                                      ],
                                                                    ),
                                                                    context.read<HomeBloc>().outStationList[key]['trip_type'] !=
                                                                            null
                                                                        ? MyText(
                                                                            text:
                                                                                '${context.read<HomeBloc>().outStationList[key]['trip_type']}',
                                                                            textStyle:
                                                                                Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16, color: AppColors.yellowColor))
                                                                        : const SizedBox(),
                                                                  ],
                                                                ),
                                                                CustomButton(
                                                                  buttonName:
                                                                      AppLocalizations.of(
                                                                              context)!
                                                                          .skip,
                                                                  onTap: () {
                                                                    context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .add(DeclineBidRideEvent(
                                                                            id: context.read<HomeBloc>().outStationList[key]['request_id']));
                                                                    context
                                                                        .read<
                                                                            HomeBloc>()
                                                                        .add(ShowoutsationpageEvent(
                                                                            isVisible:
                                                                                false));
                                                                  },
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  textSize: 15,
                                                                  borderRadius:
                                                                      30,
                                                                  buttonColor:
                                                                      AppColors
                                                                          .red,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if ((context.read<HomeBloc>().outStationList[key]
                                                                          [
                                                                          'drivers'] !=
                                                                      null &&
                                                                  (context.read<HomeBloc>().outStationList[key]['drivers']
                                                                              [
                                                                              'driver_${userData!.id}'] !=
                                                                          null &&
                                                                      context.read<HomeBloc>().outStationList[key]['drivers']['driver_${userData!.id}']
                                                                              [
                                                                              "is_rejected"] ==
                                                                          'by_user')) ||
                                                              context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .bidDeclined)
                                                            MyText(
                                                              text: AppLocalizations
                                                                      .of(context)!
                                                                  .outstationRejectText,
                                                              maxLines: 4,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .red),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                            })
                                            .values
                                            .toList())
                                    : Column(
                                        children: [
                                          Image.asset(
                                            AppImages.noBiddingFoundImage,
                                            width: size.width * 0.6,
                                          ),
                                          SizedBox(
                                            height: size.width * 0.02,
                                          ),
                                          MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .noRequest,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  ))
                                        ],
                                      ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
