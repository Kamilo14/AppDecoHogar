import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup_providers.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup y restauración')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final file = await ref.read(exportarBackupUseCaseProvider).call();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup creado en ${file.path}')),
                  );
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Exportar backup'),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                final path = result?.files.single.path;
                if (path == null) return;
                await ref.read(importarBackupUseCaseProvider).call(File(path));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup importado correctamente')),
                  );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Importar backup'),
            ),
          ],
        ),
      ),
    );
  }
}