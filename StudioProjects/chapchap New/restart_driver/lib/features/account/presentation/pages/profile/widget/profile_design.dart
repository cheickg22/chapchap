import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../app/localization.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';

class ProfileWidget extends StatelessWidget {
  final bool isEditPage;
  final String profileUrl;
  final String userName;
  final String ratings;
  final String wallet;
  final bool showWallet;
  final String trips;
  final String todaysEarnings;
  final Widget? child;
  final void Function()? backOnTap;

  const ProfileWidget({
    super.key,
    required this.isEditPage,
    required this.profileUrl,
    required this.userName,
    required this.ratings,
    required this.wallet,
    required this.showWallet,
    required this.trips,
    required this.todaysEarnings,
    this.child,
    this.backOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            // color: AppColors.commonColor,
            color: Theme.of(context).primaryColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).primaryColorLight),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: size.height * 0.05),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: isEditPage
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: backOnTap ??
                                () {
                                  Navigator.pop(context);
                                },
                            icon: const Icon(
                              CupertinoIcons.back,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.personalInformation,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: AppColors.white, fontSize: 20),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Transform.scale(
                              scaleX: size.width * 0.003,
                              scaleY: size.width * 0.0026,
                              child: Switch(
                                value: context.read<AccBloc>().isDarkTheme,
                                activeColor: Theme.of(context).primaryColorDark,
                                activeTrackColor:
                                    Theme.of(context).primaryColorDark,
                                inactiveTrackColor:
                                    Theme.of(context).primaryColorDark,
                                activeThumbImage:
                                    const AssetImage(AppImages.sun),
                                inactiveThumbImage:
                                    const AssetImage(AppImages.moon),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (value) async {
                                  context.read<AccBloc>().isDarkTheme = value;
                                  final locale = await AppSharedPreference
                                      .getSelectedLanguageCode();
                                  if (!context.mounted) return;
                                  context.read<LocalizationBloc>().add(
                                      LocalizationInitialEvent(
                                          isDark: value,
                                          locale: Locale(locale)));
                                },
                              ),
                            ),
                          )
                        ],
                      ),
              ),
              Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: size.width * 0.1,
                      backgroundColor: Theme.of(context).dividerColor,
                      backgroundImage: userData!.profilePicture.isNotEmpty
                          ? NetworkImage(userData!.profilePicture)
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isEditPage)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () => _showImageSourceSheet(context),
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 15,
                                        color: AppColors.black,
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
                    height: size.width * 0.02,
                  ),
                  MyText(
                    text: userData!.name,
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: (!isEditPage) ? size.height * 0.3 : size.height * 0.3,
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: child,
          ),
        ),
        // if (!isEditPage && userData!.role == 'driver' )
        if (!isEditPage &&
            (userData!.role == 'driver' || userData!.role == 'owner'))
          // if(!isEditPage && (userData!.role == 'driver'))
          Positioned(
            top: (!isEditPage && userData!.role == 'driver')
                ? size.height * 0.25
                : size.height * 0.23,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              height: size.width * 0.23,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).shadowColor,
                        spreadRadius: 2.0,
                        blurRadius: 2.0)
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            text: AppLocalizations.of(context)!.earnings,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.8 * 255).toInt()))),
                        MyText(
                            text: (!isEditPage && userData!.role == 'driver')
                                ? todaysEarnings
                                : todaysEarnings,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark)),
                      ],
                    ),
                    !showWallet && userData!.role == 'owner'
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: VerticalDivider(
                                color: Theme.of(context).dividerColor),
                          )
                        : const SizedBox(),
                    if (showWallet && userData!.role == 'owner') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: VerticalDivider(
                            color: Theme.of(context).dividerColor),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                              text: AppLocalizations.of(context)!.wallet,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.8 * 255).toInt()))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyText(
                                  text: wallet,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: VerticalDivider(
                            color: Theme.of(context).dividerColor),
                      ),
                    ],
                    if (userData!.role == 'driver') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: VerticalDivider(
                            color: Theme.of(context).dividerColor),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                              text: AppLocalizations.of(context)!.ratings,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withAlpha((0.8 * 255).toInt()))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MyText(
                                  text: ratings,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                              (!isEditPage && userData!.role == 'driver')
                                  ? Icon(Icons.star,
                                      size: 15,
                                      color: Theme.of(context).primaryColorDark)
                                  : const SizedBox()
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: VerticalDivider(
                            color: Theme.of(context).dividerColor),
                      ),
                    ],
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                            text: AppLocalizations.of(context)!.tripsTaken,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withAlpha((0.8 * 255).toInt()))),
                        MyText(
                            text: trips,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context).primaryColorDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
