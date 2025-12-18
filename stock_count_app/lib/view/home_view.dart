import 'package:flutter/material.dart';
import '../model/item_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Item> items = [
    Item(
      id: 1,
      name: 'Item 1',
      category: Category.bbqGrill,
      status: ItemStatus.ok,
    ),
    Item(
      id: 2,
      name: 'Item 2',
      category: Category.essentials,
      status: ItemStatus.low,
    ),
    Item(
      id: 3,
      name: 'Item 3',
      category: Category.drinks,
      status: ItemStatus.urgent,
    ),
    Item(
      id: 4,
      name: 'Item 4',
      category: Category.rawItems,
      status: ItemStatus.zero,
    ),
  ];

  // Function to update item status
  void updateItemStatus(int itemId, ItemStatus newStatus) {
    setState(() {
      // Find and update the item in the list
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        // Create a new item with updated status
        final updatedItem = Item(
          id: items[index].id,
          name: items[index].name,
          category: items[index].category,
          status: newStatus,
        );
        items[index] = updatedItem;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: items.map((item) {
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
                          'Category: ${item.category.toString().split('.').last}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Simple Status Dropdown
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
}
