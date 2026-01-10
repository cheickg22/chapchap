import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_validators.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../../auth/presentation/widgets/select_country_widget.dart';

class UpdateDetails extends StatelessWidget {
  static const String routeName = '/UpdateDetails';
  final UpdateDetailsArguments arg;

  const UpdateDetails({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccBloc()
            ..add(AccGetDirectionEvent())
            ..add(AccGetUserDetailsEvent())
            ..add(UpdateControllerWithDetailsEvent(args: arg)),
        ),
        BlocProvider(
          create: (context) => AuthBloc()
            ..add(GetDirectionEvent())
            ..add(CountryGetEvent()),
        ),
      ],
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
                                if (arg.header ==
                                    AppLocalizations.of(context)!.mobile)
                                  Builder(
                                    builder: (ctx) {
                                      final auth = ctx.watch<AuthBloc>();
                                      return Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              final countries = auth.countries;
                                              if (countries.isNotEmpty) {
                                                showModalBottomSheet(
                                                  context: ctx,
                                                  isScrollControlled: true,
                                                  backgroundColor: Theme.of(ctx)
                                                      .scaffoldBackgroundColor,
                                                  builder: (_) =>
                                                      SelectCountryWidget(
                                                          cont: ctx,
                                                          countries: countries),
                                                );
                                              }
                                            },
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 16),
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color:
                                                        AppColors.borderColors,
                                                    width: 1),
                                              ),
                                              child: MyText(
                                                text: auth.dialCode,
                                                textStyle: Theme.of(ctx)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: CustomTextField(
                                              controller:
                                                  BlocProvider.of<AccBloc>(
                                                          context)
                                                      .updateController,
                                              contentPadding: EdgeInsets.all(
                                                  size.width * 0.025),
                                              filled: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: auth.dialMaxLength,
                                              hintText:
                                                  AppLocalizations.of(context)!
                                                      .mobile,
                                              hintTextStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color:
                                                        AppColors.borderColors,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color:
                                                        AppColors.borderColors,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color:
                                                        AppColors.borderColors,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                else
                                  CustomTextField(
                                    controller:
                                        BlocProvider.of<AccBloc>(context)
                                            .updateController,
                                    contentPadding:
                                        EdgeInsets.all(size.width * 0.025),
                                    filled: true,
                                    hintText: arg.header,
                                    hintTextStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                        ),
                                    suffixConstraints: BoxConstraints(
                                        maxWidth: size.width * 0.2),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.borderColors,
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
                              context
                                  .read<AccBloc>()
                                  .add(UpdateUserDetailsEvent(
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
                                        : context.read<AccBloc>().profileImage,
                                    mobile: (arg.header ==
                                            AppLocalizations.of(context)!
                                                .mobile)
                                        ? BlocProvider.of<AccBloc>(context)
                                            .updateController
                                            .text
                                        : null,
                                    country: (arg.header ==
                                            AppLocalizations.of(context)!
                                                .mobile)
                                        ? context.read<AuthBloc>().countryCode
                                        : null,
                                  ));
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
                                      : context.read<AccBloc>().profileImage,
                                  mobile: (arg.header ==
                                          AppLocalizations.of(context)!.mobile)
                                      ? BlocProvider.of<AccBloc>(context)
                                          .updateController
                                          .text
                                      : null,
                                  country: (arg.header ==
                                          AppLocalizations.of(context)!.mobile)
                                      ? context.read<AuthBloc>().countryCode
                                      : null,
                                ));
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
