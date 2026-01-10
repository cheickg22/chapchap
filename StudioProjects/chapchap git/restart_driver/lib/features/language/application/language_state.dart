part of 'language_bloc.dart';

abstract class LanguageState {
  List<Object> get props => [];
}

final class LanguageInitialState extends LanguageState {}

final class LanguageLoadingState extends LanguageState {}

final class LanguageFailureState extends LanguageState {}

final class LanguageSuccessState extends LanguageState {}

final class LanguageSelectState extends LanguageState {
  final int selectedIndex;

  LanguageSelectState(this.selectedIndex);
}

final class LanguageUpdateState extends LanguageState {}

final class LanguageAlreadySelectedState extends LanguageState {}
