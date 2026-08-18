import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../logic/enum_labels.dart';
import '../theme/theme.dart';

/// Bewaart de per-rij bewerkbare staat (aangevinkt?, gram, doel-maaltijd) voor
/// één kopieerbare `FoodLogEntry` — gedeeld tussen `CopyProductsScreen` en
/// `CopyMealDetailScreen` (poort van de gelijknamige `CopySelection`-structs
/// in `CopyMealsView.swift`).
class CopySelection {
  CopySelection({required this.entry})
      : gramsController = TextEditingController(text: entry.grams.roundedInt.toString()),
        gramsFocusNode = FocusNode(),
        category = entry.mealCategory {
    // Poort van de scroll-to-view-fix in `CopyMealsView.swift`: zonder dit
    // blijft het gram-invoerveld onder het toetsenbord staan voor producten
    // dicht bij het einde van de lijst.
    gramsFocusNode.addListener(() {
      if (!gramsFocusNode.hasFocus) return;
      Future.delayed(const Duration(milliseconds: 300), () {
        final context = gramsFocusNode.context;
        if (context != null && context.mounted) {
          Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 250));
        }
      });
    });
  }

  final FoodLogEntryRow entry;
  final TextEditingController gramsController;
  final FocusNode gramsFocusNode;
  MealCategory category;
  bool isSelected = false;

  void dispose() {
    gramsController.dispose();
    gramsFocusNode.dispose();
  }
}

/// Poort van de herhaalde rij-UI in `CopyProductsEntryView`/
/// `CopyMealDetailView`: aanvinken, en indien aangevinkt een gram- en
/// maaltijd-keuze tonen.
class CopyEntryRow extends StatelessWidget {
  const CopyEntryRow({
    super.key,
    required this.isDark,
    required this.selection,
    required this.subtitle,
    required this.onToggleSelected,
    required this.onCategoryChanged,
  });

  final bool isDark;
  final CopySelection selection;
  final String subtitle;
  final VoidCallback onToggleSelected;
  final ValueChanged<MealCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = selection.isSelected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: WwCard(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggleSelected,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? WwColors.teal : WwColors.secondaryText(isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selection.entry.name, style: TextStyle(fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
                        Text(subtitle, style: TextStyle(fontSize: 11, color: WwColors.tertiaryText(isDark))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 10),
                child: Row(
                  children: [
                    Text('Gram', style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark))),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 56,
                      child: TextField(
                        controller: selection.gramsController,
                        focusNode: selection.gramsFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        style: TextStyle(color: WwColors.darkAccent(isDark)),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<MealCategory>(
                      value: selection.category,
                      underline: const SizedBox.shrink(),
                      dropdownColor: WwColors.cardBackground(isDark),
                      style: TextStyle(color: WwColors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                      items: MealCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                      onChanged: (v) {
                        if (v != null) onCategoryChanged(v);
                      },
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
