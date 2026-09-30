import 'gasto_entity.dart';

class Viaje {
  final int? id;
  final DateTime fecha;
  final String destino;
  final String? observaciones;
  final bool distribuido;
  final int montoDistribuido;
  int get gastoSinDistribuir =>
      (totalGastos - montoDistribuido).clamp(0, totalGastos);
  final List<Gasto> gastos;

  const Viaje({
    this.id,
    required this.fecha,
    required this.destino,
    this.observaciones,
    this.distribuido = false,
    this.montoDistribuido = 0,
    this.gastos = const [],
  });

  int get totalGastos => gastos.fold(0, (sum, item) => sum + item.monto);
}
