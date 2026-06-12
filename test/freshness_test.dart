import 'package:flutter_test/flutter_test.dart';
import 'package:link_decay_app/utils/freshness.dart';

void main() {
  group('computeFreshness tests', () {
    test('A newly created link should have a freshness score of 1.0', () {
      final now = DateTime.now();
      final score = computeFreshness(
        createdAt: now,
        now: now,
        halfLifeDays: 7.0,
      );
      expect(score, closeTo(1.0, 0.001));
    });

    test('Freshness score decays exponentially correctly', () {
      final createdAt = DateTime.now();

      // Exactly 7 days later with 7 days half-life should be exactly 0.5
      final now7DaysLater = createdAt.add(const Duration(days: 7));
      final score7 = computeFreshness(
        createdAt: createdAt,
        now: now7DaysLater,
        halfLifeDays: 7.0,
        decayCurveType: 'exponential',
      );
      expect(score7, closeTo(0.5, 0.001));

      // Exactly 14 days later with 7 days half-life should be exactly 0.25
      final now14DaysLater = createdAt.add(const Duration(days: 14));
      final score14 = computeFreshness(
        createdAt: createdAt,
        now: now14DaysLater,
        halfLifeDays: 7.0,
        decayCurveType: 'exponential',
      );
      expect(score14, closeTo(0.25, 0.001));
    });

    test('Freshness score decays linearly correctly', () {
      final createdAt = DateTime.now();

      // In linear decay, lifespan is halfLifeDays * 2 (e.g. 14 days)
      // Exactly 7 days later with 7 days half-life should be 1.0 - (7 / 14) = 0.5
      final now7DaysLater = createdAt.add(const Duration(days: 7));
      final score7 = computeFreshness(
        createdAt: createdAt,
        now: now7DaysLater,
        halfLifeDays: 7.0,
        decayCurveType: 'linear',
      );
      expect(score7, closeTo(0.5, 0.001));

      // Exactly 10.5 days later with 7 days half-life should be 1.0 - (10.5 / 14) = 0.25
      final now105DaysLater = createdAt.add(
        const Duration(hours: 252),
      ); // 10.5 days
      final score105 = computeFreshness(
        createdAt: createdAt,
        now: now105DaysLater,
        halfLifeDays: 7.0,
        decayCurveType: 'linear',
      );
      expect(score105, closeTo(0.25, 0.001));

      // Exactly 15 days later (beyond 14 days lifespan) should clamp to 0.0
      final now15DaysLater = createdAt.add(const Duration(days: 15));
      final score15 = computeFreshness(
        createdAt: createdAt,
        now: now15DaysLater,
        halfLifeDays: 7.0,
        decayCurveType: 'linear',
      );
      expect(score15, 0.0);
    });

    test('Active snooze pauses decay and freezes the freshness score', () {
      final createdAt = DateTime.now();

      // Let it decay for 3 days without snooze. Freshness should be 0.5 ^ (3/7) = ~0.743
      final now3DaysLater = createdAt.add(const Duration(days: 3));
      final scoreBeforeSnooze = computeFreshness(
        createdAt: createdAt,
        now: now3DaysLater,
        halfLifeDays: 7.0,
      );

      // Now snooze it for 2 days. Check freshness 1 day into the snooze period (now4DaysLater).
      // The score should remain exactly what it was at day 3 (~0.743).
      final snoozedUntil = now3DaysLater.add(const Duration(days: 2));
      final now4DaysLater = now3DaysLater.add(
        const Duration(days: 1),
      ); // 1 day into snooze

      final scoreDuringSnooze = computeFreshness(
        createdAt: createdAt,
        now: now4DaysLater,
        halfLifeDays: 7.0,
        snoozedUntil: snoozedUntil,
      );

      expect(scoreDuringSnooze, closeTo(scoreBeforeSnooze, 0.001));
    });

    test('Expired snooze does not freeze decay anymore', () {
      final createdAt = DateTime.now();
      final now3DaysLater = createdAt.add(const Duration(days: 3));
      final snoozedUntil = now3DaysLater.add(
        const Duration(days: 2),
      ); // Snoozed until day 5

      // Check freshness at day 6 (now6DaysLater) which is 1 day after snooze expired.
      // Since snooze is expired, decay catches up to raw age (6 days).
      // Expected score: 0.5 ^ (6/7) = ~0.552
      final now6DaysLater = now3DaysLater.add(
        const Duration(days: 3),
      ); // 3 days after day 3 = day 6

      final scoreAfterSnooze = computeFreshness(
        createdAt: createdAt,
        now: now6DaysLater,
        halfLifeDays: 7.0,
        snoozedUntil: snoozedUntil,
      );

      final expectedScore = computeFreshness(
        createdAt: createdAt,
        now: now6DaysLater,
        halfLifeDays: 7.0,
      );

      expect(scoreAfterSnooze, closeTo(expectedScore, 0.001));
    });

    test('Zero or negative half-life handles boundary correctly', () {
      final createdAt = DateTime.now();
      final now = createdAt.add(const Duration(days: 1));

      final scoreZero = computeFreshness(
        createdAt: createdAt,
        now: now,
        halfLifeDays: 0.0,
      );
      expect(scoreZero, 0.0);

      final scoreNegative = computeFreshness(
        createdAt: createdAt,
        now: now,
        halfLifeDays: -5.0,
      );
      expect(scoreNegative, 0.0);
    });
  });
}
