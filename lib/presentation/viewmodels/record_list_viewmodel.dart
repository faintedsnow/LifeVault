import 'package:flutter/foundation.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/data/repositories/record_repository.dart';

/// ViewModel for the Record List screen.
///
/// Uses [ChangeNotifier] so the UI rebuilds only when the list changes.
/// Filters out archived records at the repository level.
class RecordListViewModel extends ChangeNotifier {
  final RecordRepository _repository;

  RecordListViewModel({RecordRepository? repository})
    : _repository = repository ?? RecordRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<RecordModel> _records = [];
  List<RecordModel> get records => List.unmodifiable(_records);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fetches all non-archived records from the local database.
  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getActiveRecords();
    } catch (e) {
      _errorMessage = 'Failed to load records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Soft-deletes a record by setting `archived = true`.
  Future<void> archiveRecord(RecordModel record) async {
    try {
      final updated = record.copyWith(
        archived: true,
        updatedAt: DateTime.now(),
      );
      await _repository.update(updated);
      await loadRecords(); // refresh list
    } catch (e) {
      _errorMessage = 'Failed to archive record: $e';
      notifyListeners();
    }
  }

  /// Permanently removes a record.
  Future<void> deleteRecord(String id) async {
    try {
      await _repository.delete(id);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Failed to delete record: $e';
      notifyListeners();
    }
  }
}
