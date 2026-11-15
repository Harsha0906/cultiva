import '../../data/db.dart';
import '../../data/farm_service.dart';
import '../../data/task_repository.dart';
import '../../domain/rewards.dart';
import '../../domain/task.dart';

/// Debug-only: fills the farm with a realistic mix of plants and stages.
Future<void> seedDemoFarm(FarmService farm) async {
  final day = await farm.today();
  final dailies = [
    ('Read', 30, 'pepper'),
    ('Walk', 20, 'pumpkin'),
    ('Meditate', 10, 'lettuce'),
    ('Guitar practice', 45, 'grape'),
    ('Breathe', 1, 'wheat'), // 1-minute task for testing Focus Mode
  ];
  final todos = [
    ('Pay electricity bill', Weekdays.none, 'squash'),
    ('Drink 8 glasses', Weekdays.everyDay, 'cauliflower'),
    ('Call grandma', Weekdays.none, 'peas'),
    ('Journal', Weekdays.everyDay, 'bean'),
  ];
  final planted = <FarmTask>[];
  for (final (title, minutes, crop) in dailies) {
    try {
      planted.add(
        await farm.tasks.plant(
          title: title,
          plot: PlotKind.daily,
          crop: crop,
          today: day,
          targetMinutes: minutes,
          repeat: Weekdays.everyDay,
        ),
      );
    } on PlotFullException {
      break;
    }
  }
  for (final (title, repeat, crop) in todos) {
    try {
      planted.add(
        await farm.tasks.plant(
          title: title,
          plot: PlotKind.todo,
          crop: crop,
          today: day,
          repeat: repeat,
        ),
      );
    } on PlotFullException {
      break;
    }
  }
  FarmTask? find(String t) => planted.where((x) => x.title == t).firstOrNull;
  final read = find('Read');
  if (read != null) {
    await farm.complete(read);
    await farm.harvest(read);
  }
  for (final t in ['Walk', 'Guitar practice']) {
    final x = find(t);
    if (x != null) await farm.complete(x, method: CompletionMethod.manual);
  }
  final bill = find('Pay electricity bill');
  if (bill != null) await farm.complete(bill);
}

/// Debug-only: wipes all farm data (tasks, progress, coins).
Future<void> clearFarm(CultivaDb db) => db.transaction(() async {
  await db.delete(db.coinLedger).go();
  await db.delete(db.inventory).go();
  await db.delete(db.focusSessions).go();
  await db.delete(db.completions).go();
  await db.delete(db.tasks).go();
});

/// Debug-only: grants coins for testing the shop (recorded as a refund row,
/// so it never counts toward the daily earning cap).
Future<void> grantDebugCoins(FarmService farm, int coins) async =>
    farm.progress.append(
      coins,
      LedgerReason.refund,
      day: await farm.today(),
      refId: 'debug',
    );
