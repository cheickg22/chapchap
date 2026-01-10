import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_snack_bar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/core/utils/custom_textfield.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';

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
            height: size.height,
            width: size.width,
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(size.width * 0.05, size.width * 0.05,
                size.width * 0.05, size.width * 0.05),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.width * 0.1),
                  InkWell(
                    onTap: () {
                      context.read<HomeBloc>().add(HideCancelReasonEvent());
                    },
                    child: Container(
                      width: size.width * 0.1,
                      height: size.width * 0.1,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Theme.of(context).shadowColor)
                          ]),
                      child: Icon(
                        Icons.arrow_back,
                        size: size.width * 0.07,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  SizedBox(height: size.width * 0.05),
                  Center(
                    child: SizedBox(
                        width: size.width * 0.83,
                        child: MyText(
                            text: AppLocalizations.of(context)!
                                .selectReasonForCancel)),
                  ),
                  SizedBox(height: size.width * 0.05),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var i = 0;
                            i < context.read<HomeBloc>().cancelReasons.length;
                            i++)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: size.width * 0.05),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    context.read<HomeBloc>().add(
                                        ChooseCancelReasonEvent(choosen: i));
                                  },
                                  child: Container(
                                    width: size.width * 0.83,
                                    padding: EdgeInsets.all(size.width * 0.04),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: (context
                                                        .read<HomeBloc>()
                                                        .choosenCancelReason ==
                                                    i)
                                                ? AppColors.darkGrey
                                                : AppColors.darkGrey.withAlpha(
                                                    (0.5 * 255).toInt()))),
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
                                          width: size.width * 0.05,
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
                              ),
                            ),
                          ),
                        SizedBox(
                          height: size.width * 0.05,
                        ),
                        SizedBox(
                          width: size.width * 0.83,
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
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                  Center(
                    child: CustomButton(
                        buttonName: AppLocalizations.of(context)!.confirm,
                        onTap: () {
                          if (context
                                  .read<HomeBloc>()
                                  .cancelReasonText
                                  .text
                                  .isNotEmpty ||
                              context.read<HomeBloc>().choosenCancelReason !=
                                  null) {
                            context.read<HomeBloc>().add(CancelRequestEvent());
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .selectCancelReasonError);
                          }
                        }),
                  ),
                  SizedBox(height: size.width * 0.1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
