import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/live_query.dart';
import '../../data/providers.dart';
import '../../data/stats_service.dart';
import '../../domain/farm_day.dart';

/// Re-runs [load] whenever anything the Progress tab shows changes.
Stream<T> _live<T>(
  Ref ref,
  Future<T> Function(StatsService stats, FarmDay today) load,
) {
  final db = ref.watch(dbProvider);
  final stats = ref.watch(statsServiceProvider);
  final farm = ref.watch(farmServiceProvider);
  return liveQuery(
    db.tableUpdates(
      TableUpdateQuery.onAllTables([
        db.completions,
        db.coinLedger,
        db.journal,
        db.focusSessions,
        db.tasks,
      ]),
    ),
    () async => load(stats, await farm.today()),
  );
}

final todaySummaryProvider = StreamProvider<DaySummary>(
  (ref) => _live(ref, (s, today) => s.summary(today)),
);

final weekProvider = StreamProvider<List<DaySummary>>(
  (ref) => _live(ref, (s, today) => s.week(today)),
);

/// (year, month) -> that month's day summaries up to today.
final monthProvider = StreamProvider.family<List<DaySummary>, (int, int)>(
  (ref, ym) => _live(ref, (s, today) => s.month(ym.$1, ym.$2, today)),
);

final todayProvider = FutureProvider<FarmDay>(
  (ref) => ref.watch(farmServiceProvider).today(),
);

const moodLabels = ['Rough', 'Meh', 'Okay', 'Good', 'Great'];

String formatDay(FarmDay d) {
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${wd[d.weekday - 1]} ${d.day} ${mo[d.month - 1]}';
}

String autoLogLine(DaySummary s) =>
    '${s.harvestedCount} harvested · ${s.focusMinutes} focus min · ${s.coins} coins';
