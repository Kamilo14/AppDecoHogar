import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/cliente_local_datasource.dart';
import '../../data/repositories/cliente_repository_impl.dart';
import '../../domain/entities/cliente_entity.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/usecases/get_clientes_usecase.dart';
import '../../domain/usecases/save_cliente_usecase.dart';
import '../../domain/usecases/soft_delete_cliente_usecase.dart';

// --- Inyección de dependencias en cadena ---

final clienteDataSourceProvider = Provider<ClienteLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return ClienteLocalDataSource(db);
});

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  final ds = ref.watch(clienteDataSourceProvider);
  return ClienteRepositoryImpl(ds);
});

final getClientesUseCaseProvider = Provider<GetClientesUseCase>((ref) {
  return GetClientesUseCase(ref.watch(clienteRepositoryProvider));
});

final saveClienteUseCaseProvider = Provider<SaveClienteUseCase>((ref) {
  return SaveClienteUseCase(ref.watch(clienteRepositoryProvider));
});

final softDeleteClienteUseCaseProvider = Provider<SoftDeleteClienteUseCase>((ref) {
  return SoftDeleteClienteUseCase(ref.watch(clienteRepositoryProvider));
});

// --- Stream reactivo de clientes ---

/// La UI se suscribe a este provider y se actualiza automáticamente
/// cada vez que se agrega, edita o elimina un cliente.
final clientesStreamProvider = StreamProvider<List<Cliente>>((ref) {
  return ref.watch(getClientesUseCaseProvider).call();
});

// --- State para búsqueda ---

final clienteSearchProvider = StateProvider<String>((ref) => '');

/// Lista filtrada por búsqueda
final clientesFiltradosProvider = Provider<AsyncValue<List<Cliente>>>((ref) {
  final query = ref.watch(clienteSearchProvider).toLowerCase().trim();
  final clientes = ref.watch(clientesStreamProvider);
  if (query.isEmpty) return clientes;
  return clientes.whenData(
    (list) => list.where((c) => c.nombre.toLowerCase().contains(query)).toList(),
  );
});
