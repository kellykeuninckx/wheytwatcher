import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/calculators.dart';
import '../logic/enum_labels.dart';
import '../logic/app_settings.dart';
import '../logic/badges.dart';
import '../logic/coach_message.dart';
import '../logic/purchase_manager.dart';
import '../logic/reminder_service.dart';
import '../theme/theme.dart';
import '../widgets/ring_progress.dart';
import 'add_food_screen.dart';
import 'add_training_screen.dart';
import 'add_weight_screen.dart';
import 'barcode_scanner_screen.dart';
import 'copy_products_screen.dart';
import 'favorites_screen.dart';
import 'food_search_screen.dart';
import 'macro_breakdown_screen.dart';
import 'meals_screen.dart';
import 'paywall_screen.dart';
import 'profile_screen.dart';

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Poort van `TodayView.swift` — de "Vandaag"-hoofdweergave.
///
/// Eerste bouwstap: header, datumnavigatie, coach-tip, calorieën, macro's en
/// training. Het quick-add-menu is nu volledig geport — alle 7 opties leiden
/// ergens heen. Ook nog niet meegenomen: badges, de slimme 2-wekelijkse
/// check-in, "gemiste
/// dagen"-prompt en reminders.
class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.db,
    required this.isDark,
    required this.onToggleTheme,
  });

  final AppDatabase db;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  DateTime _selectedDate = DateTime.now();

  /// Aandeel van de trainingscalorieën dat terugvloeit naar het dagbudget,
  /// instelbaar via Profiel (default 50%).
  double _trainingCreditFactor = AppSettings.defaultTrainingCreditPercent / 100;
  bool _bluntCoach = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final percent = await AppSettings.trainingCalorieCreditPercent();
    final blunt = await AppSettings.bluntCoachMode();
    if (mounted) {
      setState(() {
        _trainingCreditFactor = percent / 100;
        _bluntCoach = blunt;
      });
    }
  }

  bool get _isToday => _isSameDay(_selectedDate, DateTime.now());

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Goedemorgen';
    if (hour >= 12 && hour < 18) return 'Goedemiddag';
    return 'Goedenavond';
  }

  DateTime? _lastSnapshotDay;
  double? _lastSnapshotCalories;

  /// Poort van `ensureTodaySnapshotExists`/`upsertTodaySnapshot`: houdt een
  /// `DailyTargetSnapshot` voor vandaag bij, zodat de eiwit-doellijn in het
  /// Progressie-scherm iets heeft om te tonen. Alleen relevant voor vandaag —
  /// bekeken historische dagen wijzigen dit niet.
  void _maybeUpsertSnapshot(UserProfileRow profile, MacroTarget target) {
    if (!_isToday) return;
    final today = DateTime.now();
    if (_lastSnapshotDay != null && _isSameDay(_lastSnapshotDay!, today) && _lastSnapshotCalories == target.calories) {
      return;
    }
    _lastSnapshotDay = today;
    _lastSnapshotCalories = target.calories;
    _upsertSnapshot(profile, target, today);
  }

  Future<void> _upsertSnapshot(UserProfileRow profile, MacroTarget target, DateTime today) async {
    final db = widget.db;
    final all = await db.select(db.dailyTargetSnapshots).get();
    final existing = all.where((s) => _isSameDay(s.date, today)).toList();

    if (existing.isNotEmpty) {
      await (db.update(db.dailyTargetSnapshots)..where((s) => s.id.equals(existing.first.id))).write(
        DailyTargetSnapshotsCompanion(
          goalMode: Value(profile.goalMode),
          goalPace: Value(profile.goalPace),
          calories: Value(target.calories),
          proteinGrams: Value(target.proteinGrams),
          carbsGrams: Value(target.carbsGrams),
          fatGrams: Value(target.fatGrams),
          fiberGrams: Value(target.fiberGrams),
          trainingCalories: Value(target.trainingCalories),
        ),
      );
    } else {
      await db.into(db.dailyTargetSnapshots).insert(
            DailyTargetSnapshotsCompanion.insert(
              date: today,
              goalMode: profile.goalMode,
              goalPace: profile.goalPace,
              calories: target.calories,
              proteinGrams: target.proteinGrams,
              carbsGrams: target.carbsGrams,
              fatGrams: target.fatGrams,
              fiberGrams: target.fiberGrams,
              trainingCalories: target.trainingCalories,
            ),
          );
    }
  }

  void _openAddFood() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddFoodScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  void _openFoodSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FoodSearchScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FavoritesScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  void _openBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => BarcodeScannerScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  void _openMeals() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MealsScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  void _openAddWeight(UserProfileRow profile) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddWeightScreen(db: widget.db, isDark: widget.isDark, profile: profile)),
    );
  }

  void _openAddTraining(UserProfileRow profile) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddTrainingScreen(db: widget.db, isDark: widget.isDark, profile: profile)),
    );
  }

  Future<void> _openProfile(UserProfileRow profile) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProfileScreen(db: widget.db, isDark: widget.isDark, profile: profile)),
    );
    // Instellingen (trainingscredit, coach-modus) kunnen in Profiel gewijzigd zijn — herladen.
    await _loadSettings();
  }

  void _openAddRestDay() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddRestDayScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  /// Premium-feature: macro-uitklap tonen als ontgrendeld, anders de paywall.
  void _openMacroBreakdown(MacroBreakdownType macro, DateTime date, List<FoodLogEntryRow> entries) {
    if (PurchaseManager.instance.isPremiumUnlocked) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MacroBreakdownScreen(isDark: widget.isDark, initialMacro: macro, date: date, entries: entries),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PaywallScreen(isDark: widget.isDark),
      ));
    }
  }

  bool? _lastHasLoggedToday;

  /// Ververst de "vandaag nog niet gelogd"-melding zodra het wel/niet-gelogd
  /// zijn van vandaag verandert (zodat de 18:00-melding vervalt na het loggen).
  void _maybeRefreshEveningReminder(bool hasLoggedToday) {
    if (_lastHasLoggedToday == hasLoggedToday) return;
    _lastHasLoggedToday = hasLoggedToday;
    ReminderService.refreshEveningLogReminder(hasLoggedToday: hasLoggedToday);
  }

  String? _lastBadgeSignature;

  /// Checkt op nieuw ontgrendelde badges zodra het aantal gelogde items/
  /// trainingen verandert, en toont er een popup voor (poort van checkNewBadge).
  void _maybeCheckBadges(int foodCount, int trainingCount) {
    final signature = '$foodCount-$trainingCount';
    if (_lastBadgeSignature == signature) return;
    _lastBadgeSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final newly = await BadgeTracker.checkNewlyUnlocked(widget.db);
      if (newly.isNotEmpty && mounted) _showNewBadges(newly);
    });
  }

  void _showNewBadges(List<BadgeTier> badges) {
    final isDark = widget.isDark;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WwColors.cardBackground(isDark),
        title: Text(badges.length == 1 ? 'Nieuwe badge! 🎉' : 'Nieuwe badges! 🎉', style: TextStyle(color: WwColors.darkAccent(isDark))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final b in badges) ...[
              Text(b.name, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.orange)),
              const SizedBox(height: 2),
              Text(b.message, style: TextStyle(fontSize: 13, color: WwColors.secondaryText(isDark))),
              const SizedBox(height: 10),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Top!', style: TextStyle(color: WwColors.teal)))],
      ),
    );
  }

  void _openCopyProducts() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CopyProductsScreen(db: widget.db, isDark: widget.isDark)),
    );
  }

  /// Poort van `quickAddOptions`/`quickAddDropdown` uit TodayView.swift, als
  /// bottom sheet i.p.v. dropdown (idiomatischer op Android). Alleen "Kopieer
  /// product" leidt nog nergens heen.
  void _showQuickAddMenu(UserProfileRow profile) {
    final isDark = widget.isDark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WwColors.cardBackground(isDark),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        Widget option(IconData icon, String label, VoidCallback onTap) {
          return ListTile(
            leading: Icon(icon, color: WwColors.teal),
            title: Text(label, style: TextStyle(color: WwColors.darkAccent(isDark))),
            onTap: () {
              Navigator.of(context).pop();
              onTap();
            },
          );
        }

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  option(Icons.copy, 'Kopieer product', _openCopyProducts),
                  option(Icons.star, 'Voeg favoriet toe', _openFavorites),
                  option(Icons.restaurant_menu, 'Voeg maaltijd toe', _openMeals),
                  option(Icons.qr_code_scanner, 'Scan barcode', _openBarcodeScanner),
                  option(Icons.search, 'Zoek product', _openFoodSearch),
                  option(Icons.edit, 'Voeg handmatig toe', _openAddFood),
                  option(Icons.monitor_weight, 'Voeg weegmoment toe', () => _openAddWeight(profile)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WwColors.background(widget.isDark),
      body: SafeArea(
        child: StreamBuilder<UserProfileRow?>(
          stream: widget.db.select(widget.db.userProfiles).watchSingleOrNull(),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            if (profile == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildBody(context, profile);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileRow profile) {
    return StreamBuilder<List<FoodLogEntryRow>>(
      stream: widget.db.select(widget.db.foodLogEntries).watch(),
      builder: (context, foodSnapshot) {
        final allFood = foodSnapshot.data ?? const <FoodLogEntryRow>[];
        final todaysFood = allFood.where((e) => _isSameDay(e.date, _selectedDate)).toList();
        _maybeRefreshEveningReminder(allFood.any((e) => _isSameDay(e.date, DateTime.now())));

        return StreamBuilder<List<TrainingSessionRow>>(
          stream: widget.db.select(widget.db.trainingSessions).watch(),
          builder: (context, trainingSnapshot) {
            final allTrainings = trainingSnapshot.data ?? const <TrainingSessionRow>[];
            final todaysTrainings =
                allTrainings.where((t) => _isSameDay(t.date, _selectedDate)).toList();
            final todaysTrainingCalories =
                todaysTrainings.fold<double>(0, (sum, t) => sum + t.estimatedCaloriesBurned);

            final target = MacroCalculator.calculate(
              profile: profile,
              goalMode: profile.goalMode,
              goalPace: profile.goalPace,
              extraTrainingCalories: todaysTrainingCalories * _trainingCreditFactor,
            );

            _maybeUpsertSnapshot(profile, target);
            _maybeCheckBadges(allFood.length, allTrainings.length);

            final caloriesEaten = todaysFood.fold<double>(0, (sum, e) => sum + e.calories);
            final proteinEaten = todaysFood.fold<double>(0, (sum, e) => sum + e.proteinGrams);
            final carbsEaten = todaysFood.fold<double>(0, (sum, e) => sum + e.carbsGrams);
            final fatEaten = todaysFood.fold<double>(0, (sum, e) => sum + e.fatGrams);
            final fiberEaten = todaysFood.fold<double>(0, (sum, e) => sum + e.fiberGrams);
            final caloriesRemaining = (target.calories - caloriesEaten).clamp(0, double.infinity);
            final proteinRemaining = (target.proteinGrams - proteinEaten).clamp(0, double.infinity).toDouble();
            final fiberRemaining = (target.fiberGrams - fiberEaten).clamp(0, double.infinity).toDouble();

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                _header(profile),
                const SizedBox(height: 16),
                _dateNavigator(),
                const SizedBox(height: 16),
                _coachCard(
                  hasLoggedToday: todaysFood.isNotEmpty,
                  caloriesRemaining: caloriesRemaining.toDouble(),
                  proteinRemaining: proteinRemaining,
                  fiberRemaining: fiberRemaining,
                ),
                const SizedBox(height: 16),
                _caloriesCard(
                  burned: todaysTrainingCalories,
                  eaten: caloriesEaten,
                  remaining: caloriesRemaining.toDouble(),
                  target: target,
                ),
                const SizedBox(height: 16),
                _macrosCard(
                  protein: proteinEaten,
                  carbs: carbsEaten,
                  fat: fatEaten,
                  fiber: fiberEaten,
                  target: target,
                  entries: todaysFood,
                  date: _selectedDate,
                ),
                const SizedBox(height: 16),
                _trainingCard(profile, todaysTrainings),
              ],
            );
          },
        );
      },
    );
  }

  Widget _header(UserProfileRow profile) {
    final isDark = widget.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _openProfile(profile),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '$_greeting ${profile.name} 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: WwColors.darkAccent(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: WwColors.secondaryText(isDark)),
                  ],
                ),
              ),
            ),
            _roundIconButton(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              onTap: widget.onToggleTheme,
            ),
            const SizedBox(width: 10),
            _roundIconButton(
              icon: Icons.restaurant,
              onTap: () => _showQuickAddMenu(profile),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'TRACK YOUR MACROS · GUARD YOUR GAINS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: WwColors.teal,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.goalMode.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: WwColors.orange,
          ),
        ),
      ],
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    final isDark = widget.isDark;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: WwColors.cardBackground(isDark),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: WwColors.teal, size: 22),
      ),
    );
  }

  Widget _dateNavigator() {
    final isDark = widget.isDark;
    final weekdayLabel = const [
      'maandag',
      'dinsdag',
      'woensdag',
      'donderdag',
      'vrijdag',
      'zaterdag',
      'zondag',
    ][_selectedDate.weekday - 1];
    final months = const [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];

    return WwCard(
      isDark: isDark,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: WwColors.teal),
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            }),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _isToday ? 'Vandaag' : weekdayLabel[0].toUpperCase() + weekdayLabel.substring(1),
                  style: TextStyle(fontWeight: FontWeight.w600, color: WwColors.darkAccent(isDark)),
                ),
                Text(
                  '${_selectedDate.day} ${months[_selectedDate.month - 1]}',
                  style: TextStyle(fontSize: 12, color: WwColors.darkAccent(isDark).withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: _isToday ? WwColors.darkAccent(isDark).withValues(alpha: 0.2) : WwColors.teal),
            onPressed: _isToday
                ? null
                : () => setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    }),
          ),
        ],
      ),
    );
  }

  Widget _coachCard({
    required bool hasLoggedToday,
    required double caloriesRemaining,
    required double proteinRemaining,
    required double fiberRemaining,
  }) {
    final isDark = widget.isDark;
    final message = CoachMessage.forState(
      blunt: _bluntCoach,
      hasLoggedToday: hasLoggedToday,
      caloriesRemaining: caloriesRemaining,
      proteinRemaining: proteinRemaining,
      fiberRemaining: fiberRemaining,
    );
    return WwCard(
      isDark: isDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: WwColors.darkAccent(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _caloriesCard({
    required double burned,
    required double eaten,
    required double remaining,
    required MacroTarget target,
  }) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calorieën', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: WwColors.darkAccent(isDark))),
              InkWell(
                onTap: _openAddRestDay,
                child: Icon(Icons.bed, size: 18, color: WwColors.secondaryText(isDark)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 118,
                height: 118,
                child: RingProgress(
                  isDark: isDark,
                  current: eaten,
                  target: target.calories,
                  unit: 'kcal',
                  gradient: WwGradients.main,
                  lineWidth: 16,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _calorieInfoRow(Icons.local_fire_department, 'Verbrand', burned.roundedInt, Colors.orange),
                    const SizedBox(height: 10),
                    _calorieInfoRow(Icons.restaurant, 'Gegeten', eaten.roundedInt, WwColors.teal),
                    const SizedBox(height: 10),
                    _calorieInfoRow(Icons.track_changes, 'Resterend', remaining.roundedInt, WwColors.aqua),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calorieInfoRow(IconData icon, String label, int value, Color color) {
    final isDark = widget.isDark;
    return Row(
      children: [
        SizedBox(width: 22, child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: WwColors.darkAccent(isDark).withValues(alpha: 0.5))),
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
          ],
        ),
      ],
    );
  }

  Widget _macrosCard({
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required MacroTarget target,
    required List<FoodLogEntryRow> entries,
    required DateTime date,
  }) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Macro's", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _openMacroBreakdown(MacroBreakdownType.eiwit, date, entries),
                child: CompactRing(isDark: isDark, title: 'Eiwit', current: protein, target: target.proteinGrams, unit: 'g', gradient: WwGradients.protein),
              ),
              GestureDetector(
                onTap: () => _openMacroBreakdown(MacroBreakdownType.koolhydraten, date, entries),
                child: CompactRing(isDark: isDark, title: 'Carbs', current: carbs, target: target.carbsGrams, unit: 'g', gradient: WwGradients.carbs),
              ),
              GestureDetector(
                onTap: () => _openMacroBreakdown(MacroBreakdownType.vet, date, entries),
                child: CompactRing(isDark: isDark, title: 'Vet', current: fat, target: target.fatGrams, unit: 'g', gradient: WwGradients.fat),
              ),
              GestureDetector(
                onTap: () => _openMacroBreakdown(MacroBreakdownType.vezels, date, entries),
                child: CompactRing(isDark: isDark, title: 'Vezels', current: fiber, target: target.fiberGrams, unit: 'g', gradient: WwGradients.fiber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trainingCard(UserProfileRow profile, List<TrainingSessionRow> todaysTrainings) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Training', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 12),
          if (todaysTrainings.isEmpty)
            _isToday
                ? InkWell(
                    onTap: () => _openAddTraining(profile),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, color: WwColors.teal),
                          const SizedBox(width: 8),
                          Text('Training toevoegen', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.teal)),
                          const Spacer(),
                          Icon(Icons.chevron_right, size: 16, color: WwColors.darkAccent(isDark).withValues(alpha: 0.3)),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.accessibility_new, color: WwColors.darkAccent(isDark).withValues(alpha: 0.3)),
                        const SizedBox(width: 8),
                        Text('Geen training gelogd', style: TextStyle(color: WwColors.darkAccent(isDark).withValues(alpha: 0.5))),
                      ],
                    ),
                  )
          else
            ...todaysTrainings.map((training) => _trainingRow(training)),
          if (todaysTrainings.isNotEmpty && _isToday) ...[
            const Divider(),
            InkWell(
              onTap: () => _openAddTraining(profile),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14, color: WwColors.teal),
                  const SizedBox(width: 4),
                  Text('Nog een training', style: TextStyle(fontSize: 12, color: WwColors.teal)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trainingRow(TrainingSessionRow training) {
    final isDark = widget.isDark;
    return Dismissible(
      key: ValueKey(training.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) {
        (widget.db.delete(widget.db.trainingSessions)..where((t) => t.id.equals(training.id))).go();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 36, child: Icon(training.type.icon, color: WwColors.teal)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(training.type.label, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                  Text(
                    '${training.durationMinutes} min • RPE ${training.rpe}',
                    style: TextStyle(fontSize: 12, color: WwColors.darkAccent(isDark).withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${training.estimatedCaloriesBurned.roundedInt}', style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                Text('kcal', style: TextStyle(fontSize: 12, color: WwColors.darkAccent(isDark).withValues(alpha: 0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
