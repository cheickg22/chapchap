import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import '../../../../common/common.dart';
import '../../../../core/model/user_detail_model.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../loading/application/loading_bloc.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';
import 'apply_refferal_page.dart';

class RegisterPage extends StatelessWidget {
  static const String routeName = '/registerPage';
  final RegisterPageArguments arg;
  const RegisterPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(RegisterPageInitEvent(arg: arg)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is LoginSuccessState) {
            if (userData != null) {
              context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            }
            if (arg.isRefferalEarnings == "1") {
              Navigator.pushNamedAndRemoveUntil(
                  context, ApplyRefferalPage.routeName, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                // backgroundColor: const Color(0xffFAFAFB),
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.register,
                  titleFontSize: 18,
                  automaticallyImplyLeading: true,
                  onBackTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Form(
                              key: context.read<AuthBloc>().formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.width * 0.05),
                                  MyText(
                                    text: AppLocalizations.of(context)!.signUp,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            fontSize: 24),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .getStarted,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 14),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                  Container(
                                    // height: size.width*0.1,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.borderColor),
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    padding: EdgeInsets.all(size.width * 0.025),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: size.width * 0.025,
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .personalInformation,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                  fontSize: 18),
                                        ),
                                        SizedBox(height: size.width * 0.05),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .fullName,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontSize: 14),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        buildUserNameField(context, size),
                                        SizedBox(height: size.width * 0.05),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .mobileNumber,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontSize: 14),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        buildMobileField(context, size),
                                        SizedBox(height: size.width * 0.05),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .emailAddress,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontSize: 14),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        buildEmailField(context, size),
                                        SizedBox(height: size.width * 0.05),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .gender,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontSize: 14),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        buildDropDownGenderField(context),
                                        SizedBox(height: size.width * 0.05),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .password,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontSize: 14),
                                        ),
                                        SizedBox(height: size.width * 0.025),
                                        buildPasswordField(context, size),
                                        SizedBox(height: size.width * 0.025),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.width * 0.05),
                        buildButton(context),
                        SizedBox(height: size.width * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildProfilePick(Size size, BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: size.width * 0.15,
        backgroundColor: Theme.of(context).dividerColor,
        backgroundImage: context.read<AuthBloc>().profileImage.isNotEmpty
            ? FileImage(File(context.read<AuthBloc>().profileImage))
            : const AssetImage(AppImages.defaultProfile),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    _showImageSourceSheet(context);
                  },
                  child: Container(
                    height: size.width * 0.1,
                    width: size.width * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: const Center(child: Icon(Icons.edit)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.continueText,
        borderRadius: 6,
        textSize: 16,
        width: MediaQuery.sizeOf(context).width,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          if (context.read<AuthBloc>().formKey.currentState!.validate() &&
              !context.read<AuthBloc>().isLoading) {
            context.read<AuthBloc>().add(RegisterUserEvent(
                userName: context.read<AuthBloc>().rUserNameController.text,
                mobileNumber: context.read<AuthBloc>().rMobileController.text,
                emailAddress: context.read<AuthBloc>().rEmailController.text,
                password: context.read<AuthBloc>().rPasswordController.text,
                countryCode: context.read<AuthBloc>().countryCode,
                gender: context.read<AuthBloc>().selectedGender,
                loginAs: arg.loginAs,
                profileImage: context.read<AuthBloc>().profileImage));
          }
        },
      ),
    );
  }

  Widget buildPasswordField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rPasswordController,
      contentPadding: EdgeInsets.all(size.width * 0.025),
      filled: true,
      obscureText: !context.read<AuthBloc>().showPassword,
      hintText: AppLocalizations.of(context)!.strongPassword,
      hintTextStyle: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      suffixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(ShowPasswordIconEvent(
              showPassword: context.read<AuthBloc>().showPassword));
        },
        child: !context.read<AuthBloc>().showPassword
            ? const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.darkGrey,
                ),
              )
            : const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.visibility,
                  color: AppColors.darkGrey,
                ),
              ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterYourPassword;
        } else if (value.length < 8) {
          return AppLocalizations.of(context)!.minimumCharacRequired;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildEmailField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rEmailController,
      contentPadding: EdgeInsets.all(size.width * 0.025),
      enabled: !context.read<AuthBloc>().isLoginByEmail,
      filled: true,
      fillColor: context.read<AuthBloc>().isLoginByEmail
          ? Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).disabledColor.withAlpha((0.1 * 255).toInt())
              : AppColors.darkGrey
          : null,
      hintText: 'you@example.com (${AppLocalizations.of(context)!.optional})',
      hintTextStyle: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.emailValidate(value)) {
          return AppLocalizations.of(context)!.enterValidEmail;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildMobileField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rMobileController,
      contentPadding: EdgeInsets.all(size.width * 0.025),
      filled: true,
      fillColor: !context.read<AuthBloc>().isLoginByEmail
          ? Theme.of(context).brightness == Brightness.light
              ? AppColors.borderColors
              : AppColors.borderColors
          : null,
      enabled: context.read<AuthBloc>().isLoginByEmail,
      hintText: AppLocalizations.of(context)!.mobile,
      keyboardType: TextInputType.number,
      prefixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      hintTextStyle: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      prefixIcon: Center(
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              context: context,
              builder: (cont) {
                return SelectCountryWidget(
                    countries: arg.countryList, cont: context);
              },
            );
          },
          child: Row(
            children: [
              Container(
                height: 20,
                width: 25,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(5),
                  image: (context.read<AuthBloc>().flagImage.isNotEmpty)
                      ? DecorationImage(
                          image:
                              NetworkImage(context.read<AuthBloc>().flagImage),
                          fit: BoxFit.fill)
                      : null,
                ),
              ),
              MyText(text: context.read<AuthBloc>().dialCode),
            ],
          ),
        ),
      ),
      validator: (value) {
        if (value!.isNotEmpty && !AppValidation.mobileNumberValidate(value)) {
          return AppLocalizations.of(context)!.enterValidMobile;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterMobileNumber;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildUserNameField(BuildContext context, Size size) {
    return CustomTextField(
      controller: context.read<AuthBloc>().rUserNameController,
      contentPadding: EdgeInsets.all(size.width * 0.025),
      filled: true,
      hintText: AppLocalizations.of(context)!.enterName,
      hintTextStyle: Theme.of(context)
          .textTheme
          .bodySmall!
          .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterUserName;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildDropDownGenderField(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      hint: Text(
        AppLocalizations.of(context)!.selectGender,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      ),
      style: Theme.of(context).textTheme.bodyMedium!,
      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
      // value: selectedItem,
      icon: const Icon(Icons.keyboard_arrow_down_outlined),
      iconSize: 20,
      elevation: 10,
      onChanged: (newValue) {
        context.read<AuthBloc>().selectedGender = newValue.toString();
      },
      items: context.read<AuthBloc>().genderList.map<DropdownMenuItem>((value) {
        return DropdownMenuItem(
          value: value,
          alignment: AlignmentDirectional.centerStart,
          child: MyText(text: value),
        );
      }).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        hintText: '',
        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        errorStyle: TextStyle(
          color: AppColors.red.withAlpha((0.8 * 255).toInt()),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColors.errorLight.withAlpha((0.8 * 255).toInt()),
              width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.errorLight.withAlpha((0.5 * 255).toInt()),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderColors, width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.borderColors,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (context.read<AuthBloc>().selectedGender.isEmpty) {
          return AppLocalizations.of(context)!.enterRequiredField;
        } else {
          return null;
        }
      },
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 1,
                  spreadRadius: 1)
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.camera,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.camera));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.gallery,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.gallery));
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.08,
            )
          ],
        ),
      ),
    );
  }
}
