import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/app_settings.dart';
import '../logic/calculators.dart';
import '../logic/enum_labels.dart';
import '../logic/goal_period.dart';
import '../logic/reminder_service.dart';
import '../theme/theme.dart';

/// iOS-weekday-conventie (1 = zondag … 7 = zaterdag), zoals bewaard in de
/// reminder-instelling.
const Map<int, String> _weekdayNames = {
  1: 'Zondag',
  2: 'Maandag',
  3: 'Dinsdag',
  4: 'Woensdag',
  5: 'Donderdag',
  6: 'Vrijdag',
  7: 'Zaterdag',
};

/// Poort van `ProfileView.swift`: kopgegevens, huidig doel (+ wijzigen en
/// geschiedenis), rustdag toevoegen, instellingen (trainingscredit, coach-
/// modus, lichaamsmetingen-grafiek, herinneringen), premium en profiel wissen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.db, required this.isDark, required this.profile});

  final AppDatabase db;
  final bool isDark;
  final UserProfileRow profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoalPeriodRow? _activePeriod;
  List<GoalPeriodRow> _pastPeriods = const [];

  bool _bluntCoach = false;
  bool _showMeasurements = false;
  double _trainingCredit = AppSettings.defaultTrainingCreditPercent;

  bool _reminderEvening = true;
  bool _reminderWeekly = true;
  bool _reminderGoal = true;
  int _weighInWeekday = 2;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = await GoalPeriodRepo.active(widget.db);
    final past = await GoalPeriodRepo.past(widget.db);
    final blunt = await AppSettings.bluntCoachMode();
    final measurements = await AppSettings.showBodyMeasurementsChart();
    final credit = await AppSettings.trainingCalorieCreditPercent();
    final evening = await ReminderService.eveningEnabled();
    final weekly = await ReminderService.weeklyEnabled();
    final goal = await ReminderService.goalEnabled();
    final weekday = await ReminderService.weighInWeekday();

    if (!mounted) return;
    setState(() {
      _activePeriod = active;
      _pastPeriods = past;
      _bluntCoach = blunt;
      _showMeasurements = measurements;
      _trainingCredit = credit;
      _reminderEvening = evening;
      _reminderWeekly = weekly;
      _reminderGoal = goal;
      _weighInWeekday = weekday;
      _loading = false;
    });
  }

  Future<void> _openEditGoal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditGoalScreen(db: widget.db, isDark: widget.isDark, profile: widget.profile)),
    );
    await _load();
    await ReminderService.refreshAll(widget.db);
  }

  Future<void> _openAddRestDay() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddRestDayScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WwColors.cardBackground(widget.isDark),
        title: Text('Gegevens verwijderen', style: TextStyle(color: WwColors.darkAccent(widget.isDark))),
        content: Text(
          'Deze actie kan niet ongedaan worden. Je profiel en doelgeschiedenis worden verwijderd; je logboek, gewicht, favorieten, trainingen en opgeslagen maaltijden blijven bewaard.',
          style: TextStyle(color: WwColors.secondaryText(widget.isDark)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Nee', style: TextStyle(color: WwColors.orange))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ja, verwijder', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.db.transaction(() async {
      await widget.db.delete(widget.db.goalPeriods).go();
      await (widget.db.delete(widget.db.userProfiles)..where((p) => p.id.equals(widget.profile.id))).go();
    });
    // Zonder profiel schakelt RootScreen automatisch terug naar de onboarding.
    if (mounted) Navigator.of(context).pop();
  }

  // MARK: - Reminder-handlers

  Future<void> _setEvening(bool v) async {
    setState(() => _reminderEvening = v);
    if (v) await ReminderService.requestPermission();
    await ReminderService.setEveningLogReminderEnabled(v);
    await ReminderService.refreshAll(widget.db);
  }

  Future<void> _setWeekly(bool v) async {
    setState(() => _reminderWeekly = v);
    if (v) await ReminderService.requestPermission();
    await ReminderService.setWeeklyWeighInReminder(enabled: v, weekday: _weighInWeekday);
  }

  Future<void> _setWeekday(int v) async {
    setState(() => _weighInWeekday = v);
    if (_reminderWeekly) {
      await ReminderService.setWeeklyWeighInReminder(enabled: true, weekday: v);
    }
  }

  Future<void> _setGoal(bool v) async {
    setState(() => _reminderGoal = v);
    if (v) await ReminderService.requestPermission();
    await ReminderService.setGoalEndingReminderEnabled(v);
    await ReminderService.refreshAll(widget.db);
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
        iconTheme: IconThemeData(color: WwColors.orange),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                children: [
                  _headerCard(),
                  const SizedBox(height: 16),
                  _statsCard(),
                  const SizedBox(height: 16),
                  _goalCard(),
                  if (_pastPeriods.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _historyCard(),
                  ],
                  const SizedBox(height: 16),
                  _restDayCard(),
                  const SizedBox(height: 16),
                  _settingsCard(),
                  const SizedBox(height: 16),
                  _premiumCard(),
                  const SizedBox(height: 16),
                  _deleteCard(),
                ],
              ),
      ),
    );
  }

  Widget _headerCard() {
    final isDark = widget.isDark;
    final p = widget.profile;
    final parts = p.name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).join();
    return WwCard(
      isDark: isDark,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: WwColors.orange.withValues(alpha: 0.15),
            child: Text(initials, style: TextStyle(color: WwColors.orange, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: WwColors.darkAccent(isDark))),
              Text('${p.age} jaar • ${p.sex.label}', style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    final isDark = widget.isDark;
    final p = widget.profile;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gegevens', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statTile(Icons.straighten, 'Lengte', '${p.heightCm.roundedInt} cm')),
            Expanded(child: _statTile(Icons.monitor_weight, 'Gewicht', '${p.currentWeightKg.roundedInt} kg')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statTile(Icons.directions_run, 'Activiteit', p.activityLevel.label)),
            Expanded(
              child: p.estimatedBodyFatPercentage != null
                  ? _statTile(Icons.percent, 'Vetpercentage', '${p.estimatedBodyFatPercentage!.roundedInt}%')
                  : const SizedBox.shrink(),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Deze gegevens kun je bij een nieuw weegmoment aanpassen.',
              style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value) {
    final isDark = widget.isDark;
    return Row(
      children: [
        Icon(icon, size: 18, color: WwColors.teal),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: WwColors.darkAccent(isDark))),
          ],
        ),
      ],
    );
  }

  Widget _goalCard() {
    final isDark = widget.isDark;
    final p = widget.profile;
    final period = _activePeriod;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Huidig doel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
              const Spacer(),
              TextButton(
                onPressed: _openEditGoal,
                style: TextButton.styleFrom(foregroundColor: WwColors.teal, padding: const EdgeInsets.symmetric(horizontal: 8)),
                child: const Text('Wijzig doel'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              _chip(p.goalMode.label, WwColors.teal),
              _chip(p.goalPace.label, WwColors.orange),
            ],
          ),
          if (period != null) ...[
            const SizedBox(height: 12),
            Text(
              'Week ${period.currentWeekNumber} van ${period.durationWeeks} • nog ${period.weeksRemaining} ${period.weeksRemaining == 1 ? "week" : "weken"} te gaan',
              style: TextStyle(fontSize: 13, color: WwColors.secondaryText(isDark)),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: period.durationWeeks == 0 ? 0 : period.currentWeekNumber / period.durationWeeks,
                minHeight: 6,
                backgroundColor: WwColors.darkAccent(isDark).withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(WwColors.teal),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(p.goalMode.shortDescription, style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _historyCard() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Geschiedenis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 8),
          for (var i = 0; i < _pastPeriods.length; i++) ...[
            if (i > 0) Divider(height: 18, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_pastPeriods[i].goalMode.label} • ${_pastPeriods[i].goalPace.label}',
                          style: TextStyle(fontWeight: FontWeight.w600, color: WwColors.darkAccent(isDark))),
                      Text(_periodRange(_pastPeriods[i]), style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                    ],
                  ),
                ),
                Text('${_pastPeriods[i].durationWeeks}w', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: WwColors.secondaryText(isDark))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _periodRange(GoalPeriodRow p) {
    String d(DateTime x) => '${x.day}-${x.month}-${x.year}';
    return '${d(p.startDate)} – ${d(p.endDate)}';
  }

  Widget _restDayCard() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _openAddRestDay,
            child: Row(
              children: [
                Icon(Icons.bed, color: WwColors.teal),
                const SizedBox(width: 8),
                Text('Rustdag toevoegen', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.teal)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Ben je ziek, met vakantie of toe aan een rustdag? Voeg die hier toe.',
              style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
        ],
      ),
    );
  }

  Widget _settingsCard() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instellingen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Bot-als-een-baksteen modus', style: TextStyle(color: WwColors.darkAccent(isDark))),
            subtitle: Text('Liever een sarcastische coach met een knipoog?', style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
            value: _bluntCoach,
            activeThumbColor: WwColors.teal,
            onChanged: (v) async {
              setState(() => _bluntCoach = v);
              await AppSettings.setBluntCoachMode(v);
            },
          ),
          Divider(color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Toon lichaamsmetingen in Progressie', style: TextStyle(color: WwColors.darkAccent(isDark))),
            value: _showMeasurements,
            activeThumbColor: WwColors.teal,
            onChanged: (v) async {
              setState(() => _showMeasurements = v);
              await AppSettings.setShowBodyMeasurementsChart(v);
            },
          ),
          Divider(color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Trainingscalorieën terugverdienen: ${_trainingCredit.round()}%',
                          style: TextStyle(color: WwColors.darkAccent(isDark))),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _trainingCredit > 0 ? () => _setCredit(_trainingCredit - 10) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: WwColors.teal,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _trainingCredit < 100 ? () => _setCredit(_trainingCredit + 10) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: WwColors.teal,
                    ),
                  ],
                ),
                Text(
                  'Hoeveel van je geschatte verbrande trainingscalorieën teruggaan naar je dagbudget. Schattingen vallen vaak hoog uit — lager houdt je dichter bij je doel.',
                  style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark)),
                ),
              ],
            ),
          ),
          Divider(color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
          Text('Herinneringen', style: TextStyle(fontWeight: FontWeight.w600, color: WwColors.darkAccent(isDark))),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Nog niet gelogd (18:00)', style: TextStyle(color: WwColors.darkAccent(isDark))),
            value: _reminderEvening,
            activeThumbColor: WwColors.teal,
            onChanged: _setEvening,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Wekelijkse gewicht-herinnering', style: TextStyle(color: WwColors.darkAccent(isDark))),
            value: _reminderWeekly,
            activeThumbColor: WwColors.teal,
            onChanged: _setWeekly,
          ),
          if (_reminderWeekly)
            Row(
              children: [
                Text('Wegdag', style: TextStyle(color: WwColors.darkAccent(isDark))),
                const Spacer(),
                DropdownButton<int>(
                  value: _weighInWeekday,
                  underline: const SizedBox.shrink(),
                  dropdownColor: WwColors.cardBackground(isDark),
                  style: TextStyle(color: WwColors.teal, fontWeight: FontWeight.bold),
                  items: _weekdayNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) {
                    if (v != null) _setWeekday(v);
                  },
                ),
              ],
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Doelperiode loopt bijna af', style: TextStyle(color: WwColors.darkAccent(isDark))),
            value: _reminderGoal,
            activeThumbColor: WwColors.teal,
            onChanged: _setGoal,
          ),
        ],
      ),
    );
  }

  Future<void> _setCredit(double v) async {
    final clamped = v.clamp(0, 100).toDouble();
    setState(() => _trainingCredit = clamped);
    await AppSettings.setTrainingCalorieCreditPercent(clamped);
  }

  Widget _premiumCard() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              // Stub: de echte paywall/Play Billing volgt in de Billing-stap.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium komt binnenkort naar Android.')),
              );
            },
            child: Row(
              children: [
                Icon(Icons.star, color: WwColors.orange),
                const SizedBox(width: 8),
                Text('Ontgrendel Premium', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Eenmalige aankoop — geen abonnement. (Binnenkort beschikbaar.)',
              style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
        ],
      ),
    );
  }

  Widget _deleteCard() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _confirmDelete,
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Gegevens verwijderen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Verwijdert je profiel en doelgeschiedenis en start de onboarding opnieuw. Je logboek, gewicht, favorieten, trainingen en maaltijden blijven bewaard.',
              style: TextStyle(fontSize: 11, color: WwColors.secondaryText(isDark))),
        ],
      ),
    );
  }
}

/// Poort van `EditGoalSheet`: doel, tempo en duur kiezen; start een nieuwe
/// doelperiode via [GoalPeriodRepo.startNew].
class EditGoalScreen extends StatefulWidget {
  const EditGoalScreen({super.key, required this.db, required this.isDark, required this.profile});

  final AppDatabase db;
  final bool isDark;
  final UserProfileRow profile;

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  late GoalMode _mode = widget.profile.goalMode;
  late GoalPace _pace = widget.profile.goalPace;
  late int _durationWeeks = GoalDurationAdvisor.recommendedWeeks(_mode, _pace);
  bool _saving = false;

  void _refreshRecommendedDuration() {
    setState(() => _durationWeeks = GoalDurationAdvisor.recommendedWeeks(_mode, _pace));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await GoalPeriodRepo.startNew(widget.db, widget.profile, mode: _mode, pace: _pace, durationWeeks: _durationWeeks);
    if (mounted) Navigator.of(context).pop();
  }

  void _showAdvice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WwColors.cardBackground(widget.isDark),
        content: Text(GoalDurationAdvisor.adviceText(_mode, _pace), style: TextStyle(color: WwColors.darkAccent(widget.isDark))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Oké', style: TextStyle(color: WwColors.teal)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Doel wijzigen', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            WwCard(
              isDark: isDark,
              child: Column(
                children: [
                  _pickerRow<GoalMode>('Doel', _mode, GoalMode.values, (m) => m.label, (v) {
                    setState(() => _mode = v);
                    _refreshRecommendedDuration();
                  }),
                  Divider(color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                  _pickerRow<GoalPace>('Tempo', _pace, GoalPace.values, (p) => p.label, (v) {
                    setState(() => _pace = v);
                    _refreshRecommendedDuration();
                  }),
                  Divider(color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                  Row(
                    children: [
                      Text('Duur', style: TextStyle(color: WwColors.darkAccent(isDark))),
                      const Spacer(),
                      Text('$_durationWeeks weken', style: TextStyle(color: WwColors.darkAccent(isDark), fontWeight: FontWeight.w600)),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _durationWeeks > 2 ? () => setState(() => _durationWeeks--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: WwColors.teal,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _durationWeeks < 52 ? () => setState(() => _durationWeeks++) : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: WwColors.teal,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Advies: ${GoalDurationAdvisor.recommendedWeeks(_mode, _pace)} weken',
                          style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _showAdvice,
                        icon: Icon(Icons.info_outline, size: 18, color: WwColors.secondaryText(isDark)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: WwColors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Bevestig nieuw doel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow<T>(String label, T value, List<T> options, String Function(T) labelFor, ValueChanged<T> onChanged) {
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
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(labelFor(o)))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

/// Poort van `AddRestDaySheet`: markeer één of meerdere dagen als rustdag,
/// ziektedag of vakantie (`DayStatus`).
class AddRestDayScreen extends StatefulWidget {
  const AddRestDayScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<AddRestDayScreen> createState() => _AddRestDayScreenState();
}

class _AddRestDayScreenState extends State<AddRestDayScreen> {
  DayStatusType _type = DayStatusType.restDay;
  DateTime _startDate = DateTime.now();
  bool _useEndDate = false;
  DateTime _endDate = DateTime.now();
  bool _saving = false;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = widget.db;
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = _useEndDate ? DateTime(_endDate.year, _endDate.month, _endDate.day) : start;

    await db.transaction(() async {
      var day = start;
      while (!day.isAfter(end)) {
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));
        // Verwijder een bestaande status op deze dag (in-memory filter houdt het simpel).
        final existing = (await db.select(db.dayStatuses).get())
            .where((s) => !s.date.isBefore(dayStart) && s.date.isBefore(dayEnd))
            .toList();
        for (final s in existing) {
          await (db.delete(db.dayStatuses)..where((r) => r.id.equals(s.id))).go();
        }
        await db.into(db.dayStatuses).insert(DayStatusesCompanion.insert(date: dayStart, type: _type));
        day = day.add(const Duration(days: 1));
      }
    });

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    String fmt(DateTime d) => '${d.day}-${d.month}-${d.year}';
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Rustdag toevoegen', style: TextStyle(color: WwColors.darkAccent(isDark))),
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
            WwCard(
              isDark: isDark,
              child: Row(
                children: [
                  Text('Type', style: TextStyle(color: WwColors.darkAccent(isDark))),
                  const Spacer(),
                  DropdownButton<DayStatusType>(
                    value: _type,
                    underline: const SizedBox.shrink(),
                    dropdownColor: WwColors.cardBackground(isDark),
                    style: TextStyle(color: WwColors.darkAccent(isDark)),
                    items: DayStatusType.values
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(t.icon, size: 16, color: WwColors.teal), const SizedBox(width: 6), Text(t.label)])))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            WwCard(
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Vanaf', style: TextStyle(color: WwColors.darkAccent(isDark))),
                      const Spacer(),
                      TextButton(onPressed: () => _pickDate(isStart: true), child: Text(fmt(_startDate), style: TextStyle(color: WwColors.teal))),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tot een einddatum', style: TextStyle(color: WwColors.darkAccent(isDark))),
                    value: _useEndDate,
                    activeThumbColor: WwColors.teal,
                    onChanged: (v) => setState(() => _useEndDate = v),
                  ),
                  if (_useEndDate)
                    Row(
                      children: [
                        Text('Tot en met', style: TextStyle(color: WwColors.darkAccent(isDark))),
                        const Spacer(),
                        TextButton(onPressed: () => _pickDate(isStart: false), child: Text(fmt(_endDate), style: TextStyle(color: WwColors.teal))),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Handig voor vakantie, waar je de einddatum vaak al weet. Bij ziekte kun je \'m later verlengen.',
                style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
          ],
        ),
      ),
    );
  }
}
