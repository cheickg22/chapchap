import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../application/acc_bloc.dart';

class ComplaintPage extends StatelessWidget {
  static const String routeName = '/complaintPage';
  final ComplaintPageArguments arg;

  const ComplaintPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is ComplaintButtonLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is ComplaintButtonLoadingState) {
            CustomLoader.dismiss(context);
          } else if (state is MakeComplaintButtonSuccess) {
            context.showSnackBar(
                color: Theme.of(context).primaryColor,
                message: AppLocalizations.of(context)!.complaintsSubmitted);
            Navigator.pop(context);
          } else if (state is MakeComplaintFailureState) {
            context.showSnackBar(
                color: Theme.of(context).primaryColor,
                message: state.errorMessage);
          } else if (state is ComplaintButtonFailureState) {
            context.showSnackBar(
                color: Theme.of(context).primaryColor,
                message: state.errorMessage);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.complaintDetails,
                automaticallyImplyLeading: true,
              ),
              body: (state is ComplaintButtonLoadingState)
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          MyText(
                            text: arg.title,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Container(
                            height: size.width * 0.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                )),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.width * 0.03),
                                  TextField(
                                      controller: context
                                          .read<AccBloc>()
                                          .complaintController,
                                      maxLines: 5,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16),
                                        hintText: AppLocalizations.of(context)!
                                            .writeYourComplaint,
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * 0.1),
                          Center(
                            child: CustomButton(
                              buttonName: AppLocalizations.of(context)!.submit,
                              onTap: () {
                                FocusScope.of(context).unfocus();

                                final complaintText = context
                                    .read<AccBloc>()
                                    .complaintController
                                    .text
                                    .trim();
                                if (complaintText.length < 10) {
                                  context.showSnackBar(
                                      message: AppLocalizations.of(context)!
                                          .complaintLengthError);
                                } else {
                                  context.read<AccBloc>().add(
                                        ComplaintButtonEvent(
                                          complaintText: complaintText,
                                          complaintTitleId:
                                              arg.complaintTitleId,
                                          requestId:
                                              (arg.selectedHistoryId == '')
                                                  ? ''
                                                  : arg.selectedHistoryId
                                                      .toString(),
                                        ),
                                      );
                                }
                              },
                            ),
                          ),
                          SizedBox(height: size.height * 0.1),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
