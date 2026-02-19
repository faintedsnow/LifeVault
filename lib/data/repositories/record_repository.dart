import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/services/database/database_service.dart';
import 'package:lifevault/services/database/schema.dart';

/// Single source of truth for all [RecordModel] persistence operations.
///
/// Sits between the ViewModel layer and [DatabaseService], ensuring
/// that ViewModels never touch raw SQL directly.
///
/// Queries LEFT JOIN with `document_versions` to populate
/// [RecordModel.activeVersion] for UI display.
class RecordRepository {
  final DatabaseService _dbService;

  RecordRepository({DatabaseService? dbService})
    : _dbService = dbService ?? DatabaseService();

  // ---------------------------------------------------------------------------
  // SQL helpers
  // ---------------------------------------------------------------------------

  /// SELECT that LEFT JOINs records with their active version.
  static const String _selectWithActiveVersion =
      '''
    SELECT
      r.id, r.title, r.category, r.archived, r.created_at, r.updated_at,
      v.id              AS v_id,
      v.version_number  AS v_version_number,
      v.issue_date      AS v_issue_date,
      v.expiry_date     AS v_expiry_date,
      v.notes           AS v_notes,
      v.metadata_json   AS v_metadata_json,
      v.status          AS v_status,
      v.created_at      AS v_created_at
    FROM ${DatabaseSchema.recordsTable} r
    LEFT JOIN ${DatabaseSchema.versionsTable} v
      ON v.record_id = r.id AND v.status = 'active'
  ''';

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all non-archived records with their active version populated.
  Future<List<RecordModel>> getActiveRecords() async {
    final db = await _dbService.database;
    final rows = await db.rawQuery(
      '$_selectWithActiveVersion WHERE r.archived = 0 ORDER BY r.created_at DESC',
    );
    return rows.map(RecordModel.fromMap).toList();
  }

  /// Returns a single record by [id] with active version, or `null`.
  Future<RecordModel?> getById(String id) async {
    final db = await _dbService.database;
    final rows = await db.rawQuery(
      '$_selectWithActiveVersion WHERE r.id = ? LIMIT 1',
      [id],
    );
    if (rows.isEmpty) return null;
    return RecordModel.fromMap(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Inserts a new record. Returns the number of rows affected.
  Future<int> insert(RecordModel record) async {
    final db = await _dbService.database;
    return await db.insert(DatabaseSchema.recordsTable, record.toMap());
  }

  /// Updates an existing record matched by its [RecordModel.id].
  Future<int> update(RecordModel record) async {
    final db = await _dbService.database;
    return await db.update(
      DatabaseSchema.recordsTable,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Permanently deletes a record by [id].
  /// Cascade will also delete associated versions.
  Future<int> delete(String id) async {
    final db = await _dbService.database;
    return await db.delete(
      DatabaseSchema.recordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
