import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/encargo_local_datasource.dart';
import '../../data/repositories/encargo_repository_impl.dart';
import '../../domain/entities/encargo_entity.dart';
import '../../domain/repositories/encargo_repository.dart';
import '../../domain/usecases/cambiar_estado_encargo_usecase.dart';
import '../../domain/usecases/convertir_encargo_a_venta_usecase.dart';
import '../../domain/usecases/get_encargos_usecase.dart';
import '../../domain/usecases/save_encargo_usecase.dart';
import '../../domain/usecases/soft_delete_encargo_usecase.dart';

final encargoDataSourceProvider = Provider<EncargoLocalDataSource>((ref) {
  return EncargoLocalDataSource(ref.watch(databaseProvider));
});

final encargoRepositoryProvider = Provider<EncargoRepository>((ref) {
  return EncargoRepositoryImpl(ref.watch(encargoDataSourceProvider));
});

final getEncargosUseCaseProvider = Provider<GetEncargosUseCase>((ref) {
  return GetEncargosUseCase(ref.watch(encargoRepositoryProvider));
});

final saveEncargoUseCaseProvider = Provider<SaveEncargoUseCase>((ref) {
  return SaveEncargoUseCase(ref.watch(encargoRepositoryProvider));
});

final cambiarEstadoEncargoUseCaseProvider =
    Provider<CambiarEstadoEncargoUseCase>((ref) {
  return CambiarEstadoEncargoUseCase(ref.watch(encargoRepositoryProvider));
});

final convertirEncargoAVentaUseCaseProvider =
    Provider<ConvertirEncargoAVentaUseCase>((ref) {
  return ConvertirEncargoAVentaUseCase(ref.watch(encargoRepositoryProvider));
});

final softDeleteEncargoUseCaseProvider =
    Provider<SoftDeleteEncargoUseCase>((ref) {
  return SoftDeleteEncargoUseCase(ref.watch(encargoRepositoryProvider));
});

final encargosStreamProvider = StreamProvider<List<Encargo>>((ref) {
  return ref.watch(getEncargosUseCaseProvider).call();
});

final estadosEncargoProvider = Provider<List<String>>((ref) => const [
      'PENDIENTE',
      'COMPRADO',
      'ENTREGADO',
    ]);
