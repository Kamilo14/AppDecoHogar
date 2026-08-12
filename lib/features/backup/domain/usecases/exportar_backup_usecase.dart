import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/database/database.dart';

class ExportarBackupUseCase {
  final AppDatabase _db;

  ExportarBackupUseCase(this._db);

  Future<File> call() async {
    final data = await _exportAll();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup_app_deco_hogar_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<Map<String, dynamic>> _exportAll() async {
    final clientes = await _db.select(_db.clientes).get();
    final categorias = await _db.select(_db.categorias).get();
    final viajes = await _db.select(_db.viajes).get();
    final gastos = await _db.select(_db.gastos).get();
    final productos = await _db.select(_db.productos).get();
    final encargos = await _db.select(_db.encargos).get();
    final detalles = await _db.select(_db.encargoDetalle).get();
    final pagos = await _db.select(_db.pagos).get();

    return {
      'clientes': clientes
          .map(
            (e) => {
              'id': e.id,
              'nombre': e.nombre,
              'telefono': e.telefono,
              'observaciones': e.observaciones,
              'fechaRegistro': e.fechaRegistro.toIso8601String(),
              'activo': e.activo,
            },
          )
          .toList(),
      'categorias': categorias.map((e) => {'id': e.id, 'nombre': e.nombre}).toList(),
      'viajes': viajes
          .map(
            (e) => {
              'id': e.id,
              'fecha': e.fecha.toIso8601String(),
              'destino': e.destino,
              'observaciones': e.observaciones,
              'distribuido': e.distribuido,
            },
          )
          .toList(),
      'gastos': gastos.map((e) => {'id': e.id, 'viajeId': e.viajeId, 'tipo': e.tipo, 'monto': e.monto}).toList(),
      'productos': productos
          .map(
            (e) => {
              'id': e.id,
              'categoriaId': e.categoriaId,
              'viajeId': e.viajeId,
              'nombre': e.nombre,
              'precioCompra': e.precioCompra,
              'comisionViaje': e.comisionViaje,
              'precioVenta': e.precioVenta,
              'cantidadDisponible': e.cantidadDisponible,
              'fotoPath': e.fotoPath,
              'activo': e.activo,
            },
          )
          .toList(),
      'encargos': encargos
          .map(
            (e) => {
              'id': e.id,
              'clienteId': e.clienteId,
              'fecha': e.fecha.toIso8601String(),
              'estado': e.estado,
              'observaciones': e.observaciones,
              'activo': e.activo,
            },
          )
          .toList(),
      'encargo_detalle': detalles
          .map(
            (e) => {
              'id': e.id,
              'encargoId': e.encargoId,
              'productoId': e.productoId,
              'cantidad': e.cantidad,
              'precioUnitario': e.precioUnitario,
            },
          )
          .toList(),
      'pagos': pagos
          .map(
            (e) => {
              'id': e.id,
              'clienteId': e.clienteId,
              'encargoId': e.encargoId,
              'monto': e.monto,
              'fecha': e.fecha.toIso8601String(),
              'metodo': e.metodo,
              'tipo': e.tipo,
            },
          )
          .toList(),
    };
  }
}