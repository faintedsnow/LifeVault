import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/core/helpers/expiry_helper.dart';

/// Data model representing a single record in the local SQLite database.
///
/// All DateTime fields are stored as millisecondsSinceEpoch (INTEGER)
/// in the database for reliable sorting, comparison, and timezone safety.
class RecordModel {
  final String id;
  final String title;
  final String category;
  final String? notes;
  final DateTime? expiryAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  const RecordModel({
    required this.id,
    required this.title,
    required this.category,
    this.notes,
    this.expiryAt,
    required this.createdAt,
    required this.updatedAt,
    this.archived = false,
  });

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Converts this model into a Map suitable for SQLite insertion.
  ///
  /// - DateTime → int (millisecondsSinceEpoch)
  /// - bool    → int (0 / 1)
  /// - Nullable expiryAt is stored as null when absent.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'notes': notes,
      'expiry_at': expiryAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'archived': archived ? 1 : 0,
    };
  }

  /// Reconstructs a [RecordModel] from a database row.
  ///
  /// - int → DateTime (fromMillisecondsSinceEpoch)
  /// - int → bool (1 == true)
  /// - A null `expiry_at` value is safely handled.
  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      notes: map['notes'] as String?,
      expiryAt: map['expiry_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiry_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      archived: (map['archived'] as int) == 1,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// Creates a copy of this model with selectively overridden fields.
  /// Useful for immutable state updates in the ViewModel layer.
  RecordModel copyWith({
    String? id,
    String? title,
    String? category,
    String? notes,
    DateTime? expiryAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
  }) {
    return RecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      expiryAt: expiryAt ?? this.expiryAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
    );
  }

  /// Classifies this record's expiry state using [resolveExpiryStatus].
  ///
  /// Returns one of: [ExpiryStatus.expired], [ExpiryStatus.expiringSoon],
  /// [ExpiryStatus.valid], or [ExpiryStatus.noExpiry].
  ExpiryStatus get expiryStatus => resolveExpiryStatus(expiryAt);

  /// Convenience shorthand — true when status is [ExpiryStatus.expired].
  bool get isExpired => expiryStatus == ExpiryStatus.expired;

  @override
  String toString() {
    return 'RecordModel(id: $id, title: $title, category: $category, '
        'expiryAt: $expiryAt, archived: $archived)';
  }
}
