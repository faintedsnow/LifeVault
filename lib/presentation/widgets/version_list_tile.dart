import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/data/models/document_version.dart';
import 'package:lifevault/main.dart';

/// Displays a single version in the version history list.
class VersionListTile extends StatelessWidget {
  final DocumentVersion version;
  final bool isCurrent;
  final VoidCallback? onSetActive;

  const VersionListTile({
    super.key,
    required this.version,
    this.isCurrent = false,
    this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    final statusColor = _statusColor(version.status);
    final statusBg = _statusBg(version.status);
    final statusLabel = _statusLabel(version.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? LVColors.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'V${version.versionNumber}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Version ${version.versionNumber}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusLabel.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (version.issueDate != null)
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Issued ${dateFormat.format(version.issueDate!)}',
                ),
              if (version.expiryDate != null)
                _buildInfoRow(
                  Icons.event_busy_outlined,
                  'Expires ${dateFormat.format(version.expiryDate!)}',
                ),
            ],
          ),
        ),
        trailing: !isCurrent && onSetActive != null
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline, size: 22),
                color: LVColors.primary,
                onPressed: onSetActive,
              )
            : isCurrent
            ? const Icon(Icons.check_circle, color: LVColors.primary, size: 22)
            : null,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF8E9997)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF596066),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return LVColors.valid;
      case 'expired':
        return LVColors.expired;
      case 'archived':
        return LVColors.noExpiry;
      default:
        return LVColors.noExpiry;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'active':
        return LVColors.validBg;
      case 'expired':
        return LVColors.expiredBg;
      case 'archived':
        return LVColors.noExpiryBg;
      default:
        return LVColors.noExpiryBg;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'archived':
        return 'Archived';
      default:
        return status;
    }
  }
}
