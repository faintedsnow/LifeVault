import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/main.dart';

/// Dashboard header: vault status + 3-stat row.
/// Pure editorial layout — no decorative shapes.
class DashboardSummary extends StatelessWidget {
  final List<RecordModel> records;

  const DashboardSummary({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final expiredCount = records
        .where(
          (r) =>
              (r.activeVersion?.expiryStatus ?? ExpiryStatus.noExpiry) ==
              ExpiryStatus.expired,
        )
        .length;
    final expiringSoonCount = records
        .where(
          (r) =>
              (r.activeVersion?.expiryStatus ?? ExpiryStatus.noExpiry) ==
              ExpiryStatus.expiringSoon,
        )
        .length;
    final validCount = records
        .where(
          (r) =>
              (r.activeVersion?.expiryStatus ?? ExpiryStatus.noExpiry) ==
              ExpiryStatus.valid,
        )
        .length;

    final hasUrgent = expiredCount > 0 || expiringSoonCount > 0;
    final statusLabel = expiredCount > 0
        ? 'ACTION REQUIRED'
        : expiringSoonCount > 0
        ? 'ATTENTION NEEDED'
        : 'VAULT SECURE';
    final statusDotColor = expiredCount > 0
        ? LVColors.expired
        : expiringSoonCount > 0
        ? LVColors.expiringSoon
        : LVColors.valid;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: BoxDecoration(
        color: LVColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusDotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: const TextStyle(
                  color: Color(0xFFB7F5DB),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main messaging
          Text(
            hasUrgent
                ? expiredCount > 0
                      ? '$expiredCount document${expiredCount > 1 ? 's' : ''} expired'
                      : '$expiringSoonCount expiring soon'
                : 'All documents current',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 20),

          // Three stats
          Row(
            children: [
              _buildStat('${records.length}', 'TOTAL'),
              _buildDivider(),
              _buildStat('$validCount', 'VALID'),
              _buildDivider(),
              _buildStat('$expiredCount', 'EXPIRED'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8AB8A8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.12),
      margin: const EdgeInsets.only(right: 20),
    );
  }
}

/// Category grid card displayed inside the dashboard.
class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final int urgentCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.count,
    this.urgentCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUrgent = urgentCount > 0;

    return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasUrgent
                    ? LVColors.expired.withValues(alpha: 0.25)
                    : const Color(0xFFD8E0DE),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LVColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 18, color: LVColors.primary),
                    ),
                    if (hasUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: LVColors.expiredBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$urgentCount',
                          style: const TextStyle(
                            color: LVColors.expired,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$count item${count != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
          duration: 100.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 400.ms, delay: 100.ms);
  }
}
