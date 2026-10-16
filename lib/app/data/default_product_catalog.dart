import 'package:flutter/material.dart' show IconData, Icons;

class CatalogProduct {
  final String name;
  final String category;
  final String? defaultUnit;
  final List<String> aliases;

  const CatalogProduct({
    required this.name,
    required this.category,
    this.defaultUnit,
    this.aliases = const [],
  });
}

class ProductSuggestion {
  final String name;
  final String category;
  final String? unit;
  final bool fromHistory;

  const ProductSuggestion({
    required this.name,
    required this.category,
    this.unit,
    this.fromHistory = false,
  });
}

String normalizeProductName(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

const kCategoryGrocery = 'Grocery & Kitchen';
const kCategorySpices = 'Spices & Powders';
const kCategoryProduce = 'Vegetables & Fruits';
const kCategoryHousehold = 'Daily Essentials';
const kCategoryBeauty = 'Beauty & Personal Care';
const kCategoryElectronics = 'Electronics';
const kCategoryStationery = 'Stationery & Misc';

const List<CatalogProduct> kProductCatalog = [
  // A: Grocery and kitchen essentials
  CatalogProduct(name: 'Rice', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['choru', 'rice bag']),
  CatalogProduct(name: 'Matta Rice', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['red rice', 'kayamori']),
  CatalogProduct(name: 'Basmati Rice', category: kCategoryGrocery, defaultUnit: 'kg'),
  CatalogProduct(name: 'Wheat Flour', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['atta', 'gehun']),
  CatalogProduct(name: 'Maida', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['maida flour', 'all purpose flour']),
  CatalogProduct(name: 'Rava', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['sooji', 'semolina']),
  CatalogProduct(name: 'Atta', category: kCategoryGrocery, defaultUnit: 'kg'),
  CatalogProduct(name: 'Sugar', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['sarkkara']),
  CatalogProduct(name: 'Salt', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['uppu'] ),
  CatalogProduct(name: 'Jaggery', category: kCategoryGrocery, defaultUnit: 'kg', aliases: ['vellam', 'gur']),
  CatalogProduct(name: 'Cooking Oil', category: kCategoryGrocery, defaultUnit: 'L', aliases: ['oil', 'salad']),
  CatalogProduct(name: 'Coconut Oil', category: kCategoryGrocery, defaultUnit: 'L', aliases: ['thengai ennai', 'copra oil']),
  CatalogProduct(name: 'Ghee', category: kCategoryGrocery, defaultUnit: 'ml', aliases: ['nei', 'clarified butter']),
  CatalogProduct(name: 'Milk', category: kCategoryGrocery, defaultUnit: 'L', aliases: ['paal', 'doodh']),
  CatalogProduct(name: 'Curd', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['yogurt', 'thayir']),
  CatalogProduct(name: 'Butter', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['butter packet']),
  CatalogProduct(name: 'Cheese', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['cheese slice']),
  CatalogProduct(name: 'Eggs', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['egg', 'mutta', 'anda']),
  CatalogProduct(name: 'Bread', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['bread packet']),
  CatalogProduct(name: 'Tea Powder', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['tea', 'chaya', 'chai']),
  CatalogProduct(name: 'Coffee Powder', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['coffee', 'kurumul']),
  CatalogProduct(name: 'Chips', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['crisps', 'potato chips', 'banana chips']),
  CatalogProduct(name: 'Chocolate', category: kCategoryGrocery, defaultUnit: 'pack', aliases: ['choco', 'dark chocolate', 'chocolate bar']),

  // B: Indian cooking powders and spices
  CatalogProduct(name: 'Turmeric Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['turmeric', 'manjal', 'manjal podi', 'halud', 'haldi']),
  CatalogProduct(name: 'Chilli Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['chili', 'chilli', 'mulaku podi', 'mirchi powder', 'red chilli powder']),
  CatalogProduct(name: 'Kashmiri Chilli Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['kashmiri chili', 'kashmiri mulaku']),
  CatalogProduct(name: 'Coriander Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['malli podi', 'dhaniya powder', 'coriander']),
  CatalogProduct(name: 'Black Pepper Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['kurakkuthu podi', 'pepper powder']),
  CatalogProduct(name: 'Cumin Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['jeeraka podi', 'jeera powder']),
  CatalogProduct(name: 'Garam Masala', category: kCategorySpices, defaultUnit: 'pack', aliases: ['masala', 'garam masala powder']),
  CatalogProduct(name: 'Sambar Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['sambar podi', 'sambhar powder', 'sambar']),
  CatalogProduct(name: 'Rasam Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['rasam podi', 'rasam']),
  CatalogProduct(name: 'Chicken Masala', category: kCategorySpices, defaultUnit: 'pack', aliases: ['chicken masala powder']),
  CatalogProduct(name: 'Fish Masala', category: kCategorySpices, defaultUnit: 'pack', aliases: ['meen masala', 'fish curry masala']),
  CatalogProduct(name: 'Meat Masala', category: kCategorySpices, defaultUnit: 'pack'),
  CatalogProduct(name: 'Biriyani Masala', category: kCategorySpices, defaultUnit: 'pack', aliases: ['biryani masala']),
  CatalogProduct(name: 'Curry Powder', category: kCategorySpices, defaultUnit: 'pack', aliases: ['curry masala']),
  CatalogProduct(name: 'Ginger-Garlic Paste', category: kCategorySpices, defaultUnit: 'pack', aliases: ['ginglic', 'garlic paste', 'ginger paste', 'inji-pundu']),
  CatalogProduct(name: 'Mustard Seeds', category: kCategorySpices, defaultUnit: 'pack', aliases: ['kadugu', 'mustard', 'rai']),
  CatalogProduct(name: 'Cumin Seeds', category: kCategorySpices, defaultUnit: 'pack', aliases: ['jeeraka', 'jeera', 'cumin']),
  CatalogProduct(name: 'Fenugreek Seeds', category: kCategorySpices, defaultUnit: 'pack', aliases: ['ureyyi', 'methi']),
  CatalogProduct(name: 'Asafoetida', category: kCategorySpices, defaultUnit: 'pack', aliases: ['hing', 'kayam']),
  CatalogProduct(name: 'Cardamom', category: kCategorySpices, defaultUnit: 'g', aliases: ['elakkai', 'elaichi']),
  CatalogProduct(name: 'Cinnamon', category: kCategorySpices, defaultUnit: 'g', aliases: ['karuvapatt', 'dalchini']),
  CatalogProduct(name: 'Cloves', category: kCategorySpices, defaultUnit: 'g', aliases: ['krrambu', 'laung']),
  CatalogProduct(name: 'Black Pepper', category: kCategorySpices, defaultUnit: 'g', aliases: ['kuruvaratti', 'kali mirchi', 'pepper']),
  CatalogProduct(name: 'Dry Red Chilli', category: kCategorySpices, defaultUnit: 'pack', aliases: ['dry chilli', 'sukka mulaku', 'red chilli']),

  // C: Vegetables and fruits
  CatalogProduct(name: 'Onion', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['ullulli', 'pyaz', 'onions']),
  CatalogProduct(name: 'Tomato', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['thakkali', 'tamatar']),
  CatalogProduct(name: 'Potato', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['ulladha', 'aloo', 'potatoes']),
  CatalogProduct(name: 'Carrot', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['carrots', 'gajar']),
  CatalogProduct(name: 'Beans', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['French beans', 'payar']),
  CatalogProduct(name: 'Cabbage', category: kCategoryProduce, defaultUnit: 'piece', aliases: ['moola']),
  CatalogProduct(name: 'Cauliflower', category: kCategoryProduce, defaultUnit: 'piece', aliases: ['phool gobhi']),
  CatalogProduct(name: 'Cucumber', category: kCategoryProduce, defaultUnit: 'piece', aliases: ['kheera', 'cucumbers']),
  CatalogProduct(name: 'Green Chilli', category: kCategoryProduce, defaultUnit: 'g', aliases: ['pacha mulaku', 'green chili']),
  CatalogProduct(name: 'Ginger', category: kCategoryProduce, defaultUnit: 'g', aliases: ['inji']),
  CatalogProduct(name: 'Garlic', category: kCategoryProduce, defaultUnit: 'g', aliases: ['thudha', 'pundu', 'lehsun']),
  CatalogProduct(name: 'Curry Leaves', category: kCategoryProduce, defaultUnit: 'pack', aliases: ['karuveppilai', 'kadi patta']),
  CatalogProduct(name: 'Coriander Leaves', category: kCategoryProduce, defaultUnit: 'pack', aliases: ['malli', 'cilantro', 'dhaniya leaves']),
  CatalogProduct(name: 'Mint Leaves', category: kCategoryProduce, defaultUnit: 'pack', aliases: ['pudhina', 'mint', 'puddina']),
  CatalogProduct(name: 'Coconut', category: kCategoryProduce, defaultUnit: 'piece', aliases: ['thenga', 'narikel', 'copra']),
  CatalogProduct(name: 'Banana', category: kCategoryProduce, defaultUnit: 'pack', aliases: ['pasola', 'kela', 'bananas', 'nendran', 'nendran banana']),
  CatalogProduct(name: 'Apple', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['appam', 'seeb', 'apples']),
  CatalogProduct(name: 'Orange', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['orange fruit', 'malta']),
  CatalogProduct(name: 'Grapes', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['draksha', 'grape']),
  CatalogProduct(name: 'Mango', category: kCategoryProduce, defaultUnit: 'kg', aliases: ['manga', 'aam', 'mangoes']),
  CatalogProduct(name: 'Lemon', category: kCategoryProduce, defaultUnit: 'pack', aliases: ['elichima', 'nimma', 'lemons']),
  CatalogProduct(name: 'Turmeric (Fresh)', category: kCategoryProduce, defaultUnit: 'g', aliases: ['fresh turmeric', 'inji manjal']),

  // D: Daily-use household items
  CatalogProduct(name: 'Bath Soap', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['soap', 'soaps', 'bathing soap']),
  CatalogProduct(name: 'Hand Wash', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['handwash', 'liquid soap']),
  CatalogProduct(name: 'Toothpaste', category: kCategoryHousehold, defaultUnit: 'piece', aliases: ['paste', 'tooth paste', 'peda']),
  CatalogProduct(name: 'Toothbrush', category: kCategoryHousehold, defaultUnit: 'piece', aliases: ['tooth brush']),
  CatalogProduct(name: 'Shampoo', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['hair wash']),
  CatalogProduct(name: 'Conditioner', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['hair conditioner']),
  CatalogProduct(name: 'Laundry Detergent', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['detergent', 'detergent powder', 'atapovittu']),
  CatalogProduct(name: 'Washing Powder', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['washing soda']),
  CatalogProduct(name: 'Dishwashing Liquid', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['villayattu soap', 'dish soap', 'utensil cleaner']),
  CatalogProduct(name: 'Dishwashing Bar', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['dish bar']),
  CatalogProduct(name: 'Floor Cleaner', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['floor soap', 'thettu soap']),
  CatalogProduct(name: 'Toilet Cleaner', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['toilet soap']),
  CatalogProduct(name: 'Toilet Paper', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['tissue paper', 'wc paper']),
  CatalogProduct(name: 'Tissues', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['tissue', 'paper tissue']),
  CatalogProduct(name: 'Garbage Bags', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['dustbin cover', 'trash bags', 'dustbin bag']),
  CatalogProduct(name: 'Sponges', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['sponge', 'scrub sponge']),
  CatalogProduct(name: 'Scrub Pads', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['scrub pad', 'steel wool']),
  CatalogProduct(name: 'Batteries', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['battery', 'torch battery']),
  CatalogProduct(name: 'Candles', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['candle']),
  CatalogProduct(name: 'Mosquito Repellent', category: kCategoryHousehold, defaultUnit: 'pack', aliases: ['mosquito coil', 'all out', 'good knight', 'repellent']),

  // E: Beauty and personal care
  CatalogProduct(name: 'Face Wash', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['facewash', 'cleanser']),
  CatalogProduct(name: 'Moisturizer', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['moisturiser', 'cream']),
  CatalogProduct(name: 'Sunscreen', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['sun cream', 'sunblock']),
  CatalogProduct(name: 'Face Cream', category: kCategoryBeauty, defaultUnit: 'pack'),
  CatalogProduct(name: 'Body Lotion', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['lotion']),
  CatalogProduct(name: 'Lip Balm', category: kCategoryBeauty, defaultUnit: 'piece', aliases: ['lipbalm']),
  CatalogProduct(name: 'Talcum Powder', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['talcum', 'baby powder', 'prickly heat powder']),
  CatalogProduct(name: 'Hair Oil', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['oil for hair']),
  CatalogProduct(name: 'Hair Gel', category: kCategoryBeauty, defaultUnit: 'pack'),
  CatalogProduct(name: 'Hair Colour', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['hair color', 'hair dye']),
  CatalogProduct(name: 'Perfume', category: kCategoryBeauty, defaultUnit: 'piece', aliases: ['attar', 'fragrance']),
  CatalogProduct(name: 'Deodorant', category: kCategoryBeauty, defaultUnit: 'piece', aliases: ['deo', 'roll on', 'body spray']),
  CatalogProduct(name: 'Kajal', category: kCategoryBeauty, defaultUnit: 'piece', aliases: ['eyeliner pencil', 'kajjal']),
  CatalogProduct(name: 'Eyeliner', category: kCategoryBeauty, defaultUnit: 'piece'),
  CatalogProduct(name: 'Lipstick', category: kCategoryBeauty, defaultUnit: 'piece'),
  CatalogProduct(name: 'Compact Powder', category: kCategoryBeauty, defaultUnit: 'piece', aliases: ['compact', 'face powder']),
  CatalogProduct(name: 'Makeup Remover', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['micellar water']),
  CatalogProduct(name: 'Cotton Pads', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['cotton', 'cotton ball', 'cotton balls']),
  CatalogProduct(name: 'Sanitary Pads', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['sanitary napkin', 'pads', 'menstrual pads']),
  CatalogProduct(name: 'Shaving Cream', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['shaving foam', 'gel shave']),
  CatalogProduct(name: 'Razor', category: kCategoryBeauty, defaultUnit: 'pack', aliases: ['blade', 'shaving blade', 'Gillette']),

  // F: Electronics and accessories
  CatalogProduct(name: 'LED Bulb', category: kCategoryElectronics, defaultUnit: 'pack', aliases: ['bulb', 'light bulb', 'villaku']),
  CatalogProduct(name: 'Charging Cable', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['data cable', 'type c cable', 'usb charging cable']),
  CatalogProduct(name: 'USB Cable', category: kCategoryElectronics, defaultUnit: 'piece'),
  CatalogProduct(name: 'Phone Charger', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['charger', 'adapter', 'mobile charger']),
  CatalogProduct(name: 'Power Bank', category: kCategoryElectronics, defaultUnit: 'piece'),
  CatalogProduct(name: 'Earphones', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['earphone', 'earbuds', 'headset', 'buds']),
  CatalogProduct(name: 'Headphones', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['over ear headphones']),
  CatalogProduct(name: 'Mouse', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['computer mouse', 'wireless mouse']),
  CatalogProduct(name: 'Keyboard', category: kCategoryElectronics, defaultUnit: 'piece'),
  CatalogProduct(name: 'HDMI Cable', category: kCategoryElectronics, defaultUnit: 'piece'),
  CatalogProduct(name: 'Extension Board', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['extension cord', 'multi plug', 'spike guard']),
  CatalogProduct(name: 'Plug Adapter', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['adapter plug', 'converter plug', 'socket plug']),
  CatalogProduct(name: 'Remote Batteries', category: kCategoryElectronics, defaultUnit: 'pack', aliases: ['button cell', 'remote battery', 'aaa battery', 'aa battery']),
  CatalogProduct(name: 'Memory Card', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['sd card', 'micro sd', 'pen drive memory']),
  CatalogProduct(name: 'USB Drive', category: kCategoryElectronics, defaultUnit: 'piece', aliases: ['pendrive', 'pen drive', 'flash drive']),

  // G: Stationery and miscellaneous
  CatalogProduct(name: 'Pen', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['pens', 'ball pen', 'blue pen']),
  CatalogProduct(name: 'Pencil', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['pencils', 'lead pencil']),
  CatalogProduct(name: 'Notebook', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['note books', 'thin', 'registers']),
  CatalogProduct(name: 'Paper', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['A4 sheet', 'A4 sheets', 'A4']),
  CatalogProduct(name: 'Glue', category: kCategoryStationery, defaultUnit: 'piece', aliases: ['fevicol', 'glue stick', 'adhesive']),
  CatalogProduct(name: 'Tape', category: kCategoryStationery, defaultUnit: 'piece', aliases: ['cellophane tape', 'cotton tape', 'fevicol tape', 'gum tape']),
  CatalogProduct(name: 'Scissors', category: kCategoryStationery, defaultUnit: 'piece', aliases: ['cutting scissors']),
  CatalogProduct(name: 'Marker', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['sketch pen', 'whiteboard marker', 'markers']),
  CatalogProduct(name: 'Envelope', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['cover']),
  CatalogProduct(name: 'Gift Wrap', category: kCategoryStationery, defaultUnit: 'pack', aliases: ['gift wrapping', 'wrapping paper', 'gift cover']),
];

const Map<String, IconData> _categoryIcons = {
  kCategoryGrocery: Icons.restaurant,
  kCategorySpices: Icons.grain,
  kCategoryProduce: Icons.eco,
  kCategoryHousehold: Icons.cleaning_services,
  kCategoryBeauty: Icons.spa,
  kCategoryElectronics: Icons.headphones,
  kCategoryStationery: Icons.edit_note,
};

IconData categoryIconFor(String category) =>
    _categoryIcons[category] ?? Icons.shopping_bag_outlined;
