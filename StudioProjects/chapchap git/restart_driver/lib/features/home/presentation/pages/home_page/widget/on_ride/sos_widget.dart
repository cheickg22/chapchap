import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class SosWidget extends StatelessWidget {
  final BuildContext cont;
  const SosWidget({super.key,required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).shadowColor,
                          spreadRadius: 1,
                          blurRadius: 1)
                    ]),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (builder) {
                          return AlertDialog(
                            content: Container(
                              height: size.width,
                              width: size.width * 0.9,
                              padding: EdgeInsets.all(size.width * 0.05),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        await FirebaseDatabase.instance
                                            .ref()
                                            .child(
                                                'SOS/${userData!.onTripRequest!.id}')
                                            .update({
                                          "is_driver": "1",
                                          "is_user": "0",
                                          "req_id": userData!.onTripRequest!.id,
                                          "serv_loc_id":
                                              userData!.serviceLocationId,
                                          "updated_at": ServerValue.timestamp
                                        });
                                        if (!context.mounted) return;
                                        showToast(
                                            message:
                                                AppLocalizations.of(context)!
                                                    .notifiedToAdmin);
                                      },
                                      child: SizedBox(
                                        width: size.width * 0.8,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .notifyAdmin,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColorDark,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400),
                                              ),
                                            ),
                                            Icon(
                                              Icons.notification_add,
                                              size: size.width * 0.07,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                    Column(
                                      children: [
                                        if(userData!.sos!=null)
                                        ListView.builder(
                                          itemCount: userData!.sos!.data.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (_, i) {
                                          return InkWell(
                                            onTap: () {
                                              context.read<HomeBloc>().add(
                                                  OpenAnotherFeatureEvent(
                                                      value:
                                                          'tel:${userData!.sos!.data[i].number}'));
                                            },
                                            child: Container(
                                              width: size.width * 0.8,
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  size.width * 0.025,
                                                  0,
                                                  size.width * 0.025),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        MyText(
                                                          text: userData!.sos!
                                                              .data[i].name,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                        ),
                                                        MyText(
                                                          text: userData!.sos!
                                                              .data[i].number,
                                                          textStyle: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.call,
                                                    size: size.width * 0.07,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                      
                                        },)    
                                          ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Container(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    decoration: BoxDecoration(
                      color:Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sos,
                      size: size.width * 0.07,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.05)
            ],
          );
        },
      ),
    );
  }
}
