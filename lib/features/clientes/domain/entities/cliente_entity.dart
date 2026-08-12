

/// Entidad de dominio pura — representa un Cliente en el negocio.
/// No depende de Drift ni de ninguna capa técnica.
class Cliente {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? observaciones;
  final DateTime fechaRegistro;
  final bool activo;

  const Cliente({
    this.id,
    required this.nombre,
    this.telefono,
    this.email,
    this.direccion,
    this.observaciones,
    required this.fechaRegistro,
    this.activo = true,
  });

  Cliente copyWith({
    int? id,
    String? nombre,
    String? telefono,
    String? email,
    String? direccion,
    String? observaciones,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }
}
