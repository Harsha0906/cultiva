import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/focus_service.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/plant_engine.dart';
import 'package:cultiva/domain/rewards.dart';
import 'package:cultiva/domain/task.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  late FocusService focus;
  late DateTime now;
  final mon = FarmDay(2026, 11, 16);

  FocusService fresh() => FocusService(db, farm, clock: () => now);

  setUp(() {
    now = DateTime(2026, 11, 16, 9);
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
    focus = fresh();
  });
  tearDown(() => db.close());

  Future<FarmTask> read({int minutes = 30}) => farm.tasks.plant(
    title: 'Read',
    plot: PlotKind.daily,
    crop: 'pepper',
    today: mon,
    targetMinutes: minutes,
    repeat: Weekdays.everyDay,
  );

  void advance(Duration d) => now = now.add(d);

  test('start, time passes, finishing ripens with full focus coins', () async {
    final t = await read(minutes: 30);
    expect((await focus.load(t)).status, FocusStatus.idle);
    final s = await focus.start(t);
    expect(s.status, FocusStatus.running);
    expect(s.endsAt, now.add(const Duration(minutes: 30)));

    advance(const Duration(minutes: 10));
    final mid = await focus.load(t);
    expect((mid.elapsedSec, mid.stage), (600, PlantStage.sprout));
    expect((await farm.plants()).single.stage, PlantStage.sprout);

    advance(const Duration(minutes: 20));
    expect((await focus.load(t)).status, FocusStatus.ripe);
    expect((await farm.plants()).single.stage, PlantStage.ripe);
    expect(await farm.harvest(t), 12 + kFullBasketBonus);
  });

  test('pause stops the clock; resume continues', () async {
    final t = await read();
    await focus.start(t);
    advance(const Duration(minutes: 5));
    final p = await focus.pause(t);
    expect((p.status, p.elapsedSec), (FocusStatus.paused, 300));
    advance(const Duration(hours: 3)); // paused time doesn't count
    expect((await focus.load(t)).elapsedSec, 300);
    await focus.start(t);
    advance(const Duration(minutes: 1));
    expect((await focus.load(t)).elapsedSec, 360);
  });

  test('survives the app restarting (new service instance)', () async {
    final t = await read();
    await focus.start(t);
    advance(const Duration(minutes: 16));
    final reopened = await fresh().load(t);
    expect(
      (reopened.status, reopened.elapsedSec, reopened.stage),
      (FocusStatus.running, 960, PlantStage.young),
    );
  });

  test('giving up keeps the growth', () async {
    final t = await read();
    await focus.start(t);
    advance(const Duration(minutes: 4));
    final g = await focus.giveUp(t);
    expect((g.status, g.elapsedSec), (FocusStatus.abandoned, 240));
    expect((await farm.plants()).single.stage, PlantStage.sprout);
  });

  test('clock moved backwards: no free time, flagged, pays half', () async {
    final t = await read(minutes: 30);
    await focus.start(t);
    advance(const Duration(minutes: 10));
    now = now.subtract(const Duration(hours: 1)); // user winds the clock back
    final s = await focus.load(t);
    expect(s.suspicious, isTrue);
    expect(s.elapsedSec, 0);
    advance(const Duration(minutes: 30));
    expect((await focus.load(t)).status, FocusStatus.ripe);
    final c = (await farm.progress.forDay(mon)).single;
    expect(c.method, CompletionMethod.manual.name);
  });

  test('a huge forward jump is capped and flagged', () async {
    final t = await read(minutes: 30);
    await focus.start(t);
    advance(const Duration(days: 0, hours: 5));
    final s = await focus.load(t);
    expect(s.status, FocusStatus.ripe);
    expect(s.suspicious, isTrue);
  });

  test('check tasks are refused', () async {
    final todo = await farm.tasks.plant(
      title: 'Bill',
      plot: PlotKind.todo,
      crop: 'pumpkin',
      today: mon,
    );
    expect(() => focus.start(todo), throwsA(isA<FocusException>()));
  });
}
