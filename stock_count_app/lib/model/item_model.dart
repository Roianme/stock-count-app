import 'package:flutter/material.dart';

enum ItemStatus { zero, low, ok, urgent }

enum Category {
  bbqGrill,
  warehouse,
  essentials,
  spices,
  rawItems,
  drinks,
  misc,
  supplier,
  produce,
  filipinoSupplier,
  colesWoolies,
}

class Item {
  final int id;
  final String name;
  final Category category;
  final ItemStatus status;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
  });
}

// Extension to add display properties to Category enum
extension CategoryExtension on Category {
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
        return Icons.agriculture;
      case Category.filipinoSupplier:
        return Icons.store;
      case Category.colesWoolies:
        return Icons.shopping_cart;
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
    }
  }
}
