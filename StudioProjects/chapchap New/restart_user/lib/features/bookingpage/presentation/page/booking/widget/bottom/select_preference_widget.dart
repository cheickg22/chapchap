import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../common/app_arguments.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../application/booking_bloc.dart';

class SelectPreferenceWidget extends StatefulWidget {
  final BuildContext cont;
  final dynamic thisValue;
  final BookingPageArguments arg;
  const SelectPreferenceWidget(
      {super.key, required this.cont, this.thisValue, required this.arg});

  @override
  State<SelectPreferenceWidget> createState() => _SelectPreferenceWidgetState();
}

class _SelectPreferenceWidgetState extends State<SelectPreferenceWidget> {
  @override
  void initState() {
    super.initState();
    final bloc = widget.cont.read<BookingBloc>();
    bloc.selectPreference = List<int>.from(bloc.selectedPreferenceDetailsList);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: widget.cont.read<BookingBloc>(),
      child: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            final bookingBloc = context.read<BookingBloc>();
            return SafeArea(
              child: Container(
                width: size.width,
                padding: EdgeInsets.all(size.width * 0.05),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.preference,
                          textStyle:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                        ),
                        InkWell(
                          onTap: () {
                            final bloc = context.read<BookingBloc>();
                            // Reset temp selection to last confirmed values
                            bloc.tempSelectPreference = List<int>.from(
                                bloc.selectedPreferenceDetailsList);
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.cancel_outlined),
                        ),
                      ],
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: (bookingBloc.isRentalRide == false)
                          ? Column(
                              children: [
                                (bookingBloc.preferenceDetailsList!.isEmpty)
                                    ? Center(
                                        child: Column(
                                          children: [
                                            SizedBox(height: size.height * 0.1),
                                            Icon(
                                              Icons.info_outline,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .preferenceNotAvailable,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(
                                          bookingBloc
                                              .preferenceDetailsList!.length,
                                          (index) {
                                            final prefId = bookingBloc
                                                .preferenceDetailsList![index]
                                                .preferenceId;
                                            final price = bookingBloc
                                                .preferenceDetailsList![index]
                                                .price;
                                            // final isSelected = bookingBloc.selectPreference.contains(prefId);
                                            final isSelected = bookingBloc
                                                .tempSelectPreference
                                                .contains(prefId);

                                            return Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor:
                                                    Theme.of(context)
                                                        .primaryColorDark,
                                              ),
                                              child: CheckboxListTile(
                                                value: isSelected,
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                onChanged: (value) {
                                                  bookingBloc.add(
                                                      SelectedPreferenceEvent(
                                                          prefId: prefId,
                                                          isSelected:
                                                              value ?? false));
                                                },
                                                title: MyText(
                                                  text: bookingBloc
                                                      .preferenceDetailsList![
                                                          index]
                                                      .name,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                subtitle: (price != 0)
                                                    ? MyText(
                                                        text:
                                                            '${bookingBloc.userData!.wallet.data.currencySymbol} ${price.toString()}',
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      )
                                                    : const SizedBox(),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                              ],
                            )
                          : Column(
                              children: [
                                (bookingBloc
                                        .rentalPreferenceDetailsList!.isEmpty)
                                    ? Center(
                                        child: Column(
                                          children: [
                                            SizedBox(height: size.height * 0.1),
                                            Icon(
                                              Icons.info_outline,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .preferenceNotAvailable,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(
                                          bookingBloc
                                              .rentalPreferenceDetailsList!
                                              .length,
                                          (index) {
                                            final prefId = bookingBloc
                                                .rentalPreferenceDetailsList![
                                                    index]
                                                .preferenceId;
                                            final price = bookingBloc
                                                .rentalPreferenceDetailsList![
                                                    index]
                                                .price;
                                            // final isSelected = bookingBloc.selectPreference.contains(prefId);
                                            final isSelected = bookingBloc
                                                .tempSelectPreference
                                                .contains(prefId);
                                            return Theme(
                                              data: ThemeData(
                                                unselectedWidgetColor:
                                                    Theme.of(context)
                                                        .primaryColorDark,
                                              ),
                                              child: CheckboxListTile(
                                                value: isSelected,
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                onChanged: (value) {
                                                  bookingBloc.add(
                                                      SelectedPreferenceEvent(
                                                          prefId: prefId,
                                                          isSelected:
                                                              value ?? false));
                                                },
                                                title: MyText(
                                                  text: bookingBloc
                                                      .rentalPreferenceDetailsList![
                                                          index]
                                                      .name,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                subtitle: (price != 0)
                                                    ? MyText(
                                                        text:
                                                            '${bookingBloc.userData!.wallet.data.currencySymbol} ${price.toString()}',
                                                        textStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      )
                                                    : const SizedBox(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              ],
                            ),
                    )),
                    CustomButton(
                      width: size.width * 0.84,
                      borderRadius: size.width * 0.025,
                      isBorder: true,
                      buttonColor: Theme.of(context).scaffoldBackgroundColor,
                      textColor: Theme.of(context).primaryColor,
                      buttonName: AppLocalizations.of(context)!.confirm,
                      onTap: () {
                        final bloc = context.read<BookingBloc>();
                        final bookingBloc = context.read<BookingBloc>();

                        bloc.add(ConfirmPreferenceSelectionEvent(
                          arg: widget.arg,
                          // selectedPreferences: List<int>.from(bloc.selectPreference),
                          selectedPreferences:
                              List<int>.from(bloc.tempSelectPreference),
                        ));

                        if (bookingBloc.isRentalRide == true) {
                          // For rental rides
                          bookingBloc.add(BookingRentalEtaRequestEvent(
                            picklat: widget.arg.picklat,
                            picklng: widget.arg.picklng,
                            transporttype: bookingBloc.transportType,
                            // preferenceId: bloc.selectPreference.isNotEmpty ? bloc.selectPreference : null,
                            preferenceId: bloc.tempSelectPreference.isNotEmpty
                                ? bloc.tempSelectPreference
                                : null,
                          ));
                        } else {
                          // For non-rental rides
                          bookingBloc.add(BookingEtaRequestEvent(
                            picklat: widget.arg.picklat,
                            picklng: widget.arg.picklng,
                            droplat: widget.arg.droplat,
                            droplng: widget.arg.droplng,
                            ridetype: 1,
                            transporttype: widget.arg.transportType,
                            distance: bookingBloc.distance,
                            duration: bookingBloc.duration,
                            polyLine: bookingBloc.polyLine,
                            pickupAddressList: widget.arg.pickupAddressList,
                            dropAddressList: widget.arg.stopAddressList,
                            isOutstationRide: widget.arg.isOutstationRide,
                            isWithoutDestinationRide:
                                widget.arg.isWithoutDestinationRide ?? false,
                            preferenceId: bloc.tempSelectPreference.isNotEmpty
                                ? bloc.tempSelectPreference
                                : null,
                          ));
                        }
                        Navigator.pop(context, bloc.tempSelectPreference);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
