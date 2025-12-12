enum ItemStatus { zero, low, ok, urgent }

class Item {
  final int id;
  final String name;
  final String category;
  final ItemStatus status;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
  });
}
