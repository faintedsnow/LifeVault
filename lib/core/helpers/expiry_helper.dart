import '../enums/expiry_status.dart';

/// Pure helper that classifies a nullable expiry date.
///
/// Accepts an optional [now] parameter for deterministic testing
/// (avoids flaky tests caused by real-time clock drift).
///
/// Edge-case behaviour:
/// - Same-day expiry (today at any time) → [ExpiryStatus.expiringSoon],
///   giving the user the full calendar day to act.
/// - Midnight boundary: comparison uses calendar dates, not timestamps,
///   so timezone offset does not cause a document to flip status
///   mid-day when the user hasn't crossed midnight.
///
/// ```
/// Timeline visualisation
/// ──────┬──────────────────────────┬───────────────
///     today                   today + 30d
///  expired ◄──┤  expiringSoon  ├──► valid
/// ```
ExpiryStatus resolveExpiryStatus(DateTime? expiryAt, {DateTime? now}) {
  if (expiryAt == null) return ExpiryStatus.noExpiry;

  final today = _toDateOnly(now ?? DateTime.now());
  final expiryDate = _toDateOnly(expiryAt);

  // Strictly in the past — already expired.
  if (expiryDate.isBefore(today)) return ExpiryStatus.expired;

  // Within the next 30 calendar days (inclusive of today).
  final threshold = today.add(const Duration(days: 30));
  if (expiryDate.isBefore(threshold) ||
      expiryDate.isAtSameMomentAs(threshold)) {
    return ExpiryStatus.expiringSoon;
  }

  return ExpiryStatus.valid;
}

/// Strips the time component so comparisons are date-only.
/// This avoids timezone-induced edge cases where a 23:59 expiry
/// could flip status depending on the hour the user opens the app.
DateTime _toDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
