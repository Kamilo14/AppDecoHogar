import '../entities/encargo_entity.dart';
import '../entities/encargo_detalle_entity.dart';
import '../repositories/encargo_repository.dart';
import '../../../productos/domain/repositories/producto_repository.dart';
import '../../../../core/errors/failures.dart';

class ConfirmarCompraUseCase {
  final EncargoRepository _encargoRepository;
  final ProductoRepository _productoRepository;

  ConfirmarCompraUseCase(this._encargoRepository, this._productoRepository);

  Future<void> call({
    required Encargo encargo,
    required List<EncargoDetalle> detallesConPrecio,
    required int viajeId,
  }) async {
    if (detallesConPrecio.any((d) => d.precioUnitario == null || d.costoUnitario == null)) {
      throw ValidationFailure('Todos los productos deben tener precio de compra y venta fijados.');
    }

    // 1. Actualizar cada producto en el catálogo (Santiago Flow: Solo precios y viaje)
    for (final detalle in detallesConPrecio) {
      if (detalle.productoId != null) {
        final producto = await _productoRepository.getProductoById(detalle.productoId!);
        if (producto != null) {
          await _productoRepository.saveProducto(producto.copyWith(
            precioCompra: detalle.costoUnitario,
            precioVenta: detalle.precioUnitario,
            // El stock ya fue reservado en saveEncargo, aquí no se toca
            viajeId: viajeId,
          ));
        }
      }
    }

    // 2. Actualizar el encargo con los precios inmutables y cambiar estado
    final encargoComprado = encargo.copyWith(
      estado: 'COMPRADO',
      detalles: detallesConPrecio,
    );

    await _encargoRepository.saveEncargo(encargoComprado);
  }
}
