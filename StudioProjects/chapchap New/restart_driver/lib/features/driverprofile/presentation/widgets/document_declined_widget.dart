import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class DocumentDeclinedWidget extends StatelessWidget {
  final BuildContext cont;
  const DocumentDeclinedWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          return Container(
            height: size.width * 1.75,
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Image.asset(
                      AppImages.documentDeclined,
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.width * 0.05),
                    SizedBox(
                      width: size.width * 0.9,
                      child: MyText(
                        text: AppLocalizations.of(context)!.profileDeclined,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  fontSize: 18,
                                  color: AppColors.red,
                                ),
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                    Column(
                      children: [
                        if (userData!.declinedReason != null &&
                            userData!.declinedReason != '')
                          SizedBox(
                            width: size.width * 0.9,
                            child: MyText(
                                text: userData!.declinedReason,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                maxLines: 6),
                          ),
                        if (userData!.declinedReason == null ||
                            userData!.declinedReason == '')
                          SizedBox(
                            width: size.width * 0.9,
                            child: MyText(
                                text:
                                    '${AppLocalizations.of(context)!.evaluatingProfile}\n${AppLocalizations.of(context)!.profileApprove}',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                maxLines: 6),
                          ),
                      ],
                    ),
                  ],
                )),
                SizedBox(height: size.width * 0.05),
                if (userData!.declinedReason != null)
                  CustomButton(
                      buttonName: AppLocalizations.of(context)!.modifyDocument,
                      width: size.width,
                      textSize: 18,
                      onTap: () {
                        context.read<DriverProfileBloc>().reUploadDocument =
                            true;
                        context
                            .read<DriverProfileBloc>()
                            .add(DriverUpdateEvent());
                      }),
                SizedBox(height: size.width * 0.05),
              ],
            ),
          );
        },
      ),
    );
  }
}
