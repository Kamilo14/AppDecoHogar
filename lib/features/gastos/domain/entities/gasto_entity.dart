class Gasto {
  final int? id;
  final int viajeId;
  final String tipo;
  final int monto;

  const Gasto({
    this.id,
    required this.viajeId,
    required this.tipo,
    required this.monto,
  });
}