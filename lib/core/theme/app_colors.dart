import 'package:flutter/material.dart';

abstract class AppColors {
  // Fondos y Superficies - Estilo Ultra-Limpio y Luminoso
  static const Color background = Color(0xFFFDFDFD); // Blanco nieve (muy cercano al blanco puro)
  static const Color surface = Color(0xFFFFFFFF);    // Blanco puro para resaltar tarjetas
  
  // Tipografía Premium
  static const Color textPrimary = Color(0xFF2C221E);   // Café tierra oscuro
  static const Color textSecondary = Color(0xFF8A7863); // Café suave
  
  // Colores de Marca
  static const Color primary = Color(0xFFC1512F);   // Terracota
  static const Color secondary = Color(0xFF6B8F71); // Verde salvia
  
  // Estados Semánticos
  static const Color success = Color(0xFF7A9D76);
  static const Color error = Color(0xFFB5533C);
  static const Color warning = Color(0xFFD9A441);
  
  // Bordes y Detalles
  static const Color outline = Color(0xFFEFE6D9); 
  static const Color muted = Color(0xFFF3EDE2);
}
