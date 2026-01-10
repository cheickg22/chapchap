import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/notifications_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final BuildContext cont;
  final NotificationData notificationData;

  const NotificationCardWidget(
      {super.key, required this.cont, required this.notificationData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            margin: EdgeInsets.only(bottom: size.width * 0.05),
            padding: EdgeInsets.all(size.width * 0.025),
            decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withAlpha((0.5 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: size.width * 0.0025,
                  color: Theme.of(context).primaryColorDark.withAlpha((0.5 * 255).toInt()),
                )),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                          SizedBox(
                            width: size.width * 0.02,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: notificationData.title,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontSize: 16),
                                  maxLines: 5,
                                ),
                                MyText(
                                  text: notificationData.body,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor),
                                  maxLines: 5,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            MyText(
                              text: notificationData.convertedCreatedAt
                                  .split(' ')[0],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                            MyText(
                              text: notificationData.convertedCreatedAt
                                  .split(' ')[1],
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        Container(
                          height: size.width * 0.1,
                          width: size.width * 0.002,
                          color: const Color(0xFF171717).withAlpha((0.5 * 255).toInt()),
                        ),
                        SizedBox(
                          width: size.width * 0.01,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext _) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<AccBloc>(context),
                                  child: CustomSingleButtonDialoge(
                                    title: AppLocalizations.of(context)!
                                        .deleteNotification,
                                    content: AppLocalizations.of(context)!
                                        .deleteNotificationContent,
                                    btnName:
                                        AppLocalizations.of(context)!.confirm,
                                    onTap: () {
                                      context.read<AccBloc>().add(
                                          DeleteNotificationEvent(
                                              id: notificationData.id));
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: const Color(0xFF171717).withAlpha((0.5 * 255).toInt()),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                notificationData.image != null &&
                        notificationData.image!.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Image.network(
                            notificationData.image!,
                            width: 320,
                            height: 320,
                            fit: BoxFit.cover,
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          );
        },
      ),
    );
  }
}
