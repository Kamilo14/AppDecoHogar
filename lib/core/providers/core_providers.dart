import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

/// Proveedor global de la base de datos local
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
