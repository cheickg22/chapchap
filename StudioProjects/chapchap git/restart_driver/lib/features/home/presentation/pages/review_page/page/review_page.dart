import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/common.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_textfield.dart';

class ReviewPage extends StatelessWidget {
  final BuildContext cont;
  const ReviewPage({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: size.width * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: MyText(
                              text: AppLocalizations.of(context)!
                                  .howWasYourLastRide
                                  .toString()
                                  .replaceAll('1111',
                                      userData!.onTripRequest!.userName),
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              maxLines: 5,
                            ),
                          ),
                          SizedBox(height: size.width * 0.05),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.grey,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyText(
                                text: userData!.onTripRequest!.requestNumber,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.width * 0.13,
                                              width: size.width * 0.13,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(35),
                                                  color: Theme.of(context)
                                                      .dividerColor),
                                              child: (userData!.onTripRequest!
                                                      .userImage.isEmpty)
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      child: CachedNetworkImage(
                                                        imageUrl: userData!
                                                            .onTripRequest!
                                                            .userImage,
                                                        height:
                                                            size.width * 0.15,
                                                        fit: BoxFit.fill,
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child: Loader(),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Center(
                                                          child: Text(""),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(width: size.width * 0.02),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: size.width * 0.6,
                                                  child: MyText(
                                                    text: userData!
                                                        .onTripRequest!
                                                        .userName,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                    maxLines: 5,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.005),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .user,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 10,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.width * 0.01),
                                    const Divider(
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    SizedBox(height: size.width * 0.01),
                                    MyText(
                                        text: 'Give Ratings',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            )),
                                    SizedBox(height: size.width * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (var i = 1; i < 6; i++)
                                          InkWell(
                                              onTap: () {
                                                context.read<HomeBloc>().add(
                                                    ReviewUpdateEvent(star: i));
                                              },
                                              child: Icon(
                                                (context
                                                            .read<HomeBloc>()
                                                            .review >=
                                                        i)
                                                    ? Icons.star
                                                    : Icons
                                                        .star_border_outlined,
                                                size: size.width * 0.09,
                                                color: (context
                                                            .read<HomeBloc>()
                                                            .review >=
                                                        i)
                                                    ? AppColors.goldenColor
                                                    : Theme.of(context)
                                                        .disabledColor,
                                              )),
                                      ],
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.1,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .leaveFeedback
                                      .replaceAll('(Optional)', ''),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      )),
                            ),
                          ),
                          SizedBox(height: size.width * 0.03),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CustomTextField(
                              controller:
                                  context.read<HomeBloc>().reviewController,
                              filled: true,
                              hintText:
                                  AppLocalizations.of(context)!.leaveFeedback,
                              maxLine: 5,
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.05,
                          ),
                        ],
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomButton(
                              isLoader: context.read<HomeBloc>().isLoading,
                              isLoaderShowWithText: false,
                              buttonName: AppLocalizations.of(context)!.submit,
                              width: 250,
                              onTap: () {
                                context.read<HomeBloc>().driverTips = 0.0;
                                context.read<HomeBloc>().sendUserDetailsWithNullRequestId();
                                if (context.read<HomeBloc>().review != 0) {
                                  context
                                      .read<HomeBloc>()
                                      .add(UploadReviewEvent());
                                } else {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .giveRatingsError);
                                }
                              }),
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
