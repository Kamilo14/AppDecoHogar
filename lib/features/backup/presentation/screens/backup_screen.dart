import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/warm_ui.dart';
import '../providers/backup_providers.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Backup y restauración')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  try {
                    final file =
                        await ref.read(exportarBackupUseCaseProvider).call();
                    if (!context.mounted) return;
                    final borrarDatos =
                        await _confirmarRespaldo(context, file.path);
                    if (borrarDatos == true && context.mounted) {
                      await ref
                          .read(importarBackupUseCaseProvider)
                          .limpiarDatos();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Respaldo creado y datos de negocio eliminados.')),
                        );
                      }
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('No se pudo crear el respaldo: $error')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Exportar backup'),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom, allowedExtensions: ['json']);
                  final path = result?.files.single.path;
                  if (path == null) return;
                  if (!context.mounted || !await _confirmarImportacion(context))
                    return;
                  try {
                    await ref
                        .read(importarBackupUseCaseProvider)
                        .call(File(path));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Backup importado correctamente')),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'No se pudo importar el respaldo: $error')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Importar backup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmarRespaldo(BuildContext context, String path) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Respaldo creado'),
        content: Text(
          'El respaldo se guardó en:\n$path\n\n¿Deseas conservar los datos en esta aplicación o eliminarlos ahora? El respaldo también incluye las fotos de productos disponibles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Conservar datos'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar datos'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarImportacion(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('¿Restaurar respaldo?'),
            content: const Text(
              'Esta acción reemplazará todos los datos de negocio actuales: clientes, encargos, pagos, productos, viajes y gastos. Crea un respaldo antes de continuar si quieres conservarlos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Restaurar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
