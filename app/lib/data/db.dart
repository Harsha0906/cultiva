import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

/// Schema v1 — see docs/steps/3.1-database.md. All tables hold durable user data:
/// migrations must never drop them, even on failure.

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 80)();
  TextColumn get plot => text()(); // PlotKind.name
  TextColumn get kind => text()(); // TaskKind.name
  IntColumn get targetMinutes => integer().nullable()();
  IntColumn get repeatMask => integer().withDefault(const Constant(0))();
  TextColumn get crop => text()();
  IntColumn get slot => integer()();
  TextColumn get createdDay => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'completions_day', columns: {#day})
class Completions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get day => text()();
  TextColumn get method => text()(); // CompletionMethod.name
  IntColumn get minutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get ripenedAt => dateTime()();
  DateTimeColumn get harvestedAt => dateTime().nullable()();
  IntColumn get coins => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {taskId, day},
  ];
}

@TableIndex(name: 'focus_task_day', columns: {#taskId, #day})
class FocusSessions extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get day => text()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get plannedSec => integer()();
  IntColumn get accumulatedSec => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  BoolColumn get suspicious => boolean().withDefault(const Constant(false))();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Journal extends Table {
  TextColumn get day => text()();
  IntColumn get mood => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {day};
}

class Inventory extends Table {
  TextColumn get itemId => text()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  IntColumn get placedSpot => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId};
}

/// Append-only. Balance = SUM(delta). Rows are never updated or deleted.
@TableIndex(name: 'ledger_day', columns: {#day})
class CoinLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get delta => integer()();
  TextColumn get reason => text()(); // LedgerReason.name
  TextColumn get refId => text().nullable()();
  TextColumn get day => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Tasks,
    Completions,
    FocusSessions,
    Journal,
    Inventory,
    CoinLedger,
    Settings,
  ],
)
class CultivaDb extends _$CultivaDb {
  CultivaDb([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'cultiva'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
