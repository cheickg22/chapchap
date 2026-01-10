import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/pickup_icon.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class OutstationRequestWidget extends StatelessWidget {
  final HomeBloc bloc;
  const OutstationRequestWidget({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          if (homeBloc.bidRideAmount.text.isEmpty &&
              homeBloc.outStationList.isNotEmpty) {
            homeBloc.bidRideAmount.text =
                '${(homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['price']) ?? ''}';
          }
          List stops = [];
          if (homeBloc.outStationList.isNotEmpty &&
              homeBloc.outStationList.firstWhere((e) =>
                      e['request_id'] == homeBloc.choosenRide)['trip_stops'] !=
                  'null') {
            stops = jsonDecode(context
                    .read<HomeBloc>()
                    .outStationList
                    .firstWhere((e) => e['request_id'] == homeBloc.choosenRide)[
                'trip_stops']);
          }

          double total = double.parse(context
              .read<HomeBloc>()
              .outStationList
              .firstWhere(
                  (e) => e['request_id'] == homeBloc.choosenRide)['price']);
          double lowPercentage = double.parse(userData!.biddingLowPercentage);
          double highPercentage = double.parse(userData!.biddingHighPercentage);

          homeBloc.maxFare = (total + ((highPercentage / 100) * total));
          homeBloc.minFare = (total - ((lowPercentage / 100) * total));
          return Column(
            children: [
              SizedBox(height: size.width * 0.01),
              Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Row(
                  children: [
                    Container(
                      width: size.width * 0.128,
                      height: size.width * 0.128,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(context
                                  .read<HomeBloc>()
                                  .outStationList
                                  .firstWhere((e) =>
                                      e['request_id'] ==
                                      context
                                          .read<HomeBloc>()
                                          .choosenRide)['user_img']),
                              fit: BoxFit.cover)),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: context
                                .read<HomeBloc>()
                                .outStationList
                                .firstWhere((e) =>
                                    e['request_id'] ==
                                    context
                                        .read<HomeBloc>()
                                        .choosenRide)['user_name'],
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12.5,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  MyText(
                                    text:
                                        '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['ratings']}',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              if (context
                                          .read<HomeBloc>()
                                          .outStationList
                                          .firstWhere((e) =>
                                              e['request_id'] ==
                                              context
                                                  .read<HomeBloc>()
                                                  .choosenRide)[
                                      'completed_ride_count'] !=
                                  '0')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 5),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.5 * 255).toInt()),
                                    ),
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: size.width * 0.2,
                                      child: MyText(
                                        text:
                                            '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['completed_ride_count']} ${AppLocalizations.of(context)!.tripsDoneText}',
                                        maxLines: 2,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * 0.02,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  text:
                                      '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['start_date']}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 12)),
                              context
                                          .read<HomeBloc>()
                                          .outStationList
                                          .firstWhere((e) =>
                                              e['request_id'] ==
                                              context
                                                  .read<HomeBloc>()
                                                  .choosenRide)['trip_type'] ==
                                      'Round Trip'
                                  ? MyText(
                                      text: context
                                          .read<HomeBloc>()
                                          .outStationList
                                          .firstWhere((e) =>
                                              e['request_id'] ==
                                              context
                                                  .read<HomeBloc>()
                                                  .choosenRide)['return_date'],
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 12))
                                  : const SizedBox()
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.03,
                    ),
                    Column(
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.rideFare,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                        MyText(
                          text:
                              '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['currency']}${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['price']}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                  color: AppColors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                        ),
                        MyText(
                          text:
                              '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['trip_type']}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColors.yellowColor,
                                  fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.width * 0.03,
              ),
              SizedBox(
                width: size.width * 0.8,
                child: Row(
                  children: [
                    const PickupIcon(),
                    SizedBox(
                      width: size.width * 0.025,
                    ),
                    Expanded(
                        child: MyText(
                      text: homeBloc.outStationList.firstWhere((e) =>
                          e['request_id'] ==
                          context.read<HomeBloc>().choosenRide)['pick_address'],
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                    ))
                  ],
                ),
              ),
              (stops.isEmpty)
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
                                width: size.width * 0.025,
                              ),
                              Expanded(
                                  child: MyText(
                                text: context
                                    .read<HomeBloc>()
                                    .outStationList
                                    .firstWhere((e) =>
                                        e['request_id'] ==
                                        context
                                            .read<HomeBloc>()
                                            .choosenRide)['drop_address'],
                                textStyle: Theme.of(context)
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
                  : Column(
                      children: [
                        for (var i = 0; i < stops.length; i++)
                          Column(
                            children: [
                              SizedBox(
                                height: size.width * 0.01,
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
                                      textStyle: Theme.of(context)
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
                    ),
              SizedBox(
                height: size.width * 0.038,
              ),
              if (context
                      .read<HomeBloc>()
                      .outStationList
                      .firstWhere((e) =>
                          e['request_id'] == homeBloc.choosenRide)['goods']
                      .toString() !=
                  'null')
                Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.8,
                      child: MyText(
                        text:
                            '${homeBloc.outStationList.firstWhere((e) => e['request_id'] == homeBloc.choosenRide)['goods']})',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.038,
                    ),
                  ],
                ),
              SizedBox(
                height: size.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      if (!context
                          .read<HomeBloc>()
                          .isBiddingDecreaseLimitReach) {
                        homeBloc.add(
                            BiddingIncreaseOrDecreaseEvent(isIncrease: false));
                      }
                    },
                    child: Container(
                      width: size.width * 0.2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: context
                                  .read<HomeBloc>()
                                  .isBiddingDecreaseLimitReach
                              ? Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.2 * 255).toInt())
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(size.width * 0.025),
                      child: MyText(
                        text:
                            '-${double.parse(userData!.biddingAmountIncreaseOrDecrease.toString())}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: context
                                        .read<HomeBloc>()
                                        .isBiddingDecreaseLimitReach
                                    ? AppColors.black
                                    : AppColors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.3,
                    child: TextField(
                      enabled: true,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: homeBloc.bidRideAmount,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          double typedFare = double.tryParse(value) ?? 0.0;
                          if (typedFare < homeBloc.minFare!) {
                            context
                                .read<HomeBloc>()
                                .isBiddingDecreaseLimitReach = true;
                            context
                                .read<HomeBloc>()
                                .isBiddingIncreaseLimitReach = false;
                          } else if (typedFare > homeBloc.maxFare!) {
                            context
                                .read<HomeBloc>()
                                .isBiddingIncreaseLimitReach = true;
                            context
                                .read<HomeBloc>()
                                .isBiddingDecreaseLimitReach = false;
                          } else {
                            context
                                .read<HomeBloc>()
                                .isBiddingIncreaseLimitReach = false;
                            context
                                .read<HomeBloc>()
                                .isBiddingDecreaseLimitReach = false;
                          }
                        }
                      },
                      decoration: InputDecoration(
                        hintText: homeBloc.acceptedRideFare,
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide()),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (!context
                          .read<HomeBloc>()
                          .isBiddingIncreaseLimitReach) {
                        homeBloc.add(
                            BiddingIncreaseOrDecreaseEvent(isIncrease: true));
                      }
                    },
                    child: Container(
                      width: size.width * 0.2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: context
                                  .read<HomeBloc>()
                                  .isBiddingIncreaseLimitReach
                              ? Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.2 * 255).toInt())
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5)),
                      padding: EdgeInsets.all(size.width * 0.025),
                      child: MyText(
                        text:
                            '+${double.parse(userData!.biddingAmountIncreaseOrDecrease.toString())}',
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                color: context
                                        .read<HomeBloc>()
                                        .isBiddingIncreaseLimitReach
                                    ? AppColors.black
                                    : AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.width * 0.05,
              ),
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomButton(
                      buttonName: AppLocalizations.of(context)!.accept,
                      onTap: () {
                        if (!context
                                .read<HomeBloc>()
                                .isBiddingIncreaseLimitReach &&
                            !context
                                .read<HomeBloc>()
                                .isBiddingDecreaseLimitReach) {
                          homeBloc.add(
                              AcceptBidRideEvent(id: homeBloc.choosenRide!));
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: true,
                            isScrollControlled: true,
                            enableDrag: false,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (_) {
                              return BlocProvider.value(
                                value: homeBloc,
                                child: Container(
                                  width: size.width,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: size.width * 0.1),
                                        MyText(
                                          text: ((double.parse(context
                                                          .read<HomeBloc>()
                                                          .bidRideAmount
                                                          .text) >=
                                                      context
                                                          .read<HomeBloc>()
                                                          .minFare!) ==
                                                  false)
                                              ? '${AppLocalizations.of(context)!.minimumRideFareError} (${userData!.currencySymbol} ${homeBloc.minFare!.toStringAsFixed(2)})'
                                              : '${AppLocalizations.of(context)!.maximumRideFareError} (${userData!.currencySymbol} ${homeBloc.maxFare!.toStringAsFixed(2)})',
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                        ),
                                        SizedBox(height: size.width * 0.1),
                                        CustomButton(
                                          width: size.width,
                                          buttonName:
                                              AppLocalizations.of(context)!.ok,
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(height: size.width * 0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      width: size.width * 0.41,
                      buttonColor: AppColors.primary,
                    ),
                    CustomButton(
                      buttonName: AppLocalizations.of(context)!.decline,
                      onTap: () {
                        homeBloc.add(
                            DeclineBidRideEvent(id: homeBloc.choosenRide!));
                      },
                      width: size.width * 0.41,
                      buttonColor: AppColors.red,
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
