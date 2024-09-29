import 'package:flutter/material.dart';

// Light Theme
final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    color: Colors.white,
  ),
  // Define other light mode specific themes here
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    color: Colors.blueGrey,
  ),
  // Define other dark mode specific themes here
);


// Define constants for your theme
const Color primaryColor = Color.fromARGB(255, 27, 18, 18);
const Color appBarColor = Color.fromARGB(255, 17, 11, 7);
const Color inputColor = Color.fromARGB(255, 240, 240, 240);
const Color errorColor = Colors.red;
const double defaultPadding = 16.0;

final OutlineInputBorder defaultOutlineInputBorder = const OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 200)),
);

final BorderSide errorBorderSide = const BorderSide(color: errorColor);

// Build your ThemeData
ThemeData buildThemeData() {
  return ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "SF Pro Text",
    appBarTheme: const AppBarTheme(
      color: appBarColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: inputColor,
      filled: true,
      contentPadding: const EdgeInsets.all(defaultPadding),
      border: defaultOutlineInputBorder,
      enabledBorder: defaultOutlineInputBorder,
      focusedBorder: defaultOutlineInputBorder.copyWith(
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 7, 2, 2).withOpacity(0.5),
        ),
      ),
      errorBorder: defaultOutlineInputBorder.copyWith(
        borderSide: errorBorderSide,
      ),
      focusedErrorBorder: defaultOutlineInputBorder.copyWith(
        borderSide: errorBorderSide,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
