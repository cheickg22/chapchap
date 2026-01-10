import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';

class SosDetailWidget extends StatelessWidget {
  final BuildContext cont;
  final List<SOSDatum> sosdata;
  const SosDetailWidget({super.key, required this.cont, required this.sosdata});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<AccBloc>(),
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return sosdata.isNotEmpty
                ? RawScrollbar(
                    radius: const Radius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sosdata.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return (sosdata[index].userType != 'admin')
                            ? Container(
                                width: size.width,
                                margin: const EdgeInsets.only(
                                    right: 10, bottom: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1.2,
                                        color:
                                            Theme.of(context).disabledColor)),
                                child: Padding(
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  child: Row(
                                    children: [
                                      SizedBox(width: size.width * 0.025),
                                      Container(
                                        height: size.width * 0.13,
                                        width: size.width * 0.13,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withAlpha((0.5 * 255).toInt()),
                                        ),
                                        alignment: Alignment.center,
                                        child: MyText(
                                          text: sosdata[index]
                                              .name
                                              .toString()
                                              .substring(0, 1),
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MyText(
                                                    text: sosdata[index].name,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MyText(
                                                    text: sosdata[index].number,
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.025),
                                      InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext _) {
                                                return BlocProvider.value(
                                                  value:
                                                      BlocProvider.of<AccBloc>(
                                                          context),
                                                  child:
                                                      CustomDoubleButtonDialoge(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .deleteSos,
                                                    content: AppLocalizations
                                                            .of(context)!
                                                        .deleteContactContent,
                                                    yesBtnName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .yes,
                                                    noBtnName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .no,
                                                    yesBtnFunc: () {
                                                      context
                                                          .read<AccBloc>()
                                                          .add(
                                                              SosLoadingEvent());
                                                      context
                                                          .read<AccBloc>()
                                                          .add(
                                                              DeleteContactEvent(
                                                                  id: sosdata[
                                                                          index]
                                                                      .id));
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                          ))
                                    ],
                                  ),
                                ),
                              )
                            : (sosdata.length == 1)
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.sosNoData,
                                          height: size.width * 0.6,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noContactsSos,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  fontSize: 18),
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .addContactSos,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor,
                                                  fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox();
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.width * 0.2,
                        ),
                        Image.asset(
                          AppImages.sosNoData,
                          height: size.width * 0.6,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.noContactsSos,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.addContactSos,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                        ),
                      ],
                    ),
                  );
          },
        ));
  }
}
