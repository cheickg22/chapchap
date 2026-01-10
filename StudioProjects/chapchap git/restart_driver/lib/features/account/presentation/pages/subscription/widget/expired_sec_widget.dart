import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class ExpiredSecWidget extends StatelessWidget {
  final AccBloc accBloc;
  final bool isFromAccPage;

  const ExpiredSecWidget(
      {super.key, required this.accBloc, required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: accBloc,
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.subscriptionExpired),
                      SizedBox(height: size.height * 0.04),
                      MyText(
                        text: AppLocalizations.of(context)!.subscriptionExpired,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: AppColors.red,
                                  fontSize: 20,
                                ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      MyText(
                        text:
                            '${AppLocalizations.of(context)!.subscriptionFailedDescOne} ${userData!.wallet!.data.currencySymbol} ${userData!.subscription!.data.paidAmount} ${AppLocalizations.of(context)!.subscriptionFailedDescTwo} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionFailedDescThree}',
                        textStyle:
                            Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: AppColors.black,
                                  fontSize: 16,
                                ),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: size.width * 0.03,
                  child: Row(
                    children: [
                      (isFromAccPage)
                          ? InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: size.width * 0.07,
                                color: AppColors.black,
                              ),
                            )
                          : const SizedBox(),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.subscription,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(fontSize: 18, color: AppColors.blackText),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: CustomButton(
                    buttonName: AppLocalizations.of(context)!.choosePlan,
                    borderRadius: 20,
                    onTap: () {
                      context.read<AccBloc>().add(
                            ChoosePlanEvent(isPlansChoosed: true),
                          );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class ExpiredSecWidget extends StatelessWidget {
//   // final BuildContext cont;
//   final bool isFromAccPage;
//   const ExpiredSecWidget(
//       {super.key,
//       //  required this.cont,
//       required this.isFromAccPage});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.sizeOf(context);
//     return BlocBuilder(
//       builder: (context, state) {
//         return Center(
//           child: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(30),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Image.asset(AppImages.subscriptionExpired),
//                     SizedBox(height: size.height * 0.04),
//                     MyText(
//                       text: AppLocalizations.of(context)!.subscriptionExpired,
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .bodyLarge!
//                           .copyWith(color: AppColors.red, fontSize: 20),
//                     ),
//                     SizedBox(height: size.height * 0.03),
//                     MyText(
//                       text:
//                           '${AppLocalizations.of(context)!.subscriptionFailedDescOne} ${userData!.wallet!.data.currencySymbol}${userData!.subscription!.data.paidAmount} ${AppLocalizations.of(context)!.subscriptionFailedDescTwo} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionFailedDescThree}',
//                       textStyle:
//                           Theme.of(context).textTheme.bodySmall!.copyWith(
//                                 color: AppColors.black,
//                                 fontSize: 16,
//                               ),
//                       maxLines: 3,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 top: 20,
//                 left: size.width * 0.03,
//                 child: Row(
//                   children: [
//                     (isFromAccPage)
//                         ? InkWell(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Icon(
//                               Icons.arrow_back,
//                               size: size.width * 0.07,
//                               color: AppColors.black,
//                             ),
//                           )
//                         : const SizedBox(),
//                     SizedBox(
//                       width: size.width * 0.05,
//                     ),
//                     MyText(
//                       text: AppLocalizations.of(context)!.subscription,
//                       textStyle: Theme.of(context)
//                           .textTheme
//                           .headlineMedium!
//                           .copyWith(fontSize: 18, color: AppColors.blackText),
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 bottom: 20,
//                 left: 0,
//                 right: 0,
//                 child: CustomButton(
//                   buttonName: AppLocalizations.of(context)!.choosePlan,
//                   borderRadius: 20,
//                   onTap: () {
//                     context.read<AccBloc>().add(
//                           ChoosePlanEvent(isPlansChoosed: true),
//                         );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
