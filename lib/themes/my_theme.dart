import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData themeData(
      {required bool isDarkTheme, required BuildContext context}) {
    return isDarkTheme
        ? ThemeData(
            scaffoldBackgroundColor: const Color(0xFF343541),
            primarySwatch: Colors.purple,
            primaryColorDark: Colors.deepPurple,
            dividerColor: Colors.white,
            disabledColor: Colors.grey,
            cardColor: const Color(0xFF444654),
            canvasColor: Colors.black,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(color: Color(0xFF444654)),
            buttonTheme: Theme.of(context)
                .buttonTheme
                .copyWith(colorScheme: const ColorScheme.dark()),
          )
        : ThemeData(
            scaffoldBackgroundColor: Colors.grey.shade300,
            primarySwatch: Colors.purple,
            primaryColorDark: Colors.deepPurple,
            dividerColor: Colors.black,
            disabledColor: Colors.grey,
            cardColor: Colors.white,
            canvasColor: Colors.grey[50],
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(color: Colors.white),
            buttonTheme: Theme.of(context)
                .buttonTheme
                .copyWith(colorScheme: const ColorScheme.light()),
          );
  }
}
