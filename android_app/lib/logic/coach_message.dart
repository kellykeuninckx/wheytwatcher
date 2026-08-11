import 'nutrition_tips.dart';

/// Poort van de `coachMessage`-logica uit TodayView.swift: kiest een
/// contextueel coach-bericht op basis van de resterende macro's/calorieën,
/// met een normale of botte toon (bot-als-een-baksteen-modus).
class CoachMessage {
  CoachMessage._();

  static const List<_CoachType> _order = [
    _CoachType.fiberClose,
    _CoachType.proteinClose,
    _CoachType.caloriesAlmostDone,
    _CoachType.caloriesPlenty,
    _CoachType.onTrack,
    _CoachType.generalTip,
  ];

  static String forState({
    required bool blunt,
    required bool hasLoggedToday,
    required double caloriesRemaining,
    required double proteinRemaining,
    required double fiberRemaining,
    DateTime? now,
  }) {
    final date = now ?? DateTime.now();
    final rotation = _rotationIndex(date);
    for (var offset = 0; offset < _order.length; offset++) {
      final type = _order[(rotation + offset) % _order.length];
      final message = _messageFor(
        type,
        blunt: blunt,
        hasLoggedToday: hasLoggedToday,
        caloriesRemaining: caloriesRemaining,
        proteinRemaining: proteinRemaining,
        fiberRemaining: fiberRemaining,
        date: date,
      );
      if (message != null) return message;
    }
    return 'Je ligt goed op schema. Blijf zo doorgaan!';
  }

  static int _rotationIndex(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    return (dayOfYear * 24 + date.hour) % _order.length;
  }

  static String? _messageFor(
    _CoachType type, {
    required bool blunt,
    required bool hasLoggedToday,
    required double caloriesRemaining,
    required double proteinRemaining,
    required double fiberRemaining,
    required DateTime date,
  }) {
    switch (type) {
      case _CoachType.fiberClose:
        if (fiberRemaining <= 0 || fiberRemaining > 5) return null;
        return blunt
            ? 'Nog ${fiberRemaining.round()}g vezels te gaan. Werk dat fruit naar binnen, joh.'
            : 'Nog ${fiberRemaining.round()} g vezels te gaan. ${_fiberEquivalent(fiberRemaining)}';

      case _CoachType.proteinClose:
        if (proteinRemaining <= 0 || proteinRemaining > 30) return null;
        return blunt
            ? 'Nog ${proteinRemaining.round()}g eiwit te gaan. Pak die kwark er nou maar bij.'
            : 'Nog ${proteinRemaining.round()} g eiwit te gaan. ${_proteinEquivalent(proteinRemaining)}';

      case _CoachType.caloriesAlmostDone:
        if (caloriesRemaining <= 0 || caloriesRemaining > 100) return null;
        return blunt
            ? 'Bijna je caloriedoel behaald. Laat die koekjes maar liggen.'
            : 'Je caloriedoel is bijna bereikt. Mooie dag!';

      case _CoachType.caloriesPlenty:
        if (caloriesRemaining <= 500) return null;
        return blunt
            ? 'Nog ${caloriesRemaining.round()} kcal over. Wil je nou gains of niet? Eten met die hap.'
            : 'Je hebt nog ${caloriesRemaining.round()} kcal over. Genoeg ruimte voor een volledige maaltijd.';

      case _CoachType.onTrack:
        return blunt
            ? 'Je ligt op schema. Hèhè, zal eens tijd worden.'
            : 'Je ligt goed op schema. Blijf zo doorgaan!';

      case _CoachType.generalTip:
        return blunt
            ? BluntCoachMessages.message(date, hasLoggedToday: hasLoggedToday)
            : NutritionTips.tip(date);
    }
  }

  static String _proteinEquivalent(double grams) {
    final quarkGrams = (grams * 10).round();
    return 'Dat is ongeveer $quarkGrams g magere kwark, of een kipfiletje.';
  }

  static String _fiberEquivalent(double grams) {
    final apples = (grams / 4).round().clamp(1, 1000);
    return 'Dat is ongeveer $apples ${apples == 1 ? "appel" : "appels"}.';
  }
}

enum _CoachType { fiberClose, proteinClose, caloriesAlmostDone, caloriesPlenty, onTrack, generalTip }
