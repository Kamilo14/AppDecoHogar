class Pago {
  final int? id;
  final int clienteId;
  final int? encargoId;
  final int monto;
  final DateTime fecha;
  final String metodo;
  final String tipo;
  final String? concepto;

  const Pago({
    this.id,
    required this.clienteId,
    this.encargoId,
    required this.monto,
    required this.fecha,
    required this.metodo,
    required this.tipo,
    this.concepto,
  });

  Pago copyWith({
    int? id,
    int? clienteId,
    int? encargoId,
    int? monto,
    DateTime? fecha,
    String? metodo,
    String? tipo,
    String? concepto,
  }) {
    return Pago(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      encargoId: encargoId ?? this.encargoId,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      metodo: metodo ?? this.metodo,
      tipo: tipo ?? this.tipo,
      concepto: concepto ?? this.concepto,
    );
  }
}