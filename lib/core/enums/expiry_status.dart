/// Classification of a record's expiry state.
///
/// Used by the dashboard and (future) reminder engine to bucket
/// documents into actionable categories.
enum ExpiryStatus {
  /// The document's expiry date has already passed.
  expired,

  /// The document expires within the next 30 days.
  expiringSoon,

  /// The document's expiry date is more than 30 days away.
  valid,

  /// The document has no expiry date set.
  noExpiry,
}
