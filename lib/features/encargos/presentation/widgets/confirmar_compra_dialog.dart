import 'package:flutter/material.dart';
import '../../domain/entities/encargo_entity.dart';
import 'encargo_form_screen.dart';

/// Usa el mismo flujo transaccional de compra parcial que el editor.
class ConfirmarCompraDialog extends StatelessWidget {
  final Encargo encargo;
  const ConfirmarCompraDialog({super.key, required this.encargo});

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
        child: EncargoFormScreen(encargoExistente: encargo),
      );
}
