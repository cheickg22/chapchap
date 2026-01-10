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
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.tripInfo,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).disabledColor, fontSize: 14),
                ),
                SizedBox(height: size.height * 0.01),
                if (arg.historyData.userDetail != null &&
                    arg.historyData.isCancelled != 1)
                  SizedBox(
                    width: size.width,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: size.width * 0.15,
                              width: size.width * 0.15,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).disabledColor,
                                  image: (arg.historyData.userDetail.data
                                          .profilePicture.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(arg.historyData
                                              .userDetail.data.profilePicture),
                                          fit: BoxFit.cover)
                                      : const DecorationImage(
                                          image: AssetImage(
                                            AppImages.defaultProfile,
                                          ),
                                        )),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: size.width * 0.66,
                                  child: MyText(
                                    text: arg.historyData.userDetail.data.name,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(),
                                    textAlign: TextAlign.start,
                                    maxLines: 5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                SizedBox(height: size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PickupIcon(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: MyText(
                          overflow: TextOverflow.ellipsis,
                          text: arg.historyData.pickAddress,
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    MyText(
                      text: arg.historyData.cvTripStartTime,
                      textStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                if (arg.historyData.requestStops != null &&
                    arg.historyData.requestStops!.isNotEmpty)
                  Column(
                    children: [
                      ListView.builder(
                        itemCount: arg.historyData.requestStops!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const DropIcon(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: MyText(
                                      overflow: TextOverflow.ellipsis,
                                      text: arg.historyData.requestStops![i]
                                          ['address'],
                                      textStyle:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                                MyText(
                                  text: arg.historyData.cvCompletedAt,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Theme.of(context).disabledColor,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                if (arg.historyData.dropAddress != "" &&
                    (arg.historyData.requestStops == null ||
                        arg.historyData.requestStops!.isEmpty))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const DropIcon(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: MyText(
                              overflow: TextOverflow.ellipsis,
                              text: arg.historyData.dropAddress,
                              textStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                        MyText(
                          text: arg.historyData.cvCompletedAt,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                      ],
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
