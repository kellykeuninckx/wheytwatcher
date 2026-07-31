import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

enum _LogFilter { all, food, training }

extension on _LogFilter {
  String get label {
    switch (this) {
      case _LogFilter.all:
        return 'Alles';
      case _LogFilter.food:
        return 'Voeding';
      case _LogFilter.training:
        return 'Training';
    }
  }
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

const _dutchMonths = ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];

String _formatDay(DateTime day) => '${day.day} ${_dutchMonths[day.month - 1]}';

/// Poort van `LogbookView.swift`/`LogbookEntryRow.swift`: dagoverzicht van
/// gelogde voeding en training, met filter, favoriet-toggle, dagstatus
/// (ziek/vakantie/rustdag) en swipe-to-delete.
///
/// Niet meegenomen: multi-select + "Bewaar als maaltijd" (`SaveMealView`,
/// aparte flow, nog niet geport).
class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  _LogFilter _filter = _LogFilter.all;

  bool get _showsFood => _filter != _LogFilter.training;
  bool get _showsTraining => _filter != _LogFilter.food;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Logboek', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<FoodLogEntryRow>>(
          stream: widget.db.select(widget.db.foodLogEntries).watch(),
          builder: (context, foodSnapshot) {
            final food = List.of(foodSnapshot.data ?? const <FoodLogEntryRow>[])
              ..sort((a, b) => b.date.compareTo(a.date));

            return StreamBuilder<List<TrainingSessionRow>>(
              stream: widget.db.select(widget.db.trainingSessions).watch(),
              builder: (context, trainingSnapshot) {
                final trainings = List.of(trainingSnapshot.data ?? const <TrainingSessionRow>[])
                  ..sort((a, b) => b.date.compareTo(a.date));

                return StreamBuilder<List<FavoriteFoodRow>>(
                  stream: widget.db.select(widget.db.favoriteFoods).watch(),
                  builder: (context, favSnapshot) {
                    final favorites = favSnapshot.data ?? const <FavoriteFoodRow>[];

                    return StreamBuilder<List<DayStatusRow>>(
                      stream: widget.db.select(widget.db.dayStatuses).watch(),
                      builder: (context, statusSnapshot) {
                        final dayStatuses = statusSnapshot.data ?? const <DayStatusRow>[];
                        return _body(food, trainings, favorites, dayStatuses);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _body(
    List<FoodLogEntryRow> food,
    List<TrainingSessionRow> trainings,
    List<FavoriteFoodRow> favorites,
    List<DayStatusRow> dayStatuses,
  ) {
    final groupedFood = <DateTime, List<FoodLogEntryRow>>{};
    for (final entry in food) {
      groupedFood.putIfAbsent(_startOfDay(entry.date), () => []).add(entry);
    }
    final groupedTraining = <DateTime, List<TrainingSessionRow>>{};
    for (final training in trainings) {
      groupedTraining.putIfAbsent(_startOfDay(training.date), () => []).add(training);
    }

    final allDays = {...groupedFood.keys, ...groupedTraining.keys}.toList()..sort((a, b) => b.compareTo(a));

    if (allDays.isEmpty) {
      return Center(
        child: Text('Nog niets gelogd', style: TextStyle(color: WwColors.secondaryText(widget.isDark))),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
      children: [
        _filterRow(),
        const SizedBox(height: 8),
        for (final day in allDays) ..._daySection(day, groupedFood[day] ?? [], groupedTraining[day] ?? [], favorites, dayStatuses),
      ],
    );
  }

  Widget _filterRow() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Row(
        children: _LogFilter.values.map((filter) {
          final selected = filter == _filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? WwColors.aqua : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : WwColors.darkAccent(isDark),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _daySection(
    DateTime day,
    List<FoodLogEntryRow> dayFood,
    List<TrainingSessionRow> dayTrainings,
    List<FavoriteFoodRow> favorites,
    List<DayStatusRow> dayStatuses,
  ) {
    final status = dayStatuses.where((s) => _startOfDay(s.date) == day).firstOrNull;
    final widgets = <Widget>[_dayLabelRow(day, status)];

    if (_showsFood) {
      for (final meal in MealCategory.values) {
        final mealEntries = dayFood.where((e) => e.mealCategory == meal).toList();
        if (mealEntries.isEmpty) continue;
        widgets.add(_sectionLabel(meal.label));
        for (final entry in mealEntries) {
          final isFavorite = favorites.any((f) => f.name == entry.name);
          widgets.add(_foodRow(entry, isFavorite));
        }
      }
    }

    if (_showsTraining && dayTrainings.isNotEmpty) {
      widgets.add(_sectionLabel('Training'));
      for (final training in dayTrainings) {
        widgets.add(_trainingRow(training));
      }
    }

    return widgets;
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6, bottom: 2),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.teal)),
    );
  }

  Widget _dayLabelRow(DateTime day, DayStatusRow? status) {
    final isDark = widget.isDark;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Text(_formatDay(day), style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
          if (status != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: WwColors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.type.icon, size: 12, color: WwColors.orange),
                  const SizedBox(width: 3),
                  Text(status.type.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: WwColors.orange)),
                ],
              ),
            ),
          ],
          const Spacer(),
          InkWell(
            onTap: () => _showDayStatusMenu(day, status),
            child: Icon(Icons.bedtime, size: 18, color: WwColors.secondaryText(isDark)),
          ),
        ],
      ),
    );
  }

  void _showDayStatusMenu(DateTime day, DayStatusRow? existing) {
    final isDark = widget.isDark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: WwColors.cardBackground(isDark),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final type in DayStatusType.values)
                ListTile(
                  leading: Icon(type.icon, color: WwColors.teal),
                  title: Text(type.label, style: TextStyle(color: WwColors.darkAccent(isDark))),
                  onTap: () {
                    Navigator.of(context).pop();
                    _setDayStatus(day, existing, type);
                  },
                ),
              if (existing != null)
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('Normaal (verwijder markering)', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _setDayStatus(day, existing, null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setDayStatus(DateTime day, DayStatusRow? existing, DayStatusType? type) async {
    final db = widget.db;
    if (existing != null) {
      await (db.delete(db.dayStatuses)..where((s) => s.id.equals(existing.id))).go();
    }
    if (type != null) {
      await db.into(db.dayStatuses).insert(DayStatusesCompanion.insert(date: day, type: type));
    }
  }

  Widget _foodRow(FoodLogEntryRow entry, bool isFavorite) {
    final isDark = widget.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: ValueKey('food-${entry.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        onDismissed: (_) => (widget.db.delete(widget.db.foodLogEntries)..where((e) => e.id.equals(entry.id))).go(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: WwColors.cardBackground(isDark), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.name, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                    Text(
                      '${entry.grams.roundedInt} g • ${entry.calories.roundedInt} kcal',
                      style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                    ),
                  ],
                ),
              ),
              InkWell(
                key: ValueKey('favorite-toggle-${entry.id}'),
                onTap: () => _toggleFavorite(entry, isFavorite),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? WwColors.coral : WwColors.secondaryText(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(FoodLogEntryRow entry, bool isFavorite) async {
    final db = widget.db;
    if (isFavorite) {
      final existing = await (db.select(db.favoriteFoods)..where((f) => f.name.equals(entry.name))).get();
      for (final row in existing) {
        await (db.delete(db.favoriteFoods)..where((f) => f.id.equals(row.id))).go();
      }
    } else {
      await db.into(db.favoriteFoods).insert(
            FavoriteFoodsCompanion.insert(
              name: entry.name,
              grams: entry.grams,
              calories: entry.calories,
              proteinGrams: entry.proteinGrams,
              carbsGrams: entry.carbsGrams,
              fatGrams: entry.fatGrams,
              fiberGrams: entry.fiberGrams,
            ),
          );
    }
  }

  Widget _trainingRow(TrainingSessionRow training) {
    final isDark = widget.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: ValueKey('training-${training.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        onDismissed: (_) => (widget.db.delete(widget.db.trainingSessions)..where((t) => t.id.equals(training.id))).go(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: WwColors.cardBackground(isDark), borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(training.type.label, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
              Text(
                '${training.durationMinutes} min • RPE ${training.rpe} • ${training.estimatedCaloriesBurned.roundedInt} kcal',
                style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
