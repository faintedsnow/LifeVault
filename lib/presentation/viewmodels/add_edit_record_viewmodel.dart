import 'package:flutter/foundation.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/data/models/document_version.dart';
import 'package:lifevault/data/repositories/record_repository.dart';
import 'package:lifevault/data/repositories/version_repository.dart';
import 'package:uuid/uuid.dart';

/// ViewModel that manages the Add / Edit record form.
///
/// On create: inserts a new record AND auto-creates version 1.
/// On edit: updates the record identity AND its active version.
class AddEditRecordViewModel extends ChangeNotifier {
  final RecordRepository _recordRepo;
  final VersionRepository _versionRepo;
  static const _uuid = Uuid();

  AddEditRecordViewModel({
    RecordRepository? recordRepository,
    VersionRepository? versionRepository,
    RecordModel? existingRecord,
  }) : _recordRepo = recordRepository ?? RecordRepository(),
       _versionRepo = versionRepository ?? VersionRepository(),
       _existingRecord = existingRecord,
       _title = existingRecord?.title ?? '',
       _category = existingRecord?.category ?? '',
       _notes = existingRecord?.activeVersion?.notes ?? '',
       _expiryAt = existingRecord?.activeVersion?.expiryDate,
       _issueDate = existingRecord?.activeVersion?.issueDate;

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

  DateTime? _issueDate;
  DateTime? get issueDate => _issueDate;
  set issueDate(DateTime? value) {
    _issueDate = value;
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

  /// Validates, then inserts or updates the record + version.
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
        final existing = _existingRecord!;
        // Update record identity
        final updated = existing.copyWith(
          title: _title.trim(),
          category: _category,
          updatedAt: now,
        );
        await _recordRepo.update(updated);

        // Update the active version
        final existingVersion = existing.activeVersion;
        if (existingVersion != null) {
          final updatedVersion = existingVersion.copyWith(
            expiryDate: _expiryAt,
            issueDate: _issueDate,
            notes: _notes.trim().isEmpty ? null : _notes.trim(),
          );
          await _versionRepo.update(updatedVersion);
        }
      } else {
        // Create new record
        final recordId = _uuid.v4();
        final newRecord = RecordModel(
          id: recordId,
          title: _title.trim(),
          category: _category,
          createdAt: now,
          updatedAt: now,
        );
        await _recordRepo.insert(newRecord);

        // Auto-create version 1
        final version = DocumentVersion(
          id: _uuid.v4(),
          recordId: recordId,
          versionNumber: 1,
          issueDate: _issueDate ?? now,
          expiryDate: _expiryAt,
          notes: _notes.trim().isEmpty ? null : _notes.trim(),
          status: 'active',
          createdAt: now,
        );
        await _versionRepo.insert(version);
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
