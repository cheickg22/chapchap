import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class AddFleetDriverWidget extends StatelessWidget {
  final BuildContext cont;
  const AddFleetDriverWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              body: Container(
                height: size.height,
                width: size.width,
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.paddingOf(context).top,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: size.width * 0.07,
                                color: Theme.of(context).primaryColorDark,
                              )),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!.addDriver,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!.driverName,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                                width: size.width * 0.9,
                                child: CustomTextField(
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AppColors.darkGrey,
                                      width: 1,
                                    )),
                                    hintText: AppLocalizations.of(context)!
                                        .enterDriverName,
                                    controller: context
                                        .read<AccBloc>()
                                        .driverNameController)),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!.driverMobile,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                                width: size.width * 0.9,
                                child: CustomTextField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AppColors.darkGrey,
                                      width: 1,
                                    )),
                                    hintText: AppLocalizations.of(context)!
                                        .enterDriverMobile,
                                    controller: context
                                        .read<AccBloc>()
                                        .driverMobileController)),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!.driverEmail,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                                width: size.width * 0.9,
                                child: CustomTextField(
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AppColors.darkGrey,
                                      width: 1,
                                    )),
                                    hintText: AppLocalizations.of(context)!
                                        .enterDriverEmail,
                                    controller: context
                                        .read<AccBloc>()
                                        .driverEmailController)),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                              width: size.width * 0.9,
                              child: MyText(
                                text: AppLocalizations.of(context)!.driverAddress,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 0.05,
                            ),
                            SizedBox(
                                width: size.width * 0.9,
                                child: CustomTextField(
                                    focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: AppColors.darkGrey,
                                      width: 1,
                                    )),
                                    hintText: AppLocalizations.of(context)!
                                        .enterDriverAddress,
                                    controller: context
                                        .read<AccBloc>()
                                        .driverAddressController)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                    CustomButton(
                        buttonName: AppLocalizations.of(context)!.addDriver,
                        onTap: () {
                          if (context
                                  .read<AccBloc>()
                                  .driverAddressController
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<AccBloc>()
                                  .driverEmailController
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<AccBloc>()
                                  .driverMobileController
                                  .text
                                  .isNotEmpty &&
                              context
                                  .read<AccBloc>()
                                  .driverNameController
                                  .text
                                  .isNotEmpty) {
                            context.read<AccBloc>().add(AddDriverEvent());
                            Navigator.pop(context);
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .enterRequiredField);
                          }
                        }),
                    SizedBox(
                      height: size.width * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
