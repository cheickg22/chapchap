import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../../../home/presentation/pages/home_page.dart';
import '../../../../application/booking_bloc.dart';

class ReviewPage extends StatelessWidget {
  static const String routeName = '/reviewPage';
  final ReviewPageArguments arg;
  const ReviewPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
        create: (context) => BookingBloc(),
        child: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) async {
            if (state is BookingUserRatingsSuccessState) {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            } else if (state is LogoutState) {
              // Navigator.pushNamedAndRemoveUntil(
              //     context, AuthPage.routeName, (route) => false);
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginPage.routeName, (route) => false);
              await AppSharedPreference.setLoginStatus(false);
            }
          },
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              return Scaffold(
                // backgroundColor: AppColors.secondary,
                appBar:
                    CustomAppBar(title: AppLocalizations.of(context)!.ratings),
                body: Column(
                  // mainAxisAlignment: MainAxisAlignment.,
                  children: [
                    Padding(
                      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 46),
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.grey),
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
                                    .lastRideReview
                                    .replaceAll('*', arg.driverData.name),
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 5,
                                textAlign: TextAlign.center,
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
                                  text: arg.orderNo,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).hintColor),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * 0.05),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.7,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: size.width * 0.1,
                                                  width: size.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      color: Theme.of(context)
                                                          .dividerColor),
                                                  child: (arg
                                                          .driverData
                                                          .profilePicture
                                                          .isEmpty)
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 50,
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(35),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: arg
                                                                .driverData
                                                                .profilePicture,
                                                            height: size.width *
                                                                0.15,
                                                            fit: BoxFit.fill,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    const Center(
                                                              child: Loader(),
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Center(
                                                              child: Text(""),
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                SizedBox(
                                                  width: size.width * 0.3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MyText(
                                                        text:
                                                            arg.driverData.name,
                                                        maxLines: 5,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium,
                                                      ),
                                                      SizedBox(
                                                          height: size.width *
                                                              0.005),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .driver,
                                                        textStyle:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  fontSize: 10,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: size.width * 0.25,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  MyText(
                                                    text: arg
                                                        .driverData.carNumber,
                                                    maxLines: 2,
                                                    textAlign: TextAlign.end,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(fontSize: 10),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.01),
                                                  MyText(
                                                    text:
                                                        '${arg.driverData.carMakeName} ${arg.driverData.carModelName}',
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          fontSize: 10,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
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
                                        children: List.generate(
                                          5,
                                          (index) {
                                            return InkWell(
                                              onTap: () {
                                                context.read<BookingBloc>().add(
                                                    BookingRatingsSelectEvent(
                                                        selectedIndex:
                                                            index + 1));
                                              },
                                              child: Icon(
                                                  (index + 1 <=
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedRatingsIndex &&
                                                          context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedRatingsIndex !=
                                                              0)
                                                      ? Icons.star
                                                      : Icons
                                                          .star_border_outlined,
                                                  color: (index + 1 <=
                                                              context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedRatingsIndex &&
                                                          context
                                                                  .read<
                                                                      BookingBloc>()
                                                                  .selectedRatingsIndex !=
                                                              0)
                                                      ? AppColors.goldenColor
                                                      : Theme.of(context)
                                                          .disabledColor,
                                                  size: 30),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                    ],
                                  ),
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
                                        .leaveFeedback,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          // fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        )),
                              ),
                            ),
                            SizedBox(height: size.width * 0.03),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CustomTextField(
                                controller: context
                                    .read<BookingBloc>()
                                    .feedBackController,
                                filled: true,
                                hintText:
                                    '${AppLocalizations.of(context)!.leaveFeedback}(${AppLocalizations.of(context)!.optional})',
                                maxLine: 5,
                              ),
                            ),
                            SizedBox(height: size.width * 0.1),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: CustomButton(
                                  width: size.width,
                                  buttonColor: Theme.of(context).primaryColor,
                                  buttonName:
                                      AppLocalizations.of(context)!.submit,
                                  onTap: () {
                                    if (context
                                            .read<BookingBloc>()
                                            .selectedRatingsIndex >
                                        0) {
                                      context.read<BookingBloc>().add(
                                            BookingUserRatingsEvent(
                                                requestId: arg.requestId,
                                                ratings:
                                                    '${context.read<BookingBloc>().selectedRatingsIndex}',
                                                feedBack: context
                                                    .read<BookingBloc>()
                                                    .feedBackController
                                                    .text),
                                          );
                                    } else {
                                      showToast(
                                          message: AppLocalizations.of(context)!
                                              .pleaseGiveRatings);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * 0.02),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      HomePage.routeName, (route) => false);
                                },
                                child: const Text(
                                  'Skip for now',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
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
