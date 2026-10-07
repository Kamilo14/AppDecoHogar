import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gasto_entity.dart';
import '../providers/viaje_providers.dart';

class GastoFormDialog extends ConsumerStatefulWidget {
  final int viajeId;

  const GastoFormDialog({super.key, required this.viajeId});

  @override
  ConsumerState<GastoFormDialog> createState() => _GastoFormDialogState();
}

class _GastoFormDialogState extends ConsumerState<GastoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tipoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();

  @override
  void dispose() {
    _tipoCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(agregarGastoUseCaseProvider).call(
          Gasto(
            viajeId: widget.viajeId,
            tipo: _tipoCtrl.text.trim(),
            monto: int.parse(_montoCtrl.text.trim()),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo gasto'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _tipoCtrl,
              decoration: const InputDecoration(labelText: 'Tipo'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa un tipo' : null,
            ),
            TextFormField(
              controller: _montoCtrl,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) return 'Monto inválido';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
