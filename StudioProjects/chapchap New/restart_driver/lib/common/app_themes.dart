import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppThemes {
  static ThemeData applicationDefaultTheme(BuildContext context) {
    ThemeData originalTheme = ThemeData.light();
    const String fontFamily = 'NotoSans';
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      brightness: Brightness.light,
      primaryColorLight: AppColors.secondary,
      // primaryColorDark: AppColors.black,
      primaryColorDark: AppColors.hintColorGrey,
      scaffoldBackgroundColor: AppColors.white,
      disabledColor: AppColors.greyHintColor,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      shadowColor: AppColors.shadowColorLight,
      // hintColor: AppColors.darkGrey,
      hintColor: AppColors.hintColor,
      dividerColor: AppColors.darkGrey,
      splashColor: AppColors.grey,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.textSelectionColor,
        selectionHandleColor: AppColors.textSelectionColor,
      ),
      appBarTheme: const AppBarTheme(
        color: AppColors.white,
        surfaceTintColor: AppColors.secondary,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
      ),
      buttonTheme: originalTheme.buttonTheme.copyWith(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.accent,
        minWidth: 30,
        splashColor: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        actionTextColor: AppColors.white,
      ),
      textTheme: GoogleFonts.notoSansTextTheme(originalTheme.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        bodyLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        bodyMedium: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: fontFamily,
            color: AppColors.black),
        bodySmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        displayLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        displayMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        displaySmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          fontFamily: '$fontFamily-Bold',
          color: AppColors.black,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        labelMedium: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
        labelSmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 10,
          fontFamily: fontFamily,
          color: AppColors.black,
        ),
      )),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.secondary,
        elevation: 0,
        type: BottomNavigationBarType.shifting,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,
      ),
      // colorScheme: ColorScheme.fromSwatch(
      //     primarySwatch: const MaterialColor(
      //   AppColors.primaryValue,
      //   <int, Color>{
      //     50: AppColors.primary,
      //     100: AppColors.primary,
      //     200: AppColors.primary,
      //     300: AppColors.primary,
      //     400: AppColors.primary,
      //     500: AppColors.primary,
      //     600: AppColors.primary,
      //     700: AppColors.primary,
      //     800: AppColors.primary,
      //     900: AppColors.primary,
      //   },
      // )).copyWith(error: AppColors.red),
    );
  }

  // DARK THEME
  static ThemeData darkTheme(BuildContext context) {
    ThemeData originalTheme = ThemeData.dark();
    const String fontFamily = 'NotoSans';
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      brightness: Brightness.dark,
      primaryColorLight: AppColors.secondary,
      primaryColorDark: AppColors.white,
      scaffoldBackgroundColor: AppColors.black,
      disabledColor: AppColors.disabledColorDark,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      shadowColor: AppColors.shadowColorDark,
      // hintColor: AppColors.darkGrey,
      hintColor: AppColors.hintColor,
      dividerColor: AppColors.darkGrey,
      splashColor: AppColors.grey,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.textSelectionColor,
        selectionHandleColor: AppColors.textSelectionColor,
      ),
      appBarTheme: const AppBarTheme(
        color: AppColors.black,
        surfaceTintColor: AppColors.secondary,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.black,
      ),
      buttonTheme: originalTheme.buttonTheme.copyWith(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.accent,
        minWidth: 30,
        splashColor: AppColors.primary,
      ),
      snackBarTheme: const SnackBarThemeData(
        actionTextColor: AppColors.white,
      ),
      textTheme: GoogleFonts.notoSansTextTheme(originalTheme.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        bodyLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        bodyMedium: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        bodySmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        displayLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        displayMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        displaySmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        headlineLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        headlineSmall: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          fontFamily: '$fontFamily-Bold',
          color: AppColors.white,
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        labelMedium: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
        labelSmall: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 10,
          fontFamily: fontFamily,
          color: AppColors.white,
        ),
      )),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}
