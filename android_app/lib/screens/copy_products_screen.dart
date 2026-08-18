import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';
import '../widgets/copy_entry_row.dart';
import '../widgets/placeholder_card.dart';
import 'copy_by_day_screen.dart';

const _dutchMonthsShort = ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];

/// Poort van `CopyProductsEntryView` uit `CopyMealsView.swift`: de laatste 30
/// unieke (op naam) recent gelogde producten, aanvinkbaar om met een nieuwe
/// hoeveelheid/maaltijd opnieuw te loggen. "Bekijk een specifieke dag" leidt
/// naar `CopyByDayScreen` voor een dag-/maaltijd-gerichte variant.
class CopyProductsScreen extends StatefulWidget {
  const CopyProductsScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<CopyProductsScreen> createState() => _CopyProductsScreenState();
}

class _CopyProductsScreenState extends State<CopyProductsScreen> {
  List<CopySelection>? _selections;
  bool _saving = false;

  @override
  void dispose() {
    for (final s in _selections ?? const <CopySelection>[]) {
      s.dispose();
    }
    super.dispose();
  }

  void _buildSelectionsOnce(List<FoodLogEntryRow> allFood) {
    if (_selections != null) return;
    final sorted = List.of(allFood)..sort((a, b) => b.date.compareTo(a.date));
    final seenNames = <String>{};
    final recent = <FoodLogEntryRow>[];
    for (final entry in sorted) {
      final key = entry.name.trim().toLowerCase();
      if (key.isEmpty || seenNames.contains(key)) continue;
      seenNames.add(key);
      recent.add(entry);
      if (recent.length == 30) break;
    }
    _selections = recent.map((e) => CopySelection(entry: e)).toList();
  }

  int get _selectedCount => _selections?.where((s) => s.isSelected).length ?? 0;

  Future<void> _copySelected() async {
    setState(() => _saving = true);
    final db = widget.db;
    final now = DateTime.now();

    for (final s in _selections!.where((s) => s.isSelected)) {
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

  Future<void> _openByDay() async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => CopyByDayScreen(db: widget.db, isDark: widget.isDark)),
    );
    if (done == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Kopieer product', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.orange),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Sluiten', style: TextStyle(color: WwColors.orange)),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<FoodLogEntryRow>>(
          stream: widget.db.select(widget.db.foodLogEntries).watch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            _buildSelectionsOnce(snapshot.data!);
            final selections = _selections!;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    children: [
                      if (selections.isEmpty)
                        PlaceholderCard(
                          isDark: isDark,
                          icon: Icons.copy_all,
                          color: WwColors.orange,
                          title: 'Nog geen producten',
                          message: 'Log eerst een product, dan kan je het hier terugvinden om te kopiëren.',
                        )
                      else ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text('RECENTE PRODUCTEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.secondaryText(isDark))),
                        ),
                        for (final selection in selections)
                          CopyEntryRow(
                            isDark: isDark,
                            selection: selection,
                            subtitle: 'laatst: ${selection.entry.grams.roundedInt} g • ${selection.entry.calories.roundedInt} kcal'
                                ' • ${selection.entry.date.day} ${_dutchMonthsShort[selection.entry.date.month - 1]}',
                            onToggleSelected: () => setState(() => selection.isSelected = !selection.isSelected),
                            onCategoryChanged: (c) => setState(() => selection.category = c),
                          ),
                      ],
                      const SizedBox(height: 4),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _openByDay,
                        child: WwCard(
                          isDark: isDark,
                          child: Row(
                            children: [
                              Text('Bekijk een specifieke dag', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.teal)),
                              const Spacer(),
                              Icon(Icons.chevron_right, color: WwColors.teal),
                            ],
                          ),
                        ),
                      ),
                      // Extra ruimte onderaan zodat Scrollable.ensureVisible() ook producten
                      // dicht bij het einde van de lijst kan centreren boven het toetsenbord.
                      const SizedBox(height: 300),
                    ],
                  ),
                ),
                if (_selectedCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: WwColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: _saving ? null : _copySelected,
                        child: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Kopieer $_selectedCount product${_selectedCount == 1 ? '' : 'en'}'),
                      ),
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
