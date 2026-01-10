import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class CancelReasonWidget extends StatelessWidget {
  final BuildContext cont;
  const CancelReasonWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            width: size.width,
            height: size.height,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Cancel Reason',
                  automaticallyImplyLeading: true,
                  titleFontSize: 18,
                  onBackTap: () {
                    context.read<HomeBloc>().add(HideCancelReasonEvent());
                  },
                ),
                Container(
                  height: size.height * 0.8,
                  width: size.width,
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      SizedBox(
                          width: size.width,
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .selectReasonForCancel,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 16,
                                ),
                            maxLines: 2,
                          )),
                      SizedBox(height: size.width * 0.05),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0;
                                i <
                                    context
                                        .read<HomeBloc>()
                                        .cancelReasons
                                        .length;
                                i++)
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.025),
                                child: InkWell(
                                  onTap: () {
                                    context.read<HomeBloc>().add(
                                        ChooseCancelReasonEvent(choosen: i));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: size.width * 0.06,
                                        height: size.width * 0.06,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: (context
                                                            .read<HomeBloc>()
                                                            .choosenCancelReason ==
                                                        i)
                                                    ? Theme.of(context)
                                                        .primaryColorDark
                                                    : AppColors.darkGrey),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCancelReason ==
                                                    i)
                                                ? Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                : Colors.transparent),
                                        child: (context
                                                    .read<HomeBloc>()
                                                    .choosenCancelReason ==
                                                i)
                                            ? Icon(
                                                Icons.done,
                                                size: size.width * 0.05,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              )
                                            : Container(),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      Expanded(
                                          child: MyText(
                                        text: context
                                            .read<HomeBloc>()
                                            .cancelReasons[i]
                                            .reason,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: (context
                                                          .read<HomeBloc>()
                                                          .choosenCancelReason ==
                                                      i)
                                                  ? Theme.of(context)
                                                      .primaryColorDark
                                                  : AppColors.darkGrey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                              width: size.width * 0.85,
                              child: CustomTextField(
                                onChange: (v) {
                                  if (context
                                          .read<HomeBloc>()
                                          .choosenCancelReason !=
                                      null) {
                                    context.read<HomeBloc>().add(
                                        ChooseCancelReasonEvent(choosen: null));
                                  }
                                },
                                controller:
                                    context.read<HomeBloc>().cancelReasonText,
                                maxLine: 5,
                                hintText: 'Others',
                              ),
                            )
                          ],
                        ),
                      )),
                      CustomButton(
                          buttonName: AppLocalizations.of(context)!.confirm,
                          width: size.width,
                          textSize: 18,
                          onTap: () {
                            if (context
                                    .read<HomeBloc>()
                                    .cancelReasonText
                                    .text
                                    .isNotEmpty ||
                                context.read<HomeBloc>().choosenCancelReason !=
                                    null) {
                              context
                                  .read<HomeBloc>()
                                  .add(CancelRequestEvent());
                            } else {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .selectCancelReasonError);
                            }
                          }),
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
