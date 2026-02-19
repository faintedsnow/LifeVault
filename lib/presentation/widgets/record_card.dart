import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/main.dart';

class RecordCard extends StatelessWidget {
  final RecordModel record;
  final VoidCallback? onTap;

  const RecordCard({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Derive status from the active version
    final version = record.activeVersion;
    final versionExpiryStatus = version?.expiryStatus ?? ExpiryStatus.noExpiry;

    final statusColor = _getStatusColor(versionExpiryStatus);
    final statusBg = _getStatusBg(versionExpiryStatus);
    final statusLabel = _getStatusChipLabel(
      versionExpiryStatus,
      version?.expiryDate,
    );

    final dateFormat = DateFormat('dd MMM yyyy');
    final expiryText = version?.expiryDate != null
        ? dateFormat.format(version!.expiryDate!)
        : 'NO EXPIRY';

    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category & Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.category.toUpperCase(),
                                  style: theme.textTheme.labelSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.title,
                                  style: theme.textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Footer: Icon + Expiry Date + Version
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(record.category),
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            expiryText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: versionExpiryStatus == ExpiryStatus.expired
                                  ? colorScheme.error
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (version != null)
                            Text(
                              'V${version.versionNumber}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Color _getStatusColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return LVColors.expired;
      case ExpiryStatus.expiringSoon:
        return LVColors.expiringSoon;
      case ExpiryStatus.valid:
        return LVColors.valid;
      case ExpiryStatus.noExpiry:
        return LVColors.noExpiry;
    }
  }

  Color _getStatusBg(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return LVColors.expiredBg;
      case ExpiryStatus.expiringSoon:
        return LVColors.expiringSoonBg;
      case ExpiryStatus.valid:
        return LVColors.validBg;
      case ExpiryStatus.noExpiry:
        return LVColors.noExpiryBg;
    }
  }

  String _getStatusChipLabel(ExpiryStatus status, DateTime? expiryDate) {
    switch (status) {
      case ExpiryStatus.expired:
        return 'Expired';
      case ExpiryStatus.expiringSoon:
        if (expiryDate != null) {
          final days = expiryDate.difference(DateTime.now()).inDays;
          return days <= 0 ? 'Expiring' : '$days Days Left';
        }
        return 'Soon';
      case ExpiryStatus.valid:
        return 'Valid';
      case ExpiryStatus.noExpiry:
        return 'No Expiry';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'ID & Personal':
        return Icons.badge_outlined;
      case 'Financial':
        return Icons.account_balance_wallet_outlined;
      case 'Medical':
        return Icons.medical_services_outlined;
      case 'Insurance':
        return Icons.security_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Travel':
        return Icons.flight_outlined;
      case 'Legal':
        return Icons.gavel_outlined;
      case 'Warranty':
        return Icons.verified_outlined;
      default:
        return Icons.article_outlined;
    }
  }
}
