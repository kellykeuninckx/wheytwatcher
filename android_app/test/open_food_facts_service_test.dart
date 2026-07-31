import 'package:flutter_test/flutter_test.dart';

import 'package:whey_mate/logic/open_food_facts_service.dart';

void main() {
  test('lookup vindt een bekend product via barcode', () async {
    // Nutella — een stabiele, altijd-aanwezige testbarcode in Open Food Facts.
    final result = await OpenFoodFactsService.lookup('3017620422003');

    expect(result, isNotNull);
    expect(result!.name.toLowerCase(), contains('nutella'));
    expect(result.caloriesPer100g, greaterThan(0));
  });

  test('lookup geeft null terug voor een niet-bestaande barcode', () async {
    final result = await OpenFoodFactsService.lookup('0000000000000');
    expect(result, isNull);
  });

  test('searchProducts vindt merkproducten op naam', () async {
    final results = await OpenFoodFactsService.searchProducts('nutella');

    expect(results, isNotEmpty);
    expect(results.any((r) => r.name.toLowerCase().contains('nutella')), isTrue);
  });
}
