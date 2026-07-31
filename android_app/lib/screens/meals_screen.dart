import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'meal_detail_screen.dart';

/// Poort van `MealsView.swift`: lijst van opgeslagen maaltijden
/// (`SavedMeal`). Lang indrukken om te verwijderen (poort van de iOS
/// context-menu "Verwijder"-actie).
class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  Future<void> _confirmDelete(BuildContext context, SavedMealRow meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Maaltijd verwijderen?'),
        content: const Text('Dit verwijdert alleen de opgeslagen maaltijd zelf — je logboek blijft ongewijzigd.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuleer')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwijder', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await (db.delete(db.mealItems)..where((i) => i.savedMealId.equals(meal.id))).go();
      await (db.delete(db.savedMeals)..where((m) => m.id.equals(meal.id))).go();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Maaltijden', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<SavedMealRow>>(
          stream: (db.select(db.savedMeals)..orderBy([(m) => OrderingTerm.desc(m.createdAt)])).watch(),
          builder: (context, mealSnapshot) {
            final meals = mealSnapshot.data ?? const <SavedMealRow>[];

            return StreamBuilder<List<MealItemRow>>(
              stream: db.select(db.mealItems).watch(),
              builder: (context, itemSnapshot) {
                final allItems = itemSnapshot.data ?? const <MealItemRow>[];

                if (meals.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(18),
                    child: PlaceholderCard(
                      isDark: isDark,
                      icon: Icons.ramen_dining,
                      color: WwColors.orange,
                      title: 'Nog geen maaltijden',
                      message: 'Sla een maaltijd op vanuit je logboek.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    final items = allItems.where((i) => i.savedMealId == meal.id).toList();
                    final totalCalories = items.fold<double>(0, (sum, i) => sum + i.calories);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final added = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(builder: (context) => MealDetailScreen(db: db, isDark: isDark, meal: meal)),
                          );
                          // Alleen relevant als dit scherm modaal geopend is (vanuit
                          // Vandaag's quick-add-menu) — als tabblad is dit een no-op.
                          if (added == true && context.mounted) Navigator.of(context).maybePop();
                        },
                        onLongPress: () => _confirmDelete(context, meal),
                        child: WwCard(
                          isDark: isDark,
                          child: Row(
                            children: [
                              Icon(Icons.ramen_dining, color: WwColors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                                    Text(
                                      '${items.length} ingrediënten • ${totalCalories.roundedInt} kcal',
                                      style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 18, color: WwColors.secondaryText(isDark)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
