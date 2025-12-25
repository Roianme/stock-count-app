import 'package:flutter/material.dart';
import '../../data/item_data.dart' as item_data;
import '../../viewmodel/home_view_model.dart';

class ExportDialog extends StatefulWidget {
  final HomeViewModel viewModel;
  final VoidCallback onExportSuccess;
  final Function(String) onSaveSuccess;
  final Function(String) onError;

  const ExportDialog({
    super.key,
    required this.viewModel,
    required this.onExportSuccess,
    required this.onSaveSuccess,
    required this.onError,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late final TextEditingController locationController;
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    locationController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = item_data.items.where((i) => i.isChecked).length;
    final totalCount = item_data.items.length;

    return AlertDialog(
      title: const Text('Export Report'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export $checkedCount / $totalCount items?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Location (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Your Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _performSaveToDevice();
          },
          child: const Text('Save to Device'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _performExport();
          },
          child: const Text('Share'),
        ),
      ],
    );
  }

  Future<void> _performExport() async {
    final success = await widget.viewModel.exportAndClear(
      context,
      location: locationController.text.isEmpty
          ? null
          : locationController.text,
      name: nameController.text.isEmpty ? null : nameController.text,
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (success) {
      widget.onExportSuccess();
    } else {
      widget.onError('No checked items to export');
    }
  }

  Future<void> _performSaveToDevice() async {
    final filePath = await widget.viewModel.saveToDeviceAndClear(
      context,
      location: locationController.text.isEmpty
          ? null
          : locationController.text,
      name: nameController.text.isEmpty ? null : nameController.text,
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (filePath != null) {
      widget.onSaveSuccess(filePath);
    } else {
      widget.onError('Failed to save report');
    }
  }
}
