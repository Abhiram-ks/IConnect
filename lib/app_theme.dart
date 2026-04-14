
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';


class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppPalette.blueColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppPalette.whiteColor,
    fontFamily: GoogleFonts.poppins().fontFamily,

    // Explicit color scheme so Flutter's M3 tonal-palette generator never
    // tints surfaces (dialogs, cards, sheets) with pink/lavender hues.
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.blueColor,
      brightness: Brightness.light,
      surface: Colors.white,        // dialog / card background
      onSurface: Colors.black,
      primary: AppPalette.blueColor,
      onPrimary: Colors.white,
    ),

    // Remove the M3 elevation tint that colours dialogs / bottom-sheets.
    // Without this, every elevated surface gets a blue/pink wash.
    cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),

    // Dialogs — pure white background, no tint.
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    // Bottom-sheets — pure white, no tint.
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),

    // Progress indicators use the app's blue, not the M3-generated purple.
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.blueColor,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.whiteColor,
      selectedItemColor: AppPalette.blackColor,
      unselectedItemColor: AppPalette.greyColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.blueColor,
      iconTheme: IconThemeData(color: Colors.black),
      surfaceTintColor: Colors.transparent, // no tint on AppBar either
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.poppins(color: AppPalette.blackColor),
      bodyMedium: GoogleFonts.poppins(color: AppPalette.blackColor),
      bodySmall: GoogleFonts.poppins(color: AppPalette.blackColor),
    ),
  );
}