import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_payment_stream.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/features/home/presentation/pages/invoice_page/widget/fare_breakdown_widget.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../common/pickup_icon.dart';
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
                backgroundColor: AppColors.secondary,
                centerTitle: true,
                title: AppLocalizations.of(context)!.tripSummary),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.05),
                    Container(
                      // height: size.width * 0.4,
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Theme.of(context).dividerColor, width: 1),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: size.width * 0.2,
                                  width: size.width * 0.2,
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
                                            color:
                                                Theme.of(context).primaryColor),
                                        MyText(
                                          text: userData!.onTripRequest!.ratings
                                              .toString(),
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: size.width * 0.025),
                            MyText(
                              text: userData!.onTripRequest!.requestNumber,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.76,
                      width: size.width * 0.9,
                      child: Column(
                        children: [
                          SizedBox(height: size.width * 0.05),
                          Expanded(
                            child: Column(
                              children: [
                                ClipPath(
                                  clipper: _SemiCircleClipper(),
                                  child: Container(
                                    padding: EdgeInsets.all(size.width * 0.05),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .hintColor
                                          .withAlpha((0.5 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            RotatedBox(
                                              quarterTurns: (context
                                                          .read<HomeBloc>()
                                                          .textDirection ==
                                                      'rtl')
                                                  ? 2
                                                  : 0,
                                              child: Icon(
                                                Icons.circle,
                                                size: 6,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .duration,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: size.width * 0.05),
                                        Row(
                                          children: [
                                            RotatedBox(
                                              quarterTurns: (context
                                                          .read<HomeBloc>()
                                                          .textDirection ==
                                                      'rtl')
                                                  ? 2
                                                  : 0,
                                              child: Icon(
                                                Icons.circle,
                                                size: 6,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .distance,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: size.width * 0.05),
                                        Row(
                                          children: [
                                            RotatedBox(
                                              quarterTurns: (context
                                                          .read<HomeBloc>()
                                                          .textDirection ==
                                                      'rtl')
                                                  ? 2
                                                  : 0,
                                              child: Icon(
                                                Icons.circle,
                                                size: 6,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .typeOfRide,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            MyText(
                                              text: (userData!.onTripRequest!
                                                          .isOutstation ==
                                                      1)
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .outStation
                                                  : (userData!.onTripRequest!
                                                              .isRental ==
                                                          true)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .rental
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .regular,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: size.width * 0.05),
                                        Container(
                                          width: double.infinity,
                                          height: 1,
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                        SizedBox(height: size.width * 0.03),
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const SizedBox(width: 1.6),
                                                  const PickupIcon(),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: MyText(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        text: userData!
                                                            .onTripRequest!
                                                            .pickAddress,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall,
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
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const DropIcon(),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Expanded(
                                                          child: MyText(
                                                            text: userData!
                                                                    .onTripRequest!
                                                                    .requestStops[
                                                                index]['address'],
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return SizedBox(
                                                        height: size.width *
                                                            0.0025);
                                                  },
                                                ),
                                              if (userData!.onTripRequest!
                                                  .requestStops.isEmpty)
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      const DropIcon(),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          child: MyText(
                                                            overflow:
                                                                TextOverflow
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
                                                            textStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (userData!.onTripRequest!.isBidRide == '0' &&
                                    userData!.onTripRequest!.requestBill !=
                                        null)
                                  Column(
                                    children: [
                                      SizedBox(height: size.width * 0.05),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .fareBreakup,
                                        textStyle: AppTextStyle.boldStyle()
                                            .copyWith(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      Column(
                                        children: [
                                          if (userData!.onTripRequest!
                                                  .requestBill!.basePrice !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name:
                                                    '${AppLocalizations.of(context)!.basePrice} (${userData!.onTripRequest!.requestBill!.baseDistance}  ${userData!.onTripRequest!.requestBill!.unit})',
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.basePrice.toStringAsFixed(2)}'),
                                          if (userData!.onTripRequest!
                                                  .requestBill!.distancePrice !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name:
                                                    '${AppLocalizations.of(context)!.distancePrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.pricePerDistance} x ${userData!.onTripRequest!.requestBill!.calculatedDistance} ${userData!.onTripRequest!.requestBill!.unit})',
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.distancePrice.toStringAsFixed(2)}'),
                                          if (userData!.onTripRequest!
                                                  .requestBill!.timePrice !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name:
                                                    '${AppLocalizations.of(context)!.timePrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.pricePerTime} x ${userData!.onTripRequest!.requestBill!.totalTime})',
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.timePrice.toStringAsFixed(2)}'),
                                          if (userData!.onTripRequest!
                                                  .requestBill!.waitingCharge !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name:
                                                    '${AppLocalizations.of(context)!.waitingPrice} (${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.waitingChargePerMin} x ${userData!.onTripRequest!.requestBill!.calculatedWaitingTime} mins)',
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.waitingCharge.toStringAsFixed(2)}'),
                                          if (userData!
                                                  .onTripRequest!
                                                  .requestBill!
                                                  .adminCommission !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name: AppLocalizations.of(
                                                        context)!
                                                    .convFee,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.adminCommission.toStringAsFixed(2)}'),
                                          if (userData!.onTripRequest!
                                                  .requestBill!.promoDiscount !=
                                              0.0)
                                            FareBreakdownWidget(
                                              cont: context,
                                              name:
                                                  AppLocalizations.of(context)!
                                                      .discount,
                                              price:
                                                  '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.promoDiscount.toStringAsFixed(2)}',
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
                                                cont: context,
                                                name: userData!
                                                    .onTripRequest!
                                                    .requestBill!
                                                    .additionalChargesReason!,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.additionalChargesAmount.toStringAsFixed(2)}'),
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
                                                cont: context,
                                                name: AppLocalizations.of(
                                                        context)!
                                                    .airportSurgeFee,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.airportSurgeFee.toStringAsFixed(2)}'),
                                          if (userData!.onTripRequest!
                                                  .requestBill!.serviceTax !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name: AppLocalizations.of(
                                                        context)!
                                                    .taxes,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.serviceTax.toStringAsFixed(2)}'),
                                          if (userData!
                                                  .onTripRequest!
                                                  .requestBill!
                                                  .preferencePriceTotal !=
                                              0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name: AppLocalizations.of(
                                                        context)!
                                                    .preferenceTotal,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${userData!.onTripRequest!.requestBill!.preferencePriceTotal.toStringAsFixed(2)}'),
                                          if (context
                                                  .read<HomeBloc>()
                                                  .driverTips !=
                                              0.0)
                                            FareBreakdownWidget(
                                                cont: context,
                                                name: AppLocalizations.of(
                                                        context)!
                                                    .tips,
                                                price:
                                                    '${userData!.onTripRequest!.requestBill!.currencySymbol} ${context.read<HomeBloc>().driverTips.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                if (userData!.onTripRequest!.isBidRide != '0' &&
                                    userData!.onTripRequest!.requestBill !=
                                        null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: size.width * 0.05,
                                      ),
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
                                        textStyle: AppTextStyle.boldStyle()
                                            .copyWith(
                                                fontSize: 26,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: size.width * 0.025,
                                      ),
                                      MyText(
                                        text:
                                            '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount + context.read<HomeBloc>().driverTips)}',
                                        textStyle: AppTextStyle.boldStyle()
                                            .copyWith(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w500),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: context.read<HomeBloc>().paymentChanged ==
                                      ''
                                  ? userData!.onTripRequest!.paymentType
                                  : context
                                      .read<HomeBloc>()
                                      .paymentChanged
                                      .replaceAll('online',
                                          AppLocalizations.of(context)!.card)
                                      .replaceAll('cash',
                                          AppLocalizations.of(context)!.cash),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: size.width * 0.025),
                            MyText(
                              text:
                                  '${userData!.onTripRequest!.requestBill!.currencySymbol} ${(userData!.onTripRequest!.requestBill!.totalAmount + context.read<HomeBloc>().driverTips)}',
                              maxLines: 2,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
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
                                      : 14
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

class _SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final radius = size.height * 0.05;
    final centerY = size.height * 0.6;

    path.moveTo(0, 0);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, centerY - radius);

    path.arcToPoint(
      Offset(size.width, centerY + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);

    path.lineTo(0, centerY + radius);

    path.arcToPoint(
      Offset(0, centerY - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
