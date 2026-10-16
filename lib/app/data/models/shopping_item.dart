class ShoppingItem {
  final int id;
  String name;
  double? quantity;
  String? unit;
  bool isPurchased;
  int sortOrder;
  final int createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.isPurchased = false,
    required this.sortOrder,
    required this.createdAt,
  });

  String get quantityLabel {
    final q = quantity;
    if (q == null) return '';
    final text = q == q.roundToDouble() ? q.toInt().toString() : '$q';
    final u = unit;
    if (u == null || u.isEmpty) return text;
    return '$text $u';
  }

  ShoppingItem copyWith({
    String? name,
    double? quantity,
    String? unit,
    bool? isPurchased,
    int? sortOrder,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'isPurchased': isPurchased,
        'sortOrder': sortOrder,
        'createdAt': createdAt,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as int,
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        isPurchased: json['isPurchased'] as bool? ?? false,
        sortOrder: json['sortOrder'] as int? ?? 0,
        createdAt: json['createdAt'] as int? ?? 0,
      );
}

const kUnits = ['kg', 'g', 'L', 'ml', 'pack', 'piece', 'box', 'bottle'];

const _productIcons = <String, String>{
  'sugar': '🥣',
  'salt': '🧂',
  'rice': '🍚',
  'flour': '🌾',
  'dal': '🥘',
  'lentil': '🥘',
  'milk': '🥛',
  'curd': '🥛',
  'butter': '🧈',
  'cheese': '🧀',
  'bread': '🍞',
  'egg': '🥚',
  'oil': '🫗',
  'tea': '🍵',
  'coffee': '☕',
  'banana': '🍌',
  'apple': '🍎',
  'orange': '🍊',
  'mango': '🥭',
  'lemon': '🍋',
  'coconut': '🥥',
  'potato': '🥔',
  'onion': '🧅',
  'tomato': '🍅',
  'carrot': '🥕',
  'ginger': '🍠',
  'garlic': '🧄',
  'chilli': '🌶️',
  'chili': '🌶️',
  'pepper': '🌶️',
  'spinach': '🥬',
  'cabbage': '🥬',
  'beans': '🫘',
  'chicken': '🍗',
  'mutton': '🍖',
  'fish': '🐟',
  'soap': '🧼',
  'shampoo': '🧴',
  'toothpaste': '🪥',
  'toothbrush': '🪥',
  'detergent': '🧺',
  'wash': '🧼',
  'tissue': '🧻',
  'napkin': '🧻',
  'candle': '🕯️',
  'biscuit': '🍪',
  'cookie': '🍪',
  'honey': '🍯',
  'jam': '🍓',
  'water': '💧',
  'juice': '🧃',
  'medicine': '💊',
  'tablet': '💊',

  // Malayalam names. Compound keys come first so the longer match wins.
  'ചെറുനാരങ്ങ': '🍋',
  'മുളക് പൊടി': '🌶️',
  'ചായ പൗഡർ': '🍵',
  'കോഫി പൗഡർ': '☕',
  'ടൂത്ത് പേസ്റ്റ്': '🪥',
  'ടൂത്ത് ബ്രഷ്': '🪥',
  'അടുക്കള സോപ്പ്': '🧼',
  'തുണി അലക്കു പൗഡർ': '🧺',
  'തറ സോപ്പ്': '🧼',
  'ടോയ്ലറ്റ് ക്ലീനർ': '🧴',
  'ടിഷ്യൂ പേപ്പർ': '🧻',
  'സാനിറ്ററി നാപ്കിൻ': '🧻',
  'ഫേസ് വാഷ്': '🧼',
  'ഹെയർ ഓയിൽ': '🫗',
  'ഗോതമ്പ് മാവ്': '🌾',
  'പുട്ട് മാവ്': '🍚',
  'മാട്ട് അരി': '🍚',
  'അരി': '🍚',
  'മാവ്': '🌾',
  'പഞ്ചസാര': '🥣',
  'ഉപ്പ്': '🧂',
  'വെളിച്ചെണ്ണ': '🫗',
  'പാല്': '🥛',
  'തൈര്': '🥛',
  'വെണ്ണ': '🧈',
  'ചീസ്': '🧀',
  'മുട്ട': '🥚',
  'ബ്രെഡ്': '🍞',
  'പരിപ്പ്': '🥘',
  'കടല': '🥘',
  'ബിസ്കറ്റ്': '🍪',
  'തേൻ': '🍯',
  'കുരുമുളക്': '🌶️',
  'തക്കാളി': '🍅',
  'ഉള്ളി': '🧅',
  'വെളുത്തുള്ളി': '🧄',
  'ഇഞ്ചി': '🍠',
  'ഉരുളക്കിഴങ്ങ്': '🥔',
  'ചെറുപഴ്': '🧅',
  'ബീൻസ്': '🫘',
  'പടവ': '🫘',
  'മുരങ്ങില': '🥬',
  'കാരറ്റ്': '🥕',
  'മധുരമുളക്': '🌶️',
  'പച്ചമുളക്': '🌶️',
  'മാങ്ങ': '🥭',
  'വാഴപ്പഴം': '🍌',
  'പൈനാപ്പിൾ': '🍍',
  'തേങ്ങ': '🥥',
  'നാരങ്ങ': '🍊',
  'ആപ്പിൾ': '🍎',
  'തണ്ണിമത്തൻ': '🍉',
  'കുളിസോപ്പ്': '🧼',
  'ഷാംപൂ': '🧴',
  'മെഴുകുതിരി': '🕯️',
};

String productIconFor(String name) {
  final lower = name.toLowerCase();
  for (final entry in _productIcons.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return '🛒';
}
