import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../../application/acc_bloc.dart';

class FleetVehicleDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  const FleetVehicleDetailsWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Column(
            children: [
              ListView.builder(
                itemCount: context.read<AccBloc>().vehicleData.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            bottom: size.width * 0.05,
                            right: size.width * 0.05,
                            left: size.width * 0.05),
                        padding: EdgeInsets.all(size.width * 0.05),
                        // width: size.width * 0.9,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).dividerColor.withAlpha((0.3 * 255).toInt()),
                            border: Border.all(
                                color: Theme.of(context)
                                    .disabledColor
                                    .withAlpha((0.5 * 255).toInt())),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: size.width * 0.15,
                                  width: size.width * 0.15,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(context
                                              .read<AccBloc>()
                                              .vehicleData[index]
                                              .icon!),
                                          fit: BoxFit.cover)),
                                ),
                                SizedBox(
                                  height: size.width * 0.025
                                ),
                                SizedBox(
                                  width: size.width * 0.2,
                                  child: MyText(
                                    text: context
                                        .read<AccBloc>()
                                        .vehicleData[index]
                                        .name,
                                    textAlign: TextAlign.center,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: size.width * 0.025),
                            Container(
                              width: 1,
                              height: size.width * 0.21,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withAlpha((0.5 * 255).toInt()),
                            ),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: size.width * 0.06,
                                      width: size.width * 0.06,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.darkGrey),
                                      child: Icon(
                                        CupertinoIcons.car_detailed,
                                        color: AppColors.white,
                                        size: size.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.025),
                                    Expanded(
                                        child: MyText(
                                      text: context
                                          .read<AccBloc>()
                                          .vehicleData[index]
                                          .model,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontSize: 14,
                                              color: AppColors.darkGrey),
                                    ))
                                  ],
                                ),
                                SizedBox(height: size.width * 0.025),
                                (context
                                                .read<AccBloc>()
                                                .vehicleData[index]
                                                .approve ==
                                            1 &&
                                        context
                                                .read<AccBloc>()
                                                .vehicleData[index]
                                                .driverDetail !=
                                            null)
                                    ? Row(
                                        children: [
                                          Container(
                                            height: size.width * 0.06,
                                            width: size.width * 0.06,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.darkGrey),
                                            child: Icon(
                                              CupertinoIcons.phone_fill,
                                              color: AppColors.white,
                                              size: size.width * 0.04,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.025),
                                          Expanded(
                                              child: MyText(
                                            text: context
                                                        .read<AccBloc>()
                                                        .vehicleData[index]
                                                        .driverDetail !=
                                                    null
                                                ? context
                                                    .read<AccBloc>()
                                                    .vehicleData[index]
                                                    .driverDetail!['mobile']
                                                : AppLocalizations.of(context)!
                                                    .assignDriver,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    fontSize: 14,
                                                    // fontWeight: FontWeight.w600,
                                                    color: AppColors.darkGrey),
                                          )),
                                          InkWell(
                                              onTap: () {
                                                context.read<AccBloc>().add(
                                                    GetDriverEvent(
                                                        from: 1,
                                                        fleetId: context
                                                            .read<AccBloc>()
                                                            .vehicleData[index]
                                                            .id));
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                size: size.width * 0.05,
                                              ))
                                        ],
                                      )
                                    : InkWell(
                                        onTap: () {
                                          if (context
                                                  .read<AccBloc>()
                                                  .vehicleData[index]
                                                  .approve ==
                                              1) {
                                            context.read<AccBloc>().add(
                                                GetDriverEvent(
                                                    from: 1,
                                                    fleetId: context
                                                        .read<AccBloc>()
                                                        .vehicleData[index]
                                                        .id));
                                          } else {
                                            String id = context
                                                .read<AccBloc>()
                                                .vehicleData[index]
                                                .id;

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        DriverProfilePage(
                                                            args:
                                                                VehicleUpdateArguments(
                                                          from: 'docs',
                                                          fleetId: id,
                                                        ))));
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Row(
                                                children: [
                                                  MyText(
                                                    text: (context
                                                                .read<AccBloc>()
                                                                .vehicleData[
                                                                    index]
                                                                .approve ==
                                                            1)
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .assignDriver
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .uploadDocument,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Icon(
                                                    CupertinoIcons
                                                        .arrow_right_circle,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    size: 20,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ))
                          ],
                        ),
                      ),
                      if (context.read<AccBloc>().vehicleData[index].approve ==
                          0)
                        Positioned(
                            top: 0,
                            right:
                                (context.read<AccBloc>().textDirection == 'rtl')
                                    ? null
                                    : size.width * 0.04,
                            left:
                                (context.read<AccBloc>().textDirection == 'ltr')
                                    ? null
                                    : 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 12,
                                      weight: 35,
                                      color: (context
                                                  .read<AccBloc>()
                                                  .vehicleData[index]
                                                  .approve ==
                                              0)
                                          ? Colors.orange
                                          : const Color.fromARGB(
                                              255, 248, 92, 81)),
                                  SizedBox(width: size.width * 0.01),
                                  MyText(
                                    text: (context
                                                .read<AccBloc>()
                                                .vehicleData[index]
                                                .isDeclined)
                                          ? AppLocalizations.of(context)!
                                            .uploadedDoccumentDeclined
                                           : (context
                                                .read<AccBloc>()
                                                .vehicleData[index]
                                                .approve ==
                                            0)
                                        ? AppLocalizations.of(context)!
                                            .waitingForApproval
                                        : AppLocalizations.of(context)!
                                            .documentNotUploaded,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: (context
                                                        .read<AccBloc>()
                                                        .vehicleData[index]
                                                        .approve ==
                                                    0)
                                                ? Colors.orange
                                                : const Color.fromARGB(
                                                    255, 248, 92, 81)),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
