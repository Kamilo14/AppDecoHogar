import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cliente_entity.dart';
import '../providers/cliente_providers.dart';

/// Widget de diálogo para crear o editar un cliente.
/// Se usa como popup modal sobre cualquier pantalla.
class ClienteFormDialog extends ConsumerStatefulWidget {
  final Cliente? clienteExistente;

  const ClienteFormDialog({super.key, this.clienteExistente});

  @override
  ConsumerState<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends ConsumerState<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _observacionesCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.clienteExistente?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: widget.clienteExistente?.telefono ?? '');
    _emailCtrl = TextEditingController(text: widget.clienteExistente?.email ?? '');
    _direccionCtrl = TextEditingController(text: widget.clienteExistente?.direccion ?? '');
    _observacionesCtrl = TextEditingController(text: widget.clienteExistente?.observaciones ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final cliente = Cliente(
      id: widget.clienteExistente?.id,
      nombre: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim().isEmpty ? null : _direccionCtrl.text.trim(),
      observaciones: _observacionesCtrl.text.trim().isEmpty ? null : _observacionesCtrl.text.trim(),
      fechaRegistro: widget.clienteExistente?.fechaRegistro ?? DateTime.now(),
    );

    try {
      await ref.read(saveClienteUseCaseProvider).call(cliente);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.clienteExistente == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nuevo Cliente' : 'Editar Cliente'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Correo (opcional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección (opcional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesCtrl,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(esNuevo ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}
