import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/functions.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/core/utils/custom_timer.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_slider/custom_sliderbutton.dart';

class AcceptRejectWidget extends StatelessWidget {
  final BuildContext cont;
  const AcceptRejectWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          double dist = 0.0;
          if (cont.read<HomeBloc>().currentLatLng != null &&
              userData!.metaRequest != null) {
            dist = calculateDistance(
              lat1: userData!.metaRequest!.pickLat,
              lon1: userData!.metaRequest!.pickLng,
              lat2: cont.read<HomeBloc>().currentLatLng!.latitude,
              lon2: cont.read<HomeBloc>().currentLatLng!.longitude,
              unit: userData?.distanceUnit ?? 'km',
            );
          }
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.width * 0.05),
                if (userData!.metaRequest!.isLater == true)
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: MyText(
                          text:
                              '${AppLocalizations.of(context)!.rideAtText} - ${userData!.metaRequest!.tripStartTime}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                if (userData!.metaRequest!.isRental)
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.9,
                        child: MyText(
                          text:
                              '${AppLocalizations.of(context)!.rentalPackageText} - ${userData!.metaRequest!.rentalPackageName}',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                Container(
                  width: size.width * 0.9,
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.5, color: Theme.of(context).disabledColor),
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.darkGrey.withAlpha((0.5 * 255).toInt())),
                  child: Row(
                    children: [
                      Container(
                        width: size.width * 0.128,
                        height: size.width * 0.128,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(
                                    userData!.metaRequest!.userImage),
                                fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * 0.3,
                              child: MyText(
                                text: userData!.metaRequest!.userName ?? '',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                maxLines: 5,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_sharp,
                                  size: 15,
                                  color: Theme.of(context).primaryColor,
                                ),
                                MyText(
                                  text:
                                      '${(dist).toStringAsFixed(2)} ${userData?.distanceUnit.toUpperCase() ?? 'KM'} ${AppLocalizations.of(context)!.away}',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    MyText(
                                      text: userData!.metaRequest!.userRatings
                                          .toString(),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (userData!.metaRequest!.userCompletedRideCount
                                    .toString() !=
                                '0')
                              MyText(
                                text:
                                    '${userData!.metaRequest!.userCompletedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                      if (userData!.metaRequest!.showRequestEtaAmount == true)
                        Column(
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.rideFare,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                            ),
                            MyText(
                              text:
                                  '${userData!.metaRequest!.currencySymbol} ${userData!.metaRequest!.requestEtaAmount}',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                      color: AppColors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: size.width * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  userData!.metaRequest!.paymentOpt == '1'
                                      ? Icons.payments_outlined
                                      : userData!.metaRequest!.paymentOpt == '0'
                                          ? Icons.credit_card_rounded
                                          : Icons
                                              .account_balance_wallet_outlined,
                                  size: size.width * 0.05,
                                  color: AppColors.green,
                                ),
                                SizedBox(width: size.width * 0.025),
                                MyText(
                                    text: userData!.metaRequest!.paymentOpt ==
                                            '1'
                                        ? AppLocalizations.of(context)!.cash
                                        : userData!.metaRequest!.paymentOpt ==
                                                '2'
                                            ? AppLocalizations.of(context)!
                                                .wallet
                                            : AppLocalizations.of(context)!
                                                .card,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        )
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      const PickupIcon(),
                      SizedBox(width: size.width * 0.025),
                      Expanded(
                          child: MyText(
                        text: userData!.metaRequest!.pickAddress,
                        maxLines: 5,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                                fontSize: 12, fontWeight: FontWeight.w500),
                      ))
                    ],
                  ),
                ),
                if (userData!.metaRequest!.transportType == 'delivery' &&
                    userData!.metaRequest!.pickPocInstruction != null &&
                    userData!.metaRequest!.pickPocInstruction != '') ...[
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
                            text: userData!.metaRequest!.pickPocInstruction,
                            maxLines: 5,
                            textStyle: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
                if (userData!.metaRequest!.requestStops.isEmpty &&
                    userData!.metaRequest!.dropAddress != null)
                  Column(
                    children: [
                      SizedBox(height: size.width * 0.03),
                      SizedBox(
                        width: size.width * 0.91,
                        child: Row(
                          children: [
                            const DropIcon(),
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                                child: MyText(
                              text: userData!.metaRequest!.dropAddress,
                              maxLines: 5,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                            ))
                          ],
                        ),
                      ),
                      if (userData!.metaRequest!.dropPocInstruction != null &&
                          userData!.metaRequest!.dropPocInstruction != '')
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
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: size.width * 0.01),
                            SizedBox(
                              width: size.width * 0.8,
                              child: MyText(
                                  text:
                                      userData!.metaRequest!.dropPocInstruction,
                                  maxLines: 5,
                                  textStyle:
                                      Theme.of(context).textTheme.bodySmall),
                            ),
                          ],
                        ),
                    ],
                  ),
                if (userData!.metaRequest!.requestStops.isNotEmpty)
                  Column(
                    children: [
                      for (var i = 0;
                          i < userData!.metaRequest!.requestStops.length;
                          i++)
                        Column(
                          children: [
                            SizedBox(height: size.width * 0.03),
                            SizedBox(
                              width: size.width * 0.91,
                              child: Row(
                                children: [
                                  const DropIcon(),
                                  SizedBox(width: size.width * 0.025),
                                  Expanded(
                                      child: MyText(
                                    text: userData!.metaRequest!.requestStops[i]
                                        ['address'],
                                    maxLines: 5,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                  ))
                                ],
                              ),
                            ),
                            if (userData!.metaRequest!.requestStops[i]
                                        ['poc_instruction'] !=
                                    null &&
                                userData!.metaRequest!.requestStops[i]
                                        ['poc_instruction'] !=
                                    'null' &&
                                userData!.metaRequest!.requestStops[i]
                                        ['poc_instruction'] !=
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
                                            .bodySmall!),
                                  ),
                                  SizedBox(height: size.width * 0.01),
                                  SizedBox(
                                    width: size.width * 0.8,
                                    child: MyText(
                                        text: userData!.metaRequest!
                                            .requestStops[i]['poc_instruction'],
                                        maxLines: 5,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!),
                                  ),
                                ],
                              ),
                          ],
                        )
                    ],
                  ),
                SizedBox(height: size.width * 0.038),
                if (userData!.metaRequest!.transportType == 'delivery')
                  Column(
                    children: [
                      SizedBox(
                        width: size.width * 0.8,
                        child: MyText(
                          text:
                              '${userData!.metaRequest!.goodsType} (${userData!.metaRequest!.goodsQuantity})',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: size.width * 0.038),
                    ],
                  ),
                if (userData!.metaRequest!.isPreferenceList != null &&
                    userData!.metaRequest!.isPreferenceList.data.length >= 1)
                  Row(
                    children: [
                      MyText(
                          text:
                              '${AppLocalizations.of(context)!.preferences} : ',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark)),
                      const SizedBox(
                        width: 5,
                      ),
                      for (int i = 0;
                          i <
                              userData!
                                  .metaRequest!.isPreferenceList.data.length;
                          i++) ...[
                        Container(
                          margin: EdgeInsets.all(size.width * 0.0025),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: userData!
                                .metaRequest!.isPreferenceList.data[i].icon,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        if (i !=
                            userData!
                                    .metaRequest!.isPreferenceList.data.length -
                                1) //avoid comma at end
                          const Text(
                            ",",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ]
                    ],
                  ),
                if (userData!.metaRequest!.transportType == 'taxi' &&
                    userData!.metaRequest!.pickPocInstruction != null &&
                    userData!.metaRequest!.pickPocInstruction != '')
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          MyText(
                              text:
                                  '${AppLocalizations.of(context)!.instruction} : ',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark)),
                          Expanded(
                            child: MyText(
                                maxLines: 3,
                                text: userData!.metaRequest!.pickPocInstruction
                                    ?.toString(),
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.only(
                      left: size.width * 0.1, right: size.width * 0.1),
                  width: size.width,
                  height: size.width * 0.115,
                  color: AppColors.darkGrey,
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.warning,
                        height: size.width * 0.04,
                        width: size.width * 0.04,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: MyText(
                          text: AppLocalizations.of(context)!
                              .rideWillCancelAutomatically
                              .toString()
                              .replaceAll(
                                  '1111', userData!.acceptDuration.toString()),
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.black
                                        .withAlpha((0.6 * 255).toInt()),
                                  ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 5),
                      CustomPaint(
                        painter: CustomTimer(
                          width: 5.0,
                          color: AppColors.white,
                          backgroundColor: AppColors.primary,
                          values: (context.read<HomeBloc>().timer) > 0
                              ? 1 -
                                  ((userData!.acceptDuration -
                                          context.read<HomeBloc>().timer) /
                                      userData!.acceptDuration)
                              : 1,
                        ),
                        child: Container(
                          height: size.width * 0.077,
                          width: size.width * 0.077,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Accept Button
                      CustomSliderButton(
                        isLoader: context.read<HomeBloc>().isAcceptLoading,
                        buttonName: AppLocalizations.of(context)!.slideToAccept,
                        onSlideSuccess: () async {
                          context.read<HomeBloc>().add(
                                AcceptRejectEvent(
                                  requestId: userData!.metaRequest!.id,
                                  status: 1,
                                ),
                              );
                          return true;
                        },
                        height: 50.0,
                        width: size.width * 0.68,
                        buttonColor: AppColors.green,
                        textColor: Colors.white,
                        sliderIcon:
                            const Icon(Icons.check, color: Colors.white),
                      ),

                      // Reject Button
                      InkWell(
                        onTap: () {
                          if (!context.read<HomeBloc>().isRejectLoading) {
                            context.read<HomeBloc>().add(
                                  AcceptRejectEvent(
                                    requestId: userData!.metaRequest!.id,
                                    status: 0,
                                  ),
                                );
                          }
                        },
                        child: Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                            color: context.read<HomeBloc>().isRejectLoading
                                ? Colors.grey
                                : AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: context.read<HomeBloc>().isRejectLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * 0.1),
              ],
            ),
          );
        },
      ),
    );
  }
}
