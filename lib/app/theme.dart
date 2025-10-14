// lib/app/theme.dart
import 'package:flutter/material.dart';

// Beautiful gradient-inspired brand colors from design
class AppColors {
  // Primary brand colors - Beautiful blue gradient
  static const Color primaryDark = Color.fromARGB(255, 2, 3, 46);      // Darkest navy (001D39)
  static const Color primaryMedium = Color.fromARGB(255, 2, 42, 78);     // Medium blue (0A4174)
  static const Color primaryLight = Color.fromARGB(255, 1, 33, 63);      // Light blue (49769F)
  
  // Accent colors - Teal gradient
  static const Color accent = Color.fromARGB(255, 3, 107, 138);            // Teal accent (4E8EA2)
  static const Color accentLight = Color.fromARGB(255, 3, 124, 165);       // Light teal (6EA2B3)
  static const Color accentLightest = Color.fromARGB(255, 11, 159, 182);    // Lightest blue (7BBDE8)
  
  // Status colors
  static const Color success = Color(0xFF2ECC71);           // Success green
  static const Color warning = Color(0xFFF39C12);           // Warning orange
  static const Color error = Color(0xFFE74C3C);             // Error red
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);       // Pure white
  static const Color textSecondary = Color(0xFFBDD8E9);     // Light blue-white (BDD8E9)
  static const Color textMuted = Color(0xFF7BBDE8);         // Muted blue (7BBDE8)
  static const Color textDark = Color(0xFF001D39);          // Dark text for light backgrounds
  
  // Surface colors - Based on gradient
  static const Color cardBackground = Color(0xFF0A4174);     // Card background
  static const Color surfaceElevated = Color(0xFF4E8EA2);   // Elevated surfaces
  static const Color borderColor = Color(0xFF6EA2B3);       // Subtle borders
  static const Color dividerColor = Color(0xFF7BBDE8);      // Dividers
  
  // Beautiful gradient definitions based on design
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryMedium, primaryLight],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryMedium, accent, accentLight, accentLightest, textSecondary],
    stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, accent],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLightest, textSecondary],
    stops: [0.0, 1.0],
  );
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.primaryDark,
  fontFamily: 'Inter', // Professional font family
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    primaryContainer: AppColors.accentLight,
    secondary: AppColors.primaryLight,
    secondaryContainer: AppColors.primaryMedium,
    surface: AppColors.cardBackground,
    surfaceVariant: AppColors.surfaceElevated,
    background: AppColors.primaryDark,
    error: AppColors.error,
    onPrimary: AppColors.textPrimary,
    onPrimaryContainer: AppColors.textPrimary,
    onSecondary: AppColors.textPrimary,
    onSecondaryContainer: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    onBackground: AppColors.textPrimary,
    onError: AppColors.textPrimary,
    outline: AppColors.borderColor,
    shadow: Colors.black26,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
    actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textPrimary,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      minimumSize: const Size(120, 56),
    ).copyWith(
      overlayColor: WidgetStateProperty.all(AppColors.accentLight.withValues(alpha: 0.1)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      side: const BorderSide(color: AppColors.accent, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      minimumSize: const Size(120, 56),
    ).copyWith(
      overlayColor: WidgetStateProperty.all(AppColors.accent.withValues(alpha: 0.1)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackground.withValues(alpha: 0.6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
  ),
  cardTheme: CardThemeData(
    color: AppColors.cardBackground,
    surfaceTintColor: AppColors.surfaceElevated,
    elevation: 8,
    shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.borderColor.withValues(alpha: 0.3), width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: AppColors.primaryLight,
  ),
  listTileTheme: ListTileThemeData(
    textColor: AppColors.textPrimary,
    iconColor: AppColors.textSecondary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  textTheme: const TextTheme(
    // Display text styles - for hero sections
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.25,
      height: 1.3,
    ),
    
    // Headline text styles - for section headers
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    
    // Title text styles - for card headers and important text
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    
    // Body text styles - for general content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      letterSpacing: 0.4,
      height: 1.4,
    ),
    
    // Label text styles - for captions and labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.5,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.5,
      height: 1.2,
    ),
  ),
  
  // Additional professional styling
  dividerTheme: const DividerThemeData(
    color: AppColors.dividerColor,
    thickness: 1,
    space: 16,
  ),
  
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.cardBackground,
    selectedColor: AppColors.accent,
    disabledColor: AppColors.borderColor,
    deleteIconColor: AppColors.textMuted,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    pressElevation: 4,
  ),
  
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surfaceElevated,
    contentTextStyle: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 8,
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.textPrimary,
    elevation: 8,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
);
