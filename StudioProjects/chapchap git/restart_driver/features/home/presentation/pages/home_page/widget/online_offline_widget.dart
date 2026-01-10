import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';
import 'instand_ride/avatar_glow.dart';

class OnlineOfflineWidget extends StatelessWidget {
  final BuildContext cont;
  const OnlineOfflineWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return AnimatedToggleSwitch<bool>.dual(
            current: userData!.active,
            first: false,
            second: true,
            spacing: size.width * 0.1,
            borderWidth: 2.0,
            height: size.width * 0.12,
            onChanged: (value) {
              if (value == false) {
                userData!.active = false;
                context.read<HomeBloc>().add(UpdateEvent());
                // Check if switching to offline
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext ctx) {
                    return CustomDoubleButtonDialoge(
                      title: AppLocalizations.of(context)!.confirmation,
                      content:
                          AppLocalizations.of(context)!.offlineConfirmation,
                      yesBtnName: AppLocalizations.of(context)!.confirm,
                      noBtnName: AppLocalizations.of(context)!.cancel,
                      yesBtnFunc: () {
                        context
                            .read<HomeBloc>()
                            .add(ChangeOnlineOfflineEvent());
                        Navigator.pop(ctx);
                      },
                      noBtnFunc: () {
                        userData!.active = true;
                        context.read<HomeBloc>().add(UpdateEvent());
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              } else {
                userData!.active = value;
                context.read<HomeBloc>().add(ChangeOnlineOfflineEvent());
              }
            },
            style: const ToggleStyle(
              borderColor: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            styleBuilder: (value) => ToggleStyle(
              indicatorColor: value
                  ? const Color.fromARGB(255, 117, 218, 0)
                  : AppColors.red,
            ),
            indicatorSize: const Size(40, 40),
            iconBuilder: (value) => value
                ? Icon(
                    Icons.done,
                    size: size.width * 0.05,
                    color: AppColors.white,
                  )
                : AvatarGlow(
                    glowColor: AppColors.red,
                    animate: true,
                    child: CircleAvatar(
                      backgroundColor: AppColors.red,
                      radius: 50.0,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: size.width * 0.05,
                        color: AppColors.white,
                      ),
                    ),
                  ),
            textBuilder: (value) => Center(
              child: MyText(
                text: value
                    ? AppLocalizations.of(context)!.onlineCaps
                    : AppLocalizations.of(context)!.offlineCaps,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: value
                          ? const Color.fromARGB(255, 117, 218, 0)
                          : AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
