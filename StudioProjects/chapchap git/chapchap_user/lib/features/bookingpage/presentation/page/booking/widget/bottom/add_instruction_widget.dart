import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/booking_bloc.dart';

class AddInstructionWidget extends StatelessWidget {
  const AddInstructionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            // 👇 THIS PUSHES CONTENT UP WHEN KEYBOARD OPENS
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
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
                    SizedBox(height: size.width * 0.025),

                    /// Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.width * 0.025,
                      ),
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
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.cancel_outlined),
                          )
                        ],
                      ),
                    ),

                    const Divider(),

                    /// TextField
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.width * 0.025,
                      ),
                      child: CustomTextField(
                        controller:
                            context.read<BookingBloc>().instructionsController,
                        borderRadius: 10,
                        filled: true,
                        hintText:
                            '${AppLocalizations.of(context)!.instructions} '
                            '(${AppLocalizations.of(context)!.optional})',
                        maxLine: 3,
                        keyboardType: TextInputType.text,
                        onChange: (_) {
                          context.read<BookingBloc>().add(UpdateEvent());
                        },
                      ),
                    ),

                    SizedBox(height: size.width * 0.03),

                    /// Button
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                      ),
                      child: CustomButton(
                        width: size.width,
                        borderRadius: 10,
                        buttonName: AppLocalizations.of(context)!.continueN,
                        buttonColor: Theme.of(context).primaryColor,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),

                    SizedBox(height: size.width * 0.1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
