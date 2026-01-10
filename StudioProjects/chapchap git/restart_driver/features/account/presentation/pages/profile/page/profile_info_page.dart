import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_user/common/local_data.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/extensions.dart';
import 'package:restart_user/features/account/presentation/pages/profile/page/update_details.dart';
import 'package:restart_user/features/account/presentation/widgets/edit_options.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

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
            final type = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, AuthPage.routeName, (route) => false,
                arguments: AuthPageArguments(type: type));
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
                      onBackTap: () {
                        Navigator.pop(context, userData);
                      },
                    ),
                    body: SizedBox(
                      height: size.height * 0.7 - size.width * 0.2,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: CircleAvatar(
                                  radius: size.width * 0.1,
                                  backgroundColor:
                                      Theme.of(context).dividerColor,
                                  backgroundImage: userData!
                                          .profilePicture.isNotEmpty
                                      ? NetworkImage(userData!.profilePicture)
                                      : null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                _showImageSourceSheet(context),
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 15,
                                                  color: AppColors.white,
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
                              const SizedBox(height: 10),
                              EditOptions(
                                text: userData!.name,
                                header: AppLocalizations.of(context)!.name,
                                onTap: () {
                                  context
                                      .read<AccBloc>()
                                      .add(UserDetailEditEvent(
                                        header:
                                            AppLocalizations.of(context)!.name,
                                        text: userData!.name,
                                      ));
                                },
                              ),
                              EditOptions(
                                text: userData!.mobile,
                                header: AppLocalizations.of(context)!.mobile,
                                onTap: () {},
                              ),
                              EditOptions(
                                text: userData!.email,
                                header: AppLocalizations.of(context)!.email,
                                onTap: () {
                                  context.read<AccBloc>().add(
                                      UserDetailEditEvent(
                                          header: AppLocalizations.of(context)!
                                              .email,
                                          text: userData!.email));
                                },
                              ),
                              EditOptions(
                                text: userData!.gender != ''
                                    ? userData!.gender
                                    : "${AppLocalizations.of(context)!.update} ${AppLocalizations.of(context)!.gender}",
                                header: AppLocalizations.of(context)!.gender,
                                onTap: () {
                                  context.read<AccBloc>().add(
                                        UserDetailEditEvent(
                                          header: AppLocalizations.of(context)!
                                              .gender,
                                          text: userData!.gender,
                                        ),
                                      );
                                },
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
