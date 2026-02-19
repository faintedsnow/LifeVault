import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lifevault/presentation/viewmodels/record_list_viewmodel.dart';
import 'package:lifevault/presentation/views/add_edit_record_screen.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/core/enums/expiry_status.dart';
import 'package:lifevault/presentation/widgets/record_card.dart';
import 'package:lifevault/presentation/widgets/section_header.dart';
import 'package:lifevault/presentation/widgets/empty_state_widget.dart';
import 'package:lifevault/presentation/widgets/dashboard_summary.dart';
import 'package:lifevault/presentation/views/record_detail_screen.dart';
import 'package:lifevault/presentation/views/scanner_screen.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  final _viewModel = RecordListViewModel();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.loadRecords();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  ExpiryStatus _expiryStatusOf(RecordModel r) {
    return r.activeVersion?.expiryStatus ?? ExpiryStatus.noExpiry;
  }

  Future<void> _navigateToAdd() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditRecordScreen()),
    );
    if (didSave == true) _viewModel.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeVault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // Future Settings
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add, size: 28),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.errorMessage != null) {
            return Center(child: Text(_viewModel.errorMessage!));
          }

          if (_viewModel.records.isEmpty) {
            return EmptyStateWidget(
              message: 'Vault Empty',
              icon: Icons.shield_outlined,
              onAction: _navigateToAdd,
              actionLabel: 'Secure Document',
            );
          }

          final records = _viewModel.records;

          // Data grouping
          final expired = records
              .where((r) => _expiryStatusOf(r) == ExpiryStatus.expired)
              .toList();
          final expiringSoon = records
              .where((r) => _expiryStatusOf(r) == ExpiryStatus.expiringSoon)
              .toList();
          final others = records
              .where(
                (r) =>
                    _expiryStatusOf(r) != ExpiryStatus.expired &&
                    _expiryStatusOf(r) != ExpiryStatus.expiringSoon,
              )
              .toList();

          return RefreshIndicator(
            onRefresh: _viewModel.loadRecords,
            child: CustomScrollView(
              slivers: [
                // 1. DASHBOARD HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: DashboardSummary(records: records)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.05, end: 0),
                  ),
                ),

                // 2. SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search documents...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        fillColor: Colors.white,
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ),

                // 3. CATEGORY GRID
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Categories'),
                ).animate(delay: 300.ms).fadeIn(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                    delegate: SliverChildListDelegate([
                      _buildCategoryItem(
                        'Identity',
                        Icons.badge_outlined,
                        records,
                        0,
                      ),
                      _buildCategoryItem(
                        'Cards',
                        Icons.credit_card_outlined,
                        records,
                        1,
                      ),
                      _buildCategoryItem(
                        'Medical',
                        Icons.medical_services_outlined,
                        records,
                        2,
                      ),
                      _buildCategoryItem(
                        'Receipts',
                        Icons.receipt_long_outlined,
                        records,
                        3,
                      ),
                      _buildCategoryItem(
                        'Documents',
                        Icons.description_outlined,
                        records,
                        4,
                      ),
                      _buildCategoryItem(
                        'Warranty',
                        Icons.verified_outlined,
                        records,
                        5,
                      ),
                    ]),
                  ),
                ),

                // 4. ACTION REQUIRED / EXPIRING SOON
                if (expired.isNotEmpty || expiringSoon.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: expired.isNotEmpty
                          ? 'Action Required'
                          : 'Due Soon',
                      subtitle: 'These documents require your attention.',
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final list = [...expired, ...expiringSoon];
                      return _buildRecordItem(list[index], context)
                          .animate(delay: (400 + (index * 100)).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0);
                    }, childCount: expired.length + expiringSoon.length),
                  ),
                ],

                // 5. RECENT DOCUMENTS / ALL OTHERS
                const SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'All Documents',
                    subtitle: 'Securely indexed in your vault.',
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRecordItem(others[index], context)
                        .animate(delay: (600 + (index * 100)).ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    childCount: others.length,
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    List<RecordModel> allRecords,
    int index,
  ) {
    final catRecords = allRecords.where((r) => r.category == label).toList();
    final urgentCount = catRecords
        .where(
          (r) =>
              _expiryStatusOf(r) == ExpiryStatus.expired ||
              _expiryStatusOf(r) == ExpiryStatus.expiringSoon,
        )
        .length;

    return CategoryCard(
          label: label,
          icon: icon,
          count: catRecords.length,
          urgentCount: urgentCount,
          onTap: () {},
        )
        .animate(delay: (350 + (index * 80)).ms)
        .fadeIn()
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  Widget _buildRecordItem(RecordModel record, BuildContext context) {
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => RecordDetailScreen(record: record),
      closedElevation: 0,
      closedShape: const RoundedRectangleBorder(),
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) {
        return RecordCard(record: record, onTap: openContainer);
      },
      onClosed: (didChange) {
        if (didChange == true) _viewModel.loadRecords();
      },
    );
  }
}
