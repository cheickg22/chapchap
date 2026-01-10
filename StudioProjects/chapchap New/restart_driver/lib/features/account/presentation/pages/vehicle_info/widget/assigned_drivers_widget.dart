import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class AssignedDriversWidget extends StatelessWidget {
  final BuildContext cont;
  const AssignedDriversWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        return Container(
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.chooseDriverAssign,
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColorDark),
                  maxLines: 5,
                ),
                SizedBox(
                  height: size.width * 0.05,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0;
                            i < context.read<AccBloc>().driverData.length;
                            i++)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context.read<AccBloc>().choosenDriverToVehicle =
                                    i;
                                context.read<AccBloc>().add(UpdateEvent());
                              },
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.025),
                                child: Row(
                                  children: [
                                    Container(
                                      width: size.width * 0.1,
                                      height: size.width * 0.1,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(context
                                                  .read<AccBloc>()
                                                  .driverData[i]
                                                  .profile),
                                              fit: BoxFit.cover)),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: context
                                                .read<AccBloc>()
                                                .driverData[i]
                                                .name,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 5,
                                          ),
                                          MyText(
                                            text: context
                                                .read<AccBloc>()
                                                .driverData[i]
                                                .mobile,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                            maxLines: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Container(
                                      width: size.width * 0.05,
                                      height: size.width * 0.05,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenDriverToVehicle ==
                                                      i)
                                                  ? Theme.of(context)
                                                      .primaryColorDark
                                                  : AppColors.darkGrey),
                                          shape: BoxShape.circle),
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: size.width * 0.03,
                                        height: size.width * 0.03,
                                        decoration: BoxDecoration(
                                            color: (context
                                                        .read<AccBloc>()
                                                        .choosenDriverToVehicle ==
                                                    i)
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : Colors.transparent,
                                            shape: BoxShape.circle),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                if (context.read<AccBloc>().choosenDriverToVehicle != null)
                  Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      CustomButton(
                          buttonName: AppLocalizations.of(context)!.assign,
                          onTap: () {
                            Navigator.pop(context);
                            context.read<AccBloc>().add(AssignDriverEvent(
                                driverId: context
                                    .read<AccBloc>()
                                    .driverData[context
                                        .read<AccBloc>()
                                        .choosenDriverToVehicle!]
                                    .id,
                                fleetId: context
                                    .read<AccBloc>()
                                    .choosenFleetToAssign!));
                          })
                    ],
                  )
              ],
            ));
      }),
    );
  }
}
