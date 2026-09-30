import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../encargos/presentation/providers/encargo_providers.dart';
import '../../data/datasources/categoria_local_datasource.dart';
import '../../data/datasources/producto_local_datasource.dart';
import '../../data/repositories/producto_repository_impl.dart';
import '../../domain/entities/categoria_entity.dart';
import '../../domain/entities/producto_entity.dart';
import '../../domain/repositories/producto_repository.dart';
import '../../domain/usecases/get_categorias_usecase.dart';
import '../../domain/usecases/get_productos_usecase.dart';
import '../../domain/usecases/save_categoria_usecase.dart';
import '../../domain/usecases/save_producto_usecase.dart';
import '../../domain/usecases/soft_delete_producto_usecase.dart';

final productoDataSourceProvider = Provider<ProductoLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductoLocalDataSource(db);
});

final categoriaDataSourceProvider = Provider<CategoriaLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriaLocalDataSource(db);
});

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepositoryImpl(
    ref.watch(productoDataSourceProvider),
    ref.watch(categoriaDataSourceProvider),
  );
});

final getProductosUseCaseProvider = Provider<GetProductosUseCase>((ref) {
  return GetProductosUseCase(ref.watch(productoRepositoryProvider));
});

final saveProductoUseCaseProvider = Provider<SaveProductoUseCase>((ref) {
  return SaveProductoUseCase(ref.watch(productoRepositoryProvider));
});

final softDeleteProductoUseCaseProvider =
    Provider<SoftDeleteProductoUseCase>((ref) {
  return SoftDeleteProductoUseCase(ref.watch(productoRepositoryProvider));
});

final getCategoriasUseCaseProvider = Provider<GetCategoriasUseCase>((ref) {
  return GetCategoriasUseCase(ref.watch(productoRepositoryProvider));
});

final saveCategoriaUseCaseProvider = Provider<SaveCategoriaUseCase>((ref) {
  return SaveCategoriaUseCase(ref.watch(productoRepositoryProvider));
});

final productosStreamProvider = StreamProvider<List<Producto>>((ref) {
  return ref.watch(getProductosUseCaseProvider).call();
});

final categoriasStreamProvider = StreamProvider<List<Categoria>>((ref) {
  return ref.watch(getCategoriasUseCaseProvider).call();
});

final productoSearchProvider = StateProvider<String>((ref) => '');

final productoCategoriaFiltroProvider = StateProvider<int?>((ref) => null);

final productosFiltradosProvider = Provider<AsyncValue<List<Producto>>>((ref) {
  final query = ref.watch(productoSearchProvider).toLowerCase().trim();
  final categoriaId = ref.watch(productoCategoriaFiltroProvider);
  final productos = ref.watch(productosStreamProvider);

  return productos.whenData((list) {
    return list.where((producto) {
      final coincideNombre =
          query.isEmpty || producto.nombre.toLowerCase().contains(query);
      final coincideCategoria =
          categoriaId == null || producto.categoriaId == categoriaId;
      return coincideNombre && coincideCategoria;
    }).toList();
  });
});

/// Existencias físicas menos unidades reservadas para encargos sin entregar.
final stockLibreProvider = Provider<Map<int, int>>((ref) {
  final productos = ref.watch(productosStreamProvider).asData?.value ?? [];
  final encargos = ref.watch(encargosStreamProvider).asData?.value ?? [];
  final libres = {
    for (final p in productos)
      if (p.id != null) p.id!: p.cantidadDisponible
  };
  for (final e in encargos.where(
      (e) => e.activo && e.estado != 'ENTREGADO' && e.estado != 'FINALIZADO')) {
    for (final d
        in e.detalles.where((d) => d.comprado && d.productoId != null)) {
      libres.update(d.productoId!, (n) => n - d.cantidad, ifAbsent: () => 0);
    }
  }
  return libres.map((k, v) => MapEntry(k, v < 0 ? 0 : v));
});
