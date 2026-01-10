import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/presentation/pages/complaint/page/complaint_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/complaint/widget/complaint_shimmer_list.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../../application/acc_bloc.dart';

class ComplaintListPage extends StatelessWidget {
  static const String routeName = '/complaintList';
  final ComplaintListPageArguments args;

  const ComplaintListPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(ComplaintEvent(
            complaintType:
                (args.choosenHistoryId == '') ? 'general' : 'request')),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.makeComplaint,
              automaticallyImplyLeading: true,
            ),
            body: (context.read<AccBloc>().isLoading)
                ? ComplaintShimmer(size: size)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.03),
                        MyText(
                            text: AppLocalizations.of(context)!.chooseComplaint,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: size.width * 0.05),
                        (state is MakeComplaintSuccess)
                            ? (state.complaintList != null &&
                                    state.complaintList!.isNotEmpty
                                ? SizedBox(
                                    height: size.height * 0.6,
                                    child: SingleChildScrollView(
                                      child: ListView.builder(
                                          itemCount:
                                              state.complaintList!.length,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final complaintList =
                                                state.complaintList![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    ComplaintPage.routeName,
                                                    arguments: ComplaintPageArguments(
                                                        title:
                                                            complaintList.title,
                                                        complaintTitleId:
                                                            complaintList.id,
                                                        selectedHistoryId: (args
                                                                    .choosenHistoryId ==
                                                                null)
                                                            ? ''
                                                            : args
                                                                .choosenHistoryId),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withAlpha((0.07 * 255)
                                                            .toInt()),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: MyText(
                                                              text:
                                                                  complaintList
                                                                      .title,
                                                              textStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16)),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 15,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.historyNoData,
                                          height: 200,
                                          width: 200,
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noComplaints,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ))
                            : const SizedBox()
                      ],
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
