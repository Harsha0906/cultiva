import 'dart:async';

/// Emits `load()` once, then again after [changes] fire — but a burst of
/// changes during a load collapses into ONE extra reload (never a queue).
///
/// Drift's `tableUpdates` fires once per write; seeding or a rollover can
/// make dozens of writes, and replaying a full reload for each made screens
/// lag by seconds. No timers, so widget tests settle normally.
Stream<T> liveQuery<T>(Stream<Object?> changes, Future<T> Function() load) {
  late final StreamController<T> out;
  StreamSubscription<Object?>? sub;
  var running = false;
  var dirty = false;
  var closed = false;

  Future<void> run() async {
    if (running) {
      dirty = true;
      return;
    }
    running = true;
    do {
      dirty = false;
      try {
        final value = await load();
        if (!closed) out.add(value);
      } catch (e, s) {
        if (!closed) out.addError(e, s);
      }
    } while (dirty && !closed);
    running = false;
  }

  out = StreamController<T>(
    onListen: () {
      unawaited(run());
      sub = changes.listen((_) => run());
    },
    onCancel: () async {
      closed = true;
      await sub?.cancel();
    },
  );
  return out.stream;
}
