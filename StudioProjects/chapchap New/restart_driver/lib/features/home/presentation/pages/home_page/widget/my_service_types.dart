import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class MyServiceTypeWidget extends StatelessWidget {
  const MyServiceTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: Container(
            height: size.height * 0.5,
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: size.width * 0.05),
                Container(
                  padding: EdgeInsets.all(size.width * 0.05),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderColors, // border color
                        width: 1, // border width
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                          text: AppLocalizations.of(context)!.vehicleType,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColorDark)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.minimize,
                          color: AppColors.hintColor,
                        ),
                      )
                    ],
                  ),
                ),
                // SizedBox(height: size.width * 0.05),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Container(
                    height: size.width * 0.13,
                    width: size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.022),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: Row(
                          children: [
                            Container(
                              height: size.width * 0.08,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.grey),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                    child: MyText(
                                        text: userData!.vehicleTypeName)),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                userData!.subVehicleType!.length,
                                (index) {
                                  return Container(
                                    height: size.width * 0.08,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).dividerColor),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Center(
                                          child: MyText(
                                              text: userData!
                                                  .subVehicleType![index]
                                                  .name)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: size.width * 0.05),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          itemCount:
                              context.read<HomeBloc>().subVehicleTypes.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                            final vehicleType =
                                context.read<HomeBloc>().subVehicleTypes[index];
                            return Padding(
                              padding: EdgeInsets.all(size.width * 0.025),
                              child: Theme(
                                data: ThemeData(
                                    unselectedWidgetColor:
                                        Theme.of(context).primaryColorDark,
                                    listTileTheme: const ListTileThemeData(
                                      horizontalTitleGap: 0.0,
                                      contentPadding: EdgeInsets.zero,
                                    )),
                                child: CheckboxListTile(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: context
                                      .read<HomeBloc>()
                                      .selectedSubVehicleTypes
                                      .contains(vehicleType.id),
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: MyText(
                                    text: vehicleType.name,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                  ),
                                  onChanged: (value) {
                                    if (value!) {
                                      context
                                          .read<HomeBloc>()
                                          .selectedSubVehicleTypes
                                          .add(vehicleType.id);
                                    } else {
                                      context
                                          .read<HomeBloc>()
                                          .selectedSubVehicleTypes
                                          .remove(vehicleType.id);
                                    }
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                Center(
                  child: CustomButton(
                      width: size.width * 0.9,
                      // height: size.width * 0.13,
                      borderRadius: 10,
                      buttonName: AppLocalizations.of(context)!.confirm,
                      onTap: () {
                        Navigator.pop(context);
                        context.read<HomeBloc>().add(UpdateSubVehiclesTypeEvent(
                            subTypes: context
                                .read<HomeBloc>()
                                .selectedSubVehicleTypes));
                      }),
                ),
                SizedBox(height: size.width * 0.05),
              ],
            ),
          ),
        );
      },
    );
  }
}
