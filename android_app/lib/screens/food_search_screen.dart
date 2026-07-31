import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/local_food_database.dart';
import '../theme/theme.dart';
import 'food_product_quick_add_screen.dart';

/// Poort van `FoodSearchView.swift` — voor nu alleen de lokale basisproducten
/// (`LocalFoodDatabase`). De Open Food Facts-netwerkzoekopdracht
/// (`OpenFoodFactsService`, "Merkproducten") is nog niet geport.
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _queryController = TextEditingController();
  List<LocalFoodItem> _results = const [];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() => _results = LocalFoodDatabase.search(query));
  }

  Future<void> _select(LocalFoodItem item) async {
    final logged = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FoodProductQuickAddScreen(
          db: widget.db,
          isDark: widget.isDark,
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
    if (_results.isEmpty) {
      return _placeholder(
        icon: Icons.help_outline,
        color: WwColors.orange,
        title: 'Niets gevonden',
        message: 'Probeer een andere zoekterm.',
      );
    }

    final isDark = widget.isDark;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _select(item),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: WwColors.cardBackground(isDark), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                  ),
                  Text('${item.caloriesPer100g.roundedInt} kcal/100g', style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder({required IconData icon, required Color color, required String title, required String message}) {
    final isDark = widget.isDark;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: WwCard(
        isDark: isDark,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(icon, size: 56, color: color),
              const SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: WwColors.secondaryText(isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
