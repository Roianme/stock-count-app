import 'package:flutter/material.dart';
import '../model/item_model.dart';
import '../viewmodel/category_view_model.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart' as data;
import 'widgets/item_card_widget.dart';
import 'widgets/masonry_layout.dart';
import '../utils/index.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({
    super.key,
    required this.category,
    required this.repository,
  });
  final Category category;
  final ItemRepository repository;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final CategoryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CategoryViewModel(
      widget.category,
      repository: widget.repository,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.category.displayName),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
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
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.responsive.maxContentWidth(),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: context.responsive.verticalPadding(
                            portraitValue: 16,
                            landscapeValue: 8,
                          ),
                        ),
                        Expanded(
                          child: viewModel.itemsInCategory.isEmpty
                              ? const Center(
                                  child: Text('No items in this category'),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: MasonryLayout(
                                    items: viewModel.itemsInCategory,
                                    statusWidth: context.statusControlWidth,
                                    columnCount: context.isLandscape ? 3 : 1,
                                    buildItemCard: (item) =>
                                        _buildCategoryItemCard(
                                          item,
                                          context.statusControlWidth,
                                        ),
                                  ),
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

  Widget _buildCategoryItemCard(Item item, double statusControlWidth) {
    return ItemCardWidget(
      item: item,
      statusControlWidth: statusControlWidth,
      hideIcon: true,
      onCheckChanged: () {
        viewModel.toggleItemChecked(item.id);
      },
      onQuantityChanged: (quantity) {
        viewModel.applyItemQuantityChange(item.id, quantity);
      },
      onStatusChanged: (newStatus) {
        viewModel.applyItemStatusChange(item.id, newStatus);
      },
      onUnitChanged: (data.ItemUnitOption newUnit) {
        viewModel.applyItemUnitChange(item.id, newUnit);
      },
      showItemNameInColumn: false,
    );
  }
}
