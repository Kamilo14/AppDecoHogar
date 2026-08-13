import 'package:flutter/material.dart';

abstract class AppColors {
  // Fondos y Superficies (Basado en look Dashboard)
  static const Color background = Color(0xFFFAF8F5); // Crema
  static const Color surface = Color(0xFFFFFCF9);    // Blanco cálido
  
  // Tipografía
  static const Color textPrimary = Color(0xFF2A2724);   // Café carbón oscuro
  static const Color textSecondary = Color(0xFF8E867C); // Café suave
  
  // Colores de Marca y Acentos
  static const Color primary = Color(0xFFC86442);   // Terracota
  static const Color secondary = Color(0xFF748363); // Verde oliva
  static const Color tertiary = Color(0xFFC9A77D);  // Beige
  
  // Estados Semánticos
  static const Color success = Color(0xFF7A9D76);
  static const Color error = Color(0xFFB5533C);
  static const Color warning = Color(0xFFD9A441);
  
  // Bordes y Detalles
  static const Color outline = Color(0xFFF0EAE4); // Border
  static const Color muted = Color(0xFFF3EAE0);   // IconBg / Muted
}
