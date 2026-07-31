import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

/// Poort van `FavoriteQuickAddView.swift`: hoeveelheid + maaltijd kiezen voor
/// een favoriet en loggen. De opgeslagen `FavoriteFoodRow` bewaart absolute
/// grams/macro's (een snapshot van de oorspronkelijke log-regel), dus bij een
/// afwijkende hoeveelheid wordt er proportioneel geschaald.
class FavoriteQuickAddScreen extends StatefulWidget {
  const FavoriteQuickAddScreen({super.key, required this.db, required this.isDark, required this.favorite});

  final AppDatabase db;
  final bool isDark;
  final FavoriteFoodRow favorite;

  @override
  State<FavoriteQuickAddScreen> createState() => _FavoriteQuickAddScreenState();
}

class _FavoriteQuickAddScreenState extends State<FavoriteQuickAddScreen> {
  late final TextEditingController _gramsController =
      TextEditingController(text: widget.favorite.grams.roundedInt.toString());
  MealCategory _meal = MealCategory.breakfast;
  bool _saving = false;

  double get _grams => double.tryParse(_gramsController.text.trim().replaceAll(',', '.')) ?? widget.favorite.grams;
  double get _factor => widget.favorite.grams > 0 ? _grams / widget.favorite.grams : 1;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    setState(() => _saving = true);
    final db = widget.db;
    final favorite = widget.favorite;

    await db.into(db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: _meal,
            name: favorite.name,
            grams: _grams,
            calories: favorite.calories * _factor,
            proteinGrams: favorite.proteinGrams * _factor,
            carbsGrams: favorite.carbsGrams * _factor,
            fatGrams: favorite.fatGrams * _factor,
            fiberGrams: favorite.fiberGrams * _factor,
          ),
        );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Toevoegen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.coral),
        actions: [
          TextButton(
            onPressed: _saving ? null : _add,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.coral))
                : Text('Toevoegen', style: TextStyle(color: WwColors.coral)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _section([
              Text(widget.favorite.name, style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),
            _section([
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _gramsController,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      style: TextStyle(color: WwColors.darkAccent(isDark)),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ),
                  Text('g', style: TextStyle(color: WwColors.secondaryText(isDark))),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _section([
              Row(
                children: [
                  Text('Maaltijd', style: TextStyle(color: WwColors.darkAccent(isDark))),
                  const Spacer(),
                  DropdownButton<MealCategory>(
                    value: _meal,
                    underline: const SizedBox.shrink(),
                    dropdownColor: WwColors.cardBackground(isDark),
                    style: TextStyle(color: WwColors.darkAccent(isDark)),
                    items: MealCategory.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _meal = v);
                    },
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(List<Widget> children) {
    return WwCard(
      isDark: widget.isDark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
