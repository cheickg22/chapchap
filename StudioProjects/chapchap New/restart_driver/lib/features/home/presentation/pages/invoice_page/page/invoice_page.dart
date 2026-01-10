import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_payment_stream.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/invoice_page/widget/fare_breakdown_widget.dart';
import 'package:restart_tagxi/features/home/presentation/pages/review_page/page/review_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_loader.dart';

class InvoicePage extends StatelessWidget {
  final BuildContext cont;
  final RideRepository repository;
  const InvoicePage({super.key, required this.cont, required this.repository});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
                automaticallyImplyLeading: false,
                titleFontSize: 18,
                centerTitle: true,
                title: AppLocalizations.of(context)!.tripSummary),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.025),
                    Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1, color: AppColors.borderColor)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: size.width * 0.15,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Theme.of(context).dividerColor),
                                  child: (userData!
                                          .onTripRequest!.userImage.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: CachedNetworkImage(
                                            imageUrl: userData!
                                                .onTripRequest!.userImage,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: Loader(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Center(
                                              child: Text(""),
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(width: size.width * 0.05),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.55,
                                      child: MyText(
                                        text: userData!.onTripRequest!.userName
                                            .toUpperCase(),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                        textAlign: TextAlign.start,
                                        maxLines: 5,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star_border_outlined,
                                            size: size.width * 0.05,
                                            color:
                                                Theme.of(context).primaryColor),
                                        MyText(
                                          text: userData!.onTripRequest!.ratings
                                              .toString(),
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: AppColors.hintColor),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    MyText(
                                      text: userData!
                                          .onTripRequest!.requestNumber,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: AppColors.hintColor),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 1.25,
                      width: size.width * 0.9,
                      child: Column(
                        children: [
                          SizedBox(height: size.width * 0.05),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: size.width,
                                  padding: EdgeInsets.all(size.width * 0.05),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.borderColor)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .tripDetails,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 18,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .duration,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          MyText(
                                            text:
                                                '${userData!.onTripRequest!.totalTime} mins',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.hintColor,
                                                ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .distance,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .primaryColorDark),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          MyText(
                                            text:
                                                '${userData!.onTripRequest!.totalDistance} ${userData!.onTripRequest!.unit}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: AppColors.hintColor),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .typeOfRide,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .primaryColorDark),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          MyText(
                                            text: ((userData!.onTripRequest!.isOutstation == 0 &&
                                                    userData!.onTripRequest!.isRental ==
                                                        false &&
                                                    userData!.onTripRequest!.goodsType ==
                                                        '-'))
                                                ? AppLocalizations.of(context)!
                                                    .regular
                                                : (userData!.onTripRequest!.isOutstation == 0 &&
                                                        userData!.onTripRequest!.isRental ==
                                                            false &&
                                                        userData!.onTripRequest!.goodsType !=
                                                            '-')
                                                    ? AppLocalizations.of(context)!
                                                        .delivery
                                                    : (userData!.onTripRequest!.isOutstation == 0 &&
                                                            userData!.onTripRequest!.isRental ==
                                                                true &&
                                                            userData!
                                                                    .onTripRequest!
                                                                    .goodsType ==
                                                                '-')
                                                        ? AppLocalizations.of(context)!
                                                            .rental
                                                        : (userData!.onTripRequest!.isOutstation == 0 &&
                                                                userData!.onTripRequest!.isRental ==
                                                                    true &&
                                                                userData!.onTripRequest!.goodsType !=
                                                                    '-')
                                                            ? AppLocalizations.of(context)!
                                                                .deliveryRental
                                                            : (userData!.onTripRequest!.isOutstation == 1 &&
                                                                    userData!.onTripRequest!.isRental == false &&
                                                                    userData!.onTripRequest!.goodsType == '-')
                                                                ? AppLocalizations.of(context)!.outStation
                                                                : (userData!.onTripRequest!.isOutstation == 1 && userData!.onTripRequest!.isRental == false && userData!.onTripRequest!.goodsType != '-')
                                                                    ? AppLocalizations.of(context)!.deliveryOutStation
                                                                    : '',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontSize: 14,
                                                    color: AppColors.hintColor),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      Container(
                                        width: size.width,
                                        height: 1,
                                        color: AppColors.borderColors,
                                      ),
                                      SizedBox(height: size.width * 0.03),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(width: 1.6),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: Image.asset(
                                                  AppImages.circleDot,
                                                  width: size.width * 0.04,
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 0.01,
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 1),
                                                  child: MyText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    text: userData!
                                                        .onTripRequest!
                                                        .pickAddress,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(fontSize: 14),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (userData!.onTripRequest!
                                              .requestStops.isNotEmpty)
                                            ListView.separated(
                                              itemCount: userData!
                                                  .onTripRequest!
                                                  .requestStops
                                                  .length,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    // const DropIcon(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      child: Image.asset(
                                                        AppImages.mapPinNew,
                                                        width:
                                                            size.width * 0.05,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: size.width * 0.02,
                                                    ),
                                                    Expanded(
                                                      child: MyText(
                                                        text: userData!
                                                                .onTripRequest!
                                                                .requestStops[
                                                            index]['address'],
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontSize: 14,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  ],
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return SizedBox(
                                                    height:
                                                        size.width * 0.0025);
                                              },
                                            ),
                                          if (userData!.onTripRequest!
                                              .requestStops.isEmpty)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  // const DropIcon(),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    child: Image.asset(
                                                      AppImages.mapPinNew,
                                                      width: size.width * 0.05,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.005,
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: MyText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: context
                                                                .read<
                                                                    HomeBloc>()
                                                                .dropAddress
                                                                .isNotEmpty
                                                            ? context
                                                                .read<
                                                                    HomeBloc>()
                                                                .dropAddress
                                                            : userData!
                                                                .onTripRequest!
                                                                .dropAddress,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  fontSize: 14,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * 0.05,
                                ),
                                (userData!.onTripRequest!.isBidRide == '0' &&
                                        userData!.onTripRequest!.requestBill !=
                                            null)
                                    ? Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: AppColors.borderColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .fareBreakup,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 18,
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                            Column(
                                              children: [
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .basePrice !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name:
                                                          '${AppLocalizations.of(context)!.basePrice} (${userData!.onTripRequest!.requestBill!.baseDistance}  ${userData!.onTripRequest!.requestBill!.unit})',
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.basePrice}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .distancePrice !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name:
                                                          '${AppLocalizations.of(context)!.distancePrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.pricePerDistance} x ${userData!.onTripRequest!.requestBill!.calculatedDistance} ${userData!.onTripRequest!.requestBill!.unit})',
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.distancePrice}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .timePrice !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name:
                                                          '${AppLocalizations.of(context)!.timePrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.pricePerTime} x ${userData!.onTripRequest!.requestBill!.totalTime})',
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.timePrice}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .waitingCharge !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name:
                                                          '${AppLocalizations.of(context)!.waitingPrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.waitingChargePerMin} x ${userData!.onTripRequest!.requestBill!.calculatedWaitingTime} mins)',
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.waitingCharge}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .adminCommission !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: AppLocalizations.of(
                                                              context)!
                                                          .convFee,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.adminCommission}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .promoDiscount !=
                                                    0.0)
                                                  FareBreakdownWidget(
                                                    showBorder: true,
                                                    cont: context,
                                                    name: AppLocalizations.of(
                                                            context)!
                                                        .discount,
                                                    price:
                                                        '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.promoDiscount}',
                                                    textColor: AppColors.red,
                                                  ),
                                                if (userData!
                                                            .onTripRequest!
                                                            .requestBill!
                                                            .additionalChargesAmount !=
                                                        0 &&
                                                    userData!
                                                            .onTripRequest!
                                                            .requestBill!
                                                            .additionalChargesReason !=
                                                        null)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: userData!
                                                          .onTripRequest!
                                                          .requestBill!
                                                          .additionalChargesReason!,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.additionalChargesAmount}'),
                                                if (userData!
                                                            .onTripRequest!
                                                            .requestBill!
                                                            .airportSurgeFee !=
                                                        0 &&
                                                    userData!.onTripRequest!
                                                            .transportType ==
                                                        'taxi' &&
                                                    userData!.onTripRequest!
                                                            .isBidRide ==
                                                        '0')
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: AppLocalizations.of(
                                                              context)!
                                                          .airportSurgeFee,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.airportSurgeFee}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .serviceTax !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: AppLocalizations.of(
                                                              context)!
                                                          .taxes,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.serviceTax}'),
                                                if (userData!
                                                        .onTripRequest!
                                                        .requestBill!
                                                        .preferencePriceTotal !=
                                                    0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: AppLocalizations.of(
                                                              context)!
                                                          .preferenceTotal,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.preferencePriceTotal}'),
                                                if (context
                                                        .read<HomeBloc>()
                                                        .driverTips !=
                                                    0.0)
                                                  FareBreakdownWidget(
                                                      showBorder: true,
                                                      cont: context,
                                                      name: AppLocalizations.of(
                                                              context)!
                                                          .tips,
                                                      price:
                                                          '${userData!.onTripRequest!.requestBill!.currencySymbol} ${context.read<HomeBloc>().driverTips}'),
                                                SizedBox(
                                                  height: size.width * 0.05,
                                                ),
                                                if (userData!.onTripRequest!
                                                            .isBidRide !=
                                                        '0' &&
                                                    userData!.onTripRequest!
                                                            .requestBill !=
                                                        null)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.05,
                                                      ),
                                                      MyText(
                                                        text: context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .paymentChanged ==
                                                                ''
                                                            ? userData!
                                                                .onTripRequest!
                                                                .paymentType
                                                            : context
                                                                .read<
                                                                    HomeBloc>()
                                                                .paymentChanged
                                                                .replaceAll(
                                                                    'online',
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .card)
                                                                .replaceAll(
                                                                    'cash',
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .cash),
                                                        textStyle: AppTextStyle
                                                                .boldStyle()
                                                            .copyWith(
                                                                fontSize: 26,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            size.width * 0.025,
                                                      ),
                                                      MyText(
                                                        text:
                                                            '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount + context.read<HomeBloc>().driverTips)}',
                                                        textStyle: AppTextStyle
                                                                .boldStyle()
                                                            .copyWith(
                                                                fontSize: 30,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                      ),
                                                    ],
                                                  ),
                                                if (userData!.onTripRequest!
                                                            .isBidRide ==
                                                        '0' &&
                                                    userData!.onTripRequest!
                                                            .requestBill !=
                                                        null)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      MyText(
                                                        text: context
                                                                    .read<
                                                                        HomeBloc>()
                                                                    .paymentChanged ==
                                                                ''
                                                            ? userData!
                                                                .onTripRequest!
                                                                .paymentType
                                                            : context
                                                                .read<
                                                                    HomeBloc>()
                                                                .paymentChanged
                                                                .replaceAll(
                                                                    'online',
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .card)
                                                                .replaceAll(
                                                                    'cash',
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .cash),
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.025),
                                                      MyText(
                                                        text:
                                                            '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount + context.read<HomeBloc>().driverTips)}',
                                                        maxLines: 2,
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          MyText(
                                            text: context
                                                        .read<HomeBloc>()
                                                        .paymentChanged ==
                                                    ''
                                                ? userData!
                                                    .onTripRequest!.paymentType
                                                : context
                                                    .read<HomeBloc>()
                                                    .paymentChanged
                                                    .replaceAll(
                                                        'online',
                                                        AppLocalizations.of(
                                                                context)!
                                                            .card)
                                                    .replaceAll(
                                                        'cash',
                                                        AppLocalizations.of(
                                                                context)!
                                                            .cash),
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          SizedBox(width: size.width * 0.025),
                                          MyText(
                                            text: (context
                                                        .read<HomeBloc>()
                                                        .driverTips !=
                                                    0)
                                                ? '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount + context.read<HomeBloc>().driverTips)}'
                                                : '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount)}',
                                            maxLines: 2,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.width * 0.1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<RidePaymentStatus>(
                        stream: repository.paymentStatusStream,
                        builder: (context, snapshot) {
                          final status = snapshot.hasData
                              ? snapshot.data!
                              : RidePaymentStatus(
                                  isPaid: false, changedPayment: '');
                          final isPaymentChanged =
                              status.changedPayment.trim().isNotEmpty;
                          final paymentType = isPaymentChanged
                              ? status.changedPayment.toLowerCase().trim()
                              : userData!.onTripRequest!.paymentOpt == '1'
                                  ? 'cash'
                                  : userData!.onTripRequest!.paymentOpt == '2'
                                      ? 'wallet'
                                      : 'online';
                          return Expanded(
                            child: CustomButton(
                              width: size.width,
                              buttonName: (userData!.onTripRequest!.isPaid == 0)
                                  ? (paymentType == 'cash')
                                      ? AppLocalizations.of(context)!
                                          .paymentRecieved
                                      : ((paymentType == 'online' ||
                                                  paymentType == 'card') &&
                                              !status.isPaid)
                                          ? AppLocalizations.of(context)!
                                              .waitingForPayment
                                          : AppLocalizations.of(context)!
                                              .confirm
                                  : AppLocalizations.of(context)!.confirm,
                              isLoader: (paymentType == 'online' ||
                                          paymentType == 'card') &&
                                      userData!.onTripRequest!.isPaid == 0
                                  ? (status.isPaid)
                                      ? false
                                      : true
                                  : false,
                              isLoaderShowWithText: (paymentType == 'online' ||
                                          paymentType == 'card') &&
                                      userData!.onTripRequest!.isPaid == 0
                                  ? (status.isPaid)
                                      ? false
                                      : true
                                  : false,
                              textSize: (paymentType == 'online' ||
                                          paymentType == 'card') &&
                                      userData!.onTripRequest!.isPaid == 0
                                  ? status.isPaid
                                      ? 16
                                      : 16
                                  : 14,
                              onTap: ((paymentType == 'online' ||
                                          paymentType == 'card') &&
                                      userData!.onTripRequest!.isPaid == 0 &&
                                      !status.isPaid)
                                  ? () {}
                                  : () {
                                      if (userData!.onTripRequest!.isPaid ==
                                          0) {
                                        context
                                            .read<HomeBloc>()
                                            .add(PaymentRecievedEvent());
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ReviewPage.routeName,
                                            (route) => false);
                                        context
                                            .read<HomeBloc>()
                                            .add(AddReviewEvent());
                                      }
                                    },
                            ),
                          );
                        },
                      )
                    ],
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
