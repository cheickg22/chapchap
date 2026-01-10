import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/custom_header.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/faq_list_widget.dart';

class FaqPage extends StatelessWidget {
  static const String routeName = '/faqPage';

  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(GetFaqListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Directionality(
            textDirection: context.read<AccBloc>().textDirection == 'rtl'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomHeader(
                      title: AppLocalizations.of(context)!.faq,
                      automaticallyImplyLeading: true,
                      titleFontSize: 18,
                      textColor: AppColors.hintColorGrey,
                    ),
                    SizedBox(height: size.width * 0.05),
                    FaqDataListWidget(
                        cont: context,
                        faqDataList: context.read<AccBloc>().faqDataList),
                    SizedBox(height: size.width * 0.05),
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
