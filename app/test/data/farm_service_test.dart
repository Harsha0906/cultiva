import 'dart:io';

import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/journal_repository.dart';
import 'package:cultiva/data/task_repository.dart';
import 'package:cultiva/domain/avatar.dart';
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
  var now = DateTime(2026, 11, 16, 9); // Monday 9am
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    now = DateTime(2026, 11, 16, 9);
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => now);
  });
  tearDown(() => db.close());

  Future<FarmTask> plantDaily(String title, {int minutes = 30}) =>
      farm.tasks.plant(
        title: title,
        plot: PlotKind.daily,
        crop: 'pepper',
        today: mon,
        targetMinutes: minutes,
        repeat: Weekdays.everyDay,
      );

  Future<FarmTask> plantTodo(String title) => farm.tasks.plant(
    title: title,
    plot: PlotKind.todo,
    crop: 'pumpkin',
    today: mon,
  );

  group('planting', () {
    test('fills slots 0..5 then refuses the 7th', () async {
      for (var i = 0; i < 6; i++) {
        expect((await plantDaily('t$i')).slot, i);
      }
      expect(() => plantDaily('t6'), throwsA(isA<PlotFullException>()));
      // the other plot is independent
      expect((await plantTodo('bill')).slot, 0);
    });

    test('invalid tasks are rejected', () async {
      expect(() => plantDaily('   '), throwsA(isA<InvalidTaskException>()));
      expect(
        () => plantDaily('x', minutes: 0),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('archiving frees the slot for reuse', () async {
      final a = await plantDaily('a');
      await plantDaily('b');
      await farm.tasks.archive(a.id);
      expect((await plantDaily('c')).slot, 0);
    });
  });

  group('complete and harvest', () {
    test('ripe then harvest pays tier coins into the ledger', () async {
      final t = await plantDaily('Read', minutes: 30);
      await farm.complete(t);
      expect((await farm.plants()).single.stage, PlantStage.ripe);
      expect(
        await farm.harvest(t),
        12 + kFullBasketBonus,
      ); // only Daily task -> Full Basket
      expect(await farm.progress.balance(), 32);
      expect((await farm.plants()).single.stage, PlantStage.harvested);
    });

    test('cannot harvest twice or without ripening', () async {
      final t = await plantDaily('Read');
      expect(() => farm.harvest(t), throwsA(isA<FarmActionException>()));
      await farm.complete(t);
      await farm.harvest(t);
      expect(() => farm.harvest(t), throwsA(isA<FarmActionException>()));
    });

    test('"I already did it" pays half', () async {
      final a = await plantDaily('Gym', minutes: 60);
      await plantDaily('Other'); // keeps Full Basket out of this test
      await farm.complete(a, method: CompletionMethod.manual);
      expect(await farm.harvest(a), 6);
    });

    test(
      'Full Basket pays once, when the last due Daily is harvested',
      () async {
        final a = await plantDaily('a');
        final b = await plantDaily('b');
        await farm.complete(a);
        await farm.complete(b);
        expect(await farm.harvest(a), 12);
        expect(await farm.harvest(b), 12 + kFullBasketBonus);
        expect(await farm.progress.balance(), 44);
      },
    );

    test('daily cap stops earnings at 150', () async {
      for (var i = 0; i < 6; i++) {
        await plantDaily('long$i', minutes: 90); // 25 each
      }
      final list = await farm.tasks.active();
      var total = 0;
      for (final t in list) {
        await farm.complete(t);
        total += await farm.harvest(t);
      }
      expect(total, kDailyCoinCap);
      expect(await farm.progress.balance(), kDailyCoinCap);
    });

    test('a finished to-do leaves the plot; undo brings it back', () async {
      final t = await plantTodo('Pay bill');
      await farm.complete(t);
      expect(await farm.harvest(t), kCheckCoins);
      expect(await farm.tasks.active(), isEmpty);
      await farm.unharvest(t);
      expect((await farm.tasks.active()).single.id, t.id);
      expect(await farm.progress.balance(), 0);
    });

    test('unharvest reverses exactly, including the bonus', () async {
      final a = await plantDaily('a');
      await farm.complete(a);
      await farm.harvest(a); // 12 + 20
      await farm.unharvest(a);
      expect(await farm.progress.balance(), 0);
      expect(await farm.progress.fullBasketPaid(mon), isFalse);
      // harvesting again pays the bonus again (it was reversed)
      expect(await farm.harvest(a), 32);
    });
  });

  group('days', () {
    test('missed yesterday -> dormant; doing it revives', () async {
      final t = await plantDaily('Read');
      now = DateTime(2026, 11, 17, 9); // Tuesday
      expect((await farm.plants()).single.stage, PlantStage.dormant);
      await farm.complete(t, method: CompletionMethod.manual);
      expect((await farm.plants()).single.stage, PlantStage.ripe);
    });

    test('done yesterday -> fresh seed today', () async {
      final t = await plantDaily('Read');
      await farm.complete(t);
      await farm.harvest(t);
      now = DateTime(2026, 11, 17, 9);
      expect((await farm.plants()).single.stage, PlantStage.seed);
    });

    test('2am still counts as the previous farm day', () async {
      final t = await plantDaily('Read');
      now = DateTime(2026, 11, 17, 2);
      await farm.complete(t);
      expect((await farm.progress.forDay(mon)).single.taskId, t.id);
    });

    test('custom reset hour is respected', () async {
      await farm.settings.setResetHour(6);
      now = DateTime(2026, 11, 17, 5);
      expect(await farm.today(), mon);
    });
  });

  group('rollover (auto-harvest left-ripe plants)', () {
    test('pays into yesterday, once', () async {
      final t = await plantTodo('Bill');
      await farm.complete(t); // ripe Monday, never tapped
      now = DateTime(2026, 11, 17, 9);
      expect(await farm.rollover(), kCheckCoins);
      expect(await farm.progress.earnedOn(mon), kCheckCoins);
      expect(await farm.rollover(), 0);
      expect(await farm.tasks.active(), isEmpty); // finished to-do archived
    });

    test("respects yesterday's cap", () async {
      for (var i = 0; i < 6; i++) {
        await plantDaily('long$i', minutes: 90);
      }
      for (final t in await farm.tasks.active()) {
        await farm.complete(t);
      }
      now = DateTime(2026, 11, 17, 9);
      expect(await farm.rollover(), kDailyCoinCap);
    });

    test('removed tasks are skipped', () async {
      final t = await plantDaily('Gone');
      await farm.complete(t);
      await farm.tasks.archive(t.id);
      now = DateTime(2026, 11, 17, 9);
      expect(await farm.rollover(), 0);
    });
  });

  group('settings & journal', () {
    test('defaults and round-trips', () async {
      final s = farm.settings;
      expect(await s.resetHour(), 4);
      expect(await s.avatar(), Avatar.fallback);
      expect(await s.farmerName(), 'Farmer');
      await s.setAvatar(const Avatar(AvatarAnimal.owl, 2));
      await s.setFarmerName('  Harsha ');
      expect(await s.avatar(), const Avatar(AvatarAnimal.owl, 2));
      expect(await s.farmerName(), 'Harsha');
      expect(() => s.setResetHour(13), throwsRangeError);
      expect(await s.reminderEnabled(), isFalse); // opt-in
      expect(await s.reduceMotion(), isFalse);
      await s.setFarmerName('A' * 40);
      expect((await s.farmerName()).length, 24);
    });

    test('journal upsert keeps untouched fields', () async {
      final j = JournalRepository(db, clock: () => now);
      await j.upsert(mon, mood: 4);
      await j.upsert(mon, note: 'Rainy walk');
      final e = await j.get(mon);
      expect((e!.mood, e.note), (4, 'Rainy walk'));
      expect(() => j.upsert(mon, mood: 9), throwsRangeError);
    });
  });

  test('data survives closing and reopening a file database', () async {
    final dir = await Directory.systemTemp.createTemp('cultiva_db');
    final file = File('${dir.path}/c.sqlite');
    var fileDb = CultivaDb(NativeDatabase(file));
    await FarmService(fileDb, clock: () => now).tasks.plant(
      title: 'Keep me',
      plot: PlotKind.todo,
      crop: 'wheat',
      today: mon,
    );
    await fileDb.close();
    fileDb = CultivaDb(NativeDatabase(file));
    final again = await FarmService(fileDb, clock: () => now).tasks.active();
    expect(again.single.title, 'Keep me');
    await fileDb.close();
    await dir.delete(recursive: true);
  });
}
