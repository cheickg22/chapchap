import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../home_page/page/home_page.dart';

class ReviewPage extends StatelessWidget {
  static const String routeName = '/reviewPage';
  const ReviewPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
        create: (context) => HomeBloc(),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) async {
            if (state is AddReviewSuccessState) {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Scaffold(
                // backgroundColor: AppColors.secondary,
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.rideRating,
                  automaticallyImplyLeading: false,
                  titleFontSize: 18,
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: size.width * 0.05),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .howWasYourLastRide
                                    .toString()
                                    .replaceAll('1111',
                                        userData!.onTripRequest!.userName),
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 5,
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.borderColor,
                              ),
                              padding: EdgeInsets.only(
                                  left: size.width * 0.025,
                                  right: size.width * 0.025),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyText(
                                  text: userData!.onTripRequest!.requestNumber,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context).hintColor),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                                              height: size.width * 0.15,
                                              width: size.width * 0.15,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                              ),
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
                                                        .bodyMedium!
                                                        .copyWith(
                                                          fontSize: 16,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        ),
                                                    // textStyle: Theme.of(context)
                                                    //     .textTheme
                                                    //     .bodyMedium,
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
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    const Divider(
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    SizedBox(height: size.width * 0.025),
                                    MyText(
                                        text: AppLocalizations.of(context)!
                                            .giveRatings,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .hintColor)),
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
                                                    ? AppColors.primary
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
                            SizedBox(height: size.width * 0.05),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .leaveFeedback
                                        .replaceAll('(Optional)', ''),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .primaryColorDark)),
                              ),
                            ),
                            // SizedBox(height: size.width * 0.03),
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.03),
                              child: CustomTextField(
                                controller:
                                    context.read<HomeBloc>().reviewController,
                                filled: true,
                                contentPadding:
                                    EdgeInsets.all(size.width * 0.05),
                                hintText:
                                    AppLocalizations.of(context)!.leaveFeedback,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.borderColors, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.borderColors, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.borderColors, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                maxLine: 5,
                              ),
                            ),
                            SizedBox(height: size.width * 0.1),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CustomButton(
                                    isLoader:
                                        context.read<HomeBloc>().isLoading,
                                    isLoaderShowWithText: false,
                                    buttonName:
                                        AppLocalizations.of(context)!.submit,
                                    width: size.width,
                                    textSize: 18,
                                    onTap: () {
                                      context.read<HomeBloc>().driverTips = 0.0;
                                      if (context.read<HomeBloc>().review !=
                                          0) {
                                        context
                                            .read<HomeBloc>()
                                            .add(UploadReviewEvent());
                                      } else {
                                        showToast(
                                            message:
                                                AppLocalizations.of(context)!
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
                ),
              );
            },
          ),
        ));
  }
}
