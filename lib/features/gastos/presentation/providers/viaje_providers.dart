import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/viaje_local_datasource.dart';
import '../../data/repositories/viaje_repository_impl.dart';
import '../../domain/entities/viaje_entity.dart';
import '../../domain/repositories/viaje_repository.dart';
import '../../domain/usecases/agregar_gasto_usecase.dart';
import '../../domain/usecases/distribuir_gastos_usecase.dart';
import '../../domain/usecases/get_viajes_usecase.dart';
import '../../domain/usecases/save_viaje_usecase.dart';

final viajeDataSourceProvider = Provider<ViajeLocalDataSource>((ref) {
  return ViajeLocalDataSource(ref.watch(databaseProvider));
});

final viajeRepositoryProvider = Provider<ViajeRepository>((ref) {
  return ViajeRepositoryImpl(ref.watch(viajeDataSourceProvider));
});

final getViajesUseCaseProvider = Provider<GetViajesUseCase>((ref) {
  return GetViajesUseCase(ref.watch(viajeRepositoryProvider));
});

final saveViajeUseCaseProvider = Provider<SaveViajeUseCase>((ref) {
  return SaveViajeUseCase(ref.watch(viajeRepositoryProvider));
});

final agregarGastoUseCaseProvider = Provider<AgregarGastoUseCase>((ref) {
  return AgregarGastoUseCase(ref.watch(viajeRepositoryProvider));
});

final distribuirGastosUseCaseProvider = Provider<DistribuirGastosUseCase>((ref) {
  return DistribuirGastosUseCase(ref.watch(viajeRepositoryProvider));
});

final viajesStreamProvider = StreamProvider<List<Viaje>>((ref) {
  return ref.watch(getViajesUseCaseProvider).call();
});

/// Cambio a StreamProvider para que la UI reaccione a los gastos agregados
final viajeDetalleProvider = StreamProvider.family<Viaje?, int>((ref, viajeId) {
  return ref.watch(viajeRepositoryProvider).watchViajeById(viajeId);
});
