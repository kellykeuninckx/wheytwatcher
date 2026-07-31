import 'package:drift/drift.dart' show OrderingTerm, Value;
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

/// Poort van `AddWeightView.swift`: dagelijks gewicht loggen, met optioneel
/// vetpercentage, lichaamsmetingen (vooringevuld met de laatst gelogde
/// waarden) en de activiteitsniveau-instelling.
class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key, required this.db, required this.isDark, required this.profile});

  final AppDatabase db;
  final bool isDark;
  final UserProfileRow profile;

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  late final _weightController = TextEditingController(text: _formatNumber(widget.profile.currentWeightKg));
  late final _bodyFatController =
      TextEditingController(text: widget.profile.estimatedBodyFatPercentage != null ? _formatNumber(widget.profile.estimatedBodyFatPercentage!) : '');
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _hipsController = TextEditingController();
  final _armController = TextEditingController();
  final _thighController = TextEditingController();

  late ActivityLevel _activityLevel = widget.profile.activityLevel;
  bool _saving = false;

  static String _formatNumber(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  @override
  void initState() {
    super.initState();
    _prefillFromLastMeasurement();
  }

  Future<void> _prefillFromLastMeasurement() async {
    final db = widget.db;
    final last = await (db.select(db.bodyMeasurementLogs)..orderBy([(m) => OrderingTerm.desc(m.date)])).getSingleOrNull();
    if (last == null || !mounted) return;
    setState(() {
      if (last.waistCm != null) _waistController.text = _formatNumber(last.waistCm!);
      if (last.chestCm != null) _chestController.text = _formatNumber(last.chestCm!);
      if (last.hipsCm != null) _hipsController.text = _formatNumber(last.hipsCm!);
      if (last.armCm != null) _armController.text = _formatNumber(last.armCm!);
      if (last.thighCm != null) _thighController.text = _formatNumber(last.thighCm!);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _hipsController.dispose();
    _armController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = widget.db;
    final now = DateTime.now();
    final weightKg = _parseDutch(_weightController.text) ?? widget.profile.currentWeightKg;
    final bodyFat = _parseDutch(_bodyFatController.text);

    await (db.update(db.userProfiles)..where((p) => p.id.equals(widget.profile.id))).write(
      UserProfilesCompanion(
        currentWeightKg: Value(weightKg),
        activityLevel: Value(_activityLevel),
        estimatedBodyFatPercentage: bodyFat != null ? Value(bodyFat) : const Value.absent(),
      ),
    );

    await db.into(db.weightLogs).insert(
          WeightLogsCompanion.insert(date: now, weightKg: weightKg),
        );

    final waist = _parseDutch(_waistController.text);
    final chest = _parseDutch(_chestController.text);
    final hips = _parseDutch(_hipsController.text);
    final arm = _parseDutch(_armController.text);
    final thigh = _parseDutch(_thighController.text);
    if (waist != null || chest != null || hips != null || arm != null || thigh != null) {
      await db.into(db.bodyMeasurementLogs).insert(
            BodyMeasurementLogsCompanion.insert(
              date: now,
              waistCm: Value(waist),
              chestCm: Value(chest),
              hipsCm: Value(hips),
              armCm: Value(arm),
              thighCm: Value(thigh),
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
        title: Text('Gewicht loggen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.teal))
                : Text('Bewaar', style: TextStyle(color: WwColors.teal)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _section('Gewicht', [
              _numberRow('Vandaag', _weightController, 'kg'),
            ]),
            const SizedBox(height: 16),
            _section('Vetpercentage (optioneel)', [
              _numberRow('', _bodyFatController, '%'),
            ]),
            const SizedBox(height: 16),
            _section('Lichaamsmetingen (optioneel, in cm)', [
              _numberRow('Taille', _waistController, 'cm'),
              _numberRow('Borst', _chestController, 'cm'),
              _numberRow('Heupen', _hipsController, 'cm'),
              _numberRow('Arm', _armController, 'cm'),
              _numberRow('Dijbeen', _thighController, 'cm'),
            ]),
            const SizedBox(height: 16),
            _section('Activiteit', [
              _activityPicker(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _activityPicker() {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text('Activiteit', style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        DropdownButton<ActivityLevel>(
          value: _activityLevel,
          underline: const SizedBox.shrink(),
          dropdownColor: WwColors.cardBackground(isDark),
          style: TextStyle(color: WwColors.darkAccent(isDark)),
          items: ActivityLevel.values.map((a) => DropdownMenuItem(value: a, child: Text(a.label))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _activityLevel = v);
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

  Widget _numberRow(String label, TextEditingController controller, String unit) {
    final isDark = widget.isDark;
    return Row(
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
          const Spacer(),
        ] else
          const Spacer(),
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
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
}
