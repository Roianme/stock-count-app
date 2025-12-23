import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import '../model/item_model.dart';
import 'category_view.dart';
import '../viewmodel/home_view_model.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart' as item_data;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});
  final ItemRepository repository;

  @override
  State<HomePage> createState() => _HomePageState(repository);
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;
  final TextEditingController _searchController = TextEditingController();
  final ItemRepository repository;

  _HomePageState(this.repository);

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(
      allCategories: Category.values,
      repository: repository,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final categories = viewModel.visibleCategories;
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Homepage',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                // Menu for location toggle
                // City, Cafe, HP, etc.
                // Different view navigation per location
                // Add sidebar
                // Also include version info at bottom
              },
            ),
            actions: [
              IconButton(
                onPressed: viewModel.hasCheckedItems
                    ? () => _showPreviewDialog(context)
                    : null,
                icon: const Icon(Icons.preview, color: Colors.black87),
                tooltip: 'Preview checked items',
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black87),
                tooltip: 'Export checked items',
                onPressed: viewModel.hasCheckedItems
                    ? () => _showExportDialog(context)
                    : null,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: viewModel.setQuery,
                            decoration: InputDecoration(
                              hintText: 'Search for keyword',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            viewModel.isGrid
                                ? Icons.view_list
                                : Icons.grid_view,
                            color: Colors.black87,
                          ),
                          onPressed: viewModel.toggleViewMode,
                          tooltip: viewModel.isGrid
                              ? 'Switch to list view'
                              : 'Switch to grid view',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      viewModel.isGrid && !viewModel.isSearching
                          ? 'Categories'
                          : (viewModel.isSearching
                                ? 'Search results'
                                : 'All Items'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: viewModel.isSearching
                      ? _buildSearchResults(viewModel.matchedItems)
                      : (viewModel.isGrid
                            ? _buildGridView(categories)
                            : _buildListView(categories)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Category> categories) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildListView(List<Category> categories) {
    final itemsByCategory = viewModel.groupedItems(categories);

    final listChildren = <Widget>[];

    for (final category in categories) {
      final categoryItems = itemsByCategory[category] ?? [];
      if (categoryItems.isEmpty) continue;

      listChildren.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category.displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );

      for (final item in categoryItems) {
        listChildren.add(
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: item.isChecked,
                      onChanged: (_) {
                        viewModel.setItemChecked(item.id, !item.isChecked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: item.category.color.withOpacity(0.12),
                    child: Icon(item.category.icon, color: item.category.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  if (item.status != ItemStatus.pieces)
                    Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ItemStatus>(
                          value: item.status,
                          isExpanded: true,
                          items: ItemStatus.values.map((status) {
                            return DropdownMenuItem<ItemStatus>(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              viewModel.updateItemStatus(item.id, newStatus);
                            }
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: ValueKey('pieces_${item.id}'),
                              initialValue: item.pieces == 0
                                  ? ''
                                  : item.pieces.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Pieces',
                              ),
                              onChanged: (value) {
                                final parsed = int.tryParse(value) ?? 0;
                                viewModel.setItemPieces(item.id, parsed);
                              },
                            ),
                          ),
                          IconButton(
                            tooltip: 'Back to status',
                            icon: const Icon(
                              Icons.arrow_drop_down_circle_outlined,
                            ),
                            onPressed: () {
                              viewModel.updateItemStatus(
                                item.id,
                                ItemStatus.ok,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: listChildren,
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCategory(category),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, size: 40, color: category.color),
              ),
              const SizedBox(height: 12),
              Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                viewModel.categoryProgress(category),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(Category category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryView(category: category, repository: repository),
      ),
    );
    setState(() {});
  }

  Widget _buildSearchResults(List<Item> itemsList) {
    if (itemsList.isEmpty) {
      return const Center(child: Text('No matching items'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemsList.length,
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.category.icon,
                  color: item.category.color,
                  size: 28,
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                item.category.displayName,
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: item.isChecked,
                    onChanged: (checked) {
                      viewModel.setItemChecked(item.id, checked ?? false);
                    },
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              onTap: () => _navigateToCategory(item.category),
            ),
          ),
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final locationController = TextEditingController();
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Export Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export ${item_data.items.where((i) => i.isChecked).length} / ${item_data.items.length} items?',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Can be modified soon if Location is set
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _performSaveToDevice(
                  context,
                  locationController.text,
                  nameController.text,
                );
              },
              child: const Text('Save to Device'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _performExport(
                  context,
                  locationController.text,
                  nameController.text,
                );
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewDialog(BuildContext context) async {
    _performPreview(context);
  }

  Future<void> _performPreview(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final image = await viewModel.generatePreviewImage(context);

    if (!mounted) return;
    Navigator.pop(context);

    if (image != null) {
      _showImagePreviewDialog(image);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate preview'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showImagePreviewDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.7,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport(
    BuildContext context,
    String location,
    String name,
  ) async {
    final success = await viewModel.exportAndClear(
      context,
      location: location.isEmpty ? null : location,
      name: name.isEmpty ? null : name,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report shared and checks cleared!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No checked items to export'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _performSaveToDevice(
    BuildContext context,
    String location,
    String name,
  ) async {
    final filePath = await viewModel.saveToDeviceAndClear(
      context,
      location: location.isEmpty ? null : location,
      name: name.isEmpty ? null : name,
    );

    if (!mounted) return;

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to:\n$filePath'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save report'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
