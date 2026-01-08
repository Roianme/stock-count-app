import 'package:flutter/material.dart';
import '../model/item_model.dart';
import '../viewmodel/category_view_model.dart';
import '../data/item_repository.dart';
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
  final Set<int> _selectedItemIds = {};
  bool _isMultiSelectMode = false;

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
            title: _isMultiSelectMode
                ? Text(
                    '${_selectedItemIds.length} item${_selectedItemIds.length == 1 ? '' : 's'} selected',
                    style: TextStyle(color: context.theme.accent),
                  )
                : Text(widget.category.displayName),
            elevation: 0,
            leading: _isMultiSelectMode
                ? IconButton(
                    icon: Icon(Icons.close, color: context.theme.accent),
                    onPressed: () {
                      setState(() {
                        _isMultiSelectMode = false;
                        _selectedItemIds.clear();
                      });
                    },
                  )
                : null,
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
        if (_isMultiSelectMode) {
          return;
        }
        viewModel.batchSetItemsChecked([item.id], !item.isChecked);
      },
      onPiecesChanged: (pieces) {
        if (_isMultiSelectMode && _selectedItemIds.isNotEmpty) {
          // Batch apply pieces to all selected items
          viewModel.batchSetItemPieces(_selectedItemIds.toList(), pieces);
          // Then check all selected items if pieces > 0
          if (pieces > 0) {
            viewModel.batchSetItemsChecked(_selectedItemIds.toList(), true);
          }
          // Exit multi-select mode
          setState(() {
            _isMultiSelectMode = false;
            _selectedItemIds.clear();
          });
        } else {
          viewModel.setItemPieces(item.id, pieces);
        }
      },
      onStatusChanged: (newStatus) {
        if (_isMultiSelectMode) {
          final idsToUpdate = {..._selectedItemIds, item.id}.toList();
          // Batch apply status to all selected items (plus the menu-target item)
          viewModel.batchUpdateItemStatus(idsToUpdate, newStatus);
          // Then check all affected items
          viewModel.batchSetItemsChecked(idsToUpdate, true);
          // Exit multi-select mode
          setState(() {
            _isMultiSelectMode = false;
            _selectedItemIds.clear();
          });
        } else {
          viewModel.updateItemStatus(item.id, newStatus);
          viewModel.batchSetItemsChecked([item.id], true);
        }
      },
      showItemNameInColumn: false,
      isMultiSelectMode: _isMultiSelectMode,
      isSelected: _selectedItemIds.contains(item.id),
      onLongPress: () {
        setState(() {
          _isMultiSelectMode = true;
          _selectedItemIds.add(item.id);
        });
      },
      onTap: () {
        setState(() {
          if (_selectedItemIds.contains(item.id)) {
            _selectedItemIds.remove(item.id);
            if (_selectedItemIds.isEmpty) {
              _isMultiSelectMode = false;
            }
          } else {
            _selectedItemIds.add(item.id);
          }
        });
      },
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
    }
  }

  IconData get icon {
    switch (this) {
      case Category.bbqGrill:
        return Icons.outdoor_grill;
      case Category.warehouse:
        return Icons.warehouse;
      case Category.essentials:
        return Icons.shopping_basket;
      case Category.spices:
        return Icons.spa;
      case Category.rawItems:
        return Icons.inventory_2;
      case Category.drinks:
        return Icons.local_drink;
      case Category.misc:
        return Icons.category;
      case Category.supplier:
        return Icons.local_shipping;
      case Category.produce:
        return Icons.eco;
      case Category.filipinoSupplier:
        return Icons.store;
      case Category.colesWoolies:
        return Icons.shopping_cart;
      case Category.chemicals:
        return Icons.science;
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
        return Colors.green;
      case Category.produce:
        return Colors.lightGreen;
      case Category.filipinoSupplier:
        return Colors.red;
      case Category.colesWoolies:
        return Colors.orange;
      case Category.chemicals:
        return Colors.teal;
    }
  }
}

extension ItemStatusUI on ItemStatus {
  String get displayName {
    switch (this) {
      case ItemStatus.zero:
        return 'Zero';
      case ItemStatus.low:
        return 'Low';
      case ItemStatus.ok:
        return 'OK';
      case ItemStatus.urgent:
        return 'Urgent';
      case ItemStatus.pieces:
        return 'Pieces';
    }
  }
}
