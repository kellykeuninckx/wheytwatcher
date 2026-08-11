import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';
import '../widgets/copy_entry_row.dart';

/// Poort van `CopyMealDetailView` uit `CopyMealsView.swift`: producten van
/// één maaltijd op één dag aanvinkbaar om opnieuw te loggen (evt. met een
/// andere hoeveelheid of ander eetmoment dan het origineel).
class CopyMealDetailScreen extends StatefulWidget {
  const CopyMealDetailScreen({
    super.key,
    required this.db,
    required this.isDark,
    required this.category,
    required this.entries,
  });

  final AppDatabase db;
  final bool isDark;
  final MealCategory category;
  final List<FoodLogEntryRow> entries;

  @override
  State<CopyMealDetailScreen> createState() => _CopyMealDetailScreenState();
}

class _CopyMealDetailScreenState extends State<CopyMealDetailScreen> {
  late final List<CopySelection> _selections = widget.entries.map((e) => CopySelection(entry: e)).toList();
  bool _saving = false;

  @override
  void dispose() {
    for (final s in _selections) {
      s.dispose();
    }
    super.dispose();
  }

  int get _selectedCount => _selections.where((s) => s.isSelected).length;

  Future<void> _copySelected() async {
    setState(() => _saving = true);
    final db = widget.db;
    final now = DateTime.now();

    for (final s in _selections.where((s) => s.isSelected)) {
      final newGrams = double.tryParse(s.gramsController.text.trim().replaceAll(',', '.')) ?? s.entry.grams;
      final ratio = s.entry.grams > 0 ? newGrams / s.entry.grams : 1.0;

      await db.into(db.foodLogEntries).insert(
            FoodLogEntriesCompanion.insert(
              date: now,
              mealCategory: s.category,
              name: s.entry.name,
              grams: newGrams,
              calories: s.entry.calories * ratio,
              proteinGrams: s.entry.proteinGrams * ratio,
              carbsGrams: s.entry.carbsGrams * ratio,
              fatGrams: s.entry.fatGrams * ratio,
              fiberGrams: s.entry.fiberGrams * ratio,
              note: Value(s.entry.note),
            ),
          );
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text(widget.category.label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.orange),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  for (final selection in _selections)
                    CopyEntryRow(
                      isDark: isDark,
                      selection: selection,
                      subtitle: 'origineel: ${selection.entry.grams.roundedInt} g • ${selection.entry.calories.roundedInt} kcal',
                      onToggleSelected: () => setState(() => selection.isSelected = !selection.isSelected),
                      onCategoryChanged: (c) => setState(() => selection.category = c),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: WwColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: (_selectedCount > 0 && !_saving) ? _copySelected : null,
                  child: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Kopieer $_selectedCount product${_selectedCount == 1 ? '' : 'en'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
