import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_text.dart';
import '../../application/language_bloc.dart';
import '../../domain/models/language_listing_model.dart';

class LanguageListWidget extends StatelessWidget {
  final BuildContext cont;
  final List<LocaleLanguageList> languageList;
  const LanguageListWidget({super.key, required this.cont, required this.languageList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(value: cont.read<LanguageBloc>(),
    child: BlocBuilder<LanguageBloc,LanguageState>(builder: (context, state) {
      return SizedBox(
            height: size.height * 0.7,
            child: RawScrollbar(
              radius: const Radius.circular(20),
              child: ListView.builder(
                itemCount: languageList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 8),
                    child: InkWell(
                      onTap: () {
                        context.read<LanguageBloc>().add(
                            LanguageSelectEvent(selectedLanguageIndex: index));
                        context.read<LocalizationBloc>().add(
                            LocalizationInitialEvent(
                              isDark: Theme.of(context).brightness ==
                                    Brightness.dark,
                                locale: Locale(languageList[index].lang)));
                      },
                      child: Container(
                        height: 50,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color:
                                  (context.read<LanguageBloc>().selectedIndex ==
                                          index)
                                      ? AppColors.black
                                      : AppColors.white,
                              width:
                                  (context.read<LanguageBloc>().selectedIndex ==
                                          index)
                                      ? 2.0
                                      : 1.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: MyText(
                              text: languageList[index].name,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: AppColors.blackText,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ;
    },),);
  }
}