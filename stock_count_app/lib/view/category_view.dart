import 'package:flutter/material.dart';
import '../model/item_model.dart';
import '../viewmodel/category_view_model.dart';
import '../data/item_repository.dart';
import '../data/item_data.dart' as data;
import 'widgets/item_card_widget.dart';
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
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: viewModel.itemsInCategory.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        viewModel.itemsInCategory[index];
                                    return _buildCategoryItemCard(
                                      item,
                                      context.statusControlWidth,
                                      context.isLandscape,
                                    );
                                  },
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

  Widget _buildCategoryItemCard(
    Item item,
    double statusControlWidth,
    bool isLandscape,
  ) {
    return ItemCardWidget(
      item: item,
      statusControlWidth: statusControlWidth,
      onCheckChanged: () {
        viewModel.toggleItemChecked(item.id);
      },
      onQuantityChanged: (quantity) {
        viewModel.setItemQuantity(item.id, quantity);
      },
      onStatusChanged: (newStatus) {
        viewModel.updateItemStatus(item.id, newStatus);
        if (newStatus == ItemStatus.urgent) {
          viewModel.toggleItemChecked(item.id);
        } else if (newStatus == ItemStatus.quantity) {
          if (item.quantity > 0) {
            viewModel.toggleItemChecked(item.id);
          }
        } else {
          viewModel.toggleItemChecked(item.id);
        }
      },
      onUnitChanged: (data.ItemUnitOption newUnit) {
        final newStatus = newUnit.isUrgent
            ? ItemStatus.urgent
            : ItemStatus.quantity;
        viewModel.updateItemUnit(item.id, newUnit.label, newStatus);
        viewModel.toggleItemChecked(item.id);
      },
      showItemNameInColumn: false,
    );
  }
}

extension CategoryUI on Category {
  String get displayName {
    switch (this) {
      case Category.bbqGrill:
        return 'BBQ Grill';
      case Category.warehouse:
        return 'Warehouse';
      case Category.essentials:
        return 'Essentials';
      case Category.spices:
        return 'Spices';
      case Category.rawItems:
        return 'Raw Items';
      case Category.drinks:
        return 'Drinks';
      case Category.misc:
        return 'Misc';
      case Category.supplier:
        return 'Supplier';
      case Category.produce:
        return 'Produce';
      case Category.filipinoSupplier:
        return 'Filipino Supplier';
      case Category.colesWoolies:
        return 'Coles/Woolies';
      case Category.chemicals:
        return 'Chemicals';
      case Category.dessert:
        return 'Dessert';
    }
  }

  Color get color {
    switch (this) {
      case Category.bbqGrill:
        return Colors.deepOrange;
      case Category.warehouse:
        return Colors.blueGrey;
      case Category.essentials:
        return Colors.blue;
      case Category.spices:
        return Colors.brown;
      case Category.rawItems:
        return Colors.grey;
      case Category.drinks:
        return Colors.cyan;
      case Category.misc:
        return Colors.purple;
      case Category.supplier:
        return Colors.yellow;
      case Category.produce:
        return Colors.lightGreen;
      case Category.filipinoSupplier:
        return Colors.red;
      case Category.colesWoolies:
        return Colors.orange;
      case Category.chemicals:
        return Colors.teal;
      case Category.dessert:
        return Colors.pink;
    }
  }
}

extension ItemStatusUI on ItemStatus {
  String get displayName {
    switch (this) {
      case ItemStatus.urgent:
        return 'Urgent';
      case ItemStatus.quantity:
        return 'Quantity';
    }
  }
}
