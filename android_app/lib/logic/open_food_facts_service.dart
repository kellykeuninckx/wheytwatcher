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

/// Poort van `OpenFoodFactsService.swift`.
///
/// Open Food Facts blokkeert tegenwoordig anonieme requests zonder
/// identificerende `User-Agent` met sporadische 503's, vooral op
/// zoek-endpoints — vandaar de header op elke aanvraag. Ontdekt doordat de
/// live test voor `searchProducts` faalde met een HTML "Page temporarily
/// unavailable"-antwoord i.p.v. JSON.
///
/// `searchProducts` gebruikt de nieuwe search-a-licious API
/// (`search.openfoodfacts.org`) i.p.v. het oude `cgi/search.pl`: dat laatste
/// bleek zelfs mét een geldige User-Agent onbetrouwbaar (herhaaldelijk
/// dezelfde 503), en `/api/v2/search` met `search_terms` blijkt geen
/// vrije-tekstzoekopdracht te zijn — het `count` bleek nagenoeg gelijk aan
/// het totale aantal producten in de database, ongeacht de zoekterm. Dit
/// wijkt af van `OpenFoodFactsService.swift`, dat nog steeds `cgi/search.pl`
/// gebruikt — de iOS-app heeft dus vermoedelijk hetzelfde probleem en is dit
/// nog niet tegengekomen, of loopt tegen dezelfde sporadische 503's aan.
class OpenFoodFactsService {
  OpenFoodFactsService._();

  static const _headers = {'User-Agent': 'WheyMate-Android/1.0 (+https://github.com/kellykeuninckx/wheytwatcher)'};

  /// Zoekt een product op via barcode. Geeft `null` terug als het product
  /// niet in de Open Food Facts-database staat (geen fout, gewoon "niet
  /// gevonden") of als het antwoord geen bruikbare naam bevat.
  static Future<OpenFoodFactsLookupResult?> lookup(String barcode) async {
    final uri = Uri.parse(
      'https://nl.openfoodfacts.org/api/v2/product/$barcode.json?fields=product_name,brands,nutriments',
    );

    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
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

  /// Zoekt producten op naam via de search-a-licious API. Geeft een lege
  /// lijst terug als er niks matcht (geen fout).
  static Future<List<OpenFoodFactsLookupResult>> searchProducts(String query) async {
    final uri = Uri.https('search.openfoodfacts.org', '/search', {
      'q': query,
      'page_size': '20',
      'fields': 'product_name,brands,code,nutriments',
    });

    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = decoded['hits'] as List<dynamic>? ?? const [];

    final results = <OpenFoodFactsLookupResult>[];
    for (final entry in hits) {
      final product = entry as Map<String, dynamic>;
      final name = (product['product_name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final nutriments = product['nutriments'] as Map<String, dynamic>?;
      double field(String key) => (nutriments?[key] as num?)?.toDouble() ?? 0;

      final brands = product['brands'] as List<dynamic>?;

      results.add(OpenFoodFactsLookupResult(
        name: name,
        brand: (brands != null && brands.isNotEmpty) ? brands.join(', ') : null,
        barcode: product['code'] as String?,
        caloriesPer100g: field('energy-kcal_100g'),
        proteinPer100g: field('proteins_100g'),
        carbsPer100g: field('carbohydrates_100g'),
        fatPer100g: field('fat_100g'),
        fiberPer100g: field('fiber_100g'),
      ));
    }
    return results;
  }
}
