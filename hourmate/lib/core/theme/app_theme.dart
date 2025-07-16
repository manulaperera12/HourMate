import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Screenshot-based colors
  static const Color backgroundColor = Color(0xFF181818); // Main background
  static const Color surfaceColor = Color(
    0xFF232323,
  ); // Card/secondary background
  static const Color cardColor = Color(0xFF232323); // Card background
  static const Color headerGradientStart = Color(
    0xFFE3FF3A,
  ); // Neon yellow-green
  static const Color headerGradientEnd = Color(0xFF3CD0FE); // Cyan/blue
  static const Color neonYellowGreen = Color(0xFFE3FF3A); // Neon yellow-green
  static const Color cyanBlue = Color(0xFF3CD0FE); // Cyan/blue
  static const Color orange = Color(0xFFE3501C); // Orange
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGray = Color(0xFF232323);
  static const Color black = Color(0xFF181818);

  // Text colors
  static const Color primaryTextColor = white;
  static const Color secondaryTextColor = Color(0xFFB0B0B0); // Light gray
  static const Color disabledTextColor = Color(0xFF6D6D6D); // Dim gray

  // Progress colors
  static const Color progressStart = neonYellowGreen;
  static const Color progressEnd = cyanBlue;
  static const Color progressBg = Color(0xFF232323);

  // Tab bar
  static const Color tabBarBg = darkGray;
  static const Color tabSelected = neonYellowGreen;
  static const Color tabUnselected = white;

  // Bottom nav
  static const Color bottomNavBg = darkGray;
  static const Color bottomNavSelected = neonYellowGreen;
  static const Color bottomNavUnselected = white;

  // Stats icons
  static const Color statOrange = orange;
  static const Color statBlue = cyanBlue;
  static const Color statYellow = neonYellowGreen;

  // Add legacy/static color getters for widget compatibility
  static const Color primaryColor = neonYellowGreen;
  static const Color secondaryColor = cyanBlue;
  static const Color dividerColor = Color(0xFF353535); // Subtle divider
  static const Color errorColor = orange;
  static const Color accentColor = cyanBlue;
  static const Color goodRatingColor = neonYellowGreen;
  static const Color averageRatingColor = cyanBlue;
  static const Color badRatingColor = orange;
  static const Color borderColor = Color(0xFF353535); // Subtle border

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: neonYellowGreen,
        secondary: cyanBlue,
        surface: surfaceColor,
        background: backgroundColor,
        error: orange,
        onPrimary: black,
        onSecondary: white,
        onSurface: white,
        onBackground: white,
        onError: white,
      ),
      textTheme: GoogleFonts.asapTextTheme().apply(
        bodyColor: primaryTextColor,
        displayColor: primaryTextColor,
      ),
      fontFamily: 'Asap',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          fontFamily: 'Asap',
        ),
      ),
      cardColor: cardColor,
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bottomNavBg,
        selectedItemColor: bottomNavSelected,
        unselectedItemColor: bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: disabledTextColor,
          fontFamily: 'Asap',
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: neonYellowGreen,
      secondary: cyanBlue,
      surface: surfaceColor,
      background: backgroundColor,
      error: orange,
      onPrimary: black,
      onSecondary: white,
      onSurface: white,
      onBackground: white,
      onError: white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'Asap',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bottomNavBg,
      selectedItemColor: bottomNavSelected,
      unselectedItemColor: bottomNavUnselected,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
