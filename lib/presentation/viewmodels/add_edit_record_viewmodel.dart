import 'package:flutter/foundation.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/data/repositories/record_repository.dart';
import 'package:uuid/uuid.dart';

/// ViewModel that manages the Add / Edit record form.
///
/// Holds mutable form state and exposes a single [save] method that
/// either inserts a new record or updates an existing one.
class AddEditRecordViewModel extends ChangeNotifier {
  final RecordRepository _repository;
  static const _uuid = Uuid();

  AddEditRecordViewModel({
    RecordRepository? repository,
    RecordModel? existingRecord,
  }) : _repository = repository ?? RecordRepository(),
       _existingRecord = existingRecord,
       _title = existingRecord?.title ?? '',
       _category = existingRecord?.category ?? '',
       _notes = existingRecord?.notes ?? '',
       _expiryAt = existingRecord?.expiryAt;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  final RecordModel? _existingRecord;

  /// Whether we are editing an existing record vs creating a new one.
  bool get isEditing => _existingRecord != null;

  String _title;
  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  String _category;
  String get category => _category;
  set category(String value) {
    _category = value;
    notifyListeners();
  }

  String _notes;
  String get notes => _notes;
  set notes(String value) {
    _notes = value;
    notifyListeners();
  }

  DateTime? _expiryAt;
  DateTime? get expiryAt => _expiryAt;
  set expiryAt(DateTime? value) {
    _expiryAt = value;
    notifyListeners();
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Predefined categories
  // ---------------------------------------------------------------------------

  static const List<String> categories = [
    'ID & Personal',
    'Financial',
    'Medical',
    'Insurance',
    'Education',
    'Travel',
    'Legal',
    'Other',
  ];

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Returns a user-facing error string, or `null` if the form is valid.
  String? validate() {
    if (_title.trim().isEmpty) return 'Title is required.';
    if (_category.trim().isEmpty) return 'Please select a category.';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  /// Validates, then inserts or updates the record.
  /// Returns `true` on success so the screen can pop.
  Future<bool> save() async {
    final validationError = validate();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      if (isEditing) {
        final updated = _existingRecord!.copyWith(
          title: _title.trim(),
          category: _category,
          notes: _notes.trim().isEmpty ? null : _notes.trim(),
          expiryAt: _expiryAt,
          updatedAt: now,
        );
        await _repository.update(updated);
      } else {
        final newRecord = RecordModel(
          id: _uuid.v4(),
          title: _title.trim(),
          category: _category,
          notes: _notes.trim().isEmpty ? null : _notes.trim(),
          expiryAt: _expiryAt,
          createdAt: now,
          updatedAt: now,
        );
        await _repository.insert(newRecord);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
