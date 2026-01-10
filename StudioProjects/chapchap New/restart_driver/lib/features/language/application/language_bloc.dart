import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import '../../../common/common.dart';
import '../../../di/locator.dart';
import 'usecases/language_usecase.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  int selectedIndex = 0;
  String choosedLanguage = '';
  String textDirection = 'ltr';

  LanguageBloc() : super(LanguageInitialState()) {
    on<LanguageInitialEvent>(storedLocaleLanguage);
    on<LanguageGetEvent>(_getLanguageList);
    on<LanguageSelectEvent>(_selectedLanguageIndex);
    on<LanguageSelectUpdateEvent>(_selectedLanguageUpdate);
  }

  Future storedLocaleLanguage(
      LanguageInitialEvent event, Emitter<LanguageState> emit) async {
    choosedLanguage = await AppSharedPreference.getSelectedLanguageCode();
    if (choosedLanguage.isNotEmpty) {
      emit(LanguageAlreadySelectedState());
    }
  }

  FutureOr<void> _getLanguageList(
      LanguageGetEvent event, Emitter<LanguageState> emit) async {
    emit(LanguageLoadingState());
    if (event.from == 1) {
      for (var i = 0; i < AppConstants.languageList.length; i++) {
        if (AppConstants.languageList[i].lang == choosedLanguage) {
          selectedIndex = i;
          break;
        }
      }
    }
    emit(LanguageSuccessState());
  }

  Future<void> _selectedLanguageIndex(
      LanguageSelectEvent event, Emitter<LanguageState> emit) async {
    selectedIndex = event.selectedLanguageIndex;
    emit(LanguageSelectState(selectedIndex));
  }

  Future<void> _selectedLanguageUpdate(
      LanguageSelectUpdateEvent event, Emitter<LanguageState> emit) async {
    final data = await serviceLocator<LanguageUsecase>()
        .updateLanguage(event.selectedLanguage);
    data.fold(
      (error) {
        if (kDebugMode) {
          debugPrint('Update Failure');
        }
      },
      (success) {
        if (kDebugMode) {
          debugPrint('Update Success');
        }
      },
    );
    if (event.selectedLanguage == 'ar' ||
        event.selectedLanguage == 'ur' ||
        event.selectedLanguage == 'iw') {
      textDirection = 'rtl';
      await AppSharedPreference.setLanguageDirection('rtl');
    } else {
      textDirection = 'ltr';
      await AppSharedPreference.setLanguageDirection('ltr');
    }
    choosenLanguage = event.selectedLanguage;
    await AppSharedPreference.setSelectedLanguageCode(event.selectedLanguage);

    emit(LanguageUpdateState());
  }
}
