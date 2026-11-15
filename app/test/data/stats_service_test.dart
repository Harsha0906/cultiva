import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/focus_service.dart';
import 'package:cultiva/data/journal_repository.dart';
import 'package:cultiva/data/shop_service.dart';
import 'package:cultiva/data/stats_service.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/domain/task.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  late JournalRepository journal;
  late StatsService stats;
  late DateTime now;
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    now = DateTime(2026, 11, 16, 9);
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
    journal = JournalRepository(db, clock: () => now);
    stats = StatsService(db, farm, journal, clock: () => now);
  });
  tearDown(() => db.close());

  Future<FarmTask> daily(String t, int min) => farm.tasks.plant(
    title: t,
    plot: PlotKind.daily,
    crop: 'pepper',
    today: mon,
    targetMinutes: min,
    repeat: Weekdays.everyDay,
  );

  test('summary counts done, harvested, focus minutes and coins', () async {
    final read = await daily('Read', 30);
    final walk = await daily('Walk', 20);
    final yoga = await daily('Yoga', 40);
    await farm.complete(read); // focus, 30 min
    await farm.harvest(read); // 12
    await farm.complete(walk, method: CompletionMethod.manual); // 20 min, ripe
    final focus = FocusService(db, farm, clock: () => now);
    await focus.start(yoga);
    now = now.add(const Duration(minutes: 7)); // in-progress focus counts

    final s = await stats.summary(mon);
    expect((s.doneCount, s.harvestedCount), (2, 1));
    expect(s.focusMinutes, 30 + 20 + 7);
    expect(s.coins, 12);
    expect(s.done.map((d) => d.title), containsAll(['Read', 'Walk']));
  });

  test('purchases are not "coins earned"', () async {
    await farm.progress.append(300, LedgerReason.harvest, day: mon);
    await ShopService(db, farm).buy('well');
    expect((await stats.summary(mon)).coins, 300);
  });

  test('mood and note come through; empty days are empty', () async {
    expect((await stats.summary(mon)).isEmpty, isTrue);
    await journal.upsert(mon, mood: 4, note: 'Rainy walk');
    final s = await stats.summary(mon);
    expect((s.mood, s.note, s.isEmpty), (4, 'Rainy walk', false));
  });

  test('week gives 7 days ending on the given day', () async {
    final w = await stats.week(mon);
    expect(w, hasLength(7));
    expect(w.first.day, mon.addDays(-6));
    expect(w.last.day, mon);
  });

  test('month stops at today', () async {
    final m = await stats.month(2026, 11, mon);
    expect(m, hasLength(16));
    expect(m.last.day, mon);
  });
}
