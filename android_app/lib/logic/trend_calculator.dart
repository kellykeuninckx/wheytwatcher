class TrendPoint {
  const TrendPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

/// Poort van de gewicht-trendlogica uit `ProgressView.swift`
/// (`smoothedPoints`/`weightTrendPoints`): exponentiële smoothing gevolgd
/// door een kleinste-kwadraten regressie, zodat een korte piek (vocht/ziekte)
/// de weergegeven trend niet laat schrikken.
class TrendCalculator {
  TrendCalculator._();

  static List<TrendPoint> smoothedPoints(List<TrendPoint> sortedByDate, {double alpha = 0.2}) {
    if (sortedByDate.isEmpty) return const [];

    final result = <TrendPoint>[];
    var previous = sortedByDate.first.value;

    for (var i = 0; i < sortedByDate.length; i++) {
      final point = sortedByDate[i];
      final smoothed = i == 0 ? point.value : alpha * point.value + (1 - alpha) * previous;
      previous = smoothed;
      result.add(TrendPoint(point.date, smoothed));
    }

    return result;
  }

  /// Geeft de twee eindpunten van de regressielijn terug (begin- en einddatum
  /// van de smoothed reeks), of een lege lijst als er te weinig data is.
  static List<TrendPoint> linearTrendLine(List<TrendPoint> smoothed) {
    if (smoothed.length < 2) return const [];

    final referenceDate = smoothed.first.date;
    final xs = smoothed.map((p) => p.date.difference(referenceDate).inSeconds / 86400.0).toList();
    final ys = smoothed.map((p) => p.value).toList();

    final n = xs.length.toDouble();
    final sumX = xs.reduce((a, b) => a + b);
    final sumY = ys.reduce((a, b) => a + b);
    var sumXY = 0.0;
    var sumXX = 0.0;
    for (var i = 0; i < xs.length; i++) {
      sumXY += xs[i] * ys[i];
      sumXX += xs[i] * xs[i];
    }

    final denominator = n * sumXX - sumX * sumX;
    if (denominator == 0) return const [];

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    final firstX = xs.first;
    final lastX = xs.last;

    return [
      TrendPoint(smoothed.first.date, slope * firstX + intercept),
      TrendPoint(smoothed.last.date, slope * lastX + intercept),
    ];
  }

  /// Gewicht-verandering per week (kg/week), positief = aankomen. `null` als
  /// er te weinig data is voor een betrouwbare trend.
  static double? weeklyChangeRate(List<TrendPoint> sortedByDate) {
    final smoothed = smoothedPoints(sortedByDate);
    if (smoothed.length < 2) return null;

    final referenceDate = smoothed.first.date;
    final xs = smoothed.map((p) => p.date.difference(referenceDate).inSeconds / 86400.0).toList();
    final ys = smoothed.map((p) => p.value).toList();

    final n = xs.length.toDouble();
    final sumX = xs.reduce((a, b) => a + b);
    final sumY = ys.reduce((a, b) => a + b);
    var sumXY = 0.0;
    var sumXX = 0.0;
    for (var i = 0; i < xs.length; i++) {
      sumXY += xs[i] * ys[i];
      sumXX += xs[i] * xs[i];
    }

    final denominator = n * sumXX - sumX * sumX;
    if (denominator == 0) return null;

    final slopePerDay = (n * sumXY - sumX * sumY) / denominator;
    return slopePerDay * 7;
  }
}
