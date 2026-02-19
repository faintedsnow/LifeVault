import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/presentation/viewmodels/add_edit_record_viewmodel.dart';
import 'package:lifevault/main.dart';
import 'package:lifevault/presentation/widgets/section_header.dart';

/// Screen for creating a new record or editing an existing one.
///
/// Returns `true` via [Navigator.pop] when a record is saved successfully,
/// allowing the list screen to know it should refresh.
class AddEditRecordScreen extends StatefulWidget {
  final RecordModel? existingRecord;

  const AddEditRecordScreen({super.key, this.existingRecord});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  late final AddEditRecordViewModel _viewModel;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _issueDateController;
  late final TextEditingController _expiryDateController;
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = AddEditRecordViewModel(existingRecord: widget.existingRecord);
    _titleController = TextEditingController(text: _viewModel.title);
    _notesController = TextEditingController(text: _viewModel.notes);
    _issueDateController = TextEditingController(
      text: _viewModel.issueDate != null
          ? _dateFormat.format(_viewModel.issueDate!)
          : '',
    );
    _expiryDateController = TextEditingController(
      text: _viewModel.expiryAt != null
          ? _dateFormat.format(_viewModel.expiryAt!)
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // --- Date Picking Logic ---

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.expiryAt ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 50),
      helpText: 'VALID UNTIL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: LVColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _viewModel.expiryAt = picked;
        _expiryDateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _pickIssueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.issueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 50),
      helpText: 'DATE OF ISSUE',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: LVColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _viewModel.issueDate = picked;
        _issueDateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _onSave() async {
    // Sync text controllers → viewmodel
    _viewModel.title = _titleController.text;
    _viewModel.notes = _notesController.text;

    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.save();
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: LVColors.background,
      appBar: AppBar(
        title: Text(
          _viewModel.isEditing ? 'ENTRY MODIFICATION' : 'NEW VAULT ENTRY',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 2,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. PRIMARY IDENTITY SECTION
                  const SectionHeader(
                    title: 'Record Identity',
                    subtitle: 'Define the core identifier of this document.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(colorScheme),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'RECORD TITLE',
                              hintText: 'e.g. Passport, Drivers License',
                              prefixIcon: Icon(Icons.title_outlined, size: 20),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Identifier is required'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          // Visual Category Selector
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'CLASSIFICATION',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.2,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          _buildCategoryGrid(theme, colorScheme),
                        ],
                      ),
                    ),
                  ),

                  // 2. LIFECYCLE SECTION
                  const SectionHeader(
                    title: 'Document Lifecycle',
                    subtitle: 'Key dates for validity and renewals.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(colorScheme),
                      child: Column(
                        children: [
                          _buildDateInputField(
                            label: 'ISSUE DATE (DD/MM/YYYY)',
                            controller: _issueDateController,
                            icon: Icons.calendar_today_outlined,
                            onPickerTap: _pickIssueDate,
                            onChanged: (val) => _updateDateFromText(val, true),
                            theme: theme,
                          ),
                          const SizedBox(height: 20),
                          _buildDateInputField(
                            label: 'EXPIRY DATE (DD/MM/YYYY)',
                            controller: _expiryDateController,
                            icon: Icons.event_busy_outlined,
                            onPickerTap: _pickExpiryDate,
                            onChanged: (val) => _updateDateFromText(val, false),
                            isExpiry: true,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. SUPPLEMENTAL SECTION
                  const SectionHeader(
                    title: 'Supplemental Information',
                    subtitle: 'Additional notes or references.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: _cardDecoration(colorScheme),
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'REMARKS',
                          hintText: 'Enter document numbers or context...',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 55),
                            child: Icon(Icons.notes_outlined, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- Error Handling ---
                  if (_viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LVColors.expiredBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: LVColors.expired.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: LVColors.expired,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _viewModel.errorMessage!,
                                style: const TextStyle(
                                  color: LVColors.expired,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Submit Action ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        SizedBox(
                              height: 58,
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _viewModel.isSaving ? null : _onSave,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _viewModel.isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.verified_user_outlined,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            (_viewModel.isEditing
                                                    ? 'COMMIT CHANGES'
                                                    : 'SECURE RECORD')
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            )
                            .animate(target: _viewModel.isSaving ? 1 : 0)
                            .shimmer(duration: 1200.ms, color: Colors.white24),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCategoryGrid(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AddEditRecordViewModel.categories.map((cat) {
        final isSelected = _viewModel.category == cat;
        return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _viewModel.category = cat;
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? LVColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? LVColors.primary
                        : colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 18,
                      color: isSelected
                          ? LVColors.primary
                          : colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? LVColors.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate(target: isSelected ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 200.ms,
              curve: Curves.easeOutBack,
            );
      }).toList(),
    );
  }

  Widget _buildDateInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onPickerTap,
    required ValueChanged<String> onChanged,
    bool isExpiry = false,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'e.g. 20/05/2025',
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            onPickerTap();
          },
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  void _updateDateFromText(String text, bool isIssueDate) {
    try {
      if (text.length == 10) {
        final date = _dateFormat.parse(text);
        if (isIssueDate) {
          _viewModel.issueDate = date;
        } else {
          _viewModel.expiryAt = date;
        }
      }
    } catch (_) {
      // Ignore invalid partial dates
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

  BoxDecoration _cardDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: colorScheme.outlineVariant, width: 1.2),
    );
  }
}
