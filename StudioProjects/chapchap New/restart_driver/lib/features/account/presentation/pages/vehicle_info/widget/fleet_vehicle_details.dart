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
          return Container(
            // padding: EdgeInsets.all(size.width*0.05),
            padding: EdgeInsets.fromLTRB(
                size.width * 0.05, 0, size.width * 0.05, size.width * 0.05),
            child: Column(
              children: [
                ListView.builder(
                  itemCount: context.read<AccBloc>().vehicleData.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(size.width * 0.025),
                      margin: EdgeInsets.only(bottom: size.width * 0.025),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: size.width * 0.1,
                                    width: size.width * 0.1,
                                    child: Image.asset(AppImages.carFront),
                                  ),
                                  SizedBox(height: size.width * 0.025),
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
                                          .bodyMedium!
                                          .copyWith(
                                              fontSize: 18,
                                              // fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * 0.025),
                          Container(
                            width: 1,
                            height: size.width * 0.21,
                            color: AppColors.borderColors,
                          ),
                          SizedBox(width: size.width * 0.05),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: size.width * 0.05,
                                    width: size.width * 0.05,
                                    child: Image.asset(
                                      AppImages.carFront,
                                      color: Theme.of(context).hintColor,
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
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ))
                                ],
                              ),
                              SizedBox(height: size.width * 0.025),
                              if (context
                                      .read<AccBloc>()
                                      .vehicleData[index]
                                      .driverDetail ==
                                  null)
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: size.width * 0.025),
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
                                              : (context.read<AccBloc>().vehicleData[index].approve == 0 &&
                                                      (context.read<AccBloc>().vehicleData[index].uploadDocument ==
                                                          true))
                                                  ? AppLocalizations.of(context)!
                                                      .waitingForApproval
                                                  : (context.read<AccBloc>().vehicleData[index].uploadDocument ==
                                                              false &&
                                                          context.read<AccBloc>().vehicleData[index].approve ==
                                                              0)
                                                      ? AppLocalizations.of(context)!
                                                          .documentNotUploaded
                                                      : (context.read<AccBloc>().vehicleData[index].approve ==
                                                                  1 &&
                                                              context.read<AccBloc>().vehicleData[index].driverDetail ==
                                                                  null)
                                                          ? AppLocalizations.of(context)!
                                                              .noDriversAssigned
                                                          : '',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .vehicleData[index]
                                                              .approve ==
                                                          0)
                                                      ? Colors.orange
                                                      : const Color.fromARGB(255, 248, 92, 81)))
                                    ],
                                  ),
                                ),
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
                                        SizedBox(
                                          height: size.width * 0.05,
                                          width: size.width * 0.05,
                                          child: Image.asset(AppImages.phone),
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
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
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
                                          child: Image.asset(
                                            AppImages.pencil,
                                            width: size.width * 0.06,
                                          ),
                                        )
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
                                            width: size.width * 0.5,
                                            padding: EdgeInsets.all(
                                                size.width * 0.025),
                                            decoration: const BoxDecoration(
                                                // color: Theme.of(context)
                                                //     .dividerColor,
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(6))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ((context
                                                                .read<AccBloc>()
                                                                .vehicleData[
                                                                    index]
                                                                .approve ==
                                                            0 &&
                                                        context
                                                                .read<AccBloc>()
                                                                .vehicleData[
                                                                    index]
                                                                .uploadDocument ==
                                                            true))
                                                    ? Container()
                                                    : Image.asset(
                                                        (context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            index]
                                                                        .approve ==
                                                                    1 &&
                                                                context
                                                                        .read<
                                                                            AccBloc>()
                                                                        .vehicleData[
                                                                            index]
                                                                        .uploadDocument ==
                                                                    true)
                                                            ? AppImages
                                                                .addDriver
                                                            : AppImages
                                                                .cloudUpload,
                                                        width:
                                                            size.width * 0.05,
                                                      ),
                                                SizedBox(
                                                  width: size.width * 0.025,
                                                ),
                                                MyText(
                                                  text: (context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .vehicleData[
                                                                      index]
                                                                  .approve ==
                                                              1 &&
                                                          context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .vehicleData[
                                                                      index]
                                                                  .uploadDocument ==
                                                              true)
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .assignDriver
                                                      : ((context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .vehicleData[
                                                                          index]
                                                                      .approve ==
                                                                  0 &&
                                                              context
                                                                      .read<
                                                                          AccBloc>()
                                                                      .vehicleData[
                                                                          index]
                                                                      .uploadDocument ==
                                                                  true))
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .viewDocument
                                                          : AppLocalizations.of(
                                                                  context)!
                                                              .uploadDocument,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
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
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
