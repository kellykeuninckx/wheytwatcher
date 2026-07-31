import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenFoodFactsLookupResult {
  const OpenFoodFactsLookupResult({
    required this.name,
    this.brand,
    this.barcode,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
  });

  final String name;
  final String? brand;
  final String? barcode;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
}

/// Poort van de `lookup(barcode:)`-helft van `OpenFoodFactsService.swift`
/// (de zoek-op-naam-helft, "Merkproducten" in `FoodSearchView.swift`, is nog
/// niet geport — zie [[whey_mate_app_context]]).
class OpenFoodFactsService {
  OpenFoodFactsService._();

  /// Zoekt een product op via barcode. Geeft `null` terug als het product
  /// niet in de Open Food Facts-database staat (geen fout, gewoon "niet
  /// gevonden") of als het antwoord geen bruikbare naam bevat.
  static Future<OpenFoodFactsLookupResult?> lookup(String barcode) async {
    final uri = Uri.parse(
      'https://nl.openfoodfacts.org/api/v2/product/$barcode.json?fields=product_name,brands,nutriments',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (decoded['status'] != 1) return null;
    final product = decoded['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    double field(String key) => (nutriments?[key] as num?)?.toDouble() ?? 0;

    return OpenFoodFactsLookupResult(
      name: name,
      brand: product['brands'] as String?,
      barcode: barcode,
      caloriesPer100g: field('energy-kcal_100g'),
      proteinPer100g: field('proteins_100g'),
      carbsPer100g: field('carbohydrates_100g'),
      fatPer100g: field('fat_100g'),
      fiberPer100g: field('fiber_100g'),
    );
  }
}
