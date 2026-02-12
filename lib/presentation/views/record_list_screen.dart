import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/presentation/viewmodels/record_list_viewmodel.dart';
import 'package:lifevault/presentation/views/add_edit_record_screen.dart';
import 'package:lifevault/presentation/widgets/expiry_badge.dart';

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

  Future<void> _navigateToEdit(int index) async {
    final record = _viewModel.records[index];
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecordScreen(existingRecord: record),
      ),
    );
    if (didSave == true) _viewModel.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Records')),
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No records yet.\nTap + to add your first document.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _viewModel.loadRecords,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _viewModel.records.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = _viewModel.records[index];
                return _RecordTile(
                  record: record,
                  onTap: () => _navigateToEdit(index),
                  onDismissed: () => _viewModel.archiveRecord(record),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Private tile widget
// -----------------------------------------------------------------------------

class _RecordTile extends StatelessWidget {
  final dynamic record; // RecordModel
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _RecordTile({
    required this.record,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final expiryText = record.expiryAt != null
        ? dateFormat.format(record.expiryAt!)
        : '—';

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.orange.shade100,
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
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        onTap: onTap,
        leading: _categoryIcon(record.category),
        title: Text(record.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Expires: $expiryText'),
        trailing: ExpiryBadge(status: record.expiryStatus),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    final (IconData icon, Color color) = switch (category) {
      'ID & Personal' => (Icons.person, Colors.blue),
      'Financial' => (Icons.account_balance, Colors.green),
      'Medical' => (Icons.local_hospital, Colors.red),
      'Insurance' => (Icons.shield, Colors.purple),
      'Education' => (Icons.school, Colors.orange),
      'Travel' => (Icons.flight, Colors.teal),
      'Legal' => (Icons.gavel, Colors.brown),
      _ => (Icons.description, Colors.grey),
    };

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
