import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/core/enums/expiry_status.dart';

class RecordCard extends StatelessWidget {
  final RecordModel record;
  final VoidCallback? onTap;

  const RecordCard({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine accent color based on status
    final statusColor = _getStatusColor(record.expiryStatus, colorScheme);

    final dateFormat = DateFormat('dd MMM yyyy');
    final expiryText = record.expiryAt != null
        ? dateFormat.format(record.expiryAt!).toUpperCase()
        : 'NO EXPIRY';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4), // Minimal rounding
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 1. Graphic Accent Bar
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
                // 2. Content Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Label
                        Text(
                          record.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          record.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Footer: Icon + Expiry Date
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
                                color:
                                    record.expiryStatus == ExpiryStatus.expired
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (record.expiryStatus ==
                                ExpiryStatus.expiringSoon) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  'SOON',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ExpiryStatus status, ColorScheme colors) {
    switch (status) {
      case ExpiryStatus.expired:
        return colors.error;
      case ExpiryStatus.expiringSoon:
        return Colors.amber.shade700; // Warning
      case ExpiryStatus.valid:
        return const Color(0xFF2E7D32); // Deep Green
      case ExpiryStatus.noExpiry:
        return colors.outline; // Grey
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
        return Icons.article_outlined; // More editorial icon
    }
  }
}
