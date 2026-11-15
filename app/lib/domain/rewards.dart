import 'dart:math';

import 'task.dart';

/// How a task was completed.
enum CompletionMethod {
  /// Timer ran to the end in Focus Mode.
  focus,

  /// "I already did it" for a timed task — logged without the timer.
  manual,

  /// Checked off (to-do / habit).
  check,
}

/// Why a ledger row exists. Stored by name; never rename existing values.
enum LedgerReason { harvest, fullBasket, unharvest, purchase, refund }

const kDailyCoinCap = 150;
const kFullBasketBonus = 20;
const kCheckCoins = 8;

/// Coins a harvest is worth before the daily cap.
int baseCoins(FarmTask task, CompletionMethod method) {
  if (task.kind == TaskKind.check) return kCheckCoins;
  final minutes = task.targetMinutes!;
  final tier = minutes < 15
      ? 5
      : minutes <= 60
      ? 12
      : 25;
  return method == CompletionMethod.manual ? tier ~/ 2 : tier;
}

final class Payout {
  const Payout(this.base, this.bonus);
  final int base;
  final int bonus;
  int get total => base + bonus;
}

/// Applies the daily cap to a harvest (and its Full Basket bonus, if any).
Payout payout({
  required int base,
  required int earnedToday,
  required bool completesFullBasket,
}) {
  var room = max(0, kDailyCoinCap - earnedToday);
  final b = min(base, room);
  room -= b;
  final bonus = completesFullBasket ? min(kFullBasketBonus, room) : 0;
  return Payout(b, bonus);
}

/// True when this harvest makes every Daily task due today harvested.
/// [harvestedIds] must already include the task being harvested now.
bool completesFullBasket({
  required Iterable<FarmTask> dueDaily,
  required Set<String> harvestedIds,
  required bool alreadyPaid,
}) {
  if (alreadyPaid) return false;
  final due = dueDaily.toList();
  return due.isNotEmpty && due.every((t) => harvestedIds.contains(t.id));
}
