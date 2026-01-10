import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:restart_tagxi/core/utils/custom_header.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';

class ReferralPage extends StatefulWidget {
  final ReferralArguments args;

  static const String routeName = '/ReferralPage';

  const ReferralPage({super.key, required this.args});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool showReferralHistory = false;

  String _formatStatus(String status) {
    if (status.isEmpty) return '';
    final normalized = status.toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) {
        final bloc = AccBloc();
        bloc.add(AccGetDirectionEvent());
        bloc.add(ReferralResponseEvent());
        return bloc;
      },
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Directionality(
            textDirection: context.read<AccBloc>().textDirection == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomHeader(
                      title: widget.args.title,
                      automaticallyImplyLeading: true,
                      titleFontSize: 18,
                      textColor: Theme.of(context).primaryColorDark,
                    ),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.all(size.width * 0.045),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      String bannerText = widget.args.userData
                                          .referralComissionString;
                                      return MyText(
                                        text: bannerText,
                                        maxLines: 3,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              fontSize: 24,
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Right side - Illustration background
                          ClipRRect(
                            child: Image.asset(AppImages.referralGenius,
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: AppColors.borderColors),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: size.width * 0.1,
                                  width: size.width * 0.4,
                                  color: const Color(0xFFF0F2FF),
                                  child: DottedBorder(
                                      color: AppColors.hintColor,
                                      strokeWidth: 2,
                                      dashPattern: const [6, 3],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(5),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            MyText(
                                              text: widget
                                                  .args.userData.refferalCode,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontSize: 15,
                                                    color:
                                                        AppColors.hintColorGrey,
                                                  ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: size.width * 0.01,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .yourReferralCode,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 14,
                                        color: AppColors.hintColor,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: size.width * 0.025,
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.args.userData.refferalCode));
                                context.showSnackBar(
                                    color: Theme.of(context).primaryColorDark,
                                    message: AppLocalizations.of(context)!
                                        .referralCopied);
                              },
                              child: Container(
                                width: size.width * 0.30,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.015)),
                                padding: EdgeInsets.all(size.width * 0.025),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      size: 14,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.025,
                                    ),
                                    MyText(
                                      text: AppLocalizations.of(context)!.copy,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: size.width * 0.05, right: size.width * 0.05),
                      child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.borderColors,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(size.width * 0.0125),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.read<AccBloc>().add(
                                      ReferralTabChangeEvent(
                                          showReferralHistory: false));
                                },
                                child: Container(
                                  width: size.width * 0.425,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  decoration: BoxDecoration(
                                    color: !context
                                            .watch<AccBloc>()
                                            .showReferralHistory
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .referAndEarn,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            color: !context
                                                    .watch<AccBloc>()
                                                    .showReferralHistory
                                                ? AppColors.hintColorGrey
                                                : AppColors.hintColor),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.read<AccBloc>().add(
                                      ReferralTabChangeEvent(
                                          showReferralHistory: true));
                                  context
                                      .read<AccBloc>()
                                      .add(ReferalHistoryEvent());
                                },
                                child: Container(
                                  width: size.width * 0.425,
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  decoration: BoxDecoration(
                                    color: context
                                            .watch<AccBloc>()
                                            .showReferralHistory
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .referralHistory,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                            fontSize: 16,
                                            color: context
                                                    .watch<AccBloc>()
                                                    .showReferralHistory
                                                ? AppColors.hintColorGrey
                                                : AppColors.hintColor),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(height: size.width * 0.05),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Builder(
                          builder: (context) {
                            final bloc = context.watch<AccBloc>();
                            if (bloc.showReferralHistory) {
                              if (state is ReferalHistoryLoadingState) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              // Render history whenever data is available
                              if (state is ReferalHistorySuccessState) {
                                final historyList = bloc.referralHistory;

                                if (historyList.isNotEmpty) {
                                  return ListView.separated(
                                    itemCount: historyList.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: size.width * 0.025),
                                    itemBuilder: (context, index) {
                                      final item = historyList[index];
                                      return Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.035),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: AppColors.borderColors),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Name
                                                MyText(
                                                  text: item.name,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .hintColorGrey,
                                                      ),
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.01),
                                                // Date
                                                MyText(
                                                  text: item.createdAt
                                                      .split(' ')
                                                      .first,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                        fontSize: 13,
                                                        color:
                                                            AppColors.hintColor,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      AppImages.referGift,
                                                      height: size.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.015),
                                                    MyText(
                                                      text:
                                                          '${item.currencySymbol}${item.earning}',
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .hintColorGrey,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height: size.width * 0.01),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 0.02,
                                                    vertical: size.width * 0.01,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.borderColors,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: MyText(
                                                    text: _formatStatus(
                                                        item.referralStatus),
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                          color: AppColors
                                                              .hintColorGrey,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              }

                              // Empty state for referral history
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.referal,
                                    height: size.width * 0.65,
                                  ),
                                  SizedBox(height: size.width * 0.025),
                                  Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .noReferralHistoryFound,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 16,
                                            color: AppColors.hintColor,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Show "Refer and Earn" tab content
                            if (state is ReferralResponseLoadingState) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final referralResponse = bloc.referralResponse;
                            if (referralResponse == null) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.referal,
                                    height: size.width * 0.65,
                                  ),
                                  SizedBox(height: size.width * 0.025),
                                  Center(
                                    child: MyText(
                                      text:
                                          'Referral content is unavailable. Please try again later.',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 16,
                                            color: AppColors.hintColor,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            final referralHtml = referralResponse
                                .data.referralContent.data.description;

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontSize: 20,
                                          color: AppColors.greyHintColor,
                                        ),
                                  ),
                                  SizedBox(height: size.width * 0.025),
                                  Html(
                                    data: referralHtml,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(14),
                                        color: AppColors.greyHintColor,
                                      ),
                                      "strong": Style(
                                        color: AppColors.greyHintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      "ol": Style(
                                        listStyleType: ListStyleType.decimal,
                                        margin: Margins.only(left: 16),
                                      ),
                                      "li": Style(
                                        margin: Margins.only(bottom: 8),
                                      ),
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: CustomButton(
                          buttonColor: AppColors.primary,
                          buttonName: AppLocalizations.of(context)!.invite,
                          width: size.width,
                          onTap: () async {
                            String androidUrl = widget.args.userData.androidApp;
                            String iosUrl = widget.args.userData.iosApp;

                            if (!context.mounted) return;
                            await Share.share(
                                "${AppLocalizations.of(context)!.referalShareOne.replaceAll('****', widget.args.userData.refferalCode).replaceAll('**', "Restart")}\n$androidUrl \n$iosUrl");
                          }),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
