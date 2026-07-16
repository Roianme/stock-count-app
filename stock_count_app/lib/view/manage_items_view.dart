import 'package:flutter/material.dart';
import '../model/item_model.dart';
import '../model/category_model.dart';

import '../data/item_repository.dart';
import '../viewmodel/manage_items_view_model.dart';

class ManageItemsView extends StatefulWidget {
  final ItemRepository repository;

  const ManageItemsView({super.key, required this.repository});

  @override
  State<ManageItemsView> createState() => _ManageItemsViewState();
}

class _ManageItemsViewState extends State<ManageItemsView> {
  late final ManageItemsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ManageItemsViewModel(repository: widget.repository);
    viewModel.addListener(_handleErrors);
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleErrors);
    viewModel.dispose();
    super.dispose();
  }

  void _handleErrors() {
    if (!mounted) return;
    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final grouped = viewModel.groupedItems;
        final categories = viewModel.sortedCategories
            .where((cat) => grouped.containsKey(cat) && grouped[cat]!.isNotEmpty)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Items'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showItemDialog(context),
            tooltip: 'Add item',
            child: const Icon(Icons.add),
          ),
          body: categories.isEmpty
              ? const Center(child: Text('No items yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final catItems = grouped[cat]!;
                    return _buildCategorySection(context, cat, catItems);
                  },
                ),
        );
      },
    );
  }
  Widget _buildCategorySection(
      BuildContext context, CategoryRecord cat, List<Item> catItems) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Color(cat.colorValue).withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  IconData(cat.iconCodePoint, fontFamily: cat.iconFontFamily),
                  color: Color(cat.colorValue),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(cat.colorValue),
                  ),
                ),
                const Spacer(),
                Text('${catItems.length}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          ...catItems.map((item) => ListTile(
                title: Text(item.name),
                subtitle: item.unitOptions.isNotEmpty
                    ? Text('${item.unitOptions.length} option(s)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, item),
                ),
                onTap: () => _showItemDialog(context, existing: item),
              )),
        ],
      ),
    );
  }
  void _confirmDelete(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?\n\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              viewModel.deleteItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  Future<void> _showItemDialog(
    BuildContext context, {
    Item? existing,
  }) async {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedCategoryId = existing?.categoryId ?? '';
    Set<Mode> selectedModes = Set.from(existing?.modes ?? {Mode.city});
    List<ItemUnitOptionRecord> unitOptions =
        List.from(existing?.unitOptions ?? []);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final categories = viewModel.sortedCategories;

            return AlertDialog(
              title: Text(isEditing ? 'Edit Item' : 'Add Item'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item name',
                          hintText: 'e.g. pork skewers',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      const Text('Category',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: categories.any((c) => c.id == selectedCategoryId)
                            ? selectedCategoryId
                            : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Select category',
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(
                                  IconData(cat.iconCodePoint,
                                      fontFamily: cat.iconFontFamily),
                                  size: 18,
                                  color: Color(cat.colorValue),
                                ),
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedCategoryId = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Modes multi-select
                      const Text('Modes',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: Mode.values.map((mode) {
                          final isSelected = selectedModes.contains(mode);
                          return FilterChip(
                            label: Text(mode.displayName, style: const TextStyle(fontSize: 13)),
                            selected: isSelected,
                            onSelected: (val) {
                              setDialogState(() {
                                if (val) {
                                  selectedModes.add(mode);
                                } else {
                                  selectedModes.remove(mode);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Unit options editor
                      _buildUnitOptionsEditor(
                        context,
                        unitOptions,
                        setDialogState,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx, {
                      'name': nameController.text.trim(),
                      'categoryId': selectedCategoryId,
                      'modes': Set.from(selectedModes),
                      'unitOptions': List.from(unitOptions),
                    });
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final name = result['name'] as String;
    final catId = result['categoryId'] as String;
    final modes = result['modes'] as Set<Mode>;
    final opts = result['unitOptions'] as List<ItemUnitOptionRecord>;

    bool success;
    if (isEditing) {
      success = await viewModel.updateItem(
        itemId: existing.id,
        name: name,
        categoryId: catId,
        modes: modes,
        unitOptions: opts,
      );
    } else {
      success = await viewModel.addItem(
        name: name,
        categoryId: catId,
        modes: modes,
        unitOptions: opts,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Item updated' : 'Item added'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Widget _buildUnitOptionsEditor(
    BuildContext context,
    List<ItemUnitOptionRecord> unitOptions,
    void Function(VoidCallback) setDialogState,
  ) {
    // Local state for the new option text field
    String newOptionText = '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Unit Options',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${unitOptions.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 4),
        // Existing options
        ...unitOptions.asMap().entries.map((entry) {
          final idx = entry.key;
          final opt = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(opt.label, style: const TextStyle(fontSize: 14)),
                ),
                if (opt.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('URGENT',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ),
                InkWell(
                  onTap: () {
                    setDialogState(() {
                      unitOptions[idx] = ItemUnitOptionRecord(
                        label: opt.label,
                        isUrgent: !opt.isUrgent,
                      );
                    });
                  },
                  child: Icon(
                    opt.isUrgent
                        ? Icons.emergency
                        : Icons.emergency_outlined,
                    size: 20,
                    color: opt.isUrgent ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    setDialogState(() {
                      unitOptions.removeAt(idx);
                    });
                  },
                  child: const Icon(Icons.close,
                      size: 20, color: Colors.red),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Add new option row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'e.g. 1 jar',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (val) {
                    newOptionText = val;
                  },
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setDialogState(() {
                        unitOptions.add(ItemUnitOptionRecord(
                            label: val.trim()));
                        newOptionText = '';
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  if (newOptionText.trim().isEmpty) return;
                  setDialogState(() {
                    unitOptions.add(ItemUnitOptionRecord(
                        label: newOptionText.trim()));
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

