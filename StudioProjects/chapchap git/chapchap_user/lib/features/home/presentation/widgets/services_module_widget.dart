import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../application/home_bloc.dart';
import '../../../moov_money/presentation/pages/moov_money_home_page.dart';

class ServicesModuleWidget extends StatelessWidget {
  final HomeBloc home;

  const ServicesModuleWidget({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: home,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.width * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (homeBloc.rideModules.length > 1)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.15),
                                Theme.of(context).primaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MyText(
                          text: AppLocalizations.of(context)?.service ?? 'Service',
                          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  // View All Services
                  if (homeBloc.rideModules.length > 4)
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return BlocProvider.value(
                                value: homeBloc,
                                child:
                                    viewAllServices(size, context, homeBloc));
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)?.viewAll ?? 'View All',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      fontSize: 13,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: size.width * 0.025),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  

                  children: List.generate(
                    homeBloc.rideModules.length > 4
                        ? 4
                        : homeBloc.rideModules.length,
                    (index) {
                      final module = homeBloc.rideModules.elementAt(index);
                      return AnimatedScale(
                        scale: module.name == homeBloc.selectedServiceType?.name ? 1.0 : 0.98,
                        duration: const Duration(milliseconds: 200),
                        child: InkWell(
                        onTap: () {
                          if (homeBloc.pickupAddressList.isNotEmpty) {
                            if (module.serviceType == 'normal') {
                              if (module.transportType == 'delivery') {
                                homeBloc.add(ServiceTypeChangeEvent(
                                    transportType: module.transportType,
                                    serviceTypeIndex: 1));
                              } else {
                                homeBloc.add(ServiceTypeChangeEvent(
                                    transportType: module.transportType,
                                    serviceTypeIndex: 0));
                              }
                            } else if (module.serviceType == 'rental') {
                              homeBloc.add(ServiceTypeChangeEvent(
                                  transportType: module.transportType,
                                  serviceTypeIndex: 2));
                            } else if (module.serviceType == 'outstation') {
                              homeBloc.add(ServiceTypeChangeEvent(
                                  transportType: module.transportType,
                                  serviceTypeIndex: 3));
                            } else if (module.serviceType == 'moov_money') {
                              if (homeBloc.userData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MoovMoneyHomePage(userData: homeBloc.userData!),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: size.width * 0.21,
                            height: size.width * 0.28,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: module.name == homeBloc.selectedServiceType?.name
                                  ? LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor.withOpacity(0.15),
                                        Theme.of(context).primaryColor.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: module.name == homeBloc.selectedServiceType?.name
                                  ? null
                                  : Colors.white,
                              border: Border.all(
                                width: module.name == homeBloc.selectedServiceType?.name ? 2 : 1,
                                color: module.name == homeBloc.selectedServiceType?.name
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (module.name == homeBloc.selectedServiceType?.name)
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                else
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: module.name == homeBloc.selectedServiceType?.name
                                        ? Colors.white
                                        : Colors.grey[50],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (module.name == homeBloc.selectedServiceType?.name)
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: module.menuIcon,
                                    fit: BoxFit.contain,
                                    height: size.width * 0.08,
                                    width: size.width * 0.08,
                                    placeholder: (context, url) => const Center(
                                      child: Loader(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(
                                          _getIconForService(module.transportType, module.serviceType),
                                          size: size.width * 0.08,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                MyText(
                                  text: module.name,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: module.name == homeBloc.selectedServiceType?.name
                                            ? Theme.of(context).primaryColor
                                            : AppColors.black,
                                        fontWeight: module.name == homeBloc.selectedServiceType?.name
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget viewAllServices(Size size, BuildContext context, HomeBloc homeBloc) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pour glisser
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.15),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 22,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyText(
                      text: AppLocalizations.of(context)?.service ?? 'Service',
                      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
                )
              ],
            ),
            SizedBox(height: size.width * 0.05),
            Wrap(
              children: List.generate(
                homeBloc.rideModules.length,
                (index) {
                  final module = homeBloc.rideModules.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (homeBloc.pickupAddressList.isNotEmpty) {
                          if (module.serviceType == 'normal') {
                            if (module.transportType == 'delivery') {
                              homeBloc.add(ServiceTypeChangeEvent(
                                  transportType: module.transportType,
                                  serviceTypeIndex: 1));
                            } else {
                              homeBloc.add(ServiceTypeChangeEvent(
                                  transportType: module.transportType,
                                  serviceTypeIndex: 0));
                            }
                          } else if (module.serviceType == 'rental') {
                            homeBloc.add(ServiceTypeChangeEvent(
                                transportType: module.transportType,
                                serviceTypeIndex: 2));
                          } else if (module.serviceType == 'outstation') {
                            homeBloc.add(ServiceTypeChangeEvent(
                                transportType: module.transportType,
                                serviceTypeIndex: 3));
                          } else if (module.serviceType == 'moov_money') {
                            // Naviguer vers Moov Money
                            if (homeBloc.userData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MoovMoneyHomePage(userData: homeBloc.userData!),
                                ),
                              );
                            }
                            return;
                          }
                        }
                      },
                      child: Container(
                        width: size.width * 0.21,
                        height: size.width * 0.28,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: module.menuIcon,
                                fit: BoxFit.contain,
                                height: size.width * 0.08,
                                width: size.width * 0.08,
                                placeholder: (context, url) => const Center(
                                  child: Loader(),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(
                                      _getIconForService(module.transportType, module.serviceType),
                                      size: size.width * 0.08,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            MyText(
                              text: module.name,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: size.width * 0.2),
          ],
        ),
      ),
    );
  }

  /// Retourne l'icône appropriée selon le type de service
  IconData _getIconForService(String transportType, String serviceType) {
    // Moov Money
    if (serviceType == 'moov_money') {
      return Icons.account_balance_wallet_rounded;
    }
    
    // Taxi / Ride
    if (transportType == 'taxi' || transportType == 'ride') {
      if (serviceType == 'rental') {
        return Icons.car_rental_rounded;
      } else if (serviceType == 'outstation') {
        return Icons.route_rounded;
      }
      return Icons.local_taxi_rounded;
    }
    
    // Delivery
    if (transportType == 'delivery') {
      return Icons.local_shipping_rounded;
    }
    
    // Restaurant
    if (transportType == 'restaurant' || serviceType == 'restaurant') {
      return Icons.restaurant_rounded;
    }
    
    // Shopping
    if (transportType == 'shopping' || serviceType == 'shopping') {
      return Icons.shopping_bag_rounded;
    }
    
    // Default fallback
    return Icons.apps_rounded;
  }
}
