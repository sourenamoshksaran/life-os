/// Single source of truth for the `localDate` correlation key used across
/// every daily-loggable entity (Session, NutritionEntry, SleepLog, WaterLog,
/// MedicineLog, SupplementLog, JournalEntry, Task).
///
/// Day boundary rule: a new local day begins at 00:00 local device time.
/// This class is the ONLY place that rule is implemented — no feature
/// module computes its own day boundary.
///
/// See docs/rfc/RFC-005_Core_Session_Engine.md §7 and
/// docs/04_Database_Schema.md "Recurrence Calendar Rule".
class DateManager {
  const DateManager();

  /// Returns the `YYYY-MM-DD` local-date string for [dateTime], defaulting
  /// to now. Solar Hijri conversion (display-only) happens separately in
  /// the presentation layer via `formatForDisplay` — this method always
  /// returns a Gregorian ISO date, since storage and recurrence math are
  /// always Gregorian regardless of the user's display calendar preference.
  String localDateFor(DateTime dateTime) {
    final local = dateTime.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String today() => localDateFor(DateTime.now());

  /// True if [a] and [b] fall on the same local day.
  bool isSameLocalDay(DateTime a, DateTime b) =>
      localDateFor(a) == localDateFor(b);
}
