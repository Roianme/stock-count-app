import 'package:flutter/material.dart';

/// Category icons selectable in the Manage Categories screen.
/// Must stay const: the web icon tree shaker only keeps glyphs of const
/// IconData instances, and categories reference icons at runtime by code
/// point (non-const `IconData(...)` constructions fail the web release build).
const List<IconData> kCategoryIcons = [
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

/// Additional icons used by legacy seed categories but not offered in the
/// picker. Const so their glyphs are included in the tree-shaken font.
const List<IconData> kCategorySeedIcons = [
  Icons.soup_kitchen_outlined,
  Icons.shopping_basket_outlined,
];

/// Fallback glyph for unknown stored code points.
const IconData kCategoryFallbackIcon = Icons.help_outline;

/// Resolves a stored icon code point to its const [IconData].
/// Never constructs IconData at runtime (breaks web icon tree shaking).
IconData categoryIcon(int codePoint) {
  for (final icon in kCategoryIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  for (final icon in kCategorySeedIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  return kCategoryFallbackIcon;
}
