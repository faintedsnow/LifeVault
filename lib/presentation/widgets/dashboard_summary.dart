import 'package:flutter/material.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/data/models/record_model.dart';

class DashboardSummary extends StatelessWidget {
  final List<RecordModel> records;

  const DashboardSummary({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    final expiredCount = records
        .where((r) => r.expiryStatus == ExpiryStatus.expired)
        .length;
    final expiringSoonCount = records
        .where((r) => r.expiryStatus == ExpiryStatus.expiringSoon)
        .length;
    final validCount = records
        .where((r) => r.expiryStatus == ExpiryStatus.valid)
        .length;

    // Editorial Logic: determine the "Headline"
    String headline = 'VAULT SECURE';
    Color statusColor = const Color(0xFF2E7D32); // Green
    String subhead = 'All documents are up to date.';

    if (expiredCount > 0) {
      headline = 'ACTION REQUIRED';
      statusColor = Theme.of(context).colorScheme.error;
      subhead = '$expiredCount document${expiredCount > 1 ? 's' : ''} expired.';
    } else if (expiringSoonCount > 0) {
      headline = 'ATTENTION';
      statusColor = Colors.amber.shade800;
      subhead =
          '$expiringSoonCount document${expiringSoonCount > 1 ? 's' : ''} expiring soon.';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4), // "Graphic block" style
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'STATUS UPDATE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900, // Display style
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subhead,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Mini stats row
          Row(
            children: [
              _buildStat(context, 'Total', records.length.toString()),
              const SizedBox(width: 24),
              _buildStat(context, 'Valid', validCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
