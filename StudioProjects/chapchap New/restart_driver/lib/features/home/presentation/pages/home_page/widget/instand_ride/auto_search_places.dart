import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../../../common/app_constants.dart';
import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class AutoSearchPlacesWidget extends StatelessWidget {
  final BuildContext cont;

  const AutoSearchPlacesWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            height: size.height,
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.05),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                SizedBox(
                    height:
                        MediaQuery.paddingOf(context).top + size.width * 0.15),
                SizedBox(
                  width: size.width * 0.9,
                  child: MyText(
                      text: (context.read<HomeBloc>().autoSuggestionSearching)
                          ? AppLocalizations.of(context)!.searching
                          : AppLocalizations.of(context)!.searchResult,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: size.width * 0.05),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount:
                            context.read<HomeBloc>().autoCompleteAddress.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) {
                          return InkWell(
                            onTap: () {
                              final address = context
                                  .read<HomeBloc>()
                                  .autoCompleteAddress[i];

                              if (mapType == 'google_map') {
                                context.read<HomeBloc>().add(
                                    GeocodingAddressEvent(
                                        placeId: address.placeId,
                                        address: address.address!));
                              } else {
                                if (address.lat != null &&
                                    address.lon != null &&
                                    double.tryParse(address.lat.toString()) !=
                                        null &&
                                    double.tryParse(address.lon.toString()) !=
                                        null) {
                                  context
                                      .read<HomeBloc>()
                                      .add(GeocodingAddressEvent(
                                          placeId: address.placeId,
                                          address: address.displayName!,
                                          position: LatLng(
                                            double.parse(
                                                address.lat.toString()),
                                            double.parse(
                                                address.lon.toString()),
                                          )));
                                } else {
                                  debugPrint(
                                      "Invalid latitude or longitude for address: ${address.displayName}");
                                }
                              }
                            },
                            child: Container(
                              width: size.width * 0.9,
                              padding: EdgeInsets.fromLTRB(
                                  0, size.width * 0.05, 0, size.width * 0.05),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AppColors.darkGrey))),
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 0.07,
                                    height: size.width * 0.07,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.grey),
                                    child: Icon(
                                      Icons.location_on_sharp,
                                      size: size.width * 0.05,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.05),
                                  Expanded(
                                      child: MyText(
                                    text: (mapType == 'google_map')
                                        ? context
                                            .read<HomeBloc>()
                                            .autoCompleteAddress[i]
                                            .address
                                        : context
                                            .read<HomeBloc>()
                                            .autoCompleteAddress[i]
                                            .displayName,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: AppColors.darkGrey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: GoogleFonts.notoSans()
                                                .fontFamily),
                                    maxLines: 5,
                                  ))
                                ],
                              ),
                            ),
                          );
                        },
                      )
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
