import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/presentation/views/add_edit_record_screen.dart';

class RecordDetailScreen extends StatelessWidget {
  final RecordModel record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    final statusColor = _getStatusColor(record.expiryStatus, colorScheme);
    final expiryText = record.expiryAt != null
        ? dateFormat.format(record.expiryAt!)
        : 'No Expiry';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        leading: BackButton(color: colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Edit Record',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Graphic Header Block
            Container(
              color: statusColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusLabel(record.expiryStatus).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Icon(
                    _getCategoryIcon(record.category),
                    size: 48,
                    color: statusColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    record.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.category.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    'EXPIRY DATE',
                    expiryText,
                    isHighlight: true,
                  ),
                  const Divider(height: 32),
                  if (record.notes != null && record.notes!.isNotEmpty) ...[
                    _buildDetailRow(context, 'NOTES', record.notes!),
                    const Divider(height: 32),
                  ],
                  _buildDetailRow(
                    context,
                    'CREATED',
                    dateFormat.format(record.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ExpiryStatus status, ColorScheme colors) {
    switch (status) {
      case ExpiryStatus.expired:
        return colors.error;
      case ExpiryStatus.expiringSoon:
        return Colors.amber.shade800;
      case ExpiryStatus.valid:
        return const Color(0xFF2E7D32);
      case ExpiryStatus.noExpiry:
        return colors.outline;
    }
  }

  String _getStatusLabel(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return 'Expired';
      case ExpiryStatus.expiringSoon:
        return 'Expiring Soon';
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

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecordScreen(existingRecord: record),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true); // Return true to refresh list
    }
  }
}
