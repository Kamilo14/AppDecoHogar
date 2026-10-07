import 'dart:math';

import '../../../encargos/domain/entities/encargo_entity.dart';
import '../entities/pago_entity.dart';

class EncargoPagoResumen {
  final int encargoId;
  final int totalExigible;
  final int montoAbonado;
  final int saldoPendiente;
  final bool estaSaldado;
  final String estadoPago; // 'PAGADO', 'PARCIAL', 'PENDIENTE'

  const EncargoPagoResumen({
    required this.encargoId,
    required this.totalExigible,
    required this.montoAbonado,
    required this.saldoPendiente,
    required this.estaSaldado,
    required this.estadoPago,
  });
}

class CalcularPagoEncargoUseCase {
  /// Calcula la distribución de abonos en cascada (FIFO) para las ventas de un cliente.
  Map<int, EncargoPagoResumen> calcularAbonosCliente({
    required int clienteId,
    required List<Encargo> encargos,
    required List<Pago> pagos,
  }) {
    // 1. Filtrar ventas activas y exigibles del cliente ordenadas cronológicamente
    final ventasCliente = encargos
        .where((e) =>
            e.clienteId == clienteId &&
            e.activo &&
            e.tipoVenta != 'Por encargo')
        .toList()
      ..sort((a, b) {
        final cmpFecha = a.fechaVenta.compareTo(b.fechaVenta);
        if (cmpFecha != 0) return cmpFecha;
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });

    // 2. Sumar todos los pagos realizados por el cliente
    final totalPagadoCliente = pagos
        .where((p) => p.clienteId == clienteId)
        .fold<int>(0, (sum, p) => sum + p.monto);

    int saldoRestantePagos = totalPagadoCliente;
    final resultado = <int, EncargoPagoResumen>{};

    // 3. Distribuir el dinero disponible en orden FIFO a las ventas
    for (final venta in ventasCliente) {
      if (venta.id == null) continue;

      final exigible = venta.totalExigible;
      if (exigible <= 0) {
        resultado[venta.id!] = EncargoPagoResumen(
          encargoId: venta.id!,
          totalExigible: 0,
          montoAbonado: 0,
          saldoPendiente: 0,
          estaSaldado: true,
          estadoPago: 'PAGADO',
        );
        continue;
      }

      final abonado = min(saldoRestantePagos, exigible);
      saldoRestantePagos = max(0, saldoRestantePagos - abonado);
      final pendiente = exigible - abonado;
      final estaSaldado = pendiente == 0;

      String estado;
      if (estaSaldado) {
        estado = 'PAGADO';
      } else if (abonado > 0) {
        estado = 'PARCIAL';
      } else {
        estado = 'PENDIENTE';
      }

      resultado[venta.id!] = EncargoPagoResumen(
        encargoId: venta.id!,
        totalExigible: exigible,
        montoAbonado: abonado,
        saldoPendiente: pendiente,
        estaSaldado: estaSaldado,
        estadoPago: estado,
      );
    }

    return resultado;
  }

  /// Retorna el resumen de pago de un encargo específico.
  EncargoPagoResumen call({
    required Encargo encargo,
    required List<Encargo> todosEncargos,
    required List<Pago> todosPagos,
  }) {
    if (encargo.id == null) {
      final exigible = encargo.totalExigible;
      return EncargoPagoResumen(
        encargoId: 0,
        totalExigible: exigible,
        montoAbonado: 0,
        saldoPendiente: exigible,
        estaSaldado: exigible <= 0,
        estadoPago: exigible <= 0 ? 'PAGADO' : 'PENDIENTE',
      );
    }

    if (encargo.clienteId == null) {
      // Venta sin cliente: se consideran únicamente los pagos vinculados
      final pagosEncargo =
          todosPagos.where((p) => p.encargoId == encargo.id).toList();
      final abonado = pagosEncargo.fold<int>(0, (sum, p) => sum + p.monto);
      final exigible = encargo.totalExigible;
      final abonadoClamped = min(abonado, exigible);
      final pendiente = max(0, exigible - abonadoClamped);
      final estaSaldado = pendiente == 0;

      return EncargoPagoResumen(
        encargoId: encargo.id!,
        totalExigible: exigible,
        montoAbonado: abonadoClamped,
        saldoPendiente: pendiente,
        estaSaldado: estaSaldado,
        estadoPago: estaSaldado
            ? 'PAGADO'
            : (abonadoClamped > 0 ? 'PARCIAL' : 'PENDIENTE'),
      );
    }

    final mapaCliente = calcularAbonosCliente(
      clienteId: encargo.clienteId!,
      encargos: todosEncargos,
      pagos: todosPagos,
    );

    return mapaCliente[encargo.id!] ??
        EncargoPagoResumen(
          encargoId: encargo.id!,
          totalExigible: encargo.totalExigible,
          montoAbonado: 0,
          saldoPendiente: encargo.totalExigible,
          estaSaldado: encargo.totalExigible <= 0,
          estadoPago: encargo.totalExigible <= 0 ? 'PAGADO' : 'PENDIENTE',
        );
  }
}
