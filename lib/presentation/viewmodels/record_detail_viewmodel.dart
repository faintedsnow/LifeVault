import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:lifevault/data/models/document_version.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/data/repositories/record_repository.dart';
import 'package:lifevault/data/repositories/version_repository.dart';

/// Manages state for the Record Detail screen.
///
/// Loads the full record + its version history and exposes
/// lifecycle actions: renew, set active, archive.
class RecordDetailViewModel extends ChangeNotifier {
  final RecordRepository _recordRepo;
  final VersionRepository _versionRepo;

  RecordDetailViewModel({
    RecordRepository? recordRepo,
    VersionRepository? versionRepo,
  }) : _recordRepo = recordRepo ?? RecordRepository(),
       _versionRepo = versionRepo ?? VersionRepository();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  RecordModel? _record;
  RecordModel? get record => _record;

  List<DocumentVersion> _versions = [];
  List<DocumentVersion> get versions => _versions;

  DocumentVersion? get activeVersion =>
      _versions.where((v) => v.status == 'active').firstOrNull;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  /// Loads the record and all its versions. Also auto-detects expired versions.
  Future<void> loadRecord(String recordId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Auto-mark expired versions first
      await _versionRepo.refreshExpiryStatuses(recordId);

      _record = await _recordRepo.getById(recordId);
      _versions = await _versionRepo.getVersionsForRecord(recordId);
    } catch (e) {
      _errorMessage = 'Failed to load record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Creates a new version, archiving the current active one.
  ///
  /// The new version starts with:
  /// - versionNumber = highestExisting + 1
  /// - status = 'active'
  /// - issueDate = today
  /// - expiryDate = null (user sets later)
  Future<bool> renewVersion() async {
    if (_record == null) return false;

    try {
      final current = activeVersion;

      // Archive the current active version if one exists
      if (current != null) {
        await _versionRepo.archiveVersion(current.id);
      }

      // Determine next version number
      final nextNumber = _versions.isNotEmpty
          ? _versions
                    .map((v) => v.versionNumber)
                    .reduce((a, b) => a > b ? a : b) +
                1
          : 1;

      final newVersion = DocumentVersion(
        id: const Uuid().v4(),
        recordId: _record!.id,
        versionNumber: nextNumber,
        issueDate: DateTime.now(),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _versionRepo.insert(newVersion);

      // Refresh the version list
      await loadRecord(_record!.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to renew: $e';
      notifyListeners();
      return false;
    }
  }

  /// Sets [versionId] as the active version and archives the rest.
  Future<bool> setActiveVersion(String versionId) async {
    if (_record == null) return false;

    try {
      await _versionRepo.setActive(versionId, _record!.id);
      await loadRecord(_record!.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to set active version: $e';
      notifyListeners();
      return false;
    }
  }
}
