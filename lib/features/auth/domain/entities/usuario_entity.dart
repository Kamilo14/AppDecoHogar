class Usuario {
  final String nombre;
  final DateTime fechaNacimiento;

  const Usuario({
    required this.nombre,
    required this.fechaNacimiento,
  });

  /// Extrae el primer nombre para el saludo del dashboard
  String get primerNombre => nombre.split(' ').first;
}
