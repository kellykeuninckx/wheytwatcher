import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';

/// Poort van `SaveMealView.swift`: geselecteerde logboek-entries bewaren als
/// herbruikbare maaltijd (`SavedMeal` + `MealItem`).
class SaveMealScreen extends StatefulWidget {
  const SaveMealScreen({super.key, required this.db, required this.isDark, required this.entries});

  final AppDatabase db;
  final bool isDark;
  final List<FoodLogEntryRow> entries;

  @override
  State<SaveMealScreen> createState() => _SaveMealScreenState();
}

class _SaveMealScreenState extends State<SaveMealScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = widget.db;

    final mealId = await db.into(db.savedMeals).insert(
          SavedMealsCompanion.insert(name: _nameController.text.trim(), createdAt: DateTime.now()),
        );

    for (final entry in widget.entries) {
      await db.into(db.mealItems).insert(
            MealItemsCompanion.insert(
              savedMealId: mealId,
              name: entry.name,
              grams: entry.grams,
              calories: entry.calories,
              proteinGrams: entry.proteinGrams,
              carbsGrams: entry.carbsGrams,
              fatGrams: entry.fatGrams,
              fiberGrams: entry.fiberGrams,
            ),
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Maaltijd opslaan', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuleren', style: TextStyle(color: WwColors.orange, fontSize: 13)),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.orange))
                : Text('Opslaan', style: TextStyle(color: _canSave ? WwColors.orange : WwColors.orange.withValues(alpha: 0.4))),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text('NAAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WwColors.secondaryText(isDark))),
              ),
              WwCard(
                isDark: isDark,
                child: TextField(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: WwColors.darkAccent(isDark)),
                  decoration: InputDecoration(hintText: 'Bijvoorbeeld: Enchiladas', hintStyle: TextStyle(color: WwColors.secondaryText(isDark)), border: InputBorder.none, isDense: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
