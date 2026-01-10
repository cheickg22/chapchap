part of 'language_bloc.dart';

abstract class LanguageEvent {
  List<Object?> get props => [];
}

class LanguageInitialEvent extends LanguageEvent {}

class LanguageGetEvent extends LanguageEvent {
  final int from;

  LanguageGetEvent({required this.from});
}

class LanguageSelectUpdateEvent extends LanguageEvent {
  final String selectedLanguage;

  LanguageSelectUpdateEvent({required this.selectedLanguage});
}

class LanguageSelectEvent extends LanguageEvent {
  final int selectedLanguageIndex;

  LanguageSelectEvent({required this.selectedLanguageIndex});
}
