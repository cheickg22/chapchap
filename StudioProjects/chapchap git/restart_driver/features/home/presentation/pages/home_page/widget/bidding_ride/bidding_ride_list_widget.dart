import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/common/pickup_icon.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

import '../../../../../../../core/utils/functions.dart';

class BiddingRideListWidget extends StatelessWidget {
  final BuildContext cont;
  const BiddingRideListWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
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
            height: size.height * 0.85 - size.width * 0.2,
            width: size.width * 0.9,
            margin: EdgeInsets.all(size.width * 0.05),
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.paddingOf(context).top),
                SizedBox(
                  width: size.width * 0.9,
                  child: MyText(
                    text: AppLocalizations.of(context)!.distanceSelector,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).primaryColorDark),
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Theme.of(context)
                              .primaryColorDark
                              .withAlpha((0.5 * 255).toInt()))),
                  child: Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: Slider(
                            min: 0.0,
                            max: context.read<HomeBloc>().distanceBetweenList[
                                context
                                        .read<HomeBloc>()
                                        .distanceBetweenList
                                        .length -
                                    1]['dist'],
                            divisions: context
                                .read<HomeBloc>()
                                .distanceBetweenList
                                .length,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.secondary,
                            value:
                                context.read<HomeBloc>().distanceBetween ?? 0.0,
                            onChanged: (v) {
                              if (v > 0.0) {
                                context
                                    .read<HomeBloc>()
                                    .add(ChangeDistanceEvent(distance: v));
                              }
                            }),
                      ),
                      SizedBox(
                        width: size.width * 0.65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                                text: AppLocalizations.of(context)!.km,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                            SizedBox(
                              width: size.width * 0.55,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  context
                                      .read<HomeBloc>()
                                      .distanceBetweenList
                                      .length,
                                  (i) {
                                    return MyText(
                                      text:
                                          '${context.read<HomeBloc>().distanceBetweenList[i]['name']} ${AppLocalizations.of(context)!.km}',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: MyText(
                      text: AppLocalizations.of(context)!.rides,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark)),
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                Expanded(
                    child: SingleChildScrollView(
                  child: (context.read<HomeBloc>().rideList.isNotEmpty)
                      ? Column(
                          children: context
                              .read<HomeBloc>()
                              .rideList
                              .asMap()
                              .map((key, value) {
                                List stops = [];
                                if (context.read<HomeBloc>().rideList[key]
                                        ['trip_stops'] !=
                                    'null') {
                                  stops = jsonDecode(context
                                      .read<HomeBloc>()
                                      .rideList[key]['trip_stops']);
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
                                  lat2: context.read<HomeBloc>().rideList[key]
                                      ['pick_lat'],
                                  lon2: context.read<HomeBloc>().rideList[key]
                                      ['pick_lng'],
                                  unit: userData?.distanceUnit ?? 'km',
                                );
                                return MapEntry(
                                    key,
                                    Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.05),
                                      margin: EdgeInsets.only(
                                          bottom: size.width * 0.05),
                                      width: size.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.secondary
                                              .withAlpha((0.4 * 255).toInt())),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.1,
                                                height: size.width * 0.1,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: NetworkImage(context
                                                                .read<HomeBloc>()
                                                                .rideList[key]
                                                            ['user_img']),
                                                        fit: BoxFit.cover)),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.025),
                                              Expanded(
                                                  child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                    text: context
                                                            .read<HomeBloc>()
                                                            .rideList[key]
                                                        ['user_name'],
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(fontSize: 16),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            size: 12.5,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                          ),
                                                          MyText(
                                                            text:
                                                                '${context.read<HomeBloc>().rideList[key]['ratings']}',
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      if (context
                                                                      .read<
                                                                          HomeBloc>()
                                                                      .rideList[key]
                                                                  [
                                                                  'completed_ride_count'] !=
                                                              '0' &&
                                                          context
                                                                      .read<
                                                                          HomeBloc>()
                                                                      .rideList[key]
                                                                  [
                                                                  'completed_ride_count'] !=
                                                              0)
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                                width: 5),
                                                            Container(
                                                              width: 1,
                                                              height: 20,
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor
                                                                  .withAlpha((0.5 *
                                                                          255)
                                                                      .toInt()),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            MyText(
                                                              text:
                                                                  '${context.read<HomeBloc>().rideList[key]['completed_ride_count']} ${AppLocalizations.of(context)!.trips}',
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                      color: AppColors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                              SizedBox(
                                                width: size.width * 0.05,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  MyText(
                                                      text:
                                                          '${context.read<HomeBloc>().rideList[key]['currency']} ${context.read<HomeBloc>().rideList[key]['price']}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                  fontSize:
                                                                      16)),
                                                  MyText(
                                                      text:
                                                          '${(dist).toStringAsFixed(2)} ${userData?.distanceUnit.toUpperCase() ?? 'KM'} ${AppLocalizations.of(context)!.away}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                  fontSize: 12))
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: size.width * 0.9,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: size.width * 0.05,
                                                  width: size.width * 0.05,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColors
                                                              .secondary),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: size.width * 0.025,
                                                    width: size.width * 0.025,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: AppColors
                                                                .primary),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width * 0.025,
                                                ),
                                                Expanded(
                                                    child: MyText(
                                                  text: context
                                                          .read<HomeBloc>()
                                                          .rideList[key]
                                                      ['pick_address'],
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                ))
                                              ],
                                            ),
                                          ),
                                          (stops.isEmpty &&
                                                  context
                                                              .read<HomeBloc>()
                                                              .rideList[key]
                                                          ['drop_address'] !=
                                                      '')
                                              ? Column(
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
                                                            width: size.width *
                                                                0.025,
                                                          ),
                                                          Expanded(
                                                              child: MyText(
                                                            text: context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .rideList[key]
                                                                [
                                                                'drop_address'],
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : (stops.isNotEmpty)
                                                  ? Column(
                                                      children: [
                                                        for (var i = 0;
                                                            i < stops.length;
                                                            i++)
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.03,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.8,
                                                                child: Row(
                                                                  children: [
                                                                    Image.asset(
                                                                      AppImages
                                                                          .dropAddressImageIcon,
                                                                      height: size
                                                                              .width *
                                                                          0.05,
                                                                      width: size
                                                                              .width *
                                                                          0.05,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                    SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.025,
                                                                    ),
                                                                    Expanded(
                                                                        child:
                                                                            MyText(
                                                                      text: stops[
                                                                              i]
                                                                          [
                                                                          'address'],
                                                                      textStyle: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w500),
                                                                    ))
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                      ],
                                                    )
                                                  : Container(),
                                          SizedBox(
                                            height: size.width * 0.05,
                                          ),
                                          if (context
                                                          .read<HomeBloc>()
                                                          .rideList[key]
                                                      ["is_pet_available"] ==
                                                  true ||
                                              context
                                                          .read<HomeBloc>()
                                                          .rideList[key][
                                                      "is_luggage_available"] ==
                                                  true)
                                            Column(
                                              children: [
                                                SizedBox(
                                                    height: size.width * 0.02),
                                                SizedBox(
                                                  width: size.width * 0.9,
                                                  child: Row(
                                                    children: [
                                                      MyText(
                                                          text:
                                                              '${AppLocalizations.of(context)!.preferences} :- ',
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                      if (context
                                                                  .read<HomeBloc>()
                                                                  .rideList[key]
                                                              [
                                                              "is_pet_available"] ==
                                                          true)
                                                        Icon(
                                                          Icons.pets,
                                                          size:
                                                              size.width * 0.05,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                      if (context
                                                                  .read<HomeBloc>()
                                                                  .rideList[key]
                                                              [
                                                              "is_luggage_available"] ==
                                                          true)
                                                        Icon(
                                                          Icons.luggage,
                                                          size:
                                                              size.width * 0.05,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.02),
                                              ],
                                            ),
                                          SizedBox(
                                            width: size.width * 0.8,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomButton(
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .decline,
                                                  onTap: () {
                                                    context.read<HomeBloc>().add(
                                                        DeclineBidRideEvent(
                                                            id: context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .rideList[key]
                                                                [
                                                                'request_id']));
                                                  },
                                                  width: size.width * 0.32,
                                                  buttonColor: AppColors.red,
                                                ),
                                                CustomButton(
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .accept,
                                                  onTap: () {
                                                    context.read<HomeBloc>().add(ShowBidRideEvent(
                                                        id: context
                                                                .read<HomeBloc>()
                                                                .rideList[key]
                                                            ['request_id'],
                                                        pickLat: context
                                                                .read<HomeBloc>()
                                                                .rideList[key]
                                                            ['pick_lat'],
                                                        pickLng: context
                                                                .read<HomeBloc>()
                                                                .rideList[key]
                                                            ['pick_lng'],
                                                        dropLat: context
                                                            .read<HomeBloc>()
                                                            .rideList[key]
                                                                ['drop_lat']
                                                            .toDouble(),
                                                        dropLng: context
                                                            .read<HomeBloc>()
                                                            .rideList[key]
                                                                ['drop_lng']
                                                            .toDouble(),
                                                        stops: stops,
                                                        pickAddress: context
                                                                .read<HomeBloc>()
                                                                .rideList[key]['pick_address'] ??
                                                            '',
                                                        dropAddress: context.read<HomeBloc>().rideList[key]['drop_address'] ?? '',
                                                        acceptedRideFare: context.read<HomeBloc>().rideList[key]['base_price'] ?? '0',
                                                        polyString: context.read<HomeBloc>().rideList[key]['polyline'] ?? '',
                                                        distance: context.read<HomeBloc>().rideList[key]['distance'] ?? '0',
                                                        duration: context.read<HomeBloc>().rideList[key]['duration'] ?? '0',
                                                        isOutstationRide: false,
                                                        isNormalBidRide: true));
                                                  },
                                                  width: size.width * 0.32,
                                                  buttonColor: AppColors.green,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
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
                            SizedBox(height: size.width * 0.02),
                            MyText(
                                text: AppLocalizations.of(context)!.noRequest,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).disabledColor,
                                    ))
                          ],
                        ),
                ))
              ],
            ),
          );
        },
      ),
    );
  }
}
