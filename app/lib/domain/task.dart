import 'farm_day.dart';

/// Plot A is Daily (timed); Plot B is To-Do & Habits (check).
enum PlotKind { daily, todo }

enum TaskKind { timed, check }

/// Repeat days as a bitmask, Monday = bit 0 … Sunday = bit 6. Empty = one-off to-do.
extension type const Weekdays(int mask) {
  static const none = Weekdays(0);
  static const everyDay = Weekdays(0x7f);

  static Weekdays of(Iterable<int> weekdays) =>
      Weekdays(weekdays.fold(0, (m, d) => m | (1 << (d - 1))));

  bool has(int weekday) => mask & (1 << (weekday - 1)) != 0;
  bool get isEmpty => mask == 0;
  List<int> get days => [
    for (var d = DateTime.monday; d <= DateTime.sunday; d++)
      if (has(d)) d,
  ];
}

const kMinTargetMinutes = 1;
const kMaxTargetMinutes = 240;

/// A task planted in a plot slot. Immutable; persisted by TaskRepository.
final class FarmTask {
  const FarmTask({
    required this.id,
    required this.title,
    required this.plot,
    required this.kind,
    required this.repeat,
    required this.crop,
    required this.slot,
    required this.createdDay,
    this.targetMinutes,
    this.archived = false,
  });

  final String id;
  final String title;
  final PlotKind plot;
  final TaskKind kind;
  final int? targetMinutes;
  final Weekdays repeat;
  final String crop;
  final int slot;
  final FarmDay createdDay;
  final bool archived;

  /// A one-off to-do (no repeat days). Habits and dailies repeat.
  bool get isTodo => repeat.isEmpty;

  /// Validation problems; empty when the task is well-formed.
  List<String> get problems => [
    if (title.trim().isEmpty) 'Give the task a name.',
    if (slot < 0 || slot > 5) 'Slot must be 0–5.',
    if (plot == PlotKind.daily) ...[
      if (kind != TaskKind.timed) 'Daily tasks use a timer.',
      if (targetMinutes == null ||
          targetMinutes! < kMinTargetMinutes ||
          targetMinutes! > kMaxTargetMinutes)
        'Pick a duration between $kMinTargetMinutes and $kMaxTargetMinutes minutes.',
      if (repeat.isEmpty) 'Pick at least one day.',
    ],
    if (plot == PlotKind.todo) ...[
      if (kind != TaskKind.check) 'To-dos and habits are checked off.',
      if (targetMinutes != null) 'To-dos and habits have no duration.',
    ],
  ];

  FarmTask copyWith({
    String? title,
    int? slot,
    int? targetMinutes,
    Weekdays? repeat,
    String? crop,
    bool? archived,
  }) => FarmTask(
    id: id,
    title: title ?? this.title,
    plot: plot,
    kind: kind,
    targetMinutes: targetMinutes ?? this.targetMinutes,
    repeat: repeat ?? this.repeat,
    crop: crop ?? this.crop,
    slot: slot ?? this.slot,
    createdDay: createdDay,
    archived: archived ?? this.archived,
  );
}
