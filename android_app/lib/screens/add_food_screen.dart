import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

double? _parseDutch(String text) {
  final trimmed = text.trim().replaceAll(',', '.');
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

/// Poort van `AddFoodView.swift`: handmatig een voedingslogregel toevoegen
/// door macro's per 100 gram in te vullen.
class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key, required this.db, required this.isDark, this.prefilledBarcode});

  final AppDatabase db;
  final bool isDark;

  /// Als dit scherm vanuit de barcode-scanner is geopend voor een product dat
  /// niet in Open Food Facts stond: koppelt de handmatige invoer aan deze
  /// barcode, zodat een volgende scan 'm meteen herkent (poort van
  /// `AddFoodView.swift`'s `prefilledBarcode`).
  final String? prefilledBarcode;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _nameController = TextEditingController();
  final _gramsController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _noteController = TextEditingController();

  MealCategory _mealCategory = MealCategory.breakfast;
  bool _saving = false;

  double get _grams => _parseDutch(_gramsController.text) ?? 100;
  double get _caloriesPer100g => _parseDutch(_caloriesController.text) ?? 0;
  double get _proteinPer100g => _parseDutch(_proteinController.text) ?? 0;
  double get _carbsPer100g => _parseDutch(_carbsController.text) ?? 0;
  double get _fatPer100g => _parseDutch(_fatController.text) ?? 0;
  double get _fiberPer100g => _parseDutch(_fiberController.text) ?? 0;

  double _scaled(double per100g) => per100g * _grams / 100.0;

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final note = _noteController.text.trim();

    final name = _nameController.text.trim();

    await widget.db.into(widget.db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: _mealCategory,
            name: name,
            grams: _grams,
            calories: _scaled(_caloriesPer100g),
            proteinGrams: _scaled(_proteinPer100g),
            carbsGrams: _scaled(_carbsPer100g),
            fatGrams: _scaled(_fatPer100g),
            fiberGrams: _scaled(_fiberPer100g),
            note: Value(note.isEmpty ? null : note),
          ),
        );

    final barcode = widget.prefilledBarcode;
    if (barcode != null) {
      await widget.db.into(widget.db.foodProducts).insert(
            FoodProductsCompanion.insert(
              name: name,
              barcode: Value(barcode),
              caloriesPer100g: _caloriesPer100g,
              proteinPer100g: _proteinPer100g,
              carbsPer100g: _carbsPer100g,
              fatPer100g: _fatPer100g,
              fiberPer100g: _fiberPer100g,
              createdAt: DateTime.now(),
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
        title: Text('Eten toevoegen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.teal))
                : Text('Voeg toe', style: TextStyle(color: _canSave ? WwColors.teal : WwColors.teal.withValues(alpha: 0.4))),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _section('Product', [
              _textRow('Naam', _nameController, onChanged: (_) => setState(() {})),
              _mealPicker(),
              _numberRow('Hoeveelheid', _gramsController, 'g'),
              if (widget.prefilledBarcode != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Wordt gekoppeld aan deze barcode, zodat je 'm de volgende keer meteen kan scannen.",
                    style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                  ),
                ),
            ]),
            const SizedBox(height: 16),
            _section('Per 100 gram', [
              _numberRow('Calorieën', _caloriesController, 'kcal', onChanged: () => setState(() {})),
              _numberRow('Eiwit', _proteinController, 'g', onChanged: () => setState(() {})),
              _numberRow('Koolhydraten', _carbsController, 'g', onChanged: () => setState(() {})),
              _numberRow('Vet', _fatController, 'g', onChanged: () => setState(() {})),
              _numberRow('Vezels', _fiberController, 'g', onChanged: () => setState(() {})),
            ]),
            const SizedBox(height: 16),
            _section('Totaal', [
              _totalRow('${_scaled(_caloriesPer100g).roundedInt} kcal'),
              _totalRow('${_scaled(_proteinPer100g).roundedInt} g eiwit'),
              _totalRow('${_scaled(_carbsPer100g).roundedInt} g koolhydraten'),
              _totalRow('${_scaled(_fatPer100g).roundedInt} g vet'),
              _totalRow('${_scaled(_fiberPer100g).roundedInt} g vezels'),
            ]),
            const SizedBox(height: 16),
            _section('Notitie (optioneel)', [
              _textRow('Bijv. veel zout, andere portie, uit eten', _noteController),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _mealPicker() {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text('Moment', style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        DropdownButton<MealCategory>(
          value: _mealCategory,
          underline: const SizedBox.shrink(),
          dropdownColor: WwColors.cardBackground(isDark),
          style: TextStyle(color: WwColors.darkAccent(isDark)),
          items: MealCategory.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _mealCategory = v);
          },
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WwColors.secondaryText(isDark))),
        ),
        WwCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 20, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _textRow(String label, TextEditingController controller, {ValueChanged<String>? onChanged}) {
    final isDark = widget.isDark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: WwColors.darkAccent(isDark)),
      decoration: InputDecoration(labelText: label, border: InputBorder.none, isDense: true),
    );
  }

  Widget _numberRow(String label, TextEditingController controller, String unit, {VoidCallback? onChanged}) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged?.call(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            textAlign: TextAlign.right,
            style: TextStyle(color: WwColors.darkAccent(isDark)),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
        const SizedBox(width: 6),
        Text(unit, style: TextStyle(color: WwColors.secondaryText(isDark))),
      ],
    );
  }

  Widget _totalRow(String text) {
    return Text(text, style: TextStyle(color: WwColors.darkAccent(widget.isDark)));
  }
}
