import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifevault/data/models/record_model.dart';
import 'package:lifevault/presentation/viewmodels/add_edit_record_viewmodel.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = AddEditRecordViewModel(existingRecord: widget.existingRecord);
    _titleController = TextEditingController(text: _viewModel.title);
    _notesController = TextEditingController(text: _viewModel.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.expiryAt ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 50),
      helpText: 'Select expiry date',
    );
    if (picked != null) {
      _viewModel.expiryAt = picked;
    }
  }

  void _clearExpiryDate() {
    _viewModel.expiryAt = null;
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
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_viewModel.isEditing ? 'Edit Record' : 'New Record'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Title ──
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g. Passport, Insurance Policy',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Category ──
                  DropdownButtonFormField<String>(
                    initialValue: _viewModel.category.isEmpty
                        ? null
                        : _viewModel.category,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: AddEditRecordViewModel.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => _viewModel.category = v ?? '',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please select a category'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Expiry Date ──
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _viewModel.expiryAt != null
                                ? dateFormat.format(_viewModel.expiryAt!)
                                : 'No expiry set',
                            style: TextStyle(
                              color: _viewModel.expiryAt != null
                                  ? null
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        if (_viewModel.expiryAt != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: 'Remove expiry',
                            onPressed: _clearExpiryDate,
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          tooltip: 'Pick date',
                          onPressed: _pickExpiryDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Notes ──
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Optional extra details…',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // ── Error ──
                  if (_viewModel.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _viewModel.errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Save Button ──
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _viewModel.isSaving ? null : _onSave,
                      icon: _viewModel.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _viewModel.isSaving
                            ? 'Saving…'
                            : (_viewModel.isEditing
                                  ? 'Update Record'
                                  : 'Save Record'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
