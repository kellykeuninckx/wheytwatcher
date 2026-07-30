import 'package:flutter/material.dart';

extension RoundedInt on double {
  int get roundedInt => round();
}

class WwColors {
  WwColors._();

  // Hoofdkleuren (gelijk in beide modi)
  static const blue = Color(0xFF1A59D9);
  static const aqua = Color(0xFF00BFCC);
  static const teal = Color(0xFF008C99);
  static const mint = Color(0xFF59E6BF);
  static const orange = Color(0xFFFAA147);
  static const coral = Color(0xFFF56378);
  static const purple = Color(0xFF856BED);

  // Adaptieve kleuren (licht/donker)
  static const _darkAccentDark = Colors.white;
  static const _darkAccentLight = Color(0xFF143B4D);

  static const _backgroundDark = Color(0xFF0F212B);
  static const _backgroundLight = Color(0xFFE0F5F2);

  static const _cardBackgroundDark = Color(0xFF3C666E);
  static const _cardBackgroundLight = Colors.white;

  static Color darkAccent(bool isDark) => isDark ? _darkAccentDark : _darkAccentLight;

  static Color background(bool isDark) => isDark ? _backgroundDark : _backgroundLight;

  static Color cardBackground(bool isDark) => isDark ? _cardBackgroundDark : _cardBackgroundLight;

  static Color ringBackground(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.14) : teal.withValues(alpha: 0.18);

  static Color secondaryText(bool isDark) => darkAccent(isDark).withValues(alpha: 0.60);

  static Color tertiaryText(bool isDark) => darkAccent(isDark).withValues(alpha: 0.40);
}

class WwGradients {
  WwGradients._();

  static const main = LinearGradient(
    colors: [WwColors.blue, WwColors.aqua],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const protein = LinearGradient(
    colors: [WwColors.blue, WwColors.aqua],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const carbs = LinearGradient(
    colors: [WwColors.aqua, WwColors.teal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const fat = LinearGradient(
    colors: [WwColors.mint, WwColors.teal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const fiber = LinearGradient(
    colors: [WwColors.teal, WwColors.mint],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Poort van de `.wwCard()` view modifier: afgeronde kaart met schaduw,
/// lichte rand in donkere modus.
class WwCard extends StatelessWidget {
  const WwCard({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WwColors.cardBackground(isDark),
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
