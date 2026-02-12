import 'package:flutter/material.dart';
import 'package:lifevault/core/enums/expiry_status.dart';

/// A colour-coded badge that communicates a record's expiry state at a glance.
///
/// Maps each [ExpiryStatus] to a distinct colour and label, leveraging
/// colour-coded salience to direct the user's attention.
class ExpiryBadge extends StatelessWidget {
  final ExpiryStatus status;

  const ExpiryBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      ExpiryStatus.expired => (
        Colors.red.shade50,
        Colors.red.shade700,
        'Expired',
      ),
      ExpiryStatus.expiringSoon => (
        Colors.amber.shade50,
        Colors.amber.shade800,
        'Expiring Soon',
      ),
      ExpiryStatus.valid => (
        Colors.green.shade50,
        Colors.green.shade700,
        'Valid',
      ),
      ExpiryStatus.noExpiry => (
        Colors.grey.shade200,
        Colors.grey.shade600,
        'No Expiry',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
