import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/database.dart';

class ImportarBackupUseCase {
  final AppDatabase _db;

  ImportarBackupUseCase(this._db);

  Future<void> call(File file) async {
    final contents = await file.readAsString();
    final data = jsonDecode(contents) as Map<String, dynamic>;
    final rutasFotos = await _restaurarImagenes(data['imagenes']);

    await _db.transaction(() async {
      await _limpiarDatos();

      for (final item in (data['clientes'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.clientes).insert(
              ClientesCompanion(
                id: Value(row['id'] as int),
                nombre: Value(row['nombre'] as String),
                telefono: Value(row['telefono'] as String?),
                observaciones: Value(row['observaciones'] as String?),
                fechaRegistro:
                    Value(DateTime.parse(row['fechaRegistro'] as String)),
                activo: Value(row['activo'] as bool),
              ),
            );
      }
      for (final item in (data['categorias'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.categorias).insert(
              CategoriasCompanion(
                id: Value(row['id'] as int),
                nombre: Value(row['nombre'] as String),
              ),
            );
      }
      for (final item in (data['viajes'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.viajes).insert(
              ViajesCompanion(
                id: Value(row['id'] as int),
                fecha: Value(DateTime.parse(row['fecha'] as String)),
                destino: Value(row['destino'] as String),
                observaciones: Value(row['observaciones'] as String?),
                distribuido: Value(row['distribuido'] as bool),
                montoDistribuido:
                    Value((row['montoDistribuido'] as num?)?.toInt() ?? 0),
              ),
            );
      }
      for (final item in (data['productos'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.productos).insert(
              ProductosCompanion(
                id: Value(row['id'] as int),
                categoriaId: Value(row['categoriaId'] as int?),
                viajeId: Value(row['viajeId'] as int?),
                nombre: Value(row['nombre'] as String),
                precioCompra: Value(row['precioCompra'] as int),
                comisionViaje: Value(row['comisionViaje'] as int),
                precioVenta: Value(row['precioVenta'] as int),
                cantidadDisponible: Value(row['cantidadDisponible'] as int),
                fotoPath: Value(
                  rutasFotos[row['fotoPath']] ?? row['fotoPath'] as String?,
                ),
                activo: Value(row['activo'] as bool),
              ),
            );
      }
      for (final item in (data['encargos'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.encargos).insert(
              EncargosCompanion(
                id: Value(row['id'] as int),
                clienteId: Value(row['clienteId'] as int?),
                correlativoCliente:
                    Value((row['correlativoCliente'] as num?)?.toInt() ?? 1),
                fecha: Value(DateTime.parse(row['fecha'] as String)),
                fechaEntregaReal: Value(row['fechaEntregaReal'] == null
                    ? null
                    : DateTime.parse(row['fechaEntregaReal'] as String)),
                fechaEntregaEstimada: Value(row['fechaEntregaEstimada'] == null
                    ? null
                    : DateTime.parse(row['fechaEntregaEstimada'] as String)),
                estado: Value(row['estado'] as String),
                observaciones: Value(row['observaciones'] as String?),
                tipoVenta: Value(row['tipoVenta'] as String? ?? 'Por encargo'),
                activo: Value(row['activo'] as bool),
              ),
            );
      }
      for (final item in (data['compras'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.compras).insert(
              ComprasCompanion(
                id: Value(row['id'] as int),
                viajeId: Value(row['viajeId'] as int),
                productoId: Value(row['productoId'] as int),
                nombreProducto: Value(row['nombreProducto'] as String),
                fecha: Value(DateTime.parse(row['fecha'] as String)),
                cantidad: Value(row['cantidad'] as int),
                costoUnitario: Value(row['costoUnitario'] as int),
                precioVenta: Value(row['precioVenta'] as int),
                gastoAsignado:
                    Value((row['gastoAsignado'] as num?)?.toInt() ?? 0),
              ),
            );
      }
      for (final item in (data['encargo_detalle'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.encargoDetalle).insert(
              EncargoDetalleCompanion(
                id: Value(row['id'] as int),
                encargoId: Value(row['encargoId'] as int),
                productoId: Value(row['productoId'] as int?),
                nombreTemporal: Value(row['nombreTemporal'] as String?),
                cantidad: Value(row['cantidad'] as int),
                compraId: Value(row['compraId'] as int?),
                costoLogistica: Value(row['costoLogistica'] as int?),
                cantidadComprada: Value(row['cantidadComprada'] as int?),
                comprado: Value(row['comprado'] as bool? ?? false),
                precioUnitario: Value(row['precioUnitario'] as int?),
                costoUnitario: Value(row['costoUnitario'] as int?),
              ),
            );
      }
      for (final item in (data['pagos'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.pagos).insert(
              PagosCompanion(
                id: Value(row['id'] as int),
                clienteId: Value(row['clienteId'] as int),
                encargoId: Value(row['encargoId'] as int?),
                monto: Value(row['monto'] as int),
                fecha: Value(DateTime.parse(row['fecha'] as String)),
                metodo: Value(row['metodo'] as String),
                tipo: Value(row['tipo'] as String),
              ),
            );
      }
      for (final item in (data['gastos'] as List<dynamic>? ?? [])) {
        final row = item as Map<String, dynamic>;
        await _db.into(_db.gastos).insert(
              GastosCompanion(
                id: Value(row['id'] as int),
                viajeId: Value(row['viajeId'] as int),
                tipo: Value(row['tipo'] as String),
                monto: Value(row['monto'] as int),
              ),
            );
      }
    });
  }

  Future<void> limpiarDatos() => _db.transaction(_limpiarDatos);

  Future<Map<String, String>> _restaurarImagenes(dynamic imagenesData) async {
    if (imagenesData is! Map<String, dynamic>) return {};

    final directorio = await getApplicationDocumentsDirectory();
    final rutas = <String, String>{};
    var indice = 0;
    for (final entry in imagenesData.entries) {
      final extension = entry.key.contains('.')
          ? entry.key.substring(entry.key.lastIndexOf('.'))
          : '.jpg';
      final archivo =
          File('${directorio.path}/producto_respaldo_$indice$extension');
      await archivo.writeAsBytes(base64Decode(entry.value as String));
      rutas[entry.key] = archivo.path;
      indice++;
    }
    return rutas;
  }

  Future<void> _limpiarDatos() async {
    await _db.delete(_db.pagos).go();
    await _db.delete(_db.encargoDetalle).go();
    await _db.delete(_db.compras).go();
    await _db.delete(_db.encargos).go();
    await _db.delete(_db.gastos).go();
    await _db.delete(_db.productos).go();
    await _db.delete(_db.viajes).go();
    await _db.delete(_db.categorias).go();
    await _db.delete(_db.clientes).go();
  }
}
