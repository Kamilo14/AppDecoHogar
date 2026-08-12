import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/viaje_entity.dart';
import '../providers/viaje_providers.dart';

class ViajeFormDialog extends ConsumerStatefulWidget {
  final Viaje? viajeExistente;
  const ViajeFormDialog({super.key, this.viajeExistente});

  @override
  ConsumerState<ViajeFormDialog> createState() => _ViajeFormDialogState();
}

class _ViajeFormDialogState extends ConsumerState<ViajeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _destinoCtrl;
  late final TextEditingController _obsCtrl;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _destinoCtrl = TextEditingController(text: widget.viajeExistente?.destino ?? '');
    _obsCtrl = TextEditingController(text: widget.viajeExistente?.observaciones ?? '');
    if (widget.viajeExistente != null) {
      _fecha = widget.viajeExistente!.fecha;
    }
  }

  @override
  void dispose() {
    _destinoCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final viaje = Viaje(
      id: widget.viajeExistente?.id,
      fecha: _fecha,
      destino: _destinoCtrl.text.trim(),
      observaciones: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      distribuido: widget.viajeExistente?.distribuido ?? false,
    );

    await ref.read(saveViajeUseCaseProvider).call(viaje);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.viajeExistente == null ? 'Nuevo viaje' : 'Editar viaje'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _destinoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  hintText: 'Ej: Santiago, Meiggs, Providencia',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del viaje',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar viaje')),
      ],
    );
  }
}
