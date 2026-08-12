import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/categoria_entity.dart';
import '../providers/producto_providers.dart';

class CategoriaFormDialog extends ConsumerStatefulWidget {
  final Categoria? categoriaExistente;

  const CategoriaFormDialog({super.key, this.categoriaExistente});

  @override
  ConsumerState<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends ConsumerState<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.categoriaExistente?.nombre ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final categoria = Categoria(
      id: widget.categoriaExistente?.id,
      nombre: _nombreCtrl.text.trim(),
    );

    try {
      await ref.read(saveCategoriaUseCaseProvider).call(categoria);
      if (mounted) Navigator.of(context).pop(categoria);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la categoría: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.categoriaExistente == null;
    return AlertDialog(
      title: Text(esNuevo ? 'Nueva categoría' : 'Editar categoría'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            prefixIcon: Icon(Icons.label_outline),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(esNuevo ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}