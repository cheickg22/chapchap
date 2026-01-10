import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_slider/custom_sliderbutton.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../account/presentation/pages/subscription/page/subscription_page.dart';
import '../../../../application/home_bloc.dart';

class ShowSubscriptionWidget extends StatelessWidget {
  const ShowSubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: PopScope(
            canPop: false,
            child: Container(
              height: userData!.driverMode == 'subscription'
                  ? size.width * 0.6
                  : size.width,
              width: size.width,
              padding: EdgeInsets.all(size.width * 0.01),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.1),
                    SizedBox(
                      width: size.width * 0.9,
                      child: MyText(
                        text: AppLocalizations.of(context)!.subscriptionHeading,
                        maxLines: 4,
                        textAlign: TextAlign.center,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                    CustomSliderButton(
                      buttonName: AppLocalizations.of(context)!.choosePlan,
                      onSlideSuccess: () async {
                        Navigator.pushNamed(
                          context,
                          SubscriptionPage.routeName,
                          arguments:
                              SubscriptionPageArguments(isFromAccPage: true),
                        ).then((value) {
                          if (!context.mounted) return;
                          if (value != null && value == true) {
                            Navigator.pop(context);
                          } else if (value == null &&
                              ((userData != null && userData!.isSubscribed!))) {
                            Navigator.pop(context);
                          }
                          context.read<HomeBloc>().add(GetUserDetailsEvent());
                        });
                        return true;
                      },
                    ),
                    SizedBox(height: size.width * 0.03),
                    if (userData!.driverMode == 'both') ...[
                      SizedBox(
                        width: size.width * 0.9,
                        child: MyText(
                          text: AppLocalizations.of(context)!.or,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),
                      InkWell(
                        onTap: () {
                          AppSharedPreference.setSubscriptionSkipStatus(true);
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          width: size.width * 0.9,
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .continueWithoutPlans,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),
                      SizedBox(
                        width: size.width * 0.9,
                        child: MyText(
                          text: AppLocalizations.of(context)!
                              .continueWithoutPlanDesc,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
