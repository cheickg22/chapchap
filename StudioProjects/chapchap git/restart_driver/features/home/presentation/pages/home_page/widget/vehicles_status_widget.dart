import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_constants.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class VehicleStatusWidget extends StatelessWidget {
  final BuildContext cont;
  const VehicleStatusWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
              margin: EdgeInsets.only(
                  left: size.width * 0.075, right: size.width * 0.075),
              padding: EdgeInsets.all(size.width * 0.015),
              height: size.width * 0.15,
              width: size.width * 0.85,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      width: 1, color: Theme.of(context).dividerColor)),
              child: Container(
                padding: EdgeInsets.only(
                    left: size.width * 0.02, right: size.width * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        context
                            .read<HomeBloc>()
                            .add(ChooseCarMenuEvent(menu: 1));
                      },
                      child: Container(
                          width: size.width * 0.24,
                          padding: EdgeInsets.all(size.width * 0.01),
                          decoration: BoxDecoration(
                            color:
                                (context.read<HomeBloc>().choosenCarMenu == 1)
                                    ? AppColors.green
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                            text: AppLocalizations.of(context)!.onlineSmall,
                            textStyle: TextStyle(
                              fontSize: (choosenLanguage == 'ta') ? 11 : 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  (context.read<HomeBloc>().choosenCarMenu == 1)
                                      ? AppColors.white
                                      : AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        context
                            .read<HomeBloc>()
                            .add(ChooseCarMenuEvent(menu: 2));
                      },
                      child: Container(
                          width: size.width * 0.24,
                          padding: EdgeInsets.all(size.width * 0.01),
                          decoration: BoxDecoration(
                            color:
                                (context.read<HomeBloc>().choosenCarMenu == 2)
                                    ? AppColors.red
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                            text: AppLocalizations.of(context)!.offlineSmall,
                            textStyle: TextStyle(
                              fontSize: (choosenLanguage == 'ta') ? 11 : 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  (context.read<HomeBloc>().choosenCarMenu == 2)
                                      ? AppColors.white
                                      : AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        context
                            .read<HomeBloc>()
                            .add(ChooseCarMenuEvent(menu: 3));
                      },
                      child: Container(
                          width: size.width * 0.24,
                          padding: EdgeInsets.all(size.width * 0.01),
                          decoration: BoxDecoration(
                            color:
                                (context.read<HomeBloc>().choosenCarMenu == 3)
                                    ? Colors.orange
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MyText(
                            text: AppLocalizations.of(context)!.onrideSmall,
                            textStyle: TextStyle(
                              fontSize: (choosenLanguage == 'ta') ? 11 : 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  (context.read<HomeBloc>().choosenCarMenu == 3)
                                      ? AppColors.white
                                      : AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
