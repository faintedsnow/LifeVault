import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/services/database/database_service.dart';
import 'package:lifevault/services/database/schema.dart';

/// Single source of truth for all [RecordModel] persistence operations.
///
/// Sits between the ViewModel layer and [DatabaseService], ensuring
/// that ViewModels never touch raw SQL directly.
class RecordRepository {
  final DatabaseService _dbService;

  RecordRepository({DatabaseService? dbService})
    : _dbService = dbService ?? DatabaseService();

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Returns all non-archived records, ordered by most-recently created first.
  Future<List<RecordModel>> getActiveRecords() async {
    final db = await _dbService.database;
    final rows = await db.query(
      DatabaseSchema.tableName,
      where: 'archived = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    return rows.map(RecordModel.fromMap).toList();
  }

  /// Returns a single record by [id], or `null` if not found.
  Future<RecordModel?> getById(String id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      DatabaseSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
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
    return await db.insert(DatabaseSchema.tableName, record.toMap());
  }

  /// Updates an existing record matched by its [RecordModel.id].
  Future<int> update(RecordModel record) async {
    final db = await _dbService.database;
    return await db.update(
      DatabaseSchema.tableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Permanently deletes a record by [id].
  Future<int> delete(String id) async {
    final db = await _dbService.database;
    return await db.delete(
      DatabaseSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
