import 'encargo_detalle_entity.dart';

class Encargo {
  final int? id;
  final int? clienteId;
  final int correlativoCliente; // Regla 8.6: Numeración local
  final DateTime fecha;
  final DateTime? fechaEntregaReal;
  DateTime get fechaVenta => fechaEntregaReal ?? fecha;
  final DateTime? fechaEntregaEstimada;
  final String estado;
  final String? observaciones;
  final String tipoVenta;
  final bool activo;
  final List<EncargoDetalle> detalles;

  const Encargo({
    this.id,
    this.clienteId,
    this.correlativoCliente = 1,
    required this.fecha,
    this.fechaEntregaReal,
    this.fechaEntregaEstimada,
    required this.estado,
    this.observaciones,
    this.tipoVenta = 'Por encargo',
    this.activo = true,
    this.detalles = const [],
  });

  int get total => detalles.fold(0, (sum, item) => sum + item.subtotal);
  int get totalExigible => estado == 'PENDIENTE'
      ? detalles.where((d) => d.comprado).fold(0, (sum, d) => sum + d.subtotal)
      : total;

  Encargo copyWith({
    int? id,
    int? clienteId,
    int? correlativoCliente,
    DateTime? fecha,
    DateTime? fechaEntregaReal,
    DateTime? fechaEntregaEstimada,
    String? estado,
    String? observaciones,
    String? tipoVenta,
    bool? activo,
    List<EncargoDetalle>? detalles,
  }) {
    return Encargo(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      correlativoCliente: correlativoCliente ?? this.correlativoCliente,
      fecha: fecha ?? this.fecha,
      fechaEntregaReal: fechaEntregaReal ?? this.fechaEntregaReal,
      fechaEntregaEstimada: fechaEntregaEstimada ?? this.fechaEntregaEstimada,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      activo: activo ?? this.activo,
      detalles: detalles ?? this.detalles,
    );
  }
}
