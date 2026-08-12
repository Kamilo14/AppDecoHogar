import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/viaje_providers.dart';

class DistribuirGastosDialog extends ConsumerWidget {
  final int viajeId;
  final int montoADistribuir;

  const DistribuirGastosDialog({
    super.key, 
    required this.viajeId,
    required this.montoADistribuir,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Confirmar actualización de precios'),
      content: Text(
        'Se aplicará una comisión total de ${formatCurrencyClp(montoADistribuir)} '
        'distribuida proporcionalmente entre los productos de este viaje.\n\n'
        'Esto actualizará los Precios de Venta definitivos en tu inventario.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(distribuirGastosUseCaseProvider).call(viajeId, montoADistribuir);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Precios actualizados con éxito')),
              );
            }
          },
          child: const Text('Aplicar cambios'),
        ),
      ],
    );
  }
}
