import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/item_model.dart';
import '../viewmodel/category_view_model.dart';
import '../data/item_repository.dart';
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
        final allChecked =
            viewModel.totalItemsCount > 0 &&
            viewModel.checkedItemsCount == viewModel.totalItemsCount;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.category.displayName),
            elevation: 0,
            actions: [
              const Text("Check All (Sure ka?)"),
              IconButton(
                icon: Icon(
                  allChecked ? Icons.check_box : Icons.check_box_outline_blank,
                ),
                tooltip: allChecked ? 'Unselect all' : 'Select all',
                onPressed: () => viewModel.setAllChecked(!allChecked),
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
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: context.responsive.verticalPadding(
          portraitValue: 8,
          landscapeValue: 4,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive.spacing(portraitValue: 12, landscapeValue: 8),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: item.isChecked,
                onChanged: (_) {
                  viewModel.toggleItemChecked(item.id);
                },
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: item.category.color.withValues(alpha: 0.12),
              child: Icon(item.category.icon, color: item.category.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: context.theme.itemName.copyWith(
                      fontSize: context.responsive.fontSize(16, 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            if (item.status != ItemStatus.pieces)
              Container(
                width: context.statusControlWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: context.theme.statusControlDecoration,
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
                width: context.statusControlWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: context.theme.statusControlDecoration,
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
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      onPressed: () {
                        viewModel.updateItemStatus(item.id, ItemStatus.ok);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
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
