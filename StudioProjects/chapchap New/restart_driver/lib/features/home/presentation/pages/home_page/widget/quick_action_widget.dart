import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/page/diagnostic_page.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/select_preference_widget.dart';

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
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: SafeArea(
              child: Column(
                key: const Key('switcher1'),
                children: [
                  Container(
                    width: size.width,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderColors, // border color
                          width: 1, // border width
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(bottom: size.width * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: size.width * 0.05),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: size.width * 0.05),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .instantActivity,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontSize: 18,
                                    ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userData!.showInstantRideFeatureForMobileApp == '1') ...[
                    SizedBox(height: size.width * 0.05),
                    InkWell(
                      onTap: () {
                        context.read<HomeBloc>().bottomSize =
                            -(size.height * 0.8);
                        context.read<HomeBloc>().animatedWidget = null;
                        context.read<HomeBloc>().add(UpdateEvent());
                        context.read<HomeBloc>().add(ShowGetDropAddressEvent());
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.borderColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.125,
                              width: size.width * 0.125,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.borderColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.vehicleMakeImage,
                                width: size.width * 0.065,
                                color: Colors.black,
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
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                  ),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: AppColors.hintColor,
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
                              color: AppColors.borderColor, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Container(
                            height: size.width * 0.125,
                            width: size.width * 0.125,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.borderColor),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.headset,
                              width: size.width * 0.065,
                              color: AppColors.black,
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
                                ),
                          )),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: size.width * 0.05,
                            color: AppColors.hintColor,
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
                              color: AppColors.borderColor, width: 1),
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Row(
                        children: [
                          Container(
                            height: size.width * 0.125,
                            width: size.width * 0.125,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.borderColor),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImages.recycle,
                              width: size.width * 0.065,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Expanded(
                              child: MyText(
                            text: AppLocalizations.of(context)!.showBubbleIcon,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 16,
                                ),
                          )),
                          Switch(
                              activeColor: AppColors.green,
                              inactiveTrackColor: AppColors.toggleButtonColor,
                              value: showBubbleIcon,
                              onChanged: (v) {
                                context
                                    .read<HomeBloc>()
                                    .add(EnableBubbleEvent(isEnabled: v));
                              })
                        ],
                      ),
                    ),
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
                                color: AppColors.borderColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.125,
                              width: size.width * 0.125,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.borderColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.vehicleModelImage,
                                width: size.width * 0.065,
                                color: AppColors.black,
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
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                  ),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: AppColors.hintColor,
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
                        Navigator.pushNamed(context, DiagnosticPage.routeName);
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.borderColor, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.125,
                              width: size.width * 0.125,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.borderColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.vehicleModelImage,
                                width: size.width * 0.065,
                                color: AppColors.black,
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
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                  ),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: AppColors.hintColor,
                            )
                          ],
                        ),
                      ),
                    ),
                  if (userData!.active && userData!.role == 'driver')
                    SizedBox(height: size.width * 0.05),
                  if (userData!.role == 'driver')
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
                              return SelectPreferenceWidget(cont: context);
                            });
                      },
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(size.width * 0.025),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.borderColor, width: 1),
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.125,
                              width: size.width * 0.125,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.borderColor),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImages.vehicleModelImage,
                                width: size.width * 0.065,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: MyText(
                              text: AppLocalizations.of(context)!.preferences,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 16,
                                  ),
                            )),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: size.width * 0.05,
                              color: AppColors.hintColor,
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
