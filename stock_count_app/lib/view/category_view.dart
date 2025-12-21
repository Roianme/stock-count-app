import 'package:flutter/material.dart';
import '../model/item_model.dart';
import '../data/item_data.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key, required this.category});
  final Category category;

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late List<Item> categoryItems;

  @override
  void initState() {
    super.initState();
    // Filter items by the selected category
    categoryItems = items
        .where((item) => item.category == widget.category)
        .toList();
  }

  // Function to update item status
  void updateItemStatus(int itemId, ItemStatus newStatus) {
    setState(() {
      // Find and update the item in the list
      final index = categoryItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        // Update in the main items list as well
        final mainIndex = items.indexWhere((item) => item.id == itemId);
        if (mainIndex != -1) {
          final updatedItem = Item(
            id: items[mainIndex].id,
            name: items[mainIndex].name,
            category: items[mainIndex].category,
            status: newStatus,
          );
          items[mainIndex] = updatedItem;
          categoryItems[index] = updatedItem;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_getCategoryDisplayText(widget.category)),
      ),
      body: categoryItems.isEmpty
          ? Center(child: Text('No items in this category'))
          : ListView(
              children: categoryItems.map((item) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _getStatusDisplayText(item.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Dropdown
                        Container(
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ItemStatus>(
                              value: item.status,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black54,
                              ),
                              isExpanded: true,
                              items: ItemStatus.values.map((ItemStatus status) {
                                return DropdownMenuItem<ItemStatus>(
                                  value: status,
                                  child: Text(
                                    _getStatusDisplayText(status),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (ItemStatus? newValue) {
                                if (newValue != null) {
                                  updateItemStatus(item.id, newValue);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // Helper function to get display text for status
  String _getStatusDisplayText(ItemStatus status) {
    switch (status) {
      case ItemStatus.zero:
        return 'Zero';
      case ItemStatus.low:
        return 'Low';
      case ItemStatus.ok:
        return 'OK';
      case ItemStatus.urgent:
        return 'Urgent';
    }
  }

  // Helper function to get display text for category
  String _getCategoryDisplayText(Category category) {
    switch (category) {
      case Category.bbqGrill:
        return 'BBQ Grill';
      case Category.essentials:
        return 'Essentials';
      case Category.drinks:
        return 'Drinks';
      case Category.rawItems:
        return 'Raw Items';
      case Category.spices:
        return 'Spices';
      case Category.warehouse:
        return 'Warehouse';
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
}
