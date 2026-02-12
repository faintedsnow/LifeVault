/// Centralizes all raw SQL definitions.
///
/// Keeping SQL strings here (instead of inline) makes schema changes
/// easy to locate and review during migrations.
class DatabaseSchema {
  DatabaseSchema._(); // prevent instantiation

  static const String tableName = 'records';

  /// Version-1 creation script for the `records` table.
  ///
  /// Design notes:
  /// - `id` is a client-generated UUID (TEXT) — safe for offline-first.
  /// - `expiry_at` is nullable because some documents never expire.
  /// - All timestamps are INTEGER (millisecondsSinceEpoch) for reliable
  ///   sorting and cross-platform consistency.
  /// - `archived` uses INTEGER 0/1 (SQLite has no native boolean).
  static const String createRecordsTable =
      '''
    CREATE TABLE $tableName (
      id         TEXT PRIMARY KEY,
      title      TEXT    NOT NULL,
      category   TEXT    NOT NULL,
      notes      TEXT,
      expiry_at  INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      archived   INTEGER NOT NULL DEFAULT 0
    )
  ''';
}
