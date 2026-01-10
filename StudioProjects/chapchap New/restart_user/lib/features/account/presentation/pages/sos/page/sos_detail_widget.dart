// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/home/domain/models/contact_model.dart';
import 'package:restart_tagxi/features/home/domain/models/user_details_model.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../features/auth/application/auth_bloc.dart';
import '../../../../../../features/auth/presentation/widgets/select_country_widget.dart';

class SosDetailWidget extends StatelessWidget {
  final BuildContext cont;
  final List<SOSDatum> sosdata;
  const SosDetailWidget({super.key, required this.cont, required this.sosdata});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<AccBloc>(),
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final list = context.watch<AccBloc>().sosdata;
            final userContacts =
                list.where((contact) => contact.userType != 'admin').toList();

            return userContacts.isNotEmpty
                ? RawScrollbar(
                    radius: const Radius.circular(20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: userContacts.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final contact = userContacts[index];
                        return Container(
                          width: size.width,
                          margin: const EdgeInsets.only(right: 10, bottom: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 1.2,
                                  color: Theme.of(context).disabledColor)),
                          child: Padding(
                            padding: EdgeInsets.all(size.width * 0.025),
                            child: Row(
                              children: [
                                SizedBox(width: size.width * 0.025),
                                Container(
                                  height: size.width * 0.13,
                                  width: size.width * 0.13,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.5 * 255).toInt()),
                                  ),
                                  alignment: Alignment.center,
                                  child: MyText(
                                    text:
                                        contact.name.toString().substring(0, 1),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.025,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text: contact.name,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyText(
                                              text: contact.number,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: size.width * 0.025),
                                InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext _) {
                                          return BlocProvider.value(
                                            value: BlocProvider.of<AccBloc>(
                                                context),
                                            child: CustomDoubleButtonDialoge(
                                              title:
                                                  AppLocalizations.of(context)!
                                                      .deleteSos,
                                              content:
                                                  AppLocalizations.of(context)!
                                                      .deleteContact,
                                              yesBtnName:
                                                  AppLocalizations.of(context)!
                                                      .yes,
                                              noBtnName:
                                                  AppLocalizations.of(context)!
                                                      .no,
                                              yesBtnFunc: () {
                                                context
                                                    .read<AccBloc>()
                                                    .add(SosLoadingEvent());
                                                context.read<AccBloc>().add(
                                                    DeleteContactEvent(
                                                        id: contact.id));
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : _buildEmptyState(context, size);
          },
        ));
  }

  Widget _buildEmptyState(BuildContext context, Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.1),
          // Illustration
          Image.asset(
            AppImages.sosNoData,
            height: size.width * 0.5,
          ),
          SizedBox(height: size.height * 0.04),
          // Title
          MyText(
            text: AppLocalizations.of(context)!.nososContacts,
            textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyHintColor,
                ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.015),
          SizedBox(height: size.height * 0.05),
          // Primary Button - Add from contacts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: CustomButton(
                height: 52,
                width: double.infinity,
                borderRadius: 12,
                buttonColor: AppColors.primary,
                textColor: AppColors.white,
                textSize: 16,
                buttonName: AppLocalizations.of(context)!.addContact,
                onTap: () {
                  context.read<AccBloc>().selectedContact =
                      ContactsModel(name: '', number: '');
                  context.read<AccBloc>().add(SelectContactDetailsEvent());
                },
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          // Secondary Button - Add manually
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: CustomButton(
                height: 52,
                width: double.infinity,
                borderRadius: 12,
                buttonColor: AppColors.white,
                textColor: const Color(0xFF0000D6),
                textSize: 16,
                border: Border.all(color: const Color(0xFFFFFFFF)),
                buttonName: AppLocalizations.of(context)!.addManually,
                onTap: () {
                  showAddManuallyBottomSheet(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddManuallyBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final accBloc = context.read<AccBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider(
          create: (_) => AuthBloc()
            ..add(GetDirectionEvent())
            ..add(CountryGetEvent())
            ..add(GetCommonModuleEvent()),
          child: Builder(
            builder: (bottomContext) {
              String? nameError;
              String? phoneError;

              return StatefulBuilder(
                builder: (ctx, setState) {
                  return SizedBox(
                    height: MediaQuery.of(sheetContext).size.height,
                    // color: AppColors.white,
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            // color: AppColors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                  text: AppLocalizations.of(sheetContext)!
                                      .addContact,
                                  textStyle: Theme.of(sheetContext)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Form Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First Name TextField
                                TextField(
                                  controller: firstNameController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(sheetContext)!
                                        .firstName,
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade400),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                if (nameError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 4.0),
                                    child: MyText(
                                      text: nameError,
                                      textStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                // Last Name TextField
                                TextField(
                                  controller: lastNameController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(sheetContext)!
                                        .lastName,
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade400),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Phone Number Row
                                Row(
                                  children: [
                                    // Country Code Dropdown (from country API)
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (ctx, state) {
                                        final auth = ctx.read<AuthBloc>();
                                        return InkWell(
                                          onTap: () {
                                            final countries = auth.countries;
                                            if (countries.isNotEmpty) {
                                              showModalBottomSheet(
                                                context: bottomContext,
                                                isScrollControlled: true,
                                                backgroundColor: Theme.of(
                                                        bottomContext)
                                                    .scaffoldBackgroundColor,
                                                builder: (_) =>
                                                    SelectCountryWidget(
                                                  cont: bottomContext,
                                                  countries: countries,
                                                ),
                                              );
                                            }
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                MyText(
                                                  text: auth.dialCode,
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.grey.shade600,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    // Phone Number TextField
                                    Expanded(
                                      child: TextField(
                                        controller: phoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          hintText:
                                              AppLocalizations.of(sheetContext)!
                                                  .phoneNumber,
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade400),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (phoneError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 4.0),
                                    child: MyText(
                                      text: phoneError,
                                      textStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom Button
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            // color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: CustomButton(
                                height: 52,
                                width: double.infinity,
                                borderRadius: 12,
                                buttonColor: AppColors.primary,
                                textColor: AppColors.white,
                                textSize: 16,
                                buttonName: AppLocalizations.of(sheetContext)!
                                    .addContact,
                                onTap: () {
                                  final firstName =
                                      firstNameController.text.trim();
                                  final lastName =
                                      lastNameController.text.trim();
                                  final name = '$firstName $lastName'.trim();
                                  final rawNumber = phoneController.text.trim();

                                  setState(() {
                                    nameError = null;
                                    phoneError = null;
                                  });

                                  if (name.isEmpty) {
                                    setState(() {
                                      nameError =
                                          AppLocalizations.of(sheetContext)!
                                              .nameRequired;
                                    });
                                    return;
                                  }

                                  final localNumber = rawNumber.replaceAll(
                                      RegExp(r'[^0-9]'), '');
                                  if (localNumber.isEmpty) {
                                    setState(() {
                                      phoneError =
                                          AppLocalizations.of(sheetContext)!
                                              .phoneNumberRequired;
                                    });
                                    return;
                                  }

                                  // Prefix with selected country dial code from AuthBloc
                                  final auth = bottomContext.read<AuthBloc>();
                                  String dialCode = auth.dialCode;
                                  if (!dialCode.startsWith('+')) {
                                    dialCode = '+$dialCode';
                                  }
                                  final number = '$dialCode$localNumber';

                                  accBloc.add(SosLoadingEvent());
                                  accBloc.add(AddContactEvent(
                                      name: name, number: number));
                                  Navigator.pop(sheetContext);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
