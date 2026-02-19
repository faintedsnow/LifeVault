import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/presentation/viewmodels/record_detail_viewmodel.dart';
import 'package:lifevault/presentation/views/add_edit_record_screen.dart';
import 'package:lifevault/presentation/widgets/version_list_tile.dart';
import 'package:lifevault/main.dart';

class RecordDetailScreen extends StatefulWidget {
  final RecordModel record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final _viewModel = RecordDetailViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadRecord(widget.record.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMMM yyyy');

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading && _viewModel.record == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final rec = _viewModel.record ?? widget.record;
        final version = _viewModel.activeVersion ?? rec.activeVersion;
        final versionExpiryStatus =
            version?.expiryStatus ?? ExpiryStatus.noExpiry;

        final statusColor = _getStatusColor(versionExpiryStatus);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: LVColors.primaryDark,
            foregroundColor: Colors.white,
            title: Text(
              rec.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: Color(0xFF8AB8A8),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEdit(rec),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER HERO
                Container(
                  width: double.infinity,
                  color: LVColors.primaryDark,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        rec.title,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildHeaderStat(
                            'ACTIVE VERSION',
                            'V${version?.versionNumber ?? 1}',
                          ),
                          const SizedBox(width: 40),
                          _buildHeaderStat(
                            'STATUS',
                            _getStatusLabel(versionExpiryStatus).toUpperCase(),
                            color: statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. PRIMARY DETAILS
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Lifecycle Details', [
                            _DetailItem(
                              'Issue Date',
                              version?.issueDate != null
                                  ? dateFormat.format(version!.issueDate!)
                                  : 'Not Specified',
                            ),
                            _DetailItem(
                              'Expiry Date',
                              version?.expiryDate != null
                                  ? dateFormat.format(version!.expiryDate!)
                                  : 'No Expiry',
                              isBold: true,
                              color: statusColor,
                            ),
                          ])
                          .animate(delay: 100.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      if (version?.notes != null &&
                          version!.notes!.isNotEmpty) ...[
                        _buildDetailSection('Notes', [
                          _DetailItem(null, version.notes!),
                        ]).animate(delay: 200.ms).fadeIn(),
                        const SizedBox(height: 32),
                      ],
                      _buildDetailSection('Metadata', [
                        _DetailItem(
                          'Created',
                          dateFormat.format(rec.createdAt),
                        ),
                        _DetailItem(
                          'Vault ID',
                          rec.id.substring(0, 8).toUpperCase(),
                        ),
                      ]).animate(delay: 300.ms).fadeIn(),
                    ],
                  ),
                ),

                // 3. VERSION HISTORY
                Container(
                  width: double.infinity,
                  color: colorScheme.surfaceContainer,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Version History',
                            style: theme.textTheme.headlineSmall,
                          ),
                          TextButton.icon(
                            onPressed: _confirmRenew,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Renew'),
                            style: TextButton.styleFrom(
                              foregroundColor: LVColors.primary,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._viewModel.versions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final v = entry.value;
                        return VersionListTile(
                              version: v,
                              isCurrent: v.id == version?.id,
                              onSetActive: () => _confirmSetActive(v.id),
                            )
                            .animate(delay: (400 + (idx * 50)).ms)
                            .fadeIn()
                            .slideX(begin: 0.05, end: 0);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8AB8A8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<_DetailItem> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: theme.textTheme.labelSmall),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8E0DE)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.label != null)
                        Text(
                          item.label!,
                          style: const TextStyle(
                            color: Color(0xFF596066),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Text(
                        item.value,
                        style: TextStyle(
                          color: item.color ?? LVColors.onSurface,
                          fontSize: 14,
                          fontWeight: item.isBold
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (idx < items.length - 1) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- Actions ---

  Future<void> _confirmRenew() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renew Document'),
        content: const Text(
          'Create a new lifecycle version for this document?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create Version'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _viewModel.renewVersion();
    }
  }

  Future<void> _confirmSetActive(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activate Version'),
        content: const Text('Set this version as the primary active record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _viewModel.setActiveVersion(id);
    }
  }

  Future<void> _navigateToEdit(RecordModel record) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecordScreen(existingRecord: record),
      ),
    );
    if (result == true && mounted) _viewModel.loadRecord(record.id);
  }

  // --- Colors & Labels ---

  Color _getStatusColor(ExpiryStatus status) => status == ExpiryStatus.expired
      ? LVColors.expired
      : status == ExpiryStatus.expiringSoon
      ? LVColors.expiringSoon
      : LVColors.valid;
  String _getStatusLabel(ExpiryStatus status) => status == ExpiryStatus.expired
      ? 'Expired'
      : status == ExpiryStatus.expiringSoon
      ? 'Expiring'
      : 'Valid';
}

class _DetailItem {
  final String? label;
  final String value;
  final bool isBold;
  final Color? color;
  _DetailItem(this.label, this.value, {this.isBold = false, this.color});
}
