import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../../core/utils/custom_text.dart';

class SelectPreferenceWidget extends StatefulWidget {
  final BuildContext cont;
  final dynamic thisValue;
  const SelectPreferenceWidget({
    super.key,
    required this.cont,
    this.thisValue,
  });

  @override
  State<SelectPreferenceWidget> createState() => _SelectPreferenceWidgetState();
}

class _SelectPreferenceWidgetState extends State<SelectPreferenceWidget> {
  @override
  void initState() {
    super.initState();
    final bloc = widget.cont.read<HomeBloc>();
    bloc.tempSelectPreference =
        List<int>.from(bloc.selectedPreferenceDetailsList);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          return SafeArea(
            child: Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderColors, // border color
                          width: 1, // border width
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.preferences,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 18),
                          ),
                          InkWell(
                            onTap: () {
                              context
                                  .read<HomeBloc>()
                                  .add(ClearTempPreferenceEvent());
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.minimize,
                              color: AppColors.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (homeBloc.preferenceDetailsList != null)
                            Column(
                              children: List.generate(
                                homeBloc.preferenceDetailsList!.length,
                                (index) {
                                  final prefId =
                                      homeBloc.preferenceDetailsList![index].id;
                                  final isSelected = homeBloc
                                      .tempSelectPreference
                                      .contains(prefId);

                                  return Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppColors
                                              .borderColors, // border color
                                          width: 1, // border width
                                        ),
                                      ),
                                    ),
                                    child: Theme(
                                      data: ThemeData(
                                        unselectedWidgetColor:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      child: CheckboxListTile(
                                        value: isSelected,
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        onChanged: (value) {
                                          homeBloc.add(
                                            SelectedPreferenceEvent(
                                              prefId: prefId,
                                              isSelected: value ?? false,
                                            ),
                                          );
                                        },
                                        title: MyText(
                                          text: homeBloc
                                              .preferenceDetailsList![index]
                                              .name,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        buttonName: AppLocalizations.of(context)!.confirm,
                        width: size.width * 0.9,
                        onTap: () {
                          context
                              .read<HomeBloc>()
                              .add(ConfirmPreferenceEvent());
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * 0.025,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
