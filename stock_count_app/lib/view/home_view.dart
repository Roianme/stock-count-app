import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/item_model.dart';
import '../viewmodel/home_view_model.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart' as data;
import 'widgets/export_dialog.dart';
import 'widgets/preview_image_dialog.dart';
import 'widgets/app_drawer.dart';
import 'widgets/item_card_widget.dart';
import '../utils/index.dart';
import 'category_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});
  final ItemRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel viewModel;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(
      allCategories: Category.values,
      repository: widget.repository,
    );
    viewModel.addListener(_handleViewModelChanges);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    viewModel.removeListener(_handleViewModelChanges);
    viewModel.dispose();
    super.dispose();
  }

  void _handleViewModelChanges() {
    if (!mounted) return;
    // Handle any notifications from ViewModel
    if (viewModel.showMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.showMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
      viewModel.clearMessage();
    }

    if (viewModel.previewImage != null) {
      _showImagePreviewDialog(viewModel.previewImage!);
      viewModel.clearPreviewImage();
    }

    if (viewModel.shouldShowExportDialog) {
      _showExportDialog();
      viewModel.clearExportDialogFlag();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        // Use the same view for all modes - filter items by currentLocation
        final categories = viewModel.visibleCategories;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: context.theme.background,
          appBar: _buildAppBar(),
          drawer: AppDrawer(
            currentLocation: viewModel.currentLocation,
            onLocationChanged: viewModel.setLocation,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxContentWidth = math.min(constraints.maxWidth, 1100.0);
                final isWide = constraints.maxWidth >= 900;
                final statusControlWidth = isWide ? 170.0 : 130.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      children: [
                        _buildSearchBar(isWide: isWide),
                        _buildSectionTitle(),
                        Expanded(
                          child: _buildListView(
                            categories,
                            statusControlWidth,
                            isWide: isWide,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.theme.surface,
      elevation: 0,
      title: Text(
        '${viewModel.currentLocation.displayName} - Stock Count',
        style: context.theme.appBarTitle,
      ),
      leading: IconButton(
        icon: Icon(Icons.menu, color: context.theme.textPrimary),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sync, color: context.theme.textPrimary),
          onPressed: () {
            viewModel.reload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View refreshed'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          tooltip: 'Reload view',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Tooltip(
            message: 'Preview checked items',
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _handlePreviewAction,
                child: Text(
                  'Preview',
                  style: TextStyle(
                    color: context.theme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Tooltip(
            message: 'Export/Share checked items',
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _handleExportAction,
                child: Text(
                  'Export',
                  style: TextStyle(
                    color: context.theme.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({required bool isWide}) {
    return Container(
      color: context.theme.background,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive.horizontalPadding(),
        vertical: context.responsive.verticalPadding(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: context.theme.searchBarDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  return TextField(
                    controller: _searchController,
                    onChanged: (text) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 200),
                        () => viewModel.setQuery(text),
                      );
                    },
                    style: TextStyle(fontSize: context.responsive.fontSize(16)),
                    decoration: InputDecoration(
                      hintText: 'Search for keyword',
                      hintStyle: AppTheme.searchHint,
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.theme.textSecondary,
                      ),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color: context.theme.textSecondary,
                              ),
                              onPressed: () {
                                _searchDebounce?.cancel();
                                _searchController.clear();
                                // Remove focus so keyboard closes after clearing search
                                FocusScope.of(context).unfocus();
                                viewModel.setQuery('');
                              },
                              tooltip: 'Clear search',
                            )
                          : null,
                      fillColor: context.theme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: context.isLandscape ? 12 : 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    final titleText = viewModel.getSectionTitle();
    final showResetButton = !viewModel.isSearching;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveSizes.spacingLarge,
        vertical: context.responsive.verticalPadding(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titleText,
              style: context.theme.sectionTitle.copyWith(
                fontSize: context.responsive.fontSize(20),
              ),
            ),
          ),
          if (showResetButton)
            TextButton.icon(
              onPressed: _handleResetAll,
              icon: Icon(Icons.refresh, size: 18, color: context.theme.accent),
              label: Text(
                'Reset',
                style: TextStyle(
                  color: context.theme.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleResetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset items?'),
        content: const Text(
          'This will reset all item statuses, quantities, and checks back to their defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Reset', style: TextStyle(color: context.theme.accent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await viewModel.resetAllToDefaults();
  }

  void _handlePreviewAction() {
    if (!viewModel.hasCheckedItems) {
      viewModel.setMessage('Please check items first');
      return;
    }
    viewModel.requestPreviewImage(context);
  }

  void _handleExportAction() {
    if (!viewModel.hasCheckedItems) {
      viewModel.setMessage('Please check items first');
      return;
    }
    viewModel.requestExportDialog();
  }

  Widget _buildListView(
    List<Category> categories,
    double statusControlWidth, {
    required bool isWide,
  }) {
    final itemsByCategory = viewModel.groupedItems(categories);

    // Filter items based on search query
    final filteredItemsByCategory = <Category, List<Item>>{};
    if (viewModel.isSearching) {
      // Only show items that match the search
      final matchedIds = viewModel.matchedItems.map((i) => i.id).toSet();
      for (final category in categories) {
        final items = itemsByCategory[category] ?? [];
        final filtered = items
            .where((item) => matchedIds.contains(item.id))
            .toList();
        if (filtered.isNotEmpty) {
          filteredItemsByCategory[category] = filtered;
        }
      }
    } else {
      // Show all items
      filteredItemsByCategory.addAll(itemsByCategory);
    }

    final categoriesWithItems = categories
        .where((cat) => (filteredItemsByCategory[cat] ?? []).isNotEmpty)
        .toList();

    if (categoriesWithItems.isEmpty) {
      return const Center(child: Text('No items'));
    }

    final statusWidth = (isWide || context.isLandscape)
        ? 130.0
        : statusControlWidth;

    final useMultiColumn = isWide || context.isLandscape;

    final loopLength = categoriesWithItems.length;

    // Single column for mobile/portrait
    if (!useMultiColumn) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final category = categoriesWithItems[index % loopLength];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              RepaintBoundary(
                key: ValueKey('h-${category.name}-$index'),
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(color: category.color),
                  width: double.infinity,
                  child: Text(
                    category.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Single column list
              ...filteredItemsByCategory[category]!.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: RepaintBoundary(
                    key: ValueKey('i-${item.id}-$index'),
                    child: _buildItemCard(item, statusWidth, hideIcon: true),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // Multi-column masonry for wide screens/landscape
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final category = categoriesWithItems[index % loopLength];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            RepaintBoundary(
              key: ValueKey('h-${category.name}-$index'),
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(color: category.color),
                width: double.infinity,
                child: Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Masonry layout for items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _MasonryLayout(
                items: filteredItemsByCategory[category]!,
                statusWidth: statusWidth,
                buildItemCard: (item) =>
                    _buildItemCard(item, statusWidth, hideIcon: true),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(
    Item item,
    double statusControlWidth, {
    bool hideIcon = true,
  }) {
    return ItemCardWidget(
      item: item,
      statusControlWidth: statusControlWidth,
      hideIcon: hideIcon,
      isListView: true,
      onCheckChanged: () {
        viewModel.setItemChecked(item.id, !item.isChecked);
      },
      onQuantityChanged: (quantity) {
        viewModel.setItemQuantity(item.id, quantity);
      },
      onStatusChanged: (newStatus) {
        viewModel.updateItemStatus(item.id, newStatus);
        if (newStatus == ItemStatus.urgent) {
          viewModel.setItemChecked(item.id, true);
        } else if (newStatus == ItemStatus.quantity) {
          if (item.quantity > 0) {
            viewModel.setItemChecked(item.id, true);
          }
        } else {
          viewModel.setItemChecked(item.id, true);
        }
      },
      onUnitChanged: (data.ItemUnitOption newUnit) {
        final newStatus = newUnit.isUrgent
            ? ItemStatus.urgent
            : ItemStatus.quantity;
        viewModel.updateItemUnit(item.id, newUnit.label, newStatus);
        viewModel.setItemChecked(item.id, true);
      },
      showItemNameInColumn: true,
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        viewModel: viewModel,
        onExportSuccess: _showExportSuccess,
        onSaveSuccess: _showSaveSuccess,
        onError: _showError,
      ),
    );
  }

  void _showImagePreviewDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => PreviewImageDialog(imageBytes: imageBytes),
    );
  }

  void _showExportSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report shared successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSuccess(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(filePath),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// Masonry layout that distributes items across 3 columns
class _MasonryLayout extends StatelessWidget {
  final List<Item> items;
  final double statusWidth;
  final Widget Function(Item) buildItemCard;

  const _MasonryLayout({
    required this.items,
    required this.statusWidth,
    required this.buildItemCard,
  });

  @override
  Widget build(BuildContext context) {
    // Distribute items across 3 columns in a round-robin fashion
    final columns = <List<Item>>[[], [], []];

    for (int i = 0; i < items.length; i++) {
      columns[i % 3].add(items[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int colIndex = 0; colIndex < 3; colIndex++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: colIndex == 0 ? 0 : 2,
                right: colIndex == 2 ? 0 : 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in columns[colIndex])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RepaintBoundary(
                        key: ValueKey('i-${item.id}'),
                        child: buildItemCard(item),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
