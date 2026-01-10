import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/features/account/domain/models/contact_model.dart';
import 'package:restart_user/features/account/presentation/pages/sos/widget/pick_contact.dart';
import 'package:restart_user/features/account/presentation/pages/sos/widget/sos_card_shimmer.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../common/common.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/sos_detail_widget.dart';

class SosPage extends StatelessWidget {
  static const String routeName = '/sosPage';
  final SOSPageArguments arg;

  const SosPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(SosInitEvent(arg: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is SelectContactDetailsState) {
            final accBloc = context.read<AccBloc>();
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: true,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) {
                return BlocProvider.value(
                  value: accBloc,
                  child: const PickContact(),
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.sosText,
                automaticallyImplyLeading: true,
                onBackTap: () {
                  Navigator.pop(context, context.read<AccBloc>().sosdata);
                },
              ),
              body: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (context.read<AccBloc>().isSosLoading)
                        ListView.builder(
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return SosShimmerLoading(size: size);
                          },
                        ),
                      if (!context.read<AccBloc>().isSosLoading)
                        SosDetailWidget(
                            sosdata: context.read<AccBloc>().sosdata,
                            cont: context),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: (context.read<AccBloc>().sosdata.length <= 4)
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: CustomButton(
                            buttonName:
                                AppLocalizations.of(context)!.addAContact,
                            isLoader: context.read<AccBloc>().isLoading,
                            onTap: () {
                              context.read<AccBloc>().selectedContact =
                                  ContactsModel(name: '', number: '');
                              context
                                  .read<AccBloc>()
                                  .add(SelectContactDetailsEvent());
                            }),
                      ),
                    )
                  : null);
        }),
      ),
    );
  }
}
