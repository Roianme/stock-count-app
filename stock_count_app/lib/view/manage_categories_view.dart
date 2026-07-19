import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../data/item_repository.dart';
import '../viewmodel/manage_categories_view_model.dart';

/// Predefined Material colors available for category selection.
const List<Color> _kCategoryColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

/// Predefined Material Icons relevant to food/inventory categories.
const List<IconData> _kCategoryIcons = [
  Icons.restaurant,
  Icons.restaurant_menu,
  Icons.local_drink,
  Icons.coffee,
  Icons.icecream,
  Icons.cake,
  Icons.kitchen,
  Icons.countertops,
  Icons.set_meal,
  Icons.dining,
  Icons.lunch_dining,
  Icons.dinner_dining,
  Icons.egg,
  Icons.egg_alt,
  Icons.ramen_dining,
  Icons.rice_bowl,
  Icons.takeout_dining,
  Icons.soup_kitchen,
  Icons.bakery_dining,
  Icons.breakfast_dining,
  Icons.brunch_dining,
  Icons.flatware,
  Icons.storage,
  Icons.inventory_2,
  Icons.warehouse,
  Icons.category,
  Icons.shopping_cart,
  Icons.store,
  Icons.local_grocery_store,
  Icons.science,
  Icons.clean_hands,
  Icons.emoji_food_beverage,
  Icons.outdoor_grill,
  Icons.raw_on,
  Icons.shopping_basket,
  Icons.storefront,
];

class ManageCategoriesView extends StatefulWidget {
  final ItemRepository repository;

  const ManageCategoriesView({super.key, required this.repository});

  @override
  State<ManageCategoriesView> createState() => _ManageCategoriesViewState();
}
class _ManageCategoriesViewState extends State<ManageCategoriesView> {
  late final ManageCategoriesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ManageCategoriesViewModel(repository: widget.repository);
    viewModel.addListener(_handleErrors);
  }

  @override
  void dispose() {
    viewModel.removeListener(_handleErrors);
    viewModel.dispose();
    super.dispose();
  }

  void _handleErrors() {
    if (!mounted) return;
    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Categories'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCategoryDialog(context),
            tooltip: 'Add category',
            child: const Icon(Icons.add),
          ),
          body: viewModel.categories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No categories yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Tap + to add your first category',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    return _CategoryListTile(
                      category: category,
                      onTap: () => _showCategoryDialog(
                        context,
                        existing: category,
                      ),
                      onDelete: () => _confirmDelete(context, category),
                    );
                  },
                ),
        );
      },
    );
  }
  void _confirmDelete(BuildContext context, CategoryRecord category) {
    final itemCount = viewModel.categoryItemCount(category.id);
    final isInUse = itemCount > 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isInUse ? 'Cannot Delete' : 'Delete Category'),
        content: Text(
          isInUse
              ? '"${category.name}" is used by $itemCount item(s).\n\nRemove or reassign those items first before deleting this category.'
              : 'Are you sure you want to delete "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (!isInUse)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                viewModel.deleteCategory(category.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryRecord? existing,
  }) async {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    int selectedColor = existing?.colorValue ?? Colors.blue.toARGB32();
    int selectedIcon = existing?.iconCodePoint ?? Icons.category.codePoint;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Category' : 'Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                        hintText: 'e.g. Frozen Goods',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    const Text('Color',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kCategoryColors.map((color) {
                        final isSelected = color.toARGB32() == selectedColor;
                        return GestureDetector(
                          onTap: () => setDialogState(() {
                            selectedColor = color.toARGB32();
                          }),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.black87, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Icon',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _kCategoryIcons.map((icon) {
                        final isSelected = icon.codePoint == selectedIcon;
                        return GestureDetector(
                          onTap: () => setDialogState(() {
                            selectedIcon = icon.codePoint;
                          }),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(selectedColor)
                                      .withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color: Color(selectedColor), width: 2)
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? Color(selectedColor)
                                  : Colors.grey[700],
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            IconData(selectedIcon,
                                fontFamily: 'MaterialIcons'),
                            color: Color(selectedColor),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nameController.text.isEmpty
                                  ? 'Category Preview'
                                  : nameController.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(selectedColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx, {
                      'name': nameController.text.trim(),
                      'colorValue': selectedColor,
                      'iconCodePoint': selectedIcon,
                    });
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final name = result['name'] as String;
    final colorValue = result['colorValue'] as int;
    final iconCodePoint = result['iconCodePoint'] as int;

    bool success;
    if (isEditing) {
      success = await viewModel.updateCategory(
        id: existing.id,
        name: name,
        colorValue: colorValue,
        iconCodePoint: iconCodePoint,
      );
    } else {
      success = await viewModel.addCategory(
        name: name,
        colorValue: colorValue,
        iconCodePoint: iconCodePoint,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Category updated' : 'Category added',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
class _CategoryListTile extends StatelessWidget {
  final CategoryRecord category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CategoryListTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.colorValue),
          child: Icon(
            IconData(category.iconCodePoint,
                fontFamily: category.iconFontFamily),
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Order: ${category.sortOrder}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

