import 'dart:async';

import 'package:cultiva/core/live_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a burst of changes during a load causes one extra reload', () async {
    final changes = StreamController<void>();
    var loads = 0;
    final gate = <Completer<void>>[];
    Future<int> load() async {
      loads++;
      final c = Completer<void>();
      gate.add(c);
      await c.future;
      return loads;
    }

    final values = <int>[];
    final sub = liveQuery(changes.stream, load).listen(values.add);
    await Future<void>.delayed(Duration.zero);
    expect(loads, 1); // initial load in flight
    for (var i = 0; i < 30; i++) {
      changes.add(null); // burst while loading
    }
    gate.removeAt(0).complete();
    await Future<void>.delayed(Duration.zero);
    expect(loads, 2); // exactly one catch-up reload
    gate.removeAt(0).complete();
    await Future<void>.delayed(Duration.zero);
    expect(values, [1, 2]);
    await sub.cancel();
    await changes.close();
  });

  test('errors are delivered, later changes still reload', () async {
    final changes = StreamController<void>();
    var n = 0;
    final events = <Object>[];
    final sub = liveQuery(changes.stream, () async {
      n++;
      if (n == 1) throw StateError('boom');
      return n;
    }).listen(events.add, onError: events.add);
    await Future<void>.delayed(Duration.zero);
    changes.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(events.first, isA<StateError>());
    expect(events.last, 2);
    await sub.cancel();
    await changes.close();
  });
}
