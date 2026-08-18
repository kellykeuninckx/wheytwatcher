import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../logic/reminder_service.dart';
import '../logic/calculators.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

const _weekdayNames = ['zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag'];

double? _parseDutch(String text) {
  final trimmed = text.trim().replaceAll(',', '.');
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

/// Poort van `OnboardingView.swift` — eerste-profiel-formulier, getoond zolang
/// er nog geen [UserProfileRow] in de database staat (zie `RootView.swift`).
///
/// Niet meegenomen: het wekelijkse weeg-herinnering-tijdstip wordt gekozen
/// maar nog niet als notificatie ingepland (ReminderManager is nog niet geport).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController(text: '180');
  final _weightController = TextEditingController(text: '80');
  final _bodyFatController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _hipsController = TextEditingController();
  final _armController = TextEditingController();
  final _thighController = TextEditingController();

  int _age = 30;
  Sex _sex = Sex.male;
  GoalMode _goalMode = GoalMode.maintenance;
  GoalPace _goalPace = GoalPace.normal;
  ActivityLevel _activityLevel = ActivityLevel.light;
  late int _durationWeeks = GoalDurationAdvisor.recommendedWeeks(_goalMode, _goalPace);
  int _weighInWeekday = 2;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _targetWeightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _hipsController.dispose();
    _armController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _onGoalChanged() {
    setState(() {
      _durationWeeks = GoalDurationAdvisor.recommendedWeeks(_goalMode, _goalPace);
    });
  }

  String? get _impliedPaceText {
    final target = _parseDutch(_targetWeightController.text);
    final weight = _parseDutch(_weightController.text);
    if (target == null || weight == null) return null;
    return GoalDurationAdvisor.impliedPaceDescription(
      currentWeightKg: weight,
      targetWeightKg: target,
      durationWeeks: _durationWeeks,
    );
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_saving;

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final heightCm = _parseDutch(_heightController.text) ?? 180;
    final weightKg = _parseDutch(_weightController.text) ?? 80;

    setState(() => _saving = true);

    final db = widget.db;
    final now = DateTime.now();

    final profileId = await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: name,
            age: _age,
            sex: _sex,
            heightCm: heightCm,
            currentWeightKg: weightKg,
            targetWeightKg: Value(_parseDutch(_targetWeightController.text)),
            estimatedBodyFatPercentage: Value(_parseDutch(_bodyFatController.text)),
            goalMode: _goalMode,
            goalPace: _goalPace,
            activityLevel: _activityLevel,
            createdAt: now,
          ),
        );

    await db.into(db.weightLogs).insert(
          WeightLogsCompanion.insert(date: now, weightKg: weightKg),
        );

    await db.into(db.goalPeriods).insert(
          GoalPeriodsCompanion.insert(
            profileId: Value(profileId),
            startDate: now,
            durationWeeks: _durationWeeks,
            goalMode: _goalMode,
            goalPace: _goalPace,
          ),
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
    // Vraag meldingstoestemming en plan meteen de eerste herinneringen.
    await ReminderService.requestPermission();
    await ReminderService.setWeeklyWeighInReminder(enabled: true, weekday: _weighInWeekday);
    await ReminderService.refreshAll(db);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Profiel', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _section('Jij', [
              _textRow('Naam', _nameController, onChanged: (_) => setState(() {})),
              _stepperRow('Leeftijd', '$_age', onDecrement: _age > 12 ? () => setState(() => _age--) : null, onIncrement: _age < 90 ? () => setState(() => _age++) : null),
              _enumDropdown<Sex>(
                label: 'Geslacht',
                value: _sex,
                values: Sex.values,
                labelOf: (s) => s.label,
                onChanged: (v) => setState(() => _sex = v),
              ),
              _numberRow('Lengte', _heightController, 'cm'),
              _numberRow('Gewicht', _weightController, 'kg'),
              _textRow('Vetpercentage (optioneel)', _bodyFatController, keyboardType: TextInputType.number),
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
            _section('Doel', [
              _enumDropdown<GoalMode>(
                label: 'Doel',
                value: _goalMode,
                values: GoalMode.values,
                labelOf: (m) => m.label,
                onChanged: (v) {
                  _goalMode = v;
                  _onGoalChanged();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _goalMode.shortDescription,
                  style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark)),
                ),
              ),
              _numberRow('Doelgewicht (optioneel)', _targetWeightController, 'kg'),
              _enumDropdown<GoalPace>(
                label: 'Tempo',
                value: _goalPace,
                values: GoalPace.values,
                labelOf: (p) => p.label,
                onChanged: (v) {
                  _goalPace = v;
                  _onGoalChanged();
                },
              ),
              _enumDropdown<ActivityLevel>(
                label: 'Activiteit',
                value: _activityLevel,
                values: ActivityLevel.values,
                labelOf: (a) => a.label,
                onChanged: (v) => setState(() => _activityLevel = v),
              ),
              _stepperRow(
                'Duur',
                '$_durationWeeks weken',
                onDecrement: _durationWeeks > 2 ? () => setState(() => _durationWeeks--) : null,
                onIncrement: _durationWeeks < 52 ? () => setState(() => _durationWeeks++) : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Advies: ${GoalDurationAdvisor.recommendedWeeks(_goalMode, _goalPace)} weken',
                      style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, size: 18, color: WwColors.teal),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(GoalDurationAdvisor.adviceText(_goalMode, _goalPace)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sluiten')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_impliedPaceText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_impliedPaceText!, style: const TextStyle(fontSize: 12, color: WwColors.orange)),
                ),
            ]),
            const SizedBox(height: 16),
            _section('Wekelijkse weeg-herinnering', [
              _enumDropdown<int>(
                label: 'Wegdag',
                value: _weighInWeekday,
                values: const [1, 2, 3, 4, 5, 6, 7],
                labelOf: (v) => _weekdayNames[v - 1][0].toUpperCase() + _weekdayNames[v - 1].substring(1),
                onChanged: (v) => setState(() => _weighInWeekday = v),
              ),
              Text(
                'Dagelijks wegen kan natuurlijk ook — dit is puur een wekelijkse herinnering, geen limiet.',
                style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark)),
              ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: WwColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _canSave ? _saveProfile : null,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Start Whey, mate!'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tip: Ziek, op vakantie of toe aan een rustdag? Dat kun je instellen via je Profiel of op je Vandaag scherm. Zo tellen deze dagen niet mee als 'gemist'. Handig!",
              style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark)),
            ),
          ],
        ),
      ),
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

  Widget _textRow(String label, TextEditingController controller, {ValueChanged<String>? onChanged, TextInputType? keyboardType}) {
    final isDark = widget.isDark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(color: WwColors.darkAccent(isDark)),
      decoration: InputDecoration(labelText: label, border: InputBorder.none, isDense: true),
    );
  }

  Widget _numberRow(String label, TextEditingController controller, String unit) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        SizedBox(
          width: 70,
          child: TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
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

  Widget _stepperRow(String label, String valueLabel, {VoidCallback? onDecrement, VoidCallback? onIncrement}) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Expanded(child: Text('$label: $valueLabel', style: TextStyle(color: WwColors.darkAccent(isDark)))),
        IconButton(icon: const Icon(Icons.remove_circle_outline), color: WwColors.teal, onPressed: onDecrement),
        IconButton(icon: const Icon(Icons.add_circle_outline), color: WwColors.teal, onPressed: onIncrement),
      ],
    );
  }

  Widget _enumDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        const Spacer(),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          dropdownColor: WwColors.cardBackground(isDark),
          style: TextStyle(color: WwColors.darkAccent(isDark)),
          items: values.map((v) => DropdownMenuItem(value: v, child: Text(labelOf(v)))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => onChanged(v));
          },
        ),
      ],
    );
  }
}
