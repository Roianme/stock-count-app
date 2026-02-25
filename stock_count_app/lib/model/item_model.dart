import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'item_model.g.dart';

@HiveType(typeId: 0)
enum ItemStatus {
  @HiveField(0)
  urgent,
  @HiveField(1)
  quantity,
}

@HiveType(typeId: 1)
enum Category {
  @HiveField(0)
  bbqGrill,
  @HiveField(1)
  warehouse,
  @HiveField(2)
  essentials,
  @HiveField(3)
  spices,
  @HiveField(4)
  rawItems,
  @HiveField(5)
  drinks,
  @HiveField(6)
  misc,
  @HiveField(7)
  asianSupplier,
  @HiveField(8)
  produce,
  @HiveField(9)
  filipinoSupplier,
  @HiveField(10)
  colesWoolies,
  @HiveField(11)
  chemicals,
  @HiveField(12)
  dessert,
  @HiveField(13)
  asianGrocer,
}

enum Mode { city, cafe, hp, warehouse, manager }

extension ModeExtension on Mode {
  String get displayName {
    switch (this) {
      case Mode.city:
        return 'City';
      case Mode.cafe:
        return 'Cafe';
      case Mode.hp:
        return 'HP';
      case Mode.warehouse:
        return 'Warehouse';
      case Mode.manager:
        return 'Manager';
    }
  }

  IconData get icon {
    switch (this) {
      case Mode.city:
        return Icons.location_city;
      case Mode.cafe:
        return Icons.local_cafe;
      case Mode.hp:
        return Icons.business;
      case Mode.warehouse:
        return Icons.warehouse;
      case Mode.manager:
        return Icons.admin_panel_settings;
    }
  }
}

@HiveType(typeId: 2)
class Item {
  static int _nextId = 1;

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Category category;

  @HiveField(3)
  final ItemStatus status;

  @HiveField(4)
  final bool isChecked;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final Set<Mode> modes;

  @HiveField(7)
  final String? unit;

  Item({
    int? id,
    String? name,
    Category? category,
    ItemStatus? status,
    this.isChecked = false,
    this.quantity = 0,
    this.modes = const {Mode.city},
    this.unit,
  }) : id = id ?? _nextId++,
       name = name ?? 'Unnamed Item',
       category = category ?? Category.misc,
       status = status ?? ItemStatus.quantity {
    if (id != null && id >= _nextId) _nextId = id + 1;
  }

  Item copyWith({
    int? id,
    String? name,
    Category? category,
    ItemStatus? status,
    bool? isChecked,
    int? quantity,
    Set<Mode>? modes,
    String? unit,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      isChecked: isChecked ?? this.isChecked,
      quantity: quantity ?? this.quantity,
      modes: modes ?? this.modes,
      unit: unit ?? this.unit,
    );
  }
}

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
      case Category.asianSupplier:
        return 'Asian Supplier';
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
      case Category.asianGrocer:
        return 'Asian Grocer';
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
      case Category.asianSupplier:
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
      case Category.asianGrocer:
        return Colors.lime;
    }
  }

  IconData get icon {
    switch (this) {
      case Category.bbqGrill:
        return Icons.outdoor_grill;
      case Category.warehouse:
        return Icons.warehouse;
      case Category.essentials:
        return Icons.inventory_2;
      case Category.spices:
        return Icons.set_meal;
      case Category.rawItems:
        return Icons.raw_on;
      case Category.drinks:
        return Icons.local_drink;
      case Category.misc:
        return Icons.category;
      case Category.asianSupplier:
        return Icons.store;
      case Category.produce:
        return Icons.shopping_basket_outlined;
      case Category.filipinoSupplier:
        return Icons.storefront;
      case Category.colesWoolies:
        return Icons.shopping_cart;
      case Category.chemicals:
        return Icons.science;
      case Category.dessert:
        return Icons.cake;
      case Category.asianGrocer:
        return Icons.local_grocery_store;
    }
  }
}

extension ItemStatusExtension on ItemStatus {
  String get displayName {
    switch (this) {
      case ItemStatus.urgent:
        return 'Urgent';
      case ItemStatus.quantity:
        return 'Quantity';
    }
  }
}
