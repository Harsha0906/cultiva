import 'package:cultiva/data/db.dart';
import 'package:cultiva/data/farm_service.dart';
import 'package:cultiva/data/journal_repository.dart';
import 'package:cultiva/data/task_repository.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/plant_engine.dart';
import 'package:cultiva/domain/task.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CultivaDb db;
  late FarmService farm;
  final mon = FarmDay(2026, 11, 16);

  setUp(() {
    db = CultivaDb(NativeDatabase.memory());
    farm = FarmService(db, clock: () => DateTime(2026, 11, 16, 9));
  });
  tearDown(() => db.close());

  Future<FarmTask> daily(String title) => farm.tasks.plant(
    title: title,
    plot: PlotKind.daily,
    crop: 'wheat',
    today: mon,
    targetMinutes: 10,
    repeat: Weekdays.everyDay,
  );

  group('TaskRepository.update', () {
    test('saves trimmed title, crop, minutes and days', () async {
      final t = await daily('Read');
      await farm.tasks.update(
        t,
        title: '  Read more ',
        crop: 'grape',
        targetMinutes: 25,
        repeat: Weekdays.of([DateTime.monday]),
      );
      final saved = (await farm.tasks.byId(t.id))!;
      expect(saved.title, 'Read more');
      expect(saved.crop, 'grape');
      expect(saved.targetMinutes, 25);
      expect(saved.repeat, Weekdays.of([DateTime.monday]));
    });

    test('rejects an empty title and keeps the old one', () async {
      final t = await daily('Walk');
      await expectLater(
        farm.tasks.update(t, title: '   '),
        throwsA(isA<InvalidTaskException>()),
      );
      expect((await farm.tasks.byId(t.id))!.title, 'Walk');
    });
  });

  group('TaskRepository.restore', () {
    test('moves to a free slot when its old slot was taken', () async {
      final a = await daily('A'); // slot 0
      await farm.tasks.archive(a.id);
      final b = await daily('B'); // takes slot 0
      await farm.tasks.restore(a.id);
      final restored = (await farm.tasks.byId(a.id))!;
      expect(restored.archived, isFalse);
      expect(restored.slot, isNot(b.slot));
    });

    test('throws when the plot is full', () async {
      final a = await daily('A');
      await farm.tasks.archive(a.id);
      for (var i = 0; i < kPlotCapacity; i++) {
        await daily('T$i');
      }
      await expectLater(
        farm.tasks.restore(a.id),
        throwsA(isA<PlotFullException>()),
      );
    });
  });

  group('JournalRepository', () {
    test('upsert keeps omitted fields; clearMood keeps the note', () async {
      final j = JournalRepository(db, clock: () => DateTime(2026, 11, 16, 21));
      await j.upsert(mon, mood: 4);
      await j.upsert(mon, note: 'Good day');
      var row = (await j.get(mon))!;
      expect(row.mood, 4);
      expect(row.note, 'Good day');
      await j.clearMood(mon);
      row = (await j.get(mon))!;
      expect(row.mood, isNull);
      expect(row.note, 'Good day');
    });

    test('rejects moods outside 1-5', () async {
      final j = JournalRepository(db);
      expect(() => j.upsert(mon, mood: 6), throwsRangeError);
    });
  });
}
