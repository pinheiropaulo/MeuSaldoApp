import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/shared/data/local/app_database.dart';

/// Provedor global da instância única do banco de dados local Drift.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
