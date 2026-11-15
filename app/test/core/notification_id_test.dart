import 'package:cultiva/core/notifications.dart';
import 'package:cultiva/domain/farm_day.dart';
import 'package:cultiva/domain/task.dart';
import 'package:flutter_test/flutter_test.dart';

FarmTask _task(String id) => FarmTask(
  id: id,
  title: 'Read',
  plot: PlotKind.daily,
  kind: TaskKind.timed,
  targetMinutes: 30,
  repeat: Weekdays.everyDay,
  crop: 'pepper',
  slot: 0,
  createdDay: FarmDay(2026, 11, 16),
);

void main() {
  test('notification id is a fixed function of the task id', () {
    // FNV-1a of "a" (0xe40c292c) masked to 31 bits: same value on every run.
    expect(notificationIdFor(_task('a')), 0x640c292c);
    final id = notificationIdFor(_task('3f2b8c1e-uuid'));
    expect(id, notificationIdFor(_task('3f2b8c1e-uuid')));
    expect(id, isNonNegative);
    expect(id, isNot(kDailyReminderId));
  });
}
