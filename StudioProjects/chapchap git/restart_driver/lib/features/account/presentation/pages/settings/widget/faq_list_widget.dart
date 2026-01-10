import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/faq_model.dart';

class FaqDataListWidget extends StatelessWidget {
  final BuildContext cont;
  final List<FaqData> faqDataList;
  const FaqDataListWidget({super.key, required this.cont, required this.faqDataList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(value: cont.read<AccBloc>(),
    child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return faqDataList.isNotEmpty
        ? SizedBox(
            height: size.height * 0.725,
            child: RawScrollbar(
              radius: const Radius.circular(20),
              child: ListView.builder(
                itemCount: faqDataList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      context
                          .read<AccBloc>()
                          .add(FaqOnTapEvent(selectedFaqIndex: index));
                    },
                    child: Container(
                      width: size.width,
                      margin: const EdgeInsets.only(right: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1.2,
                              color: Theme.of(context).disabledColor)),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.025),
                        child: Row(
                          children: [
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          text: faqDataList[index].question,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                        ),
                                      ),
                                      RotatedBox(
                                          quarterTurns: (context
                                                      .read<AccBloc>()
                                                      .choosenFaqIndex ==
                                                  index)
                                              ? (context.read<AccBloc>().textDirection == 'ltr')
                                                  ? 2
                                                  : 4
                                              : (context.read<AccBloc>().textDirection == 'ltr')
                                                  ? 4
                                                  : 2,
                                          child: Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ))
                                    ],
                                  ),
                                  (context.read<AccBloc>().choosenFaqIndex ==
                                          index)
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: size.width * 0.025,
                                            ),
                                            SizedBox(
                                              width: size.width * 0.8,
                                              child: MyText(
                                                text: faqDataList[index].answer,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                maxLines: 3,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : SizedBox(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.08,
                  ),
                  Image.asset(
                    AppImages.noFaqPage,
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Text(AppLocalizations.of(context)!.noDataFound),
                ],
              ),
            ),
          );
  
    },),);
  }
}