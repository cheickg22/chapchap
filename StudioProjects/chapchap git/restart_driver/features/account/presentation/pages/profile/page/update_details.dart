import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_validators.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_snack_bar.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class UpdateDetails extends StatelessWidget {
  static const String routeName = '/UpdateDetails';
  final UpdateDetailsArguments arg;

  const UpdateDetails({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent())
        ..add(UpdateControllerWithDetailsEvent(args: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is UserDetailsButtonSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.detailsUpdateSuccess)),
            );
            AccGetUserDetailsEvent();
            Navigator.pop(context);
          } else if (state is UpdateUserDetailsFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.detailsUpdatefail)),
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: '${AppLocalizations.of(context)!.update} ${arg.header}',
                automaticallyImplyLeading: true,
              ),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: arg.header,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                          ),
                          MyText(
                            text:
                                '${AppLocalizations.of(context)!.youCanEditText} ${arg.header} ${AppLocalizations.of(context)!.here}.',
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context).disabledColor,
                                    fontSize: 14),
                          ),
                          SizedBox(height: size.height * 0.02),
                          if (arg.header ==
                              AppLocalizations.of(context)!.gender)
                            BlocBuilder<AccBloc, AccState>(
                              builder: (context, state) {
                                return DropdownButtonFormField<String>(
                                  alignment: Alignment.bottomCenter,
                                  dropdownColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    filled: true,
                                    hintText: AppLocalizations.of(context)!
                                        .selectGender,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  value: BlocProvider.of<AccBloc>(context)
                                          .selectedGender
                                          .isNotEmpty
                                      ? BlocProvider.of<AccBloc>(context)
                                          .selectedGender
                                      : null,
                                  items: BlocProvider.of<AccBloc>(context)
                                      .genderOptions
                                      .map((gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    BlocProvider.of<AccBloc>(context).add(
                                        GenderSelectedEvent(
                                            selectedGender: value!));
                                  },
                                );
                              },
                            ),
                          if (arg.header !=
                              AppLocalizations.of(context)!.gender)
                            CustomTextField(
                              controller: BlocProvider.of<AccBloc>(context)
                                  .updateController,
                              hintText: arg.header,
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: 18),
                            ),
                          const Divider(height: 1, color: Color(0xFFD9D9D9)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: CustomButton(
                        isLoader: BlocProvider.of<AccBloc>(context).isLoading,
                        buttonName: AppLocalizations.of(context)!.update,
                        onTap: () {
                          if (arg.header ==
                              AppLocalizations.of(context)!.email) {
                            if (!AppValidation.emailValidate(
                                BlocProvider.of<AccBloc>(context)
                                    .updateController
                                    .text)) {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .enterValidEmail);
                            } else {
                              context.read<AccBloc>().add(
                                  UpdateUserDetailsEvent(
                                      name: arg.header ==
                                              AppLocalizations.of(context)!.name
                                          ? BlocProvider.of<AccBloc>(context)
                                              .updateController
                                              .text
                                          : userData!.role == 'owner'
                                              ? userData!.companyName!
                                              : userData!.name,
                                      email: arg.header ==
                                              AppLocalizations.of(context)!
                                                  .email
                                          ? BlocProvider.of<AccBloc>(context)
                                              .updateController
                                              .text
                                          : userData!.email,
                                      gender: arg.header ==
                                              AppLocalizations.of(context)!
                                                  .gender
                                          ? BlocProvider.of<AccBloc>(context)
                                              .selectedGender
                                          : userData!.gender,
                                      profileImage: context
                                              .read<AccBloc>()
                                              .profileImage
                                              .isEmpty
                                          ? ""
                                          : context
                                              .read<AccBloc>()
                                              .profileImage));
                            }
                          } else {
                            context.read<AccBloc>().add(UpdateUserDetailsEvent(
                                name: arg.header ==
                                        AppLocalizations.of(context)!.name
                                    ? BlocProvider.of<AccBloc>(context)
                                        .updateController
                                        .text
                                    : userData!.role == 'owner'
                                        ? userData!.companyName!
                                        : userData!.name,
                                email: arg.header ==
                                        AppLocalizations.of(context)!.email
                                    ? BlocProvider.of<AccBloc>(context)
                                        .updateController
                                        .text
                                    : userData!.email,
                                gender: arg.header ==
                                        AppLocalizations.of(context)!.gender
                                    ? BlocProvider.of<AccBloc>(context)
                                        .selectedGender
                                    : userData!.gender,
                                profileImage: context
                                        .read<AccBloc>()
                                        .profileImage
                                        .isEmpty
                                    ? ""
                                    : context.read<AccBloc>().profileImage));
                          }
                        },
                      ),
                    ),
                    SizedBox(height: size.width * 0.1),
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
