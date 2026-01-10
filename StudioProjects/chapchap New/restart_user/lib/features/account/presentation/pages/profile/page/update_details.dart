import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/network/extensions.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class UpdateDetails extends StatelessWidget {
  static const String routeName = '/UpdateDetails';
  final UpdateDetailsArguments arg;

  const UpdateDetails({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(UpdateControllerWithDetailsEvent(args: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is UserDetailsButtonSuccess) {
            context.read<AccBloc>().add(AccGetUserDetailsEvent());
            Navigator.pop(context);
          } else if (state is UserDetailsUpdatedState) {
            context.showSnackBar(
              color: Theme.of(context).primaryColorDark,
              message: AppLocalizations.of(context)!.updateSuccess,
            );
            Navigator.pop(context, state);
          } else if (state is UpdateUserDetailsFailureState) {
            context.showSnackBar(
              color: Theme.of(context).primaryColor,
              message: AppLocalizations.of(context)!.failedUpdateDetails,
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            final user = accBloc.userData ?? arg.userData;
            final header = arg.header;
            final isMobileHeader =
                header == AppLocalizations.of(context)!.mobile;
            final isEmailHeader =
                header == AppLocalizations.of(context)!.email ||
                    header == AppLocalizations.of(context)!.emailAddress;

            if (isMobileHeader) {
              accBloc.updateController.text = user.mobile;
            }

            return Scaffold(
              appBar: CustomAppBar(
                title: '${AppLocalizations.of(context)!.update} ${arg.header}',
                automaticallyImplyLeading: true,
              ),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: (arg.header ==
                                    AppLocalizations.of(context)!.name)
                                ? AppLocalizations.of(context)!
                                    .enterNameIdOrPassport
                                : (arg.header ==
                                        AppLocalizations.of(context)!.gender)
                                    ? AppLocalizations.of(context)!
                                        .enterYourGender
                                    : AppLocalizations.of(context)!
                                        .enterYourEmail,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor),
                            maxLines: 2,
                          ),
                          SizedBox(height: size.height * 0.02),

                          // Gender Dropdown
                          if (header == AppLocalizations.of(context)!.gender)
                            BlocBuilder<AccBloc, AccState>(
                              builder: (context, state) {
                                List<String> showGenderList = [
                                  AppLocalizations.of(context)!.male,
                                  AppLocalizations.of(context)!.female,
                                  AppLocalizations.of(context)!.preferNotSay,
                                ];
                                return DropdownButtonFormField<String>(
                                  alignment: Alignment.bottomCenter,
                                  dropdownColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    filled: true,
                                    hintText: context
                                            .read<AccBloc>()
                                            .selectedGender
                                            .isNotEmpty
                                        ? context.read<AccBloc>().selectedGender
                                        : AppLocalizations.of(context)!
                                            .selectGender,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                  ),
                                  items: showGenderList.map((gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    int index = showGenderList
                                        .indexOf(newValue.toString());
                                    if (index != -1) {
                                      String codedValue = context
                                          .read<AccBloc>()
                                          .genderOptions[index];
                                      context.read<AccBloc>().add(
                                          GenderSelectedEvent(
                                              selectedGender: codedValue));
                                    }
                                  },
                                );
                              },
                            ),

                          // TextField for Name/Email/Mobile
                          if (header != AppLocalizations.of(context)!.gender)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: arg.header,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 12,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                CustomTextField(
                                  controller: accBloc.updateController,
                                  contentPadding:
                                      EdgeInsets.all(size.width * 0.025),
                                  filled: true,
                                  hintText: arg.header,
                                  hintTextStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontSize: 14,
                                        color: AppColors.greyHintColor,
                                      ),
                                  keyboardType: isMobileHeader
                                      ? TextInputType.number
                                      : (isEmailHeader
                                          ? TextInputType.emailAddress
                                          : TextInputType.text),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.greyHintColor,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.borderColors,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.borderColors,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: CustomButton(
                        isLoader: BlocProvider.of<AccBloc>(context).isLoading,
                        buttonName: AppLocalizations.of(context)!.update,
                        width: size.width * 0.9,
                        textSize: 16,
                        onTap: () {
                          final updatedText = accBloc.updateController.text;
                          final accUser = user;
                          final updatedName =
                              header == AppLocalizations.of(context)!.name
                                  ? updatedText
                                  : accUser.name;
                          final updatedEmail =
                              (header == AppLocalizations.of(context)!.email ||
                                      header ==
                                          AppLocalizations.of(context)!
                                              .emailAddress)
                                  ? updatedText
                                  : accUser.email;
                          final updatedMobile =
                              isMobileHeader ? updatedText : accUser.mobile;

                          context.read<AccBloc>().add(
                                UpdateUserDetailsEvent(
                                  name: updatedName,
                                  email: updatedEmail,
                                  gender: header ==
                                          AppLocalizations.of(context)!.gender
                                      ? accBloc.selectedGender
                                      : accUser.gender,
                                  profileImage: accBloc.profileImage.isEmpty
                                      ? ''
                                      : accBloc.profileImage,
                                  mobile: updatedMobile,
                                  country: accUser.countryCode,
                                ),
                              );
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
