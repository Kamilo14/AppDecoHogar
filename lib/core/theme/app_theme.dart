import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
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
        bodyMedium: GoogleFonts.outfit(color: AppColors.textPrimary.withValues(alpha: 0.85)),
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
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        indicatorColor: AppColors.muted,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: AppColors.textPrimary, size: 24),
        ),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: AppColors.primary,
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
        backgroundColor: AppColors.muted,
        selectedColor: AppColors.secondary,
        labelStyle: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        secondaryLabelStyle: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),
    );
  }
}
