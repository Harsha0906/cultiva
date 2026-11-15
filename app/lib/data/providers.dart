import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db.dart';
import 'farm_service.dart';
import 'focus_service.dart';
import 'journal_repository.dart';
import 'shop_service.dart';

/// The single app database. Override in tests with an in-memory instance.
final dbProvider = Provider<CultivaDb>((ref) {
  final db = CultivaDb();
  ref.onDispose(db.close);
  return db;
});

/// Test seam: widget tests turn the Flame farm scene off (it animates forever).
final farmSceneEnabledProvider = Provider<bool>((_) => true);

/// Clock seam for tests.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);

final farmServiceProvider = Provider<FarmService>(
  (ref) => FarmService(ref.watch(dbProvider), clock: ref.watch(clockProvider)),
);

final focusServiceProvider = Provider<FocusService>(
  (ref) => FocusService(
    ref.watch(dbProvider),
    ref.watch(farmServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final shopServiceProvider = Provider<ShopService>(
  (ref) => ShopService(ref.watch(dbProvider), ref.watch(farmServiceProvider)),
);

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) =>
      JournalRepository(ref.watch(dbProvider), clock: ref.watch(clockProvider)),
);
