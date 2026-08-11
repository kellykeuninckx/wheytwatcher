import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/local_food_database.dart';
import '../logic/open_food_facts_service.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'food_product_quick_add_screen.dart';

/// Poort van `FoodSearchView.swift`: lokale basisproducten
/// (`LocalFoodDatabase`, live terwijl je typt) plus merkproducten via Open
/// Food Facts (`OpenFoodFactsService.searchProducts`, gezocht op indrukken
/// van "zoeken" — net als bij het opzoeken van een barcode wordt een
/// gevonden merkproduct lokaal gecached in `FoodProducts` zodat een latere
/// scan/zoekopdracht 'm meteen herkent).
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required this.db, required this.isDark, this.onPick});

  final AppDatabase db;
  final bool isDark;

  /// Als gezet werkt de zoeker in "ingrediënt-modus": een gekozen product
  /// wordt niet naar het logboek gelogd maar via [onPick] teruggegeven (met de
  /// gekozen hoeveelheid), zodat het bewerken van een opgeslagen maaltijd
  /// dezelfde zoek/hoeveelheid-flow hergebruikt.
  final Future<void> Function(FoodCandidate product, double grams)? onPick;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _queryController = TextEditingController();
  List<LocalFoodItem> _localResults = const [];
  List<OpenFoodFactsLookupResult> _networkResults = const [];
  bool _isSearchingNetwork = false;
  bool _hasSearchedNetwork = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _localResults = LocalFoodDatabase.search(query);
      _networkResults = const [];
      _hasSearchedNetwork = false;
    });
  }

  Future<void> _onSubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isSearchingNetwork = true);

    List<OpenFoodFactsLookupResult> results;
    try {
      results = await OpenFoodFactsService.searchProducts(trimmed);
    } catch (_) {
      results = const [];
    }

    if (!mounted) return;
    setState(() {
      _networkResults = results;
      _isSearchingNetwork = false;
      _hasSearchedNetwork = true;
    });
  }

  Future<void> _selectLocal(LocalFoodItem item) async {
    final logged = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FoodProductQuickAddScreen(
          db: widget.db,
          isDark: widget.isDark,
          onAdd: widget.onPick,
          product: FoodCandidate(
            name: item.name,
            caloriesPer100g: item.caloriesPer100g,
            proteinPer100g: item.proteinPer100g,
            carbsPer100g: item.carbsPer100g,
            fatPer100g: item.fatPer100g,
            fiberPer100g: item.fiberPer100g,
          ),
        ),
      ),
    );
    if (logged == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _selectNetwork(OpenFoodFactsLookupResult result) async {
    final db = widget.db;

    // Poort van FoodSearchView.swift's `select(_ result:)`: bestaat er al een
    // lokaal gecached product met deze barcode (bv. eerder gescand), gebruik
    // dat; anders het nieuwe merkproduct opslaan zodat het herkend wordt bij
    // een volgende scan of zoekopdracht.
    if (result.barcode != null) {
      final existing = await (db.select(db.foodProducts)..where((p) => p.barcode.equals(result.barcode!))).getSingleOrNull();
      if (existing != null) {
        await _openQuickAdd(FoodCandidate(
          name: existing.name,
          brand: existing.brand,
          caloriesPer100g: existing.caloriesPer100g,
          proteinPer100g: existing.proteinPer100g,
          carbsPer100g: existing.carbsPer100g,
          fatPer100g: existing.fatPer100g,
          fiberPer100g: existing.fiberPer100g,
        ));
        return;
      }
    }

    await db.into(db.foodProducts).insert(
          FoodProductsCompanion.insert(
            name: result.name,
            brand: Value(result.brand),
            barcode: Value(result.barcode),
            caloriesPer100g: result.caloriesPer100g,
            proteinPer100g: result.proteinPer100g,
            carbsPer100g: result.carbsPer100g,
            fatPer100g: result.fatPer100g,
            fiberPer100g: result.fiberPer100g,
            createdAt: DateTime.now(),
          ),
        );

    await _openQuickAdd(FoodCandidate(
      name: result.name,
      brand: result.brand,
      caloriesPer100g: result.caloriesPer100g,
      proteinPer100g: result.proteinPer100g,
      carbsPer100g: result.carbsPer100g,
      fatPer100g: result.fatPer100g,
      fiberPer100g: result.fiberPer100g,
    ));
  }

  Future<void> _openQuickAdd(FoodCandidate candidate) async {
    final logged = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FoodProductQuickAddScreen(db: widget.db, isDark: widget.isDark, product: candidate, onAdd: widget.onPick),
      ),
    );
    if (logged == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final query = _queryController.text.trim();

    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Zoek product', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: WwCard(
                isDark: isDark,
                child: TextField(
                  controller: _queryController,
                  onChanged: _onQueryChanged,
                  onSubmitted: _onSubmitted,
                  textInputAction: TextInputAction.search,
                  autofocus: true,
                  style: TextStyle(color: WwColors.darkAccent(isDark)),
                  decoration: InputDecoration(
                    hintText: 'Zoek een product (bv. "banaan" of "kwark")',
                    hintStyle: TextStyle(color: WwColors.secondaryText(isDark)),
                    border: InputBorder.none,
                    isDense: true,
                    icon: Icon(Icons.search, color: WwColors.secondaryText(isDark)),
                  ),
                ),
              ),
            ),
            Expanded(child: _body(query)),
          ],
        ),
      ),
    );
  }

  Widget _body(String query) {
    if (query.isEmpty) {
      return _placeholder(
        icon: Icons.search,
        color: WwColors.teal,
        title: 'Zoek een product',
        message: 'Typ een naam (bv. \'banaan\' of \'kwark\').',
      );
    }

    final showEmptyState = _localResults.isEmpty && _networkResults.isEmpty && !_isSearchingNetwork && _hasSearchedNetwork;
    if (showEmptyState) {
      return _placeholder(
        icon: Icons.help_outline,
        color: WwColors.orange,
        title: 'Niets gevonden',
        message: 'Probeer een andere zoekterm.',
      );
    }

    final isDark = widget.isDark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        if (_localResults.isNotEmpty) ...[
          _sectionLabel('Basisproducten'),
          for (final item in _localResults)
            _resultRow(
              name: item.name,
              subtitle: null,
              caloriesPer100g: item.caloriesPer100g,
              onTap: () => _selectLocal(item),
            ),
          const SizedBox(height: 8),
        ],
        if (_isSearchingNetwork)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.teal)),
                const SizedBox(width: 10),
                Text('Merkproducten zoeken…', style: TextStyle(color: WwColors.secondaryText(isDark))),
              ],
            ),
          )
        else if (_hasSearchedNetwork && _networkResults.isNotEmpty) ...[
          _sectionLabel('Merkproducten'),
          for (final (index, result) in _networkResults.indexed)
            _resultRow(
              key: ValueKey('network-result-$index'),
              name: result.name,
              subtitle: result.brand,
              caloriesPer100g: result.caloriesPer100g,
              onTap: () => _selectNetwork(result),
            ),
        ] else if (!_hasSearchedNetwork)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Druk op zoeken op je toetsenbord om ook merkproducten te doorzoeken.',
              style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
            ),
          ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.secondaryText(widget.isDark))),
    );
  }

  Widget _resultRow({Key? key, required String name, required String? subtitle, required double caloriesPer100g, required VoidCallback onTap}) {
    final isDark = widget.isDark;
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: WwColors.cardBackground(isDark), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                    if (subtitle != null && subtitle.trim().isNotEmpty)
                      Text(subtitle, style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                  ],
                ),
              ),
              Text('${caloriesPer100g.roundedInt} kcal/100g', style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder({required IconData icon, required Color color, required String title, required String message}) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: PlaceholderCard(isDark: widget.isDark, icon: icon, color: color, title: title, message: message),
    );
  }
}
