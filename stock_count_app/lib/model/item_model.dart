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
  chemicals,
}

class Item {
  static int _nextId = 1;

  final int id;
  final String name;
  final Category category;
  final ItemStatus status;
  final bool isChecked;

  Item({
    int? id,
    String? name,
    Category? category,
    ItemStatus? status,
    this.isChecked = false,
  }) : id = id ?? _nextId++,
       name = name ?? 'Unnamed Item',
       category = category ?? Category.misc,
       status = status ?? ItemStatus.ok {
    if (id != null && id >= _nextId) _nextId = id + 1;
  }

  Item copyWith({
    int? id,
    String? name,
    Category? category,
    ItemStatus? status,
    bool? isChecked,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
