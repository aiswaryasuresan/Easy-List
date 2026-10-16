import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/app/data/default_product_catalog.dart';
import 'package:shopping_list/app/data/malayalam_product_catalog.dart';

void main() {
  test('malayalam items are searchable by malayalam prefix', () {
    final matches = kAllProductCatalog
        .where((p) => normalizeProductName(p.name).startsWith('ത'))
        .map((p) => p.name)
        .toList();
    expect(matches, containsAll(['തക്കാളി', 'തൈര്', 'തണ്ണിമത്തൻ', 'തലയിണ']));
  });

  test('malayalam items are also reachable when typed in english', () {
    final byAlias = kMalayalamProductCatalog
        .where((p) => p.aliases.any((a) => normalizeProductName(a) == 'tomato'))
        .toList();
    expect(byAlias, isNotEmpty);
  });

  test('english autocomplete still resolves', () {
    final matches = kAllProductCatalog
        .where((p) => normalizeProductName(p.name).startsWith('tomato'))
        .toList();
    expect(matches, isNotEmpty);
  });
}
