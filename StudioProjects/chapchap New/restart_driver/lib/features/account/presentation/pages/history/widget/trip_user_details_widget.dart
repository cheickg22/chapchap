import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class TripUserDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripUserDetailsWidget(
      {super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: AppColors.borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.tripInfo,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5),
                ),
                SizedBox(height: size.height * 0.02),

                // User Profile Section
                if (arg.historyData.userDetail != null &&
                    arg.historyData.isCancelled != 1)
                  Row(
                    children: [
                      Container(
                        height: size.width * 0.14,
                        width: size.width * 0.14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).disabledColor,
                          border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          image: (arg.historyData.userDetail.data.profilePicture
                                  .isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(arg.historyData.userDetail
                                      .data.profilePicture),
                                  fit: BoxFit.cover)
                              : const DecorationImage(
                                  image: AssetImage(
                                    AppImages.defaultProfile,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: MyText(
                          text: arg.historyData.userDetail.data.name,
                          textStyle:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: size.height * 0.02),

                // Pickup Location
                Row(
                  children: [
                    Image(
                      height: size.width * 0.08,
                      width: size.width * 0.16,
                      image: const AssetImage(AppImages.historyDot),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            overflow: TextOverflow.ellipsis,
                            text: arg.historyData.pickAddress,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    // fontWeight: FontWeight.w400,
                                    ),
                            maxLines: 2,
                          ),
                          SizedBox(height: size.height * 0.005),
                          MyText(
                            text: arg.historyData.cvTripStartTime,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 14, color: AppColors.hintColor
                                    // fontWeight: FontWeight.w200,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Stop Points Indicator Line
                if ((arg.historyData.requestStops != null &&
                        arg.historyData.requestStops!.isNotEmpty) ||
                    arg.historyData.dropAddress != "")
                  Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.08,
                      top: size.height * 0.01,
                      bottom: size.height * 0.01,
                    ),
                    child: Container(
                      width: 2,
                      height: size.height * 0.03,
                      decoration: const BoxDecoration(
                        color: AppColors.grey,
                      ),
                    ),
                  ),

                // Request Stops
                if (arg.historyData.requestStops != null &&
                    arg.historyData.requestStops!.isNotEmpty)
                  ListView.builder(
                    itemCount: arg.historyData.requestStops!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.01),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.015,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const DropIcon(),
                              SizedBox(width: size.width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      overflow: TextOverflow.ellipsis,
                                      text: arg.historyData.requestStops![i]
                                          ['address'],
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              // fontWeight: FontWeight.w500,
                                              ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    MyText(
                                      text: arg.historyData.cvCompletedAt,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: AppColors.hintColor,
                                            fontSize: 11,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // Drop Location
                if (arg.historyData.dropAddress != "" &&
                    (arg.historyData.requestStops == null ||
                        arg.historyData.requestStops!.isEmpty))
                  Row(
                    children: [
                      Image(
                        height: size.width * 0.08,
                        width: size.width * 0.16,
                        image: const AssetImage(AppImages.mapPin),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              overflow: TextOverflow.ellipsis,
                              text: arg.historyData.dropAddress,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      // fontWeight: FontWeight.w400,
                                      ),
                              maxLines: 2,
                            ),
                            SizedBox(height: size.height * 0.005),
                            MyText(
                              text: arg.historyData.cvCompletedAt,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      // fontWeight: FontWeight.w200,
                                      fontSize: 14,
                                      color: AppColors.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
