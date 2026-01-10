// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/features/home/presentation/pages/home_page/page/diagnostic_page.dart';
import 'package:restart_user/features/home/presentation/pages/home_page/widget/select_preference_widget.dart';

import '../../../../../../common/app_constants.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../account/presentation/pages/admin_chat/page/admin_chat.dart';
import '../../../../application/home_bloc.dart';

class QuickActionsWidget extends StatelessWidget {
  final BuildContext cont;
  const QuickActionsWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor),
            child: SafeArea(
              child: Column(
                key: const Key('switcher1'),
                children: [
                  Container(
                    width: size.width,
                    padding: EdgeInsets.fromLTRB(
                        size.width * 0.05,
                        size.width * 0.05,
                        size.width * 0.05,
                        size.width * 0.05),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Container(
                          width: size.width * 0.15,
                          height: size.width * 0.01,
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                            color: Theme.of(context)
                                .disabledColor
                                .withAlpha((0.2*256).toInt()),
                          ),
                        ),
                        SizedBox(height: size.width * 0.1),
                        InkWell(
                          onTap: () {
                            context.read<HomeBloc>().bottomSize =
                                -(size.height * 0.8);
                            context.read<HomeBloc>().animatedWidget = null;
                            context.read<HomeBloc>().add(UpdateEvent());
                          },
                          child: Row(
                            children: [
                              // Icon(
                              //   Icons.arrow_back_ios,
                              //   size: size.width * 0.05,
                              //   color: Theme.of(context).disabledColor,
                              // ),
                              SizedBox(width: size.width * 0.05),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .instantActivity,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userData!.showInstantRideFeatureForMobileApp ==
                      '1') ...[
                    SizedBox(height: size.width * 0.05),
                    InkWell(
                      onTap: () {
                        context.read<HomeBloc>().bottomSize =
                            -(size.height * 0.8);
                        context.read<HomeBloc>().animatedWidget = null;
                        context.read<HomeBloc>().add(UpdateEvent());
                        context
                            .read<HomeBloc>()
                            .add(ShowGetDropAddressEvent());
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                offset: const Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.1,
                              width: size.width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).dividerColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.instantCar,
                                width: size.width * 0.05,
                              ),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!.instantRide,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: Theme.of(context).primaryColorDark,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: size.width * 0.05),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AdminChat.routeName);
                    },
                    child: Container(
                      width: size.width * 0.9,
                      padding: EdgeInsets.all(size.width * 0.025),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.5 * 255).toInt()),
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.5 * 255).toInt()),
                              offset: const Offset(
                                5.0,
                                5.0,
                              ),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ), //BoxShadow
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Container(
                            height: size.width * 0.1,
                            width: size.width * 0.1,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).dividerColor),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.helpCenter,
                              width: size.width * 0.05,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Expanded(
                              child: MyText(
                            text: AppLocalizations.of(context)!.helpCenter,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                          )),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: size.width * 0.05,
                            color: Theme.of(context).primaryColorDark,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.05),
                  if (Platform.isAndroid) ...[
                    Container(
                      width: size.width * 0.9,
                      padding: EdgeInsets.all(size.width * 0.015),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.5 * 255).toInt()),
                              width: 0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .disabledColor
                                  .withAlpha((0.5 * 255).toInt()),
                              offset: const Offset(
                                5.0,
                                5.0,
                              ),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ), //BoxShadow
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Container(
                            height: size.width * 0.1,
                            width: size.width * 0.1,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).dividerColor),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.icon,
                              width: size.width * 0.1,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Expanded(
                              child: MyText(
                            text:
                                AppLocalizations.of(context)!.showBubbleIcon,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                          )),
                          Switch(
                              activeColor: AppColors.green,
                              inactiveTrackColor: AppColors.darkGrey,
                              value: showBubbleIcon,
                              onChanged: (v) {
                                context
                                    .read<HomeBloc>()
                                    .add(EnableBubbleEvent(isEnabled: v));
                              })
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                  ],

                  
                  
                  
                    SizedBox(height: size.width * 0.05),
                  
                  if (userData!.enableSubVehicleFeature == "1")
                    InkWell(
                      onTap: () {
                        context.read<HomeBloc>().add(GetSubVehicleTypesEvent(
                            serviceLocationId: userData!.serviceLocationId!,
                            vehicleType: userData!.vehicleTypes![0]));
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                offset: const Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.1,
                              width: size.width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).dividerColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.myServices,
                                width: size.width * 0.05,
                              ),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!.myServices,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: Theme.of(context).primaryColorDark,
                            )
                          ],
                        ),
                      ),
                    ),
                  if (userData!.enableSubVehicleFeature == "1")
                    SizedBox(height: size.width * 0.05),
                  if (userData!.active && userData!.role == 'driver')
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, DiagnosticPage.routeName);
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                offset: const Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.1,
                              width: size.width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).dividerColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.diagnosticSettings,
                                width: size.width * 0.05,
                              ),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!
                                  .notGettingRequest,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: Theme.of(context).primaryColorDark,
                            )
                          ],
                        ),
                      ),
                    ),
                    if (userData!.active && userData!.role == 'driver')
                    SizedBox(height: size.width * 0.05),
                    if ( userData!.role == 'driver')
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: false,
                                    enableDrag: false,
                                    isDismissible: false,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(
                                            20.0), // Adjust the radius to your liking
                                      ),
                                    ),
                                    builder: (_) {
                                      return SelectPreferenceWidget(
                                          cont: context);
                                    });
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt()),
                                offset: const Offset(
                                  5.0,
                                  5.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: 2.0,
                              ), //BoxShadow
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                            ],
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.1,
                              width: size.width * 0.1,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).dividerColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.diagnosticSettings,
                                width: size.width * 0.05,
                              ),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!
                                                      .preferences,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: Theme.of(context).primaryColorDark,
                            )
                          ],
                        ),
                      ),
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
