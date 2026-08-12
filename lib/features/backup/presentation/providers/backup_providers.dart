import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/usecases/exportar_backup_usecase.dart';
import '../../domain/usecases/importar_backup_usecase.dart';

final exportarBackupUseCaseProvider = Provider<ExportarBackupUseCase>((ref) {
  return ExportarBackupUseCase(ref.watch(databaseProvider));
});

final importarBackupUseCaseProvider = Provider<ImportarBackupUseCase>((ref) {
  return ImportarBackupUseCase(ref.watch(databaseProvider));
});
