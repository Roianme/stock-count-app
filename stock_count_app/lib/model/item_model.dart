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
