part of 'loading_bloc.dart';

abstract class LoaderState {}

final class LoaderInitialState extends LoaderState {}

final class LoaderUpdateState extends LoaderState {}

final class LoaderSuccessState extends LoaderState {
  final bool loginStatus;
  final bool landingStatus;
  final bool isOwnerEnabled;
  final String selectedLanguage;
  final String userType;

  LoaderSuccessState(
      {required this.loginStatus,
      required this.landingStatus,
      required this.isOwnerEnabled,
      required this.selectedLanguage,
      required this.userType});
}

final class LoaderLocationSuccessState extends LoaderState {}
