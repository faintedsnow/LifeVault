import 'package:flutter/material.dart';
import 'package:lifevault/presentation/viewmodels/record_list_viewmodel.dart';
import 'package:lifevault/presentation/views/add_edit_record_screen.dart'; // Keep this if used, otherwise remove? ExpiryBadge is used in RecordCard, not here? Wait, RecordListScreen doesn't use ExpiryBadge directly anymore, RecordCard does.
// But check imports.
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/presentation/widgets/record_card.dart';
import 'package:lifevault/presentation/widgets/section_header.dart';
import 'package:lifevault/presentation/widgets/empty_state_widget.dart';
import 'package:lifevault/presentation/widgets/dashboard_summary.dart';
import 'package:lifevault/presentation/views/record_detail_screen.dart';

/// Displays all non-archived records with expiry status badges.
class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final _viewModel = RecordListViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadRecords();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _navigateToAdd() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditRecordScreen()),
    );
    if (didSave == true) _viewModel.loadRecords();
  }

  Future<void> _navigateToDetail(RecordModel record) async {
    final didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
    );
    if (didChange == true) _viewModel.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY VAULT')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(_viewModel.errorMessage!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _viewModel.loadRecords,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_viewModel.records.isEmpty) {
            return EmptyStateWidget(
              message: 'No records yet.\nTap + to add your first document.',
              icon: Icons.folder_open,
              onAction: _navigateToAdd,
              actionLabel: 'Add Record',
            );
          }

          // Group records by status
          final expired = _viewModel.records
              .where((r) => r.expiryStatus == ExpiryStatus.expired)
              .toList();
          final expiringSoon = _viewModel.records
              .where((r) => r.expiryStatus == ExpiryStatus.expiringSoon)
              .toList();
          final valid = _viewModel.records
              .where((r) => r.expiryStatus == ExpiryStatus.valid)
              .toList();
          final noExpiry = _viewModel.records
              .where((r) => r.expiryStatus == ExpiryStatus.noExpiry)
              .toList();

          // Sort within groups
          // Sort within groups
          int compareDates(RecordModel a, RecordModel b) {
            if (a.expiryAt == null) return 1;
            if (b.expiryAt == null) return -1;
            return a.expiryAt!.compareTo(b.expiryAt!);
          }

          expired.sort(compareDates);
          expiringSoon.sort(compareDates);
          valid.sort(compareDates);
          noExpiry.sort((a, b) => a.title.compareTo(b.title));

          return RefreshIndicator(
            onRefresh: _viewModel.loadRecords,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardSummary(records: _viewModel.records),
                ),
                if (expired.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'Expired'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecordItem(expired[index], context),
                      childCount: expired.length,
                    ),
                  ),
                ],
                if (expiringSoon.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'Expiring Soon'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecordItem(expiringSoon[index], context),
                      childCount: expiringSoon.length,
                    ),
                  ),
                ],
                if (valid.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'Valid'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecordItem(valid[index], context),
                      childCount: valid.length,
                    ),
                  ),
                ],
                if (noExpiry.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'No Expiry'),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecordItem(noExpiry[index], context),
                      childCount: noExpiry.length,
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordItem(RecordModel record, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: ValueKey(record.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.archive, color: Colors.orange.shade700),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Archive Record'),
              content: const Text('Move this record to archive?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Archive'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => _viewModel.archiveRecord(record),
        child: RecordCard(
          record: record,
          onTap: () {
            _navigateToDetail(record);
          },
        ),
      ),
    );
  }
}
