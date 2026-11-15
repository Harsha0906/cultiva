import 'db.dart';

/// Session statuses stored in focus_sessions.status.
abstract final class FocusRowStatus {
  static const running = 'running';
  static const paused = 'paused';
  static const abandoned = 'abandoned';
  static const done = 'done';
}

/// How far past the plan a single running segment may go before we treat the
/// wall clock as untrustworthy.
const kForwardJumpGraceSec = 2 * 60 * 60;

/// Elapsed seconds for a session at [now], with the gentle clock guard:
/// a clock moved backwards counts the segment as 0, a huge forward jump is
/// capped at the plan. Returns (elapsedSec, clockLooksWrong).
(int, bool) focusElapsed(FocusSession s, DateTime now) {
  if (s.status != FocusRowStatus.running) {
    return (s.accumulatedSec.clamp(0, s.plannedSec), false);
  }
  final segment = now.difference(s.startedAt).inSeconds;
  if (segment < 0) return (s.accumulatedSec, true);
  if (segment > s.plannedSec + kForwardJumpGraceSec) {
    return (s.plannedSec, true);
  }
  final total = s.accumulatedSec + segment;
  return (total > s.plannedSec ? s.plannedSec : total, false);
}
