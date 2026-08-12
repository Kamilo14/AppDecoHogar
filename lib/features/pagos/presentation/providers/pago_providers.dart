import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../data/datasources/pago_local_datasource.dart';
import '../../data/repositories/pago_repository_impl.dart';
import '../../domain/entities/pago_entity.dart';
import '../../domain/repositories/pago_repository.dart';
import '../../domain/usecases/calcular_deuda_cliente_usecase.dart';
import '../../domain/usecases/editar_pago_usecase.dart';
import '../../domain/usecases/eliminar_pago_usecase.dart';
import '../../domain/usecases/get_pagos_cliente_usecase.dart';
import '../../domain/usecases/registrar_pago_usecase.dart';

final pagoDataSourceProvider = Provider<PagoLocalDataSource>((ref) {
  return PagoLocalDataSource(ref.watch(databaseProvider));
});

final pagoRepositoryProvider = Provider<PagoRepository>((ref) {
  return PagoRepositoryImpl(ref.watch(pagoDataSourceProvider));
});

final registrarPagoUseCaseProvider = Provider<RegistrarPagoUseCase>((ref) {
  return RegistrarPagoUseCase(ref.watch(pagoRepositoryProvider));
});

final getPagosClienteUseCaseProvider = Provider<GetPagosClienteUseCase>((ref) {
  return GetPagosClienteUseCase(ref.watch(pagoRepositoryProvider));
});

final editarPagoUseCaseProvider = Provider<EditarPagoUseCase>((ref) {
  return EditarPagoUseCase(ref.watch(pagoRepositoryProvider));
});

final eliminarPagoUseCaseProvider = Provider<EliminarPagoUseCase>((ref) {
  return EliminarPagoUseCase(ref.watch(pagoRepositoryProvider));
});

final pagosStreamProvider = StreamProvider<List<Pago>>((ref) {
  return ref.watch(pagoRepositoryProvider).watchPagos();
});

final pagosPorClienteProvider = StreamProvider.family<List<Pago>, int>((ref, clienteId) {
  return ref.watch(getPagosClienteUseCaseProvider).call(clienteId);
});

final calcularDeudaClienteUseCaseProvider = Provider<CalcularDeudaClienteUseCase>((ref) {
  return CalcularDeudaClienteUseCase();
});

final deudaClienteProvider = Provider.family<int, int>((ref, clienteId) {
  final encargos = ref.watch(encargosStreamProvider).asData?.value ?? const [];
  final pagos = ref.watch(pagosStreamProvider).asData?.value ?? const [];
  return ref.watch(calcularDeudaClienteUseCaseProvider).call(encargos, pagos, clienteId);
});