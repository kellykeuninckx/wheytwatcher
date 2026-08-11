import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/calculators.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

/// Poort van `AddTrainingView.swift`: een training loggen met type, duur en
/// RPE. De verbrande calorieën worden live geschat via [TrainingCalculator]
/// (type-MET-bereik geschaald op RPE × lichaamsgewicht × duur).
class AddTrainingScreen extends StatefulWidget {
  const AddTrainingScreen({super.key, required this.db, required this.isDark, required this.profile});

  final AppDatabase db;
  final bool isDark;
  final UserProfileRow profile;

  @override
  State<AddTrainingScreen> createState() => _AddTrainingScreenState();
}

class _AddTrainingScreenState extends State<AddTrainingScreen> {
  TrainingType _type = TrainingType.hyrox;
  int _durationMinutes = 60;
  int _rpe = 8;
  bool _saving = false;

  /// Meest gelogde types bovenaan — past zich vanzelf aan naarmate iemands
  /// trainingsgewoontes veranderen (poort van `sortedTypes`).
  List<TrainingType> _sortedTypes = TrainingType.values;

  @override
  void initState() {
    super.initState();
    _loadTypeOrder();
  }

  Future<void> _loadTypeOrder() async {
    final trainings = await widget.db.select(widget.db.trainingSessions).get();
    final counts = <TrainingType, int>{};
    for (final t in trainings) {
      counts[t.type] = (counts[t.type] ?? 0) + 1;
    }
    const all = TrainingType.values;
    final sorted = List.of(all)
      ..sort((a, b) {
        final ca = counts[a] ?? 0;
        final cb = counts[b] ?? 0;
        if (ca != cb) return cb.compareTo(ca);
        return all.indexOf(a).compareTo(all.indexOf(b));
      });
    if (mounted) setState(() => _sortedTypes = sorted);
  }

  double get _estimatedCalories => TrainingCalculator.estimateCalories(
        type: _type,
        durationMinutes: _durationMinutes,
        rpe: _rpe,
        bodyWeightKg: widget.profile.currentWeightKg,
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.db.into(widget.db.trainingSessions).insert(
          TrainingSessionsCompanion.insert(
            date: DateTime.now(),
            type: _type,
            durationMinutes: _durationMinutes,
            rpe: _rpe,
            bodyWeightKg: widget.profile.currentWeightKg,
            estimatedCaloriesBurned: _estimatedCalories,
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
        title: Text('Training loggen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: WwColors.teal))
                : Text('Bewaar', style: TextStyle(color: WwColors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _sectionLabel('TRAINING'),
            WwCard(
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Type', style: TextStyle(color: WwColors.darkAccent(isDark))),
                      const Spacer(),
                      DropdownButton<TrainingType>(
                        value: _type,
                        underline: const SizedBox.shrink(),
                        dropdownColor: WwColors.cardBackground(isDark),
                        style: TextStyle(color: WwColors.darkAccent(isDark)),
                        items: _sortedTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _type = v);
                        },
                      ),
                    ],
                  ),
                  Divider(height: 20, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                  _stepperRow(
                    label: 'Duur',
                    value: '$_durationMinutes min',
                    onMinus: _durationMinutes > 5 ? () => setState(() => _durationMinutes -= 5) : null,
                    onPlus: _durationMinutes < 240 ? () => setState(() => _durationMinutes += 5) : null,
                  ),
                  Divider(height: 20, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                  _stepperRow(
                    label: 'RPE',
                    value: '$_rpe/10',
                    onMinus: _rpe > 1 ? () => setState(() => _rpe -= 1) : null,
                    onPlus: _rpe < 10 ? () => setState(() => _rpe += 1) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionLabel('SCHATTING'),
            WwCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: WwColors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text('${_estimatedCalories.roundedInt} kcal verbrand',
                          style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Deze schatting gebruikt type training, duur, RPE en lichaamsgewicht.',
                    style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.secondaryText(widget.isDark))),
    );
  }

  Widget _stepperRow({required String label, required String value, VoidCallback? onMinus, VoidCallback? onPlus}) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        Text(value, style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline),
          color: WwColors.teal,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline),
          color: WwColors.teal,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
