import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class ShowStopsWidgets extends StatelessWidget {
  const ShowStopsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc,HomeState>(
      builder: (context, state) {
       return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
          child: Container(
            height: size.width,
            width: size.width,
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: size.width * 0.1),
                SizedBox(
                  width: size.width * 0.9,
                  child: MyText(
                    text: AppLocalizations.of(context)!.chooseStop,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0;
                          i < userData!.onTripRequest!.requestStops.length;
                          i++)
                        if (userData!.onTripRequest!.requestStops[i]
                                ['completed_at'] ==
                            null)
                          InkWell(
                            onTap: () {
                                context.read<HomeBloc>().choosenCompleteStop =
                                    userData!
                                        .onTripRequest!.requestStops[i]['id']
                                        .toString();
                              context.read<HomeBloc>().add(UpdateEvent());
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                  0, size.width * 0.025, 0, size.width * 0.025),
                              child: Row(
                                children: [
                                  Container(
                                    height: size.width * 0.05,
                                    width: size.width * 0.05,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCompleteStop ==
                                                    userData!.onTripRequest!
                                                        .requestStops[i]['id']
                                                        .toString())
                                                ? Theme.of(context)
                                                    .primaryColorDark
                                                : AppColors.darkGrey)),
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: size.width * 0.03,
                                      width: size.width * 0.03,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (context
                                                      .read<HomeBloc>()
                                                      .choosenCompleteStop ==
                                                  userData!.onTripRequest!
                                                      .requestStops[i]['id']
                                                      .toString())
                                              ? Theme.of(context)
                                                  .primaryColorDark
                                              : Colors.transparent),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.025),
                                  Expanded(
                                      child: MyText(
                                    text: userData!.onTripRequest!
                                        .requestStops[i]['address'],
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                  ))
                                ],
                              ),
                            ),
                          )
                    ],
                  ),
                )),
                SizedBox(height: size.width * 0.06),
                CustomButton(
                    buttonName:
                        (userData!.onTripRequest!.transportType == 'taxi')
                            ? AppLocalizations.of(context)!.endRide
                            : AppLocalizations.of(context)!.dispatchGoods,
                    onTap: () {
                      if (context.read<HomeBloc>().choosenCompleteStop !=
                          null) {
                        Navigator.pop(context);

                        if (userData!.onTripRequest!.transportType ==
                                'delivery' &&
                            userData!.onTripRequest!.enableShipmentUnload ==
                                '1') {
                          if (userData!.onTripRequest!.showOtpFeature == true) {
                              context.read<HomeBloc>().add(ShowOtpEvent());
                          } else{
                            context.read<HomeBloc>().add(ShowImagePickEvent());
                          }         
                        } else if (userData!.onTripRequest!.transportType ==
                                'delivery' &&
                            userData!.onTripRequest!.enableDigitalSignature ==
                                '1') {
                          context.read<HomeBloc>().add(ShowSignatureEvent());
                        } else {
                          context.read<HomeBloc>().add(CompleteStopEvent(
                              id: context
                                  .read<HomeBloc>()
                                  .choosenCompleteStop!));
                        }
                      }
                    }),
                SizedBox(height: size.width * 0.1),    
              ],
            ),
          ),
        ),
      );
  
    },);
  }
}