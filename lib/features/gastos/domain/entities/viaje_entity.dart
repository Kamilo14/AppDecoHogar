import 'gasto_entity.dart';

class Viaje {
  final int? id;
  final DateTime fecha;
  final String destino;
  final String? observaciones;
  final bool distribuido;
  final List<Gasto> gastos;

  const Viaje({
    this.id,
    required this.fecha,
    required this.destino,
    this.observaciones,
    this.distribuido = false,
    this.gastos = const [],
  });

  int get totalGastos => gastos.fold(0, (sum, item) => sum + item.monto);
}