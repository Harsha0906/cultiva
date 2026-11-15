import 'package:drift/drift.dart';

import '../domain/farm_day.dart';
import 'db.dart';

class JournalRepository {
  JournalRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CultivaDb _db;
  final DateTime Function() _clock;

  Stream<JournalData?> watch(FarmDay day) => (_db.select(
    _db.journal,
  )..where((j) => j.day.equals(day.key))).watchSingleOrNull();

  Future<JournalData?> get(FarmDay day) => (_db.select(
    _db.journal,
  )..where((j) => j.day.equals(day.key))).getSingleOrNull();

  /// Saves mood (1–5) and/or note for a day; omitted fields keep their value.
  Future<void> upsert(FarmDay day, {int? mood, String? note}) async {
    if (mood != null && (mood < 1 || mood > 5)) {
      throw RangeError.range(mood, 1, 5, 'mood');
    }
    final current = await get(day);
    await _db
        .into(_db.journal)
        .insertOnConflictUpdate(
          JournalCompanion.insert(
            day: day.key,
            mood: Value(mood ?? current?.mood),
            note: Value(note ?? current?.note),
            updatedAt: _clock(),
          ),
        );
  }
}
