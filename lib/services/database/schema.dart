/// Centralizes all raw SQL definitions.
///
/// Keeping SQL strings here (instead of inline) makes schema changes
/// easy to locate and review during migrations.
class DatabaseSchema {
  DatabaseSchema._(); // prevent instantiation

  static const String recordsTable = 'records';
  static const String versionsTable = 'document_versions';

  // ---------------------------------------------------------------------------
  // V2 Schema (Current) — records no longer hold expiry/notes
  // ---------------------------------------------------------------------------

  /// Version-2 creation script for the `records` table.
  ///
  /// Design notes:
  /// - `id` is a client-generated UUID (TEXT) — safe for offline-first.
  /// - `expiry_at` and `notes` have been moved to `document_versions`.
  /// - All timestamps are INTEGER (millisecondsSinceEpoch).
  /// - `archived` uses INTEGER 0/1 (SQLite has no native boolean).
  static const String createRecordsTable =
      '''
    CREATE TABLE $recordsTable (
      id         TEXT PRIMARY KEY,
      title      TEXT    NOT NULL,
      category   TEXT    NOT NULL,
      archived   INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  /// Creation script for the `document_versions` table.
  ///
  /// Each version is a lifecycle instance of a record.
  /// `status` is one of: 'active', 'expired', 'archived'.
  static const String createDocumentVersionsTable =
      '''
    CREATE TABLE $versionsTable (
      id              TEXT PRIMARY KEY,
      record_id       TEXT    NOT NULL,
      version_number  INTEGER NOT NULL,
      issue_date      INTEGER,
      expiry_date     INTEGER,
      notes           TEXT,
      metadata_json   TEXT,
      status          TEXT    NOT NULL DEFAULT 'active',
      created_at      INTEGER NOT NULL,
      FOREIGN KEY (record_id) REFERENCES $recordsTable (id) ON DELETE CASCADE
    )
  ''';

  /// Index for fast version lookups by record.
  static const String createVersionRecordIndex =
      '''
    CREATE INDEX idx_versions_record_id ON $versionsTable (record_id)
  ''';

  // ---------------------------------------------------------------------------
  // V1 → V2 Migration SQL
  // ---------------------------------------------------------------------------

  /// Step 1: Create the versions table (uses [createDocumentVersionsTable]).

  /// Step 2: Migrate existing records' expiry_at + notes into version rows.
  static const String migrateExpiryToVersions =
      '''
    INSERT INTO $versionsTable (id, record_id, version_number, issue_date, expiry_date, notes, status, created_at)
    SELECT
      id || '_v1',
      id,
      1,
      created_at,
      expiry_at,
      notes,
      CASE WHEN expiry_at IS NOT NULL AND expiry_at < strftime('%s','now') * 1000
           THEN 'expired' ELSE 'active' END,
      created_at
    FROM records
  ''';

  /// Step 3: Rebuild the records table without expiry_at and notes.
  static const String createRecordsTableTemp = '''
    CREATE TABLE records_new (
      id         TEXT PRIMARY KEY,
      title      TEXT    NOT NULL,
      category   TEXT    NOT NULL,
      archived   INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  static const String copyRecordsToNew = '''
    INSERT INTO records_new (id, title, category, archived, created_at, updated_at)
    SELECT id, title, category, archived, created_at, updated_at FROM records
  ''';

  static const String dropOldRecordsTable = 'DROP TABLE records';

  static const String renameNewRecordsTable =
      'ALTER TABLE records_new RENAME TO records';
}
