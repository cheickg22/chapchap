import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_header.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class SuccessSecWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  const SuccessSecWidget(
      {super.key, required this.cont, required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Column(
            children: [
              CustomHeader(
                title: AppLocalizations.of(context)!.subscription,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
              ),
              SizedBox(
                height: size.width * 0.1,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.subcriptionPlanActive),
                  SizedBox(height: size.height * 0.04),
                  MyText(
                    text: AppLocalizations.of(context)!.subscriptionSuccess,
                    textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 20),
                  ),
                  SizedBox(height: size.height * 0.03),
                  if (userData!.subscription != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyText(
                        text:
                            '${AppLocalizations.of(context)!.subscriptionSuccessDescOne.replaceAll('\\n', '\n').replaceAll('A', userData!.subscription!.data.subscriptionName)} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionSuccessDescTwo.replaceAll("\\n", "\n")}',
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 15,
                                ),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
