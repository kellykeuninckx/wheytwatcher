import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';
import 'food_search_screen.dart';

/// Poort van `MealDetailView.swift`: ingrediënten van een opgeslagen
/// maaltijd, met een knop om alles in één keer aan het logboek toe te
/// voegen voor een gekozen eetmoment. Ingrediënten zijn ook aanpasbaar:
/// verwijderen per rij en toevoegen via de productzoeker.
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.db, required this.isDark, required this.meal});

  final AppDatabase db;
  final bool isDark;
  final SavedMealRow meal;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealCategory _selectedCategory = MealCategory.lunch;
  bool _adding = false;

  Future<void> _addToToday(List<MealItemRow> items) async {
    setState(() => _adding = true);
    final db = widget.db;
    final now = DateTime.now();

    for (final item in items) {
      await db.into(db.foodLogEntries).insert(
            FoodLogEntriesCompanion.insert(
              date: now,
              mealCategory: _selectedCategory,
              name: item.name,
              grams: item.grams,
              calories: item.calories,
              proteinGrams: item.proteinGrams,
              carbsGrams: item.carbsGrams,
              fatGrams: item.fatGrams,
              fiberGrams: item.fiberGrams,
            ),
          );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  /// Voegt een ingrediënt toe via de productzoeker (in "ingrediënt-modus":
  /// niet loggen, maar teruggeven). De StreamBuilder hieronder ververst de
  /// lijst automatisch zodra de nieuwe [MealItem] is opgeslagen.
  Future<void> _addIngredient() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(
          db: widget.db,
          isDark: widget.isDark,
          onPick: (product, grams) async {
            final factor = grams / 100.0;
            await widget.db.into(widget.db.mealItems).insert(
                  MealItemsCompanion.insert(
                    savedMealId: widget.meal.id,
                    name: product.name,
                    grams: grams,
                    calories: product.caloriesPer100g * factor,
                    proteinGrams: product.proteinPer100g * factor,
                    carbsGrams: product.carbsPer100g * factor,
                    fatGrams: product.fatPer100g * factor,
                    fiberGrams: product.fiberPer100g * factor,
                  ),
                );
          },
        ),
      ),
    );
  }

  Future<void> _deleteItem(MealItemRow item) async {
    await (widget.db.delete(widget.db.mealItems)..where((r) => r.id.equals(item.id))).go();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text(widget.meal.name, style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.orange),
      ),
      body: SafeArea(
        child: StreamBuilder<List<MealItemRow>>(
          stream: (widget.db.select(widget.db.mealItems)..where((i) => i.savedMealId.equals(widget.meal.id))).watch(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <MealItemRow>[];
            final totalCalories = items.fold<double>(0, (sum, i) => sum + i.calories);

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
              children: [
                WwCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.meal.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} ingrediënten • ${totalCalories.roundedInt} kcal',
                        style: TextStyle(color: WwColors.secondaryText(isDark)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WwCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Ingrediënten', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addIngredient,
                            style: TextButton.styleFrom(foregroundColor: WwColors.orange, padding: const EdgeInsets.symmetric(horizontal: 8)),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Toevoegen'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Nog geen ingrediënten. Tik op "Toevoegen" om er een toe te voegen.',
                            style: TextStyle(color: WwColors.secondaryText(isDark)),
                          ),
                        ),
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) Divider(height: 20, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(items[i].name, style: TextStyle(color: WwColors.darkAccent(isDark))),
                                  Text('${items[i].calories.roundedInt} kcal', style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                                ],
                              ),
                            ),
                            Text('${items[i].grams.roundedInt} g', style: TextStyle(color: WwColors.secondaryText(isDark))),
                            IconButton(
                              onPressed: () => _deleteItem(items[i]),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: WwColors.secondaryText(isDark),
                              tooltip: 'Verwijder ${items[i].name}',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WwCard(
                  isDark: isDark,
                  child: Row(
                    children: [
                      Text('Eetmoment', style: TextStyle(color: WwColors.darkAccent(isDark))),
                      const Spacer(),
                      DropdownButton<MealCategory>(
                        value: _selectedCategory,
                        underline: const SizedBox.shrink(),
                        dropdownColor: WwColors.cardBackground(isDark),
                        style: TextStyle(color: WwColors.orange, fontWeight: FontWeight.bold),
                        items: MealCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: WwColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: (_adding || items.isEmpty) ? null : () => _addToToday(items),
                    icon: _adding
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_circle),
                    label: const Text('Voeg toe aan vandaag'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
