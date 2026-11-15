import 'package:cultiva/domain/farm_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FarmDay.of (reset hour)', () {
    test('before 4am belongs to the previous day', () {
      expect(FarmDay.of(DateTime(2026, 11, 17, 3, 59)), FarmDay(2026, 11, 16));
      expect(FarmDay.of(DateTime(2026, 11, 17, 0, 30)), FarmDay(2026, 11, 16));
    });

    test('from 4am it is the calendar day', () {
      expect(FarmDay.of(DateTime(2026, 11, 17, 4)), FarmDay(2026, 11, 17));
      expect(FarmDay.of(DateTime(2026, 11, 17, 23, 59)), FarmDay(2026, 11, 17));
    });

    test('custom reset hour and month/year boundaries', () {
      expect(
        FarmDay.of(DateTime(2026, 12, 1, 5), resetHour: 6),
        FarmDay(2026, 11, 30),
      );
      expect(FarmDay.of(DateTime(2027, 1, 1, 1)), FarmDay(2026, 12, 31));
      expect(
        FarmDay.of(DateTime(2026, 11, 17, 0, 1), resetHour: 0),
        FarmDay(2026, 11, 17),
      );
    });
  });

  test('keys round-trip and sort', () {
    final d = FarmDay(2026, 3, 7);
    expect(d.key, '2026-03-07');
    expect(FarmDay.parse('2026-03-07'), d);
    expect(FarmDay(2026, 3, 7) < FarmDay(2026, 3, 8), isTrue);
    expect(FarmDay(2026, 2, 28).addDays(1), FarmDay(2026, 3, 1));
    expect(FarmDay(2026, 3, 1).daysSince(FarmDay(2026, 2, 27)), 2);
  });

  test('weekday is 1=Mon..7=Sun', () {
    expect(FarmDay(2026, 11, 16).weekday, DateTime.monday);
    expect(FarmDay(2026, 11, 22).weekday, DateTime.sunday);
  });

  test('parse rejects junk', () {
    expect(() => FarmDay.parse('2026-13-01'), throwsFormatException);
    expect(() => FarmDay.parse('yesterday'), throwsFormatException);
  });
}
