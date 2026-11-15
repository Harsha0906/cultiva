import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/farm_day.dart';
import '../domain/rewards.dart';
import 'db.dart';

/// Completions (ripe/harvest per task per day) and the append-only coin ledger.
class ProgressRepository {
  ProgressRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CultivaDb _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  // ---------------------------------------------------------------- completions

  Future<List<Completion>> forDay(FarmDay day) =>
      (_db.select(_db.completions)..where((c) => c.day.equals(day.key))).get();

  Stream<List<Completion>> watchDay(FarmDay day) => (_db.select(
    _db.completions,
  )..where((c) => c.day.equals(day.key))).watch();

  Future<Completion?> forTaskOn(String taskId, FarmDay day) =>
      (_db.select(_db.completions)
            ..where((c) => c.taskId.equals(taskId) & c.day.equals(day.key)))
          .getSingleOrNull();

  /// Ripe-but-unharvested completions from days before [day].
  Future<List<Completion>> unharvestedBefore(FarmDay day) =>
      (_db.select(_db.completions)..where(
            (c) => c.harvestedAt.isNull() & c.day.isSmallerThanValue(day.key),
          ))
          .get();

  /// Days (from [since]) on which the task was completed (ripened or harvested).
  Future<Set<FarmDay>> doneDays(String taskId, {required FarmDay since}) async {
    final rows =
        await (_db.select(_db.completions)..where(
              (c) =>
                  c.taskId.equals(taskId) &
                  c.day.isBiggerOrEqualValue(since.key),
            ))
            .get();
    return {for (final r in rows) FarmDay.parse(r.day)};
  }

  /// Marks a task ripe for [day]. Idempotent: returns the existing completion.
  Future<Completion> ripen({
    required String taskId,
    required FarmDay day,
    required CompletionMethod method,
    int minutes = 0,
  }) async {
    final existing = await forTaskOn(taskId, day);
    if (existing != null) return existing;
    final id = _uuid.v4();
    await _db
        .into(_db.completions)
        .insert(
          CompletionsCompanion.insert(
            id: id,
            taskId: taskId,
            day: day.key,
            method: method.name,
            minutes: Value(minutes),
            ripenedAt: _clock(),
          ),
        );
    return (await forTaskOn(taskId, day))!;
  }

  Future<void> markHarvested(String completionId, int coins) =>
      (_db.update(
        _db.completions,
      )..where((c) => c.id.equals(completionId))).write(
        CompletionsCompanion(harvestedAt: Value(_clock()), coins: Value(coins)),
      );

  Future<void> clearHarvest(String completionId) =>
      (_db.update(
        _db.completions,
      )..where((c) => c.id.equals(completionId))).write(
        const CompletionsCompanion(harvestedAt: Value(null), coins: Value(0)),
      );

  Future<void> deleteCompletion(String completionId) => (_db.delete(
    _db.completions,
  )..where((c) => c.id.equals(completionId))).go();

  // ---------------------------------------------------------------- ledger

  Future<void> append(
    int delta,
    LedgerReason reason, {
    required FarmDay day,
    String? refId,
  }) async {
    if (delta == 0) return;
    await _db
        .into(_db.coinLedger)
        .insert(
          CoinLedgerCompanion.insert(
            delta: delta,
            reason: reason.name,
            refId: Value(refId),
            day: day.key,
            createdAt: _clock(),
          ),
        );
  }

  Expression<int> get _sum => _db.coinLedger.delta.sum();

  Stream<int> watchBalance() {
    final q = _db.selectOnly(_db.coinLedger)..addColumns([_sum]);
    return q.watchSingle().map((r) => r.read(_sum) ?? 0);
  }

  Future<int> balance() async {
    final q = _db.selectOnly(_db.coinLedger)..addColumns([_sum]);
    return (await q.getSingle()).read(_sum) ?? 0;
  }

  static final _earningReasons = [
    LedgerReason.harvest.name,
    LedgerReason.fullBasket.name,
    LedgerReason.unharvest.name,
  ];

  /// Net coins earned from harvesting on [day] (what the daily cap counts).
  Future<int> earnedOn(FarmDay day) async {
    final q = _db.selectOnly(_db.coinLedger)
      ..addColumns([_sum])
      ..where(
        _db.coinLedger.day.equals(day.key) &
            _db.coinLedger.reason.isIn(_earningReasons),
      );
    return (await q.getSingle()).read(_sum) ?? 0;
  }

  /// Whether the Full Basket bonus is currently (net) paid for [day].
  Future<bool> fullBasketPaid(FarmDay day) async {
    final q = _db.selectOnly(_db.coinLedger)
      ..addColumns([_sum])
      ..where(
        _db.coinLedger.day.equals(day.key) &
            _db.coinLedger.reason.equals(LedgerReason.fullBasket.name),
      );
    return ((await q.getSingle()).read(_sum) ?? 0) > 0;
  }

  /// Ledger rows tied to a completion (harvest + any bonus it triggered).
  Future<List<CoinLedgerData>> rowsFor(String refId) =>
      (_db.select(_db.coinLedger)..where((l) => l.refId.equals(refId))).get();
}
