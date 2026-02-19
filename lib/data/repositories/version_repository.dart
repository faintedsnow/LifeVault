import 'package:lifevault/data/models/document_version.dart';
import 'package:lifevault/services/database/database_service.dart';
import 'package:lifevault/services/database/schema.dart';

/// Handles persistence for [DocumentVersion] records.
class VersionRepository {
  final DatabaseService _dbService;

  VersionRepository({DatabaseService? dbService})
    : _dbService = dbService ?? DatabaseService();

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all versions for a record, ordered by version_number DESC.
  Future<List<DocumentVersion>> getVersionsForRecord(String recordId) async {
    final db = await _dbService.database;
    final rows = await db.query(
      DatabaseSchema.versionsTable,
      where: 'record_id = ?',
      whereArgs: [recordId],
      orderBy: 'version_number DESC',
    );
    return rows.map(DocumentVersion.fromMap).toList();
  }

  /// Returns the active version for a record, or `null` if none exists.
  Future<DocumentVersion?> getActiveVersion(String recordId) async {
    final db = await _dbService.database;
    final rows = await db.query(
      DatabaseSchema.versionsTable,
      where: 'record_id = ? AND status = ?',
      whereArgs: [recordId, 'active'],
      orderBy: 'version_number DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DocumentVersion.fromMap(rows.first);
  }

  /// Returns a single version by its [id].
  Future<DocumentVersion?> getById(String id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      DatabaseSchema.versionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DocumentVersion.fromMap(rows.first);
  }

  /// Returns the count of versions for a given record.
  Future<int> getVersionCount(String recordId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.versionsTable} WHERE record_id = ?',
      [recordId],
    );
    return result.first['count'] as int;
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Inserts a new version.
  Future<int> insert(DocumentVersion version) async {
    final db = await _dbService.database;
    return await db.insert(DatabaseSchema.versionsTable, version.toMap());
  }

  /// Updates an existing version matched by its [DocumentVersion.id].
  Future<int> update(DocumentVersion version) async {
    final db = await _dbService.database;
    return await db.update(
      DatabaseSchema.versionsTable,
      version.toMap(),
      where: 'id = ?',
      whereArgs: [version.id],
    );
  }

  /// Permanently deletes a version by [id].
  Future<int> delete(String id) async {
    final db = await _dbService.database;
    return await db.delete(
      DatabaseSchema.versionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle Helpers
  // ---------------------------------------------------------------------------

  /// Scans all active versions for [recordId] and sets their status to
  /// `'expired'` if the expiry date is in the past.
  Future<int> refreshExpiryStatuses(String recordId) async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.rawUpdate(
      '''
      UPDATE ${DatabaseSchema.versionsTable}
      SET status = 'expired'
      WHERE record_id = ?
        AND status = 'active'
        AND expiry_date IS NOT NULL
        AND expiry_date < ?
    ''',
      [recordId, now],
    );
  }

  /// Sets the status of a version to `'archived'`.
  Future<int> archiveVersion(String id) async {
    final db = await _dbService.database;
    return await db.update(
      DatabaseSchema.versionsTable,
      {'status': 'archived'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Sets [versionId] as the active version for its record, deactivating
  /// any other active version for the same record.
  Future<void> setActive(String versionId, String recordId) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      // Deactivate current active version(s)
      await txn.rawUpdate(
        '''
        UPDATE ${DatabaseSchema.versionsTable}
        SET status = 'archived'
        WHERE record_id = ? AND status = 'active'
      ''',
        [recordId],
      );
      // Activate the chosen version
      await txn.update(
        DatabaseSchema.versionsTable,
        {'status': 'active'},
        where: 'id = ?',
        whereArgs: [versionId],
      );
    });
  }
}
