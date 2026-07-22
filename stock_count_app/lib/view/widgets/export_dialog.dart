import 'package:flutter/material.dart';
import 'package:stock_count_app/model/item_model.dart';
import '../../data/item_data.dart' as item_data;
import '../../viewmodel/home_view_model.dart';
import '../../utils/index.dart';

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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 550),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Export Report',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: context.theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Items count display with better styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.theme.accent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.theme.accent.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Items to Export',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$checkedCount',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: context.theme.accent,
                              ),
                            ),
                            TextSpan(
                              text: ' / $totalCount',
                              style: TextStyle(
                                fontSize: 18,
                                color: context.theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name input field
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.theme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your Name',
                    hintStyle: TextStyle(
                      color: context.theme.textSecondary,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.theme.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.theme.accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.theme.accent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: context.theme.surface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 28),

                // Action buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _performExport();
                            },
                            icon: const Icon(Icons.share, size: 24),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: context.theme.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _performSaveToDevice();
                            },
                            icon: const Icon(Icons.download, size: 24),
                            label: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: context.theme.accent.withValues(
                                alpha: 0.7,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: context.theme.accent.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.theme.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performExport() async {
    final success = await widget.viewModel.exportAndClear(
      context,
      location: widget.viewModel.currentLocation.displayName,
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
      location: widget.viewModel.currentLocation.displayName,
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
