import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class SuccessSecWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  const SuccessSecWidget({super.key, required this.cont, required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
     final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Center(
        child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.subscriptionSuccess),
              SizedBox(height: size.height * 0.04),
              MyText(
                text: AppLocalizations.of(context)!.subscriptionSuccess,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.blackText, fontSize: 20),
              ),
              SizedBox(height: size.height * 0.03),
              if(userData!.subscription!=null)
              MyText(
                text:
                    '${AppLocalizations.of(context)!.subscriptionSuccessDescOne.replaceAll('\\n', '\n').replaceAll('A', userData!.subscription!.data.subscriptionName)} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionSuccessDescTwo.replaceAll("\\n", "\n")}',
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.black,
                      fontSize: 16,
                    ),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: size.width * 0.02,
          child: Row(
            children: [
              (isFromAccPage)
                  ? InkWell(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: size.width * 0.07,
                        color: AppColors.black,
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                width: size.width * 0.05,
              ),
              MyText(
                text: AppLocalizations.of(context)!.subscription,
                textStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontSize: 18, color: AppColors.blackText),
              ),
            ],
          ),
        ),
      ],
    ));
  
          },
      ),
    );
  }
}