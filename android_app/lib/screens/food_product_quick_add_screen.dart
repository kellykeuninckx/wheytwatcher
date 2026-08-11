import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

/// Lichtgewicht kandidaat-product voor de quick-add-flow: een basisproduct uit
/// [LocalFoodDatabase] heeft geen barcode en wordt dus (net als in
/// `FoodSearchView.swift`) niet apart in de database opgeslagen — alleen de
/// resulterende [FoodLogEntry] telt.
class FoodCandidate {
  const FoodCandidate({
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
  });

  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
}

/// Poort van `FoodProductQuickAddView.swift`: hoeveelheid + maaltijd kiezen
/// voor een al-gekozen product, en loggen.
///
/// Als [onAdd] gezet is werkt het scherm in "ingrediënt-modus": de
/// maaltijd/eetmoment-keuze vervalt en in plaats van naar het logboek te
/// loggen wordt [onAdd] aangeroepen met het product en de gekozen hoeveelheid.
/// Zo hergebruikt het bewerken van een opgeslagen maaltijd dezelfde flow.
class FoodProductQuickAddScreen extends StatefulWidget {
  const FoodProductQuickAddScreen({super.key, required this.db, required this.isDark, required this.product, this.onAdd});

  final AppDatabase db;
  final bool isDark;
  final FoodCandidate product;
  final Future<void> Function(FoodCandidate product, double grams)? onAdd;

  @override
  State<FoodProductQuickAddScreen> createState() => _FoodProductQuickAddScreenState();
}

class _FoodProductQuickAddScreenState extends State<FoodProductQuickAddScreen> {
  final _gramsController = TextEditingController(text: '100');
  MealCategory _meal = MealCategory.breakfast;
  bool _saving = false;

  double get _grams => double.tryParse(_gramsController.text.trim().replaceAll(',', '.')) ?? 100;
  double get _factor => _grams / 100.0;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  Future<void> _log() async {
    setState(() => _saving = true);
    final product = widget.product;

    if (widget.onAdd != null) {
      await widget.onAdd!(product, _grams);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    await widget.db.into(widget.db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: _meal,
            name: product.name,
            grams: _grams,
            calories: product.caloriesPer100g * _factor,
            proteinGrams: product.proteinPer100g * _factor,
            carbsGrams: product.carbsPer100g * _factor,
            fatGrams: product.fatPer100g * _factor,
            fiberGrams: product.fiberPer100g * _factor,
          ),
        );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final product = widget.product;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text(widget.onAdd != null ? 'Ingrediënt toevoegen' : 'Toevoegen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.orange),
        actions: [
          TextButton(
            onPressed: _saving ? null : _log,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.orange))
                : Text('Toevoegen', style: TextStyle(color: WwColors.orange)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _section([
              Text(product.name, style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.w600)),
              if (product.brand != null && product.brand!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(product.brand!, style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                ),
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
            if (widget.onAdd == null) ...[
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
            const SizedBox(height: 16),
            _section([
              Row(
                children: [
                  Text('Calorieën', style: TextStyle(color: WwColors.darkAccent(isDark))),
                  const Spacer(),
                  Text('${(product.caloriesPer100g * _factor).roundedInt} kcal', style: TextStyle(color: WwColors.secondaryText(isDark))),
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
