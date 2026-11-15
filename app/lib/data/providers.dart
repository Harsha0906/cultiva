import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db.dart';
import 'farm_service.dart';
import 'journal_repository.dart';

/// The single app database. Override in tests with an in-memory instance.
final dbProvider = Provider<CultivaDb>((ref) {
  final db = CultivaDb();
  ref.onDispose(db.close);
  return db;
});

/// Clock seam for tests.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

final farmServiceProvider = Provider<FarmService>(
  (ref) => FarmService(ref.watch(dbProvider), clock: ref.watch(clockProvider)),
);

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) =>
      JournalRepository(ref.watch(dbProvider), clock: ref.watch(clockProvider)),
);
