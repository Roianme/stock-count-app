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
  Item(id: 5, name: 'Item 5', category: Category.spices, status: ItemStatus.ok),
];
