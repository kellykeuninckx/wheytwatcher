import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../logic/app_settings.dart';
import '../logic/enum_labels.dart';
import '../logic/purchase_manager.dart';
import '../logic/trend_calculator.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'paywall_screen.dart';

enum _ChartRange { twoWeeks, month, all }

extension on _ChartRange {
  String get label {
    switch (this) {
      case _ChartRange.twoWeeks:
        return '14 dagen';
      case _ChartRange.month:
        return '30 dagen';
      case _ChartRange.all:
        return 'Alles';
    }
  }

  int? get days {
    switch (this) {
      case _ChartRange.twoWeeks:
        return 14;
      case _ChartRange.month:
        return 30;
      case _ChartRange.all:
        return null;
    }
  }
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Poort van `ProgressView.swift` — voor nu de gewicht-, calorieën- en
/// eiwit-trendgrafieken met de 14-dagen/30-dagen/Alles-periodekiezer.
///
/// Nog niet meegenomen: premium-gating op de langere periodes (er is nog
/// geen PurchaseManager/Play Billing), lichaamsmetingen-grafiek, de
/// "Prestaties"-badges-kaart, de roterende coach-tip, en tikken om een
/// grafiek uit te vergroten.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.db, required this.isDark});

  final AppDatabase db;
  final bool isDark;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _ChartRange _range = _ChartRange.twoWeeks;

  bool _showMeasurements = false;
  BodyMeasurementType _selectedMeasurement = BodyMeasurementType.waist;

  @override
  void initState() {
    super.initState();
    _loadShowMeasurements();
  }

  Future<void> _loadShowMeasurements() async {
    final show = await AppSettings.showBodyMeasurementsChart();
    if (mounted) setState(() => _showMeasurements = show);
  }

  /// Langere geschiedenis (maand/alles) is een premium-feature; 2 weken blijft
  /// gratis. Bij een gated keuze zonder premium volgt de paywall.
  void _selectRange(_ChartRange range) {
    if (range != _ChartRange.twoWeeks && !PurchaseManager.instance.isPremiumUnlocked) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaywallScreen(isDark: widget.isDark)));
      return;
    }
    setState(() => _range = range);
  }

  DateTime _rangeStart(List<DateTime> allDates) {
    final days = _range.days;
    if (days == null) {
      return allDates.isEmpty ? DateTime.now() : allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    }
    return _startOfDay(DateTime.now()).subtract(Duration(days: days));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Progressie', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<WeightLogRow>>(
          stream: widget.db.select(widget.db.weightLogs).watch(),
          builder: (context, weightSnapshot) {
            final allWeights = List.of(weightSnapshot.data ?? const <WeightLogRow>[])
              ..sort((a, b) => a.date.compareTo(b.date));

            return StreamBuilder<List<FoodLogEntryRow>>(
              stream: widget.db.select(widget.db.foodLogEntries).watch(),
              builder: (context, foodSnapshot) {
                final allFood = foodSnapshot.data ?? const <FoodLogEntryRow>[];

                return StreamBuilder<List<DailyTargetSnapshotRow>>(
                  stream: widget.db.select(widget.db.dailyTargetSnapshots).watch(),
                  builder: (context, snapshotSnapshot) {
                    final allSnapshots = snapshotSnapshot.data ?? const <DailyTargetSnapshotRow>[];
                    return StreamBuilder<List<BodyMeasurementLogRow>>(
                      stream: widget.db.select(widget.db.bodyMeasurementLogs).watch(),
                      builder: (context, measurementSnapshot) {
                        final allMeasurements = List.of(measurementSnapshot.data ?? const <BodyMeasurementLogRow>[])
                          ..sort((a, b) => a.date.compareTo(b.date));
                        return _body(allWeights, allFood, allSnapshots, allMeasurements);
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

  Widget _body(List<WeightLogRow> allWeights, List<FoodLogEntryRow> allFood, List<DailyTargetSnapshotRow> allSnapshots,
      List<BodyMeasurementLogRow> allMeasurements) {
    final rangeStart = _rangeStart([
      ...allWeights.map((w) => w.date),
      ...allFood.map((f) => f.date),
    ]);

    final weights = allWeights.where((w) => !w.date.isBefore(rangeStart)).toList();
    final food = allFood.where((f) => !f.date.isBefore(rangeStart)).toList();
    final snapshots = allSnapshots.where((s) => !s.date.isBefore(rangeStart)).toList();
    final measurements = allMeasurements.where((m) => !m.date.isBefore(rangeStart)).toList();

    final dailyCalories = <DateTime, double>{};
    final dailyProtein = <DateTime, double>{};
    for (final entry in food) {
      final day = _startOfDay(entry.date);
      dailyCalories[day] = (dailyCalories[day] ?? 0) + entry.calories;
      dailyProtein[day] = (dailyProtein[day] ?? 0) + entry.proteinGrams;
    }

    final dailyTargetProtein = <DateTime, double>{};
    for (final snapshot in snapshots) {
      dailyTargetProtein.putIfAbsent(_startOfDay(snapshot.date), () => snapshot.proteinGrams);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
      children: [
        _rangePicker(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _weightCard(weights)),
            const SizedBox(width: 12),
            Expanded(child: _proteinCard(dailyProtein, dailyTargetProtein)),
          ],
        ),
        const SizedBox(height: 16),
        _caloriesCard(dailyCalories),
        if (_showMeasurements) ...[
          const SizedBox(height: 16),
          _measurementCard(measurements),
        ],
      ],
    );
  }

  double? _measurementValue(BodyMeasurementLogRow log, BodyMeasurementType type) {
    switch (type) {
      case BodyMeasurementType.waist:
        return log.waistCm;
      case BodyMeasurementType.chest:
        return log.chestCm;
      case BodyMeasurementType.hips:
        return log.hipsCm;
      case BodyMeasurementType.arm:
        return log.armCm;
      case BodyMeasurementType.thigh:
        return log.thighCm;
    }
  }

  Widget _measurementCard(List<BodyMeasurementLogRow> measurements) {
    final isDark = widget.isDark;
    final availableTypes =
        BodyMeasurementType.values.where((t) => measurements.any((m) => _measurementValue(m, t) != null)).toList();
    if (availableTypes.isEmpty) return const SizedBox.shrink();

    final selected = availableTypes.contains(_selectedMeasurement) ? _selectedMeasurement : availableTypes.first;
    final points = measurements.where((m) => _measurementValue(m, selected) != null).toList();

    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lichaamsmetingen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WwColors.darkAccent(isDark))),
              const Spacer(),
              DropdownButton<BodyMeasurementType>(
                value: selected,
                isDense: true,
                underline: const SizedBox.shrink(),
                dropdownColor: WwColors.cardBackground(isDark),
                style: TextStyle(color: WwColors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                items: availableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMeasurement = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: points.length >= 2
                ? _measurementChart(points, selected)
                : Center(
                    child: Text('Nog te weinig metingen in deze periode.',
                        style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _measurementChart(List<BodyMeasurementLogRow> points, BodyMeasurementType type) {
    final origin = points.first.date;
    final spots = points.map((m) => FlSpot(m.date.difference(origin).inHours / 24.0, _measurementValue(m, type)!)).toList();
    final values = spots.map((s) => s.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _compactTitlesData(
          origin,
          points.length,
          leftInterval: ((maxY + padding) - (minY - padding)) / 4,
          leftDecimals: 1,
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(spots: spots, isCurved: false, color: WwColors.teal, barWidth: 2, dotData: const FlDotData(show: true)),
        ],
      ),
    );
  }

  Widget _rangePicker() {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Row(
        children: _ChartRange.values.map((range) {
          final selected = range == _range;
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectRange(range),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? WwColors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  range.label,
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

  Widget _weightCard(List<WeightLogRow> weights) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Gewicht', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WwColors.darkAccent(isDark))),
              const Spacer(),
              if (weights.isNotEmpty)
                Text('${weights.last.weightKg.roundedInt} kg', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: WwColors.teal)),
            ],
          ),
          const SizedBox(height: 10),
          if (weights.isEmpty)
            PlaceholderCard(isDark: isDark, icon: Icons.monitor_weight, color: WwColors.blue, title: 'Nog geen gewicht', message: 'Log je gewicht om je trend te zien.')
          else
            SizedBox(height: 130, child: _weightChart(weights)),
        ],
      ),
    );
  }

  Widget _weightChart(List<WeightLogRow> weights) {
    final origin = weights.first.date;
    final actualSpots = weights
        .map((w) => FlSpot(w.date.difference(origin).inHours / 24.0, w.weightKg))
        .toList();

    final trendInput = weights.map((w) => TrendPoint(w.date, w.weightKg)).toList();
    final smoothed = TrendCalculator.smoothedPoints(trendInput);
    final trendLine = TrendCalculator.linearTrendLine(smoothed);
    final trendSpots = trendLine
        .map((p) => FlSpot(p.date.difference(origin).inHours / 24.0, p.value))
        .toList();

    final values = [...weights.map((w) => w.weightKg), ...trendLine.map((p) => p.value)];
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.3, double.infinity);

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _compactTitlesData(
          origin,
          weights.length,
          leftInterval: ((maxY + padding) - (minY - padding)) / 4,
          leftDecimals: 1,
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(spots: actualSpots, isCurved: false, color: WwColors.teal, barWidth: 2, dotData: const FlDotData(show: true)),
          if (trendSpots.length == 2)
            LineChartBarData(
              spots: trendSpots,
              isCurved: false,
              color: WwColors.teal.withValues(alpha: 0.6),
              barWidth: 1.5,
              dashArray: const [4, 3],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _proteinCard(Map<DateTime, double> dailyProtein, Map<DateTime, double> dailyTargetProtein) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Eiwit-trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 10),
          if (dailyProtein.isEmpty)
            PlaceholderCard(isDark: isDark, icon: Icons.eco, color: WwColors.teal, title: 'Nog geen data', message: 'Log maaltijden om je eiwit te zien.')
          else
            SizedBox(height: 130, child: _proteinChart(dailyProtein, dailyTargetProtein)),
        ],
      ),
    );
  }

  Widget _proteinChart(Map<DateTime, double> dailyProtein, Map<DateTime, double> dailyTargetProtein) {
    final days = dailyProtein.keys.toList()..sort();
    final origin = days.first;

    final actualSpots = days.map((d) => FlSpot(d.difference(origin).inDays.toDouble(), dailyProtein[d]!)).toList();

    final targetDays = dailyTargetProtein.keys.toList()..sort();
    final targetSpots = targetDays
        .map((d) => FlSpot(d.difference(origin).inDays.toDouble(), dailyTargetProtein[d]!))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _compactTitlesData(origin, days.length),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(spots: actualSpots, isCurved: false, color: WwColors.teal, barWidth: 2, dotData: const FlDotData(show: true)),
          if (targetSpots.length >= 2)
            LineChartBarData(
              spots: targetSpots,
              isCurved: false,
              color: WwColors.purple.withValues(alpha: 0.6),
              barWidth: 1.5,
              dashArray: const [4, 3],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _caloriesCard(Map<DateTime, double> dailyCalories) {
    final isDark = widget.isDark;
    return WwCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calorieën', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: WwColors.darkAccent(isDark))),
          const SizedBox(height: 12),
          if (dailyCalories.isEmpty)
            PlaceholderCard(isDark: isDark, icon: Icons.local_fire_department, color: WwColors.orange, title: 'Nog geen data', message: 'Log maaltijden om je intake te zien.')
          else
            SizedBox(height: 180, child: _caloriesChart(dailyCalories)),
        ],
      ),
    );
  }

  Widget _caloriesChart(Map<DateTime, double> dailyCalories) {
    final days = dailyCalories.keys.toList()..sort();
    final origin = days.first;

    final groups = days.map((d) {
      final x = d.difference(origin).inDays;
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: dailyCalories[d]!,
            color: WwColors.orange.withValues(alpha: 0.7),
            width: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titlesData(origin, days.length, stride: (days.length / 5).ceil().clamp(1, 1000)),
        barTouchData: BarTouchData(enabled: false),
        barGroups: groups,
      ),
    );
  }

  FlTitlesData _compactTitlesData(DateTime origin, int pointCount, {double? leftInterval, int leftDecimals = 0}) {
    return _titlesData(
      origin,
      pointCount,
      stride: (pointCount / 3).ceil().clamp(1, 1000),
      leftInterval: leftInterval,
      leftDecimals: leftDecimals,
    );
  }

  FlTitlesData _titlesData(
    DateTime origin,
    int pointCount, {
    required int stride,
    double? leftInterval,
    int leftDecimals = 0,
  }) {
    final isDark = widget.isDark;
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: leftInterval,
          getTitlesWidget: (value, meta) => Text(
            value.toStringAsFixed(leftDecimals),
            style: TextStyle(fontSize: 9, color: WwColors.darkAccent(isDark).withValues(alpha: 0.6)),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          interval: stride.toDouble(),
          getTitlesWidget: (value, meta) {
            final date = origin.add(Duration(days: value.round()));
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${date.day}/${date.month}',
                style: TextStyle(fontSize: 9, color: WwColors.darkAccent(isDark).withValues(alpha: 0.6)),
              ),
            );
          },
        ),
      ),
    );
  }
}
