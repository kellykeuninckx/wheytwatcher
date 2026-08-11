import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';

/// Poort van `MacroBreakdownType` uit TodayView.swift.
enum MacroBreakdownType { eiwit, koolhydraten, vet, vezels }

extension MacroBreakdownTypeX on MacroBreakdownType {
  String get label {
    switch (this) {
      case MacroBreakdownType.eiwit:
        return 'Eiwit';
      case MacroBreakdownType.koolhydraten:
        return 'Koolhydraten';
      case MacroBreakdownType.vet:
        return 'Vet';
      case MacroBreakdownType.vezels:
        return 'Vezels';
    }
  }

  double grams(FoodLogEntryRow entry) {
    switch (this) {
      case MacroBreakdownType.eiwit:
        return entry.proteinGrams;
      case MacroBreakdownType.koolhydraten:
        return entry.carbsGrams;
      case MacroBreakdownType.vet:
        return entry.fatGrams;
      case MacroBreakdownType.vezels:
        return entry.fiberGrams;
    }
  }
}

/// Poort van `MacroBreakdownView.swift`: per macro welke gelogde producten die
/// dag het meest bijdroegen (premium-feature).
class MacroBreakdownScreen extends StatefulWidget {
  const MacroBreakdownScreen({
    super.key,
    required this.isDark,
    required this.initialMacro,
    required this.date,
    required this.entries,
  });

  final bool isDark;
  final MacroBreakdownType initialMacro;
  final DateTime date;
  final List<FoodLogEntryRow> entries;

  @override
  State<MacroBreakdownScreen> createState() => _MacroBreakdownScreenState();
}

class _MacroBreakdownScreenState extends State<MacroBreakdownScreen> {
  late MacroBreakdownType _macro = widget.initialMacro;

  List<({String name, double grams, int count})> get _contributions {
    final grouped = <String, List<FoodLogEntryRow>>{};
    for (final e in widget.entries) {
      grouped.putIfAbsent(e.name, () => []).add(e);
    }
    final result = grouped.entries
        .map((entry) => (
              name: entry.key,
              grams: entry.value.fold<double>(0, (sum, e) => sum + _macro.grams(e)),
              count: entry.value.length,
            ))
        .where((c) => c.grams > 0)
        .toList()
      ..sort((a, b) => b.grams.compareTo(a.grams));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final contributions = _contributions;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text(_macro.label, style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: WwCard(
                isDark: isDark,
                child: Row(
                  children: MacroBreakdownType.values.map((m) {
                    final selected = m == _macro;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _macro = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: selected ? WwColors.teal : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            m.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : WwColors.darkAccent(isDark),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: contributions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: PlaceholderCard(
                        isDark: isDark,
                        icon: Icons.pie_chart_outline,
                        color: WwColors.teal,
                        title: 'Nog niks gelogd',
                        message: 'Zodra je iets logt met ${_macro.label.toLowerCase()} erin, zie je hier welke producten het meest bijdroegen.',
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                      children: [
                        WwCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              for (var i = 0; i < contributions.length; i++) ...[
                                if (i > 0) Divider(height: 20, color: WwColors.darkAccent(isDark).withValues(alpha: 0.08)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contributions[i].count > 1 ? '${contributions[i].name} (${contributions[i].count}x)' : contributions[i].name,
                                        style: TextStyle(color: WwColors.darkAccent(isDark)),
                                      ),
                                    ),
                                    Text('${contributions[i].grams.roundedInt} g',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.teal)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
