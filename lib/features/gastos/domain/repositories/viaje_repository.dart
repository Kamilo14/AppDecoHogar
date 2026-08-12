import '../entities/gasto_entity.dart';
import '../entities/viaje_entity.dart';

abstract class ViajeRepository {
  Stream<List<Viaje>> watchViajes();
  Stream<Viaje?> watchViajeById(int viajeId);
  Future<void> saveViaje(Viaje viaje);
  Future<void> addGasto(Gasto gasto);
  // Se agrega el parámetro monto para la distribución personalizada
  Future<void> distribuirGastos(int viajeId, int montoADistribuir);
  Future<Viaje?> getViajeById(int viajeId);
}
