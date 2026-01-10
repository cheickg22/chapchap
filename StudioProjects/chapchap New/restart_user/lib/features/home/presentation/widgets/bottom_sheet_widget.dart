import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_divider.dart';
import '../../../../core/utils/custom_navigation_icon.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'banner_widget.dart';
import 'home_on_going_rides.dart';
import 'recent_search_places_widget.dart';
import 'services_module_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final HomeBloc home;

  const BottomSheetWidget({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: home,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final homeBloc = context.read<HomeBloc>();
            if (homeBloc.userData == null) {
              return const SizedBox.shrink(); // Or a loading indicator
            }
            // Access the current sheetSize directly from HomeBloc
            double sheetSize = homeBloc.sheetSize;
            double maxSheetSize = homeBloc.maxChildSize;
            double recentSearchWidth =
                sheetSize == maxSheetSize ? size.width * 0.9 : size.width * 0.9;

            return Container(
              height: size.height,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!homeBloc.isSheetAtTop) ...[
                    SizedBox(height: size.width * 0.03),
                    Center(
                        child: CustomDivider(
                            height: 5,
                            width: size.width * 0.2,
                            color: Theme.of(context)
                                .dividerColor
                                .withAlpha((0.4 * 255).toInt()))),
                    SizedBox(height: size.width * 0.02),
                  ],
                  if (homeBloc.isSheetAtTop)
                    SizedBox(height: size.width * 0.15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: size.width * 0.0,
                            left: size.width * 0,
                            top: size.width * 0.020,
                            bottom: size.width * 0.020),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.02),
                                if (homeBloc.isSheetAtTop == true &&
                                    homeBloc.userData != null)
                                  Flexible(
                                    child: NavigationIconWidget(
                                      icon: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                                  AccountPage.routeName,
                                                  arguments:
                                                      AccountPageArguments(
                                                          userData: homeBloc
                                                              .userData!))
                                              .then((value) {
                                            if (!context.mounted) return;
                                            homeBloc.add(GetDirectionEvent());
                                            if (value != null) {
                                              homeBloc.userData =
                                                  value as UserDetail;
                                              homeBloc.add(UpdateEvent());
                                            }
                                          });
                                        },
                                        child: Icon(
                                          Icons.menu,
                                          size: 20,
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                      ),
                                      isShadowWidget: true,
                                    ),
                                  ),
                                if (homeBloc.isSheetAtTop)
                                  SizedBox(width: size.width * 0.02),
                                Flexible(
                                  flex: homeBloc
                                      .calculateResponsiveFlex(size.width),
                                  child: InkWell(
                                    onTap: () {
                                      if (homeBloc.userData != null) {
                                        homeBloc.add(DestinationSelectEvent(
                                            isPickupChange: false,
                                            transportType: homeBloc
                                                .selectedServiceType!
                                                .transportType));
                                      }
                                    },
                                    child: AnimatedContainer(
                                      transformAlignment: Alignment.centerRight,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      width: recentSearchWidth,
                                      padding:
                                          EdgeInsets.all(size.width * 0.02),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withAlpha((0.5 * 255).toInt()),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .shadowColor
                                                .withAlpha((0.1 * 255).toInt()),
                                            blurRadius: 15,
                                            offset: const Offset(0, 1),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width * 0.075,
                                            height: size.width * 0.075,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .disabledColor
                                                  .withAlpha(
                                                      (0.5 * 255).toInt()),
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.search,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Expanded(
                                            // Place Expanded inside Row to prevent overflow here
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .whereAreYouGoing,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColorDark
                                                          .withAlpha((0.5 * 255)
                                                              .toInt()),
                                                      fontSize: 16),
                                            ),
                                          ),
                                          if (homeBloc.userData != null &&
                                              (homeBloc.userData!
                                                      .showRideWithoutDestination ==
                                                  "1") &&
                                              (homeBloc.userData!
                                                          .enableModulesForApplications ==
                                                      'taxi' ||
                                                  homeBloc.userData!
                                                          .enableModulesForApplications ==
                                                      'both'))
                                            InkWell(
                                              onTap: () {
                                                if (homeBloc.userData != null) {
                                                  homeBloc.add(
                                                      RideWithoutDestinationEvent());
                                                }
                                              },
                                              child: Container(
                                                height: size.width * 0.075,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: AppColors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .skip,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            color: AppColors
                                                                .primary),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05),
                              child: ServicesModuleWidget(home: homeBloc),
                            ),

                            // ON GOING RIDES
                            if (homeBloc.isMultipleRide) ...[
                              SizedBox(height: size.width * 0.05),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bolt),
                                    MyText(
                                        text: AppLocalizations.of(context)!
                                            .onGoingRides,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColorDark)),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.03),
                                child: HomeOnGoingRidesWidget(cont: context),
                              ),
                            ],
                            // Recent search places
                            if (homeBloc.recentSearchPlaces.isNotEmpty) ...[
                              SizedBox(
                                  height: homeBloc.isSheetAtTop == false
                                      ? size.width * 0.01
                                      : size.width * 0.02),
                              RecentSearchPlacesWidget(cont: context)
                            ],
                            // Banner
                            if (homeBloc.isSheetAtTop == true &&
                                homeBloc.userData != null &&
                                homeBloc.userData!.bannerImage != null &&
                                homeBloc
                                    .userData!.bannerImage.data.isNotEmpty) ...[
                              SizedBox(height: size.width * 0.025),
                              BannerWidget(cont: context),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.01),
                  SizedBox(height: size.width * 0.1),
                  Expanded(
                      child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.bottomBackground),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
                ],
              ),
            );
          },
        ));
  }
}
