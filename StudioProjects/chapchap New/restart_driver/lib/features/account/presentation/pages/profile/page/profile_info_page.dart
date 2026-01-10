import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/presentation/pages/profile/page/update_details.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/edit_options.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../../application/acc_bloc.dart';
import 'update_phone_number_page.dart';

class ProfileInfoPage extends StatelessWidget {
  static const String routeName = '/editPage';

  const ProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is UserProfileDetailsLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is UpdatedUserDetailsState) {}
          if (state is UpdateUserDetailsFailureState) {
            context.showSnackBar(
                message: AppLocalizations.of(context)!.failToUpdateDetails);
          }
          if (state is UserDetailsButtonSuccess) {
            context.read<AccBloc>().add(AccGetUserDetailsEvent());
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
          if (state is UserDetailEditState) {
            Navigator.pushNamed(
              context,
              UpdateDetails.routeName,
              arguments: UpdateDetailsArguments(
                  header: state.header, text: state.text, userData: userData!),
            ).then(
              (value) {
                // ignore: use_build_context_synchronously
                context.read<AccBloc>().add(AccGetUserDetailsEvent());
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return (userData != null)
                ? Scaffold(
                    appBar: CustomAppBar(
                      title: AppLocalizations.of(context)!.personalInformation,
                      automaticallyImplyLeading: true,
                      titleFontSize: 18,
                      onBackTap: () {
                        Navigator.pop(context, userData);
                      },
                    ),
                    body: SizedBox(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.width * 0.1),
                              Container(
                                padding: EdgeInsets.all(size.width * 0.05),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: size.width * 0.1,
                                        backgroundColor:
                                            Theme.of(context).dividerColor,
                                        backgroundImage:
                                            userData!.profilePicture.isNotEmpty
                                                ? NetworkImage(
                                                    userData!.profilePicture)
                                                : null,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () =>
                                                      _showImageSourceSheet(
                                                          context),
                                                  child: Container(
                                                    height: size.width * 0.085,
                                                    width: size.width * 0.085,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors.white,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height:
                                                          size.width * 0.075,
                                                      width: size.width * 0.075,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 18,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * 0.05,
                                    ),
                                    SizedBox(
                                        width: size.width * 0.8,
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .addProfilePhoto,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.05),
                              Container(
                                padding: EdgeInsets.all(size.width * 0.025),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: AppColors.borderColor),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    EditOptions(
                                      text: userData!.name,
                                      header:
                                          AppLocalizations.of(context)!.name,
                                      imagePath: AppImages.user,
                                      showEditIcon: true,
                                      showUnderLine: true,
                                      onTap: () {
                                        context
                                            .read<AccBloc>()
                                            .add(UserDetailEditEvent(
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .name,
                                              text: userData!.name,
                                            ));
                                      },
                                    ),
                                    EditOptions(
                                      text: userData!.mobile,
                                      header:
                                          AppLocalizations.of(context)!.mobile,
                                      imagePath: AppImages.phone,
                                      showEditIcon: true,
                                      showUnderLine: true,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const UpdatePhoneNumberPage(),
                                          ),
                                        );
                                        if (context.mounted) {
                                          context
                                              .read<AccBloc>()
                                              .add(AccGetUserDetailsEvent());
                                        }
                                      },
                                    ),
                                    EditOptions(
                                      text: userData!.email,
                                      header:
                                          AppLocalizations.of(context)!.email,
                                      imagePath: AppImages.mail,
                                      showEditIcon: true,
                                      showUnderLine: false,
                                      onTap: () {
                                        context.read<AccBloc>().add(
                                            UserDetailEditEvent(
                                                header: AppLocalizations.of(
                                                        context)!
                                                    .email,
                                                text: userData!.email));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const Scaffold(
                    body: Loader(),
                  );
          },
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context)
                    .primaryColorDark
                    .withAlpha((0.5 * 255).toInt()),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.camera,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .primaryColorDark
                        .withAlpha((0.5 * 255).toInt())),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                size: 20,
                color: Theme.of(context)
                    .primaryColorDark
                    .withAlpha((0.5 * 255).toInt()),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.gallery,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .primaryColorDark
                        .withAlpha((0.5 * 255).toInt())),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfileImage(BuildContext context, ImageSource source) {
    final AccBloc accBloc = context.read<AccBloc>();
    accBloc.add(UpdateImageEvent(
      name: userData!.name,
      email: userData!.email,
      gender: userData!.gender,
      source: source,
    ));
  }
}
