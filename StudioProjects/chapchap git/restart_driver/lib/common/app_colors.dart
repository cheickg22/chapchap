// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFCA53D);
  static const Color secondary = Color(0xFFFCA53D);

//Light
  static const Color errorLight = Color.fromARGB(255, 196, 32, 32);
  static const Color onErrorLight = Color.fromARGB(255, 245, 39, 39);
  static const Color shadowColorLight = Color.fromARGB(255, 188, 188, 188);

// Dark
  static const Color secondaryDark = Color.fromRGBO(84, 197, 248, 1);
  static const Color disabledColorDark = Color.fromARGB(255, 166, 166, 166);
  static const Color shadowColorDark = Color.fromARGB(255, 175, 175, 175);

// Common colors
  static const int primaryValue = 0xFFA432A7;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color.fromARGB(200, 218, 212, 212);
  static const Color green = Color(0xFF669C1A);
  static const Color lightGreen = Color(0XFF14B014);
  static const Color greyHeader = Color(0xFF99AABE);
  static const Color yellowColor = Color(0xFFCFA829);

  static const MaterialColor darkGrey = Colors.grey;
  static const Color lightGrey = Color.fromARGB(166, 158, 158, 158);
  static const Color red = Color(0xFFef413b);
  static const Color greyContainerColor = Color(0xFFEEEEEE);

  static const Color greyHintColor = Color(0xFF696969);
  static Color textSelectionColor =
  greyHintColor.withAlpha((0.5 * 255).toInt());

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color blackText = Color(0xFF000000);
  static const Color commonColor = Color(0xFFDBDBDB);
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor orange = Colors.orange;
  static const Color buttonColor = Color(0xFFFCA53D);
  static const Color buttonTextColor = Color(0xFFFFFFFF);
  static const Color goldenColor = Color(0xffFFD700);
}
