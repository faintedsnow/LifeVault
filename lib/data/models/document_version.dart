import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/core/helpers/expiry_helper.dart';

/// Represents a single lifecycle version of a document record.
///
/// Each [DocumentVersion] belongs to exactly one record (via [recordId])
/// and holds the expiry/issue dates that previously lived on the record.
///
/// Status values: `active`, `expired`, `archived`.
class DocumentVersion {
  final String id;
  final String recordId;
  final int versionNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? notes;
  final String? metadataJson;
  final String status; // 'active' | 'expired' | 'archived'
  final DateTime createdAt;

  const DocumentVersion({
    required this.id,
    required this.recordId,
    required this.versionNumber,
    this.issueDate,
    this.expiryDate,
    this.notes,
    this.metadataJson,
    required this.status,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Converts this model into a Map suitable for SQLite insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_id': recordId,
      'version_number': versionNumber,
      'issue_date': issueDate?.millisecondsSinceEpoch,
      'expiry_date': expiryDate?.millisecondsSinceEpoch,
      'notes': notes,
      'metadata_json': metadataJson,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Reconstructs a [DocumentVersion] from a database row.
  factory DocumentVersion.fromMap(Map<String, dynamic> map) {
    return DocumentVersion(
      id: map['id'] as String,
      recordId: map['record_id'] as String,
      versionNumber: map['version_number'] as int,
      issueDate: map['issue_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['issue_date'] as int)
          : null,
      expiryDate: map['expiry_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiry_date'] as int)
          : null,
      notes: map['notes'] as String?,
      metadataJson: map['metadata_json'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// Creates a copy with selectively overridden fields.
  DocumentVersion copyWith({
    String? id,
    String? recordId,
    int? versionNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
    String? metadataJson,
    String? status,
    DateTime? createdAt,
  }) {
    return DocumentVersion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      versionNumber: versionNumber ?? this.versionNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      metadataJson: metadataJson ?? this.metadataJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Classifies this version's expiry state using [resolveExpiryStatus].
  ExpiryStatus get expiryStatus => resolveExpiryStatus(expiryDate);

  /// True when [expiryStatus] is [ExpiryStatus.expired].
  bool get isExpired => expiryStatus == ExpiryStatus.expired;

  /// True when this version is the currently active one.
  bool get isActive => status == 'active';

  @override
  String toString() {
    return 'DocumentVersion(id: $id, recordId: $recordId, '
        'v$versionNumber, status: $status, expiryDate: $expiryDate)';
  }
}
