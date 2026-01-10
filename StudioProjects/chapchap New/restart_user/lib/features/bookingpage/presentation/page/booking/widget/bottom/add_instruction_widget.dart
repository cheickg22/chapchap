import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';

import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';

// Instruction
class AddInstructionWidget extends StatelessWidget {
  const AddInstructionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return SafeArea(
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.width * 0.025),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      size.width * 0.05,
                      size.width * 0.025,
                      size.width * 0.05,
                      size.width * 0.025),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.addInstructions,
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel_outlined),
                      )
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(height: size.width * 0.03),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      size.width * 0.05,
                      size.width * 0.025,
                      size.width * 0.05,
                      size.width * 0.025),
                  child: CustomTextField(
                    controller:
                        context.read<BookingBloc>().instructionsController,
                    borderRadius: 10,
                    filled: true,
                    hintText:
                        '${AppLocalizations.of(context)!.instructions}(${AppLocalizations.of(context)!.optional})',
                    maxLine: 3,
                    keyboardType: TextInputType.text,
                    onChange: (p0) {
                      context.read<BookingBloc>().add(UpdateEvent());
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.03),
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width * 0.05, right: size.width * 0.05),
                  child: CustomButton(
                    borderRadius: 10,
                    buttonName: AppLocalizations.of(context)!.continueN,
                    width: size.width,
                    buttonColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.1),
              ],
            ),
          ),
        );
      },
    );
  }
}
