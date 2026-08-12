import '../entities/pago_entity.dart';

abstract class PagoRepository {
  Stream<List<Pago>> watchPagos();

  Stream<List<Pago>> watchPagosCliente(int clienteId);

  Future<void> savePago(Pago pago);

  Future<void> deletePago(int pagoId);

  Future<Pago?> getPagoById(int pagoId);
}