import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary, // Verde Oliva
        onPrimary: Colors.white,
        secondary: AppColors.secondary, // Terracota
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.outline,
        surfaceVariant: AppColors.muted,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.outfit(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textPrimary.withOpacity(0.85)),
        bodySmall: GoogleFonts.outfit(color: AppColors.textSecondary),
        labelLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700),
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w800, 
          fontSize: 20, 
          color: AppColors.textPrimary,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.95),
        indicatorColor: AppColors.primary.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary);
          }
          return GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 26);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary, // Verde Oliva
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary, // Verde Oliva
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        secondaryLabelStyle: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.outline),
      ),
    );
  }
}
