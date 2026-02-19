import 'package:lifevault/data/models/document_version.dart';

/// Data model representing a document identity in the local SQLite database.
///
/// In the versioned architecture (v2), expiry and notes live on
/// [DocumentVersion], not on the record itself. The optional
/// [activeVersion] field is populated by the repository via JOIN
/// for UI convenience — it is NOT persisted.
class RecordModel {
  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  /// The currently active version, loaded by the repository.
  /// Not stored in the `records` table.
  final DocumentVersion? activeVersion;

  const RecordModel({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
    this.activeVersion,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Converts this model into a Map suitable for SQLite insertion.
  ///
  /// - DateTime → int (millisecondsSinceEpoch)
  /// - bool    → int (0 / 1)
  /// - [activeVersion] is NOT included (it's a transient UI field).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'archived': archived ? 1 : 0,
    };
  }

  /// Reconstructs a [RecordModel] from a database row.
  ///
  /// If the row contains version columns (from a JOIN), the
  /// [activeVersion] is populated automatically.
  factory RecordModel.fromMap(Map<String, dynamic> map) {
    // Try to build activeVersion from JOIN columns prefixed with 'v_'.
    DocumentVersion? version;
    if (map['v_id'] != null) {
      version = DocumentVersion(
        id: map['v_id'] as String,
        recordId: map['id'] as String,
        versionNumber: map['v_version_number'] as int,
        issueDate: map['v_issue_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['v_issue_date'] as int)
            : null,
        expiryDate: map['v_expiry_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['v_expiry_date'] as int)
            : null,
        notes: map['v_notes'] as String?,
        metadataJson: map['v_metadata_json'] as String?,
        status: map['v_status'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['v_created_at'] as int,
        ),
      );
    }

    return RecordModel(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      archived: (map['archived'] as int) == 1,
      activeVersion: version,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// Creates a copy of this model with selectively overridden fields.
  RecordModel copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
    DocumentVersion? activeVersion,
  }) {
    return RecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      activeVersion: activeVersion ?? this.activeVersion,
    );
  }

  @override
  String toString() {
    return 'RecordModel(id: $id, title: $title, category: $category, '
        'archived: $archived, activeVersion: $activeVersion)';
  }
}
