import '../model/item_model.dart';

final List<Item> items = [
  // BBQ GRILL
  Item(
    id: 1,
    name: 'pork skewers',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
    modes: {Mode.city, Mode.hp},
  ),
  Item(
    id: 2,
    name: 'chicken skewers',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 3,
    name: 'isaw s',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 4,
    name: 'isaw o',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 5,
    name: 'pork ears',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 6,
    name: 'pork belly',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 7,
    name: 'chicken feet',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 8,
    name: 'beef patties',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 9,
    name: 'chicken inasal',
    category: Category.bbqGrill,
    status: ItemStatus.quantity,
  ),

  // RAW ITEMS
  Item(
    id: 10,
    name: 'pork face',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 11,
    name: 'pork trim',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 12,
    name: 'pork pata (raw)',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 13,
    name: 'beef brisket',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 14,
    name: 'beef mince',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 15,
    name: 'beef bones',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 16,
    name: 'chicken pieces',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 17,
    name: 'chicken fat',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 18,
    name: 'chicken skin',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 19,
    name: 'daing na bangus',
    category: Category.rawItems,
    status: ItemStatus.quantity,
  ),

  // WAREHOUSE
  Item(
    id: 20,
    name: 'tak tak',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 21,
    name: 'soy milk',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 22,
    name: 'tofu',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 23,
    name: 'frozen ube',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 24,
    name: 'sago',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 25,
    name: 'taho powder',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 26,
    name: 'corn starch',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 27,
    name: 'yellow food color',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 28,
    name: 'red food color',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 29,
    name: 'ube flavor',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 30,
    name: 'staff gloves large',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 31,
    name: 'staff gloves medium',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 32,
    name: 'bin bags',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 33,
    name: 'basahan',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 34,
    name: 'takeaway sauce cup',
    category: Category.warehouse,
    status: ItemStatus.quantity,
  ),

  // ESSENTIALS
  Item(
    id: 35,
    name: 'vinegar',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 36,
    name: 'plain flour (kg)',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 37,
    name: 'soda water',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 38,
    name: 'tomato sauce',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 39,
    name: 'sprite 1.25L',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 40,
    name: 'white sugar',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 41,
    name: 'brown sugar (sack)',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 42,
    name: 'evaporated milk',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 43,
    name: 'corn flakes',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 44,
    name: 'chocolate syrup',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 45,
    name: 'pasta',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 46,
    name: 'vanilla flavor',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 47,
    name: 'eta mayo',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 48,
    name: 'vegan mayo',
    category: Category.essentials,
    status: ItemStatus.quantity,
  ),

  // SPICES
  Item(
    id: 49,
    name: 'black pepper',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 50,
    name: 'salt',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 51,
    name: 'onion powder',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 52,
    name: 'garlic powder',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 53,
    name: 'star anise',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 54,
    name: 'bay leaf',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 55,
    name: 'fried shallots',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 56,
    name: 'vetsin',
    category: Category.spices,
    status: ItemStatus.quantity,
  ),

  // DRINKS
  Item(
    id: 57,
    name: 'coke',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 58,
    name: 'coke no sugar',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 59,
    name: 'sprite',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 60,
    name: 'fanta',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 61,
    name: 'water',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 62,
    name: 'c2 500ml',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 63,
    name: 'zesto',
    category: Category.drinks,
    status: ItemStatus.quantity,
  ),

  // MISC
  Item(
    id: 64,
    name: 'rice',
    category: Category.misc,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 65,
    name: 'garlic oil',
    category: Category.misc,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 66,
    name: 'vegetable oil',
    category: Category.misc,
    status: ItemStatus.quantity,
  ),

  // SUPPLIER
  Item(
    id: 67,
    name: 'fishball',
    category: Category.supplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 68,
    name: 'chicken powder',
    category: Category.supplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 69,
    name: 'quail eggs',
    category: Category.supplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 70,
    name: 'jackfruit',
    category: Category.supplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 71,
    name: 'champignon',
    category: Category.supplier,
    status: ItemStatus.quantity,
  ),

  // COLES/WOOLIES
  Item(
    id: 72,
    name: 'hotdog (bags)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 73,
    name: 'cheese block',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 74,
    name: 'thickened cream',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 75,
    name: 'vanilla ice cream',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 76,
    name: 'skim milk powder (bags)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 77,
    name: 'frozen strawberry (bags)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 78,
    name: 'soda water',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 79,
    name: 'large zip lock (boxes)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 80,
    name: 'small freezer bag (bags)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),

  // PRODUCE
  Item(
    id: 81,
    name: 'salad mix',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 82,
    name: 'tomato',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 83,
    name: 'cucumber',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 84,
    name: 'lemon',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 85,
    name: 'garlic',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 86,
    name: 'fresh ginger',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 87,
    name: 'tub ginger',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 88,
    name: 'brown onion',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 89,
    name: 'red onion',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 90,
    name: 'green chili',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 91,
    name: 'red chili',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 92,
    name: 'sweet potato',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 93,
    name: 'red capsicum',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 95,
    name: 'eggs',
    category: Category.produce,
    status: ItemStatus.quantity,
  ),

  // FILIPINO SUPPLIER
  Item(
    id: 96,
    name: 'soy sauce',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 97,
    name: 'spaghetti sauce',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 98,
    name: 'beef cubes',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 99,
    name: 'Argentina liver spread',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 100,
    name: 'glutinous rice',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 101,
    name: 'knorr liquid seasoning',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 102,
    name: 'mang tomas',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 103,
    name: 'white beans',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 104,
    name: 'kaong',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 105,
    name: 'nata',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 106,
    name: 'frozen saba',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 107,
    name: 'gulaman powder (box)',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 108,
    name: 'frozen ube',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 109,
    name: 'scramble powder',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 110,
    name: 'chocolate wafer (container)',
    category: Category.filipinoSupplier,
    status: ItemStatus.quantity,
  ),

  Item(
    id: 111,
    name: 'toilet paper',
    modes: {Mode.manager},
    status: ItemStatus.quantity,
  ),
  Item(
    id: 112,
    name: 'dorothy',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 113,
    name: 'harry',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 114,
    name: 'barry',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 115,
    name: 'louie',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 116,
    name: 'ada',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 117,
    name: 'samantha',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 118,
    name: 'kent (ken)',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 119,
    name: 'hannah',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 120,
    name: 'ice (bags)',
    category: Category.colesWoolies,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 121,
    name: 'hand wash',
    category: Category.chemicals,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 122,
    name: 'brown sugar (blocks)',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 123,
    name: 'condensed milk',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 124,
    name: 'corn kernels',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 125,
    name: 'creamed corn',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 126,
    name: 'full cream milk',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 127,
    name: 'leche flan',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 128,
    name: 'mango (diced)',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 129,
    name: 'marshmallows',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 130,
    name: 'nutella',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 131,
    name: 'pandan essence',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 132,
    name: 'pinipig',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 133,
    name: 'strawberry essence',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 134,
    name: 'vanilla extract',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 135,
    name: 'violet food color',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 136,
    name: 'spring roll wrap',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 137,
    name: 'iced candy',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 138,
    name: 'puto bumbong',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 139,
    name: 'curly fries ',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 140,
    name: 'squid ball',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 141,
    name: 'fish ball ',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
  Item(
    id: 142,
    name: 'kikiam',
    category: Category.dessert,
    status: ItemStatus.quantity,
  ),
];

class ItemUnitOption {
  final String label;
  final bool isUrgent;

  const ItemUnitOption(this.label, {this.isUrgent = false});
}

const _taktakOptions = [
  ItemUnitOption('¼ or less', isUrgent: true),
  ItemUnitOption('½ or less'),
  ItemUnitOption('<1'),
  ItemUnitOption('>½'),
  ItemUnitOption('1'),
  ItemUnitOption('2'),
];

const _basahanOptions = [
  ItemUnitOption('<6', isUrgent: true),
  ItemUnitOption('>6'),
  ItemUnitOption('Unopened'),
  ItemUnitOption('1-3'),
];

const _spiceOptions = [
  ItemUnitOption('<½', isUrgent: true),
  ItemUnitOption('<1'),
  ItemUnitOption('>1'),
];

const _drinkBoxOptions = [
  ItemUnitOption('<1', isUrgent: true),
  ItemUnitOption('1-10 (Unopened)'),
];

const _sauceCupOptions = [
  ItemUnitOption('¼', isUrgent: true),
  ItemUnitOption('½'),
  ItemUnitOption('1-5'),
];

const _etaOptions = [
  ItemUnitOption('0', isUrgent: true),
  ItemUnitOption('1x3.5'),
  ItemUnitOption('2x3.5'),
  ItemUnitOption('¼ (20L)'),
  ItemUnitOption('½ (20L)'),
  ItemUnitOption('<1 (20L)'),
  ItemUnitOption('1'),
  ItemUnitOption('2'),
];

const _veganOptions = [
  ItemUnitOption('<1', isUrgent: true),
  ItemUnitOption('1'),
  ItemUnitOption('2'),
  ItemUnitOption('3'),
];

const _garlicOilOptions = [
  ItemUnitOption('½ jar', isUrgent: true),
  ItemUnitOption('1-5 jars'),
];

const _quailOptions = [
  ItemUnitOption('<½ box', isUrgent: true),
  ItemUnitOption('<1 box'),
  ItemUnitOption('1-6 boxes'),
];

const _jackOptions = [
  ItemUnitOption('<½ box', isUrgent: true),
  ItemUnitOption('<1 box'),
  ItemUnitOption('1-3 boxes'),
];

const _saladOptions = [
  ItemUnitOption('½ box', isUrgent: true),
  ItemUnitOption('<1'),
  ItemUnitOption('1-5 boxes'),
];

const _tomatoOptions = [
  ItemUnitOption('<10 pcs', isUrgent: true),
  ItemUnitOption('>10 pcs'),
  ItemUnitOption('>20 pcs'),
];

const _lemonOptions = [
  ItemUnitOption('<6 pcs', isUrgent: true),
  ItemUnitOption('>6 pcs'),
  ItemUnitOption('>12 pcs'),
];

const _garlicBagOptions = [
  ItemUnitOption('<½ bag', isUrgent: true),
  ItemUnitOption('>½ bag'),
  ItemUnitOption('1-3 bags'),
];

const _freshGingerOptions = [
  ItemUnitOption('<6 pcs', isUrgent: true),
  ItemUnitOption('>6 pcs'),
];

const _tubGingerOptions = [
  ItemUnitOption('<½', isUrgent: true),
  ItemUnitOption('>½'),
  ItemUnitOption('1'),
  ItemUnitOption('2'),
];

const _onionSackOptions = [
  ItemUnitOption('¼ or less', isUrgent: true),
  ItemUnitOption('½ or less'),
  ItemUnitOption('<1'),
  ItemUnitOption('>½'),
  ItemUnitOption('1'),
  ItemUnitOption('>1'),
];

const _greenChiliOptions = [
  ItemUnitOption('<10 pcs', isUrgent: true),
  ItemUnitOption('>10 pcs'),
  ItemUnitOption('>15 pcs'),
];

const _redChiliOptions = [
  ItemUnitOption('<5 pcs', isUrgent: true),
  ItemUnitOption('>5 pcs'),
];

const _eggsOptions = [
  ItemUnitOption('<12 pcs', isUrgent: true),
  ItemUnitOption('>12'),
  ItemUnitOption('>30'),
  ItemUnitOption('2 trays'),
  ItemUnitOption('≤6 trays'),
];

const _beefCubesOptions = [
  ItemUnitOption('<10 pcs', isUrgent: true),
  ItemUnitOption('>10 pcs'),
  ItemUnitOption('<1 box'),
  ItemUnitOption('1-4 boxes'),
];

const _liverSpreadOptions = [
  ItemUnitOption('<5', isUrgent: true),
  ItemUnitOption('>5'),
  ItemUnitOption('>10'),
  ItemUnitOption('1-2 boxes'),
];

const _glutinousOptions = [
  ItemUnitOption('¼ or less', isUrgent: true),
  ItemUnitOption('½ or less'),
  ItemUnitOption('<1'),
  ItemUnitOption('>½'),
  ItemUnitOption('1'),
  ItemUnitOption('2'),
];

const _mangTomasOptions = [
  ItemUnitOption('<2', isUrgent: true),
  ItemUnitOption('>2'),
  ItemUnitOption('>9'),
  ItemUnitOption('1 box'),
  ItemUnitOption('2 box'),
];

const _knorrOptions = [
  ItemUnitOption('<2 pcs', isUrgent: true),
  ItemUnitOption('3-8 pcs'),
];

const _beansOptions = [
  ItemUnitOption('<6', isUrgent: true),
  ItemUnitOption('>6'),
  ItemUnitOption('1-2 boxes'),
];

const _scrambleOptions = [
  ItemUnitOption('<1 bag', isUrgent: true),
  ItemUnitOption('1-8 bags'),
];

const _taktakIds = [20, 24, 25, 29, 40, 41, 43];
const _basahanIds = [33, 42, 45];
const _spiceIds = [49, 50, 51, 52, 53, 54, 55, 56];
const _drinkIds = [57, 58, 59, 60, 61, 62, 63];
const _chemicalIds = [112, 113, 114, 115, 116, 117, 118, 119, 121];

/// Map of itemId -> allowed unit options for that item.
/// Add your item-specific units here. If an itemId is not listed, it will
/// fall back to the normal status/quantity control.
final Map<int, List<ItemUnitOption>> itemUnitOptionsById = {
  // Warehouse + selected items (taktak set)
  for (final id in _taktakIds) id: _taktakOptions,

  // Basahan/Evap/Pasta set
  for (final id in _basahanIds) id: _basahanOptions,

  // Others (specific)
  34: _sauceCupOptions,
  47: _etaOptions,
  48: _veganOptions,

  // Spices (all spices)
  for (final id in _spiceIds) id: _spiceOptions,

  // Drinks (boxes)
  for (final id in _drinkIds) id: _drinkBoxOptions,

  // Misc
  65: _garlicOilOptions,

  // Supplier (Asian)
  69: _quailOptions,
  70: _jackOptions,

  // Produce
  81: _saladOptions,
  82: _tomatoOptions,
  84: _lemonOptions,
  85: _garlicBagOptions,
  86: _freshGingerOptions,
  87: _tubGingerOptions,
  88: _onionSackOptions,
  89: _onionSackOptions,
  90: _greenChiliOptions,
  91: _redChiliOptions,
  95: _eggsOptions,

  // Filipino Supplier
  98: _beefCubesOptions,
  99: _liverSpreadOptions,
  100: _glutinousOptions,
  102: _mangTomasOptions,
  101: _knorrOptions,
  103: _beansOptions,
  104: _beansOptions,
  105: _beansOptions,
  109: _scrambleOptions,

  // Chemicals (same as taktak set)
  for (final id in _chemicalIds) id: _taktakOptions,
};

List<ItemUnitOption> unitOptionsForItem(Item item) {
  return itemUnitOptionsById[item.id] ?? const [];
}

ItemUnitOption? selectedUnitOption(Item item) {
  final options = itemUnitOptionsById[item.id];
  if (options == null || options.isEmpty) return null;
  final unit = item.unit;
  if (unit == null || unit.isEmpty) return null;
  for (final option in options) {
    if (option.label == unit) return option;
  }
  return null;
}

// Mutable map that will hold the seed data - populated once before persistence loads
Map<int, Item> seedItemsById = {};

// Initialize the seed data with the original values (before any persistence loading)
// This should be called from main.dart BEFORE items are loaded from storage
void initializeSeedData() {
  if (seedItemsById.isNotEmpty) return; // Only initialize once

  for (final item in items) {
    seedItemsById[item.id] = Item(
      id: item.id,
      name: item.name,
      category: item.category,
      status: item.status, // Capture the ORIGINAL status from the defined seed
      isChecked: false, // Always reset to unchecked
      quantity:
          item.quantity, // Capture the ORIGINAL quantity from the defined seed
      modes: item.modes, // Capture the ORIGINAL modes from the defined seed
      unit: item.unit, // Capture the ORIGINAL unit from the defined seed
    );
  }
}
