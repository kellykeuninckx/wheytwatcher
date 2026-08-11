import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'copy_meal_detail_screen.dart';

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

const _dutchMonthsWide = [
  'januari', 'februari', 'maart', 'april', 'mei', 'juni', 'juli', 'augustus', 'september', 'oktober', 'november', 'december',
];
const _dutchWeekdays = ['maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag', 'zondag'];

/// Poort van `CopyMealsView` uit `CopyMealsView.swift`: kies een dag (default
/// gisteren) en zie welke maaltijden er die dag gelogd zijn, om er
/// vervolgens producten uit te kopiëren.
class CopyByDayScreen extends StatefulWidget {
  const CopyByDayScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<CopyByDayScreen> createState() => _CopyByDayScreenState();
}

class _CopyByDayScreenState extends State<CopyByDayScreen> {
  late DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));

  bool get _isToday => _isSameDay(_selectedDate, DateTime.now());

  String get _dayTitle {
    if (_isToday) return 'Vandaag';
    if (_isSameDay(_selectedDate, DateTime.now().subtract(const Duration(days: 1)))) return 'Gisteren';
    final w = _dutchWeekdays[_selectedDate.weekday - 1];
    return w[0].toUpperCase() + w.substring(1);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _openMealDetail(MealCategory category, List<FoodLogEntryRow> entries) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CopyMealDetailScreen(db: widget.db, isDark: widget.isDark, category: category, entries: entries),
      ),
    );
    if (done == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Kopieer maaltijd', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.orange),
      ),
      body: SafeArea(
        child: StreamBuilder<List<FoodLogEntryRow>>(
          stream: widget.db.select(widget.db.foodLogEntries).watch(),
          builder: (context, snapshot) {
            final allFood = snapshot.data ?? const <FoodLogEntryRow>[];
            final dayEntries = allFood.where((e) => _isSameDay(e.date, _selectedDate)).toList();

            final grouped = <MealCategory, List<FoodLogEntryRow>>{};
            for (final entry in dayEntries) {
              grouped.putIfAbsent(entry.mealCategory, () => []).add(entry);
            }
            final categories = MealCategory.values.where(grouped.containsKey).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                _dateNavigator(),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  PlaceholderCard(
                    isDark: isDark,
                    icon: Icons.restaurant,
                    color: WwColors.orange,
                    title: 'Geen maaltijden gevonden',
                    message: 'Er zijn geen maaltijden gelogd op deze datum.',
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text('MAALTIJDEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.secondaryText(isDark))),
                  ),
                  for (final category in categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _openMealDetail(category, grouped[category]!),
                        child: WwCard(
                          isDark: isDark,
                          child: Row(
                            children: [
                              Text(category.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                              const Spacer(),
                              Text('(${grouped[category]!.length})', style: TextStyle(color: WwColors.secondaryText(isDark))),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _dateNavigator() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: WwColors.teal),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              child: Column(
                children: [
                  Text(_dayTitle, style: TextStyle(fontWeight: FontWeight.w600, color: WwColors.darkAccent(isDark))),
                  Text(
                    '${_selectedDate.day} ${_dutchMonthsWide[_selectedDate.month - 1]}',
                    style: TextStyle(fontSize: 12, color: WwColors.darkAccent(isDark).withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: _isToday ? WwColors.darkAccent(isDark).withValues(alpha: 0.2) : WwColors.teal),
            onPressed: _isToday ? null : () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}
