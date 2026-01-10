import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/network/endpoints.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../../common/pickup_icon.dart';
import '../../../../../../../core/utils/custom_divider.dart';

class OnRideWidget extends StatelessWidget {
  final BuildContext cont;

  const OnRideWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                color: Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              children: [
                SizedBox(height: size.width * 0.04),
                Container(
                  width: size.width * 0.15,
                  height: size.width * 0.01,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context)
                          .disabledColor
                          .withAlpha((0.3 * 255).toInt())),
                ),
                SizedBox(height: size.width * 0.03),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, bottom: 10, top: 10, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: MyText(
                            text: (userData?.onTripRequest!.arrivedAt == null)
                                ? AppLocalizations.of(context)!.onWayToPickup
                                : (userData?.onTripRequest!.isTripStart == 0)
                                    ? AppLocalizations.of(context)!
                                        .arrivedWaiting
                                    : AppLocalizations.of(context)!
                                        .onTheWayToDrop,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold),
                          )),
                          if (userData!.onTripRequest!.arrivedAt != null &&
                              userData!.onTripRequest!.isBidRide == "0" &&
                              !userData!.onTripRequest!.isRental)
                            Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                Image.asset(
                                  AppImages.waitingTime,
                                  color: Theme.of(context).disabledColor,
                                  width: size.width * 0.098,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                    child: Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).shadowColor,
                                          blurRadius: 1)
                                    ],
                                    // color: AppColors.white,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                  child: MyText(
                                    text:
                                        '${(Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours.toString().padLeft(2, '0'))} : ${((Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inMinutes - (Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours * 60)).toString().padLeft(2, '0'))} hr',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ))
                              ],
                            )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: HorizontalDotDividerWidget(),
                    ),
                    SizedBox(height: size.width * 0.02),
                    if (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.isBidRide == "0" &&
                        !userData!.onTripRequest!.isRental)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: size.width * 0.7,
                              child: MyText(
                                text: (userData!.onTripRequest!
                                                .freeWaitingTimeBeforeStart ==
                                            0 ||
                                        userData!.onTripRequest!
                                                .freeWaitingTimeAfterStart ==
                                            0)
                                    ? AppLocalizations.of(context)!
                                        .waitingChargeText
                                        .replaceAll('*',
                                            "${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.waitingCharge}")
                                    : AppLocalizations.of(context)!
                                        .waitingText
                                        .replaceAll("***",
                                            "${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.waitingCharge}")
                                        .replaceAll(
                                            "*",
                                            userData?.onTripRequest!
                                                        .isTripStart ==
                                                    0
                                                ? "${userData!.onTripRequest!.freeWaitingTimeBeforeStart}"
                                                : "${userData!.onTripRequest!.freeWaitingTimeAfterStart}"),
                                maxLines: 5,
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall!,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: size.width * 0.05),
                Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PickupIcon(),
                          SizedBox(width: size.width * 0.025),
                          Expanded(
                            child: MyText(
                              text: userData!.onTripRequest!.pickAddress,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 5,
                            ),
                          ),
                          if (userData!.onTripRequest!.requestStops.isNotEmpty)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    if (userData!
                                            .onTripRequest!.pickPocMobile !=
                                        null)
                                      Row(
                                        children: [
                                          SizedBox(width: size.width * 0.025),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.05),
                                            onTap: () {
                                              context.read<HomeBloc>().add(
                                                  OpenAnotherFeatureEvent(
                                                      value:
                                                          'tel:${userData!.onTripRequest!.pickPocMobile}'));
                                            },
                                            child: const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    Icon(Icons.call, size: 23)),
                                          ),
                                        ],
                                      ),
                                    Row(
                                      children: [
                                        SizedBox(width: size.width * 0.025),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                              size.width * 0.05),
                                          onTap: () {
                                            if (userData!.enableWazeMap ==
                                                '0') {
                                              context.read<HomeBloc>().add(
                                                  OpenAnotherFeatureEvent(
                                                      value:
                                                          '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                                            } else {
                                              context.read<HomeBloc>().add(
                                                  NavigationTypeEvent(
                                                      isMapNavigation: false));
                                            }
                                          },
                                          child: Icon(
                                            CupertinoIcons.location_fill,
                                            size: size.width * 0.05,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (context.read<HomeBloc>().navigationType1 ==
                                    true) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              context.read<HomeBloc>().add(
                                                  OpenAnotherFeatureEvent(
                                                      value:
                                                          '${ApiEndpoints.openMap}${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}'));
                                            },
                                            child: SizedBox(
                                              width: size.width * 0.07,
                                              child: Image.asset(
                                                AppImages.googleMaps,
                                                height: size.width * 0.07,
                                                width: 200,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          InkWell(
                                            onTap: () async {
                                              var browseUrl =
                                                  'https://waze.com/ul?ll=${userData!.onTripRequest!.pickLat},${userData!.onTripRequest!.pickLng}&navigate=yes';
                                              if (browseUrl.isNotEmpty) {
                                                await launchUrl(
                                                    Uri.parse(browseUrl));
                                              } else {
                                                throw 'Could not launch $browseUrl';
                                              }
                                            },
                                            child: SizedBox(
                                              width: size.width * 0.07,
                                              child: Image.asset(
                                                AppImages.wazeMap,
                                                height: size.width * 0.07,
                                                width: 200,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (userData!.onTripRequest!.transportType == 'delivery' &&
                        userData!.onTripRequest!.pickPocInstruction != null &&
                        userData!.onTripRequest!.pickPocInstruction != '') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.width * 0.02),
                          SizedBox(
                            width: size.width * 0.8,
                            child: MyText(
                              text:
                                  '${AppLocalizations.of(context)!.instruction}: ',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: size.width * 0.01),
                          SizedBox(
                            width: size.width * 0.8,
                            child: MyText(
                                text:
                                    userData!.onTripRequest!.pickPocInstruction,
                                maxLines: 5,
                                textStyle:
                                    Theme.of(context).textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ],

                    // Drop-off or Stops
                    (userData!.onTripRequest!.requestStops.isEmpty &&
                            userData!.onTripRequest!.dropAddress != null)
                        ? Column(
                            children: [
                              SizedBox(height: size.width * 0.03),
                              SizedBox(
                                width: size.width * 0.91,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const DropIcon(),
                                    SizedBox(width: size.width * 0.025),
                                    Expanded(
                                      child: MyText(
                                        text: userData!
                                            .onTripRequest!.dropAddress,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                        maxLines: 5,
                                      ),
                                    ),
                                    if (userData!
                                                .onTripRequest!.transportType ==
                                            'delivery' &&
                                        userData!
                                                .onTripRequest!.dropPocMobile !=
                                            null)
                                      Row(
                                        children: [
                                          SizedBox(width: size.width * 0.025),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                                size.width * 0.05),
                                            onTap: () {
                                              context.read<HomeBloc>().add(
                                                  OpenAnotherFeatureEvent(
                                                      value:
                                                          'tel:${userData!.onTripRequest!.dropPocMobile!}'));
                                            },
                                            child: const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    Icon(Icons.call, size: 23)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              if (userData!.onTripRequest!.dropPocInstruction !=
                                      null &&
                                  userData!.onTripRequest!.dropPocInstruction !=
                                      '')
                                Column(
                                  children: [
                                    SizedBox(height: size.width * 0.02),
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: MyText(
                                        text:
                                            '${AppLocalizations.of(context)!.instruction}: ',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.01),
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: MyText(
                                          text: userData!.onTripRequest!
                                              .dropPocInstruction,
                                          maxLines: 5,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                  ],
                                ),
                              SizedBox(height: size.width * 0.05)
                            ],
                          )
                        : (userData!.onTripRequest!.requestStops.isNotEmpty)
                            ? Column(
                                children: [
                                  for (var i = 0;
                                      i <
                                          userData!.onTripRequest!.requestStops
                                              .length;
                                      i++)
                                    Column(
                                      children: [
                                        SizedBox(height: size.width * 0.03),
                                        SizedBox(
                                          width: size.width * 0.9,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: Icon(
                                                  Icons.location_on_rounded,
                                                  color: (userData!
                                                                  .onTripRequest!
                                                                  .requestStops[i]
                                                              [
                                                              'completed_at'] !=
                                                          null)
                                                      ? AppColors.secondary
                                                      : AppColors.red,
                                                  size: 23,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.025),
                                              Expanded(
                                                child: MyText(
                                                  text: userData!.onTripRequest!
                                                          .requestStops[i]
                                                      ['address'],
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: (userData!
                                                                          .onTripRequest!
                                                                          .requestStops[i]
                                                                      [
                                                                      'completed_at'] !=
                                                                  null)
                                                              ? AppColors
                                                                  .darkGrey
                                                              : null,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 5,
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.025),
                                                          InkWell(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    size.width *
                                                                        0.05),
                                                            onTap: () {
                                                              context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .add(OpenAnotherFeatureEvent(
                                                                      value:
                                                                          'tel:${userData!.onTripRequest!.requestStops[i]['poc_mobile']}'));
                                                            },
                                                            child: const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child: Icon(
                                                                    Icons.call,
                                                                    size: 23)),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.025),
                                                          InkWell(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    size.width *
                                                                        0.05),
                                                            onTap: () {
                                                              if (userData!
                                                                      .enableWazeMap ==
                                                                  '0') {
                                                                context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .add(OpenAnotherFeatureEvent(
                                                                        value:
                                                                            '${ApiEndpoints.openMap}${userData!.onTripRequest!.requestStops[i]['latitude']},${userData!.onTripRequest!.requestStops[i]['longitude']}'));
                                                              } else {
                                                                context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .add(NavigationTypeEvent(
                                                                        isMapNavigation:
                                                                            false));
                                                              }
                                                            },
                                                            child: Icon(
                                                              CupertinoIcons
                                                                  .location_fill,
                                                              size: size.width *
                                                                  0.05,
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  if (context
                                                          .read<HomeBloc>()
                                                          .navigationType1 ==
                                                      true) ...[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            size.width * 0.02),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Theme.of(
                                                                    context)
                                                                .scaffoldBackgroundColor,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .shadowColor,
                                                                  spreadRadius:
                                                                      1,
                                                                  blurRadius: 1)
                                                            ]),
                                                        child: Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .add(OpenAnotherFeatureEvent(
                                                                        value:
                                                                            '${ApiEndpoints.openMap}${userData!.onTripRequest!.requestStops[i]['latitude']},${userData!.onTripRequest!.requestStops[i]['longitude']}'));
                                                              },
                                                              child: SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.07,
                                                                child:
                                                                    Image.asset(
                                                                  AppImages
                                                                      .googleMaps,
                                                                  height:
                                                                      size.width *
                                                                          0.07,
                                                                  width: 200,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.02),
                                                            InkWell(
                                                              onTap: () async {
                                                                var browseUrl =
                                                                    'https://waze.com/ul?ll=${userData!.onTripRequest!.requestStops[i]['latitude']},${userData!.onTripRequest!.requestStops[i]['longitude']}&navigate=yes';
                                                                if (browseUrl
                                                                    .isNotEmpty) {
                                                                  await launchUrl(
                                                                      Uri.parse(
                                                                          browseUrl));
                                                                } else {
                                                                  throw 'Could not launch $browseUrl';
                                                                }
                                                              },
                                                              child: SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.07,
                                                                child:
                                                                    Image.asset(
                                                                  AppImages
                                                                      .wazeMap,
                                                                  height:
                                                                      size.width *
                                                                          0.07,
                                                                  width: 200,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (userData!.onTripRequest!
                                                        .requestStops[i]
                                                    ['poc_instruction'] !=
                                                null &&
                                            userData!.onTripRequest!
                                                        .requestStops[i]
                                                    ['poc_instruction'] !=
                                                'null' &&
                                            userData!.onTripRequest!
                                                        .requestStops[i]
                                                    ['poc_instruction'] !=
                                                '')
                                          Column(
                                            children: [
                                              SizedBox(
                                                  height: size.width * 0.02),
                                              SizedBox(
                                                width: size.width * 0.8,
                                                child: MyText(
                                                  text:
                                                      '${AppLocalizations.of(context)!.instruction}: ',
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: (userData!
                                                                        .onTripRequest!
                                                                        .requestStops[i]
                                                                    [
                                                                    'completed_at'] !=
                                                                null)
                                                            ? AppColors.darkGrey
                                                            : null,
                                                      ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.width * 0.01),
                                              SizedBox(
                                                width: size.width * 0.8,
                                                child: MyText(
                                                  text: userData!.onTripRequest!
                                                          .requestStops[i]
                                                      ['poc_instruction'],
                                                  maxLines: 5,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        color: (userData!
                                                                        .onTripRequest!
                                                                        .requestStops[i]
                                                                    [
                                                                    'completed_at'] !=
                                                                null)
                                                            ? AppColors.darkGrey
                                                            : null,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: size.width * 0.02),
                                      ],
                                    ),
                                ],
                              )
                            : Container(),

                    SizedBox(height: size.width * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              width: 0.5,
                              color: Theme.of(context).disabledColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: size.width * 0.93,
                              padding: EdgeInsets.all(size.width * 0.05),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withAlpha((0.3 * 255).toInt())),
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.128,
                                    height: size.width * 0.128,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: NetworkImage(userData!
                                                .onTripRequest!.userImage),
                                            fit: BoxFit.cover)),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.6,
                                          child: MyText(
                                            text: userData!
                                                .onTripRequest!.userName,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontWeight:
                                                        FontWeight.w600),
                                            maxLines: 5,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 15,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                MyText(
                                                  text: userData!
                                                      .onTripRequest!.ratings
                                                      .toString(),
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            if (userData!.onTripRequest!
                                                    .completedRideCount
                                                    .toString() !=
                                                '0')
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withAlpha((0.5 * 255)
                                                            .toInt()),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  MyText(
                                                    text:
                                                        '${userData!.onTripRequest!.completedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (userData!.onTripRequest!
                                          .showRequestEtaAmount ==
                                      true)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        (userData!.onTripRequest!
                                                    .rentalPackageId ==
                                                null)
                                            ? MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .rideFare,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              )
                                            : SizedBox(
                                                width: size.width * 0.3,
                                                child: MyText(
                                                  text: userData!.onTripRequest!
                                                      .rentalPackageName,
                                                  textAlign: (context
                                                              .read<HomeBloc>()
                                                              .textDirection ==
                                                          'ltr')
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                )),
                                        MyText(
                                          text: (userData!.onTripRequest!
                                                      .isBidRide ==
                                                  "0")
                                              ? '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.requestEtaAmount}'
                                              : '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.acceptedRideFare}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .copyWith(
                                                  color: AppColors.green,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                          textAlign: (context
                                                      .read<HomeBloc>()
                                                      .textDirection ==
                                                  'ltr')
                                              ? TextAlign.right
                                              : TextAlign.left,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (userData!.onTripRequest!.transportType ==
                                    'taxi' &&
                                userData!.onTripRequest!.pickPocInstruction !=
                                    null &&
                                userData!.onTripRequest!.pickPocInstruction !=
                                    '') ...[
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: MyText(
                                        text:
                                            '${AppLocalizations.of(context)!.instruction}: ',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.01),
                                    SizedBox(
                                      width: size.width * 0.8,
                                      child: MyText(
                                          text: userData!.onTripRequest!
                                              .pickPocInstruction,
                                          maxLines: 5,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (userData!.onTripRequest!
                                      .requestPreferences!=null&&userData!.onTripRequest!.requestPreferences.data.length>=1)
                                      Row(
                                      children: [
                                        MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.preferences} : ',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        for (int i = 0;
                                            i <
                                                userData!
                                                    .onTripRequest!
                                                    .requestPreferences
                                                    .data
                                                    .length;
                                            i++) ...[
                                          Container(
                                            margin: EdgeInsets.all(
                                                size.width * 0.0025),
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: userData!
                                                    .onTripRequest!
                                                  .requestPreferences
                                                  .data[i]
                                                  .icon,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.error,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          if (i !=
                                              userData!
                                                    .onTripRequest!
                                                      .requestPreferences
                                                      .data
                                                      .length -
                                                  1) //avoid comma at end
                                            const Text(
                                              ",",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                        ]
                                      ],
                                    ),
                            // if (userData!.onTripRequest!.isPetAvailable == 1 ||
                            //     userData!.onTripRequest!.isLuggageAvailable ==
                            //         1) ...[
                            //   Padding(
                            //     padding: const EdgeInsets.all(5),
                            //     child: SizedBox(
                            //       width: size.width * 0.9,
                            //       child: Row(
                            //         children: [
                            //           MyText(
                            //               text:
                            //                   '${AppLocalizations.of(context)!.preferences} : ',
                            //               textStyle: Theme.of(context)
                            //                   .textTheme
                            //                   .bodyMedium!
                            //                   .copyWith(
                            //                       color: Theme.of(context)
                            //                           .primaryColorDark)),
                            //           if (userData!
                            //                   .onTripRequest!.isPetAvailable ==
                            //               1)
                            //             Icon(
                            //               Icons.pets,
                            //               size: size.width * 0.05,
                            //               color: Theme.of(context)
                            //                   .primaryColorDark,
                            //             ),
                            //           if (userData!.onTripRequest!
                            //                   .isLuggageAvailable ==
                            //               1)
                            //             Icon(
                            //               Icons.luggage,
                            //               size: size.width * 0.05,
                            //               color: Theme.of(context)
                            //                   .primaryColorDark,
                            //             )
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                    if (userData != null &&
                        userData!.onTripRequest != null &&
                        ((userData!.onTripRequest!.isTripStart == 0&&userData!.onTripRequest!.transportType ==
                                    'taxi')||((userData!.onTripRequest!.transportType !=
                                    'taxi'))))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  context
                                      .read<HomeBloc>()
                                      .add(GetRideChatEvent());
                                  context.read<HomeBloc>().add(ShowChatEvent());
                                },
                                child: Container(
                                  height: size.width * 0.100,
                                  width: size.width * 0.110,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.3 * 255).toInt()),
                                      border: Border.all(
                                          width: 0.5,
                                          color: AppColors.darkGrey
                                              .withAlpha((0.8 * 255).toInt()))),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.message,
                                    size: size.width * 0.05,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                              if (context.read<HomeBloc>().chats.isNotEmpty &&
                                  context
                                      .read<HomeBloc>()
                                      .chats
                                      .where((e) =>
                                          e['from_type'] == 1 && e['seen'] == 0)
                                      .isNotEmpty)
                                Positioned(
                                  top: size.width * 0.01,
                                  right: size.width * 0.008,
                                  child: Container(
                                    height: size.width * 0.03,
                                    width: size.width * 0.03,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: size.width * 0.025),
                          InkWell(
                            onTap: () async {
                              context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                                  value:
                                      'tel:${userData!.onTripRequest!.userMobile}'));
                            },
                            child: Container(
                              height: size.width * 0.100,
                              width: size.width * 0.110,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .disabledColor
                                      .withAlpha((0.3 * 255).toInt()),
                                  border: Border.all(
                                      width: 0.5,
                                      color: AppColors.darkGrey
                                          .withAlpha((0.8 * 255).toInt()))),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.call,
                                size: size.width * 0.05,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.025),
                        ],
                      ),
                    SizedBox(height: size.width * 0.05),
                    Container(
                      margin: EdgeInsets.only(
                          left: size.width * 0.05, right: size.width * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: size.width * 0.5,
                                  child: MyText(
                                      text: userData!.onTripRequest!.isRental
                                          ? userData!
                                              .onTripRequest!.rentalPackageName
                                          : AppLocalizations.of(context)!
                                              .rideFare,
                                      maxLines: 2,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w600)),
                                ),
                                (userData!.onTripRequest!.isBidRide == "1")
                                    ? MyText(
                                        text:
                                            '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.acceptedRideFare}',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                                color: AppColors.green,
                                                fontWeight: FontWeight.bold))
                                    : MyText(
                                        text:
                                            '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.requestEtaAmount}',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .displayLarge!
                                            .copyWith(
                                                color: AppColors.green,
                                                fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    userData!.onTripRequest!.paymentOpt == '1'
                                        ? Icons.payments_outlined
                                        : userData!.onTripRequest!.paymentOpt ==
                                                '0'
                                            ? Icons.credit_card_rounded
                                            : Icons
                                                .account_balance_wallet_outlined,
                                    size: size.width * 0.05,
                                    color: AppColors.green,
                                  ),
                                  SizedBox(width: size.width * 0.025),
                                  MyText(
                                      text: userData!
                                                  .onTripRequest!.paymentOpt ==
                                              '1'
                                          ? AppLocalizations.of(context)!.cash
                                          : userData!.onTripRequest!
                                                      .paymentOpt ==
                                                  '2'
                                              ? AppLocalizations.of(context)!
                                                  .wallet
                                              : AppLocalizations.of(context)!
                                                  .card,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (userData!.onTripRequest!.transportType ==
                                  'delivery')
                                MyText(
                                  text: userData!.onTripRequest!.paidAt ==
                                          'Sender'
                                      ? AppLocalizations.of(context)!
                                          .payBysender
                                      : AppLocalizations.of(context)!
                                          .payByreceiver,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontWeight: FontWeight.bold),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                    if (userData!.onTripRequest != null &&
                        userData!.onTripRequest!.isTripStart == 1 &&
                        userData!.onTripRequest!.showAdditionalChargeFeature ==
                            1) ...[
                      SizedBox(height: size.width * 0.03),
                      InkWell(
                        child: MyText(
                          text:
                              "${AppLocalizations.of(context)!.additionalCharges} ?",
                          textStyle: AppTextStyle.boldStyle().copyWith(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          context.read<HomeBloc>().add(AdditionalChargeEvent());
                        },
                      ),
                    ],
                    SizedBox(height: size.width * 0.5),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
