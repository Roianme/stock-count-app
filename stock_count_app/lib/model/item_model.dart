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
