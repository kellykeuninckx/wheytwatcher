import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';
import '../widgets/placeholder_card.dart';
import 'favorite_quick_add_screen.dart';

/// Poort van `FavoritesView.swift`: lijst van favoriete producten
/// (`FavoriteFood`, beheerd via het hartje in het Logboek), tikken om te
/// loggen. Geen verwijderknop hier — dat gebeurt door het hartje in het
/// Logboek weer uit te zetten.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.db, required this.isDark, this.onAdded});

  final AppDatabase db;
  final bool isDark;
  final VoidCallback? onAdded;

  Future<void> _select(BuildContext context, FavoriteFoodRow favorite) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => FavoriteQuickAddScreen(db: db, isDark: isDark, favorite: favorite)),
    );
    if (added == true) {
      onAdded?.call();
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text('Favorieten', style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<FavoriteFoodRow>>(
          stream: db.select(db.favoriteFoods).watch(),
          builder: (context, snapshot) {
            final favorites = List.of(snapshot.data ?? const <FavoriteFoodRow>[])
              ..sort((a, b) => a.name.compareTo(b.name));

            if (favorites.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(18),
                child: PlaceholderCard(
                  isDark: isDark,
                  icon: Icons.favorite_border,
                  color: WwColors.coral,
                  title: 'Nog geen favorieten',
                  message: 'Voeg producten toe aan je favorieten vanuit je logboek.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _select(context, favorite),
                    child: WwCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: WwColors.coral),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(favorite.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: WwColors.darkAccent(isDark))),
                                Text(
                                  '${favorite.grams.roundedInt} g • ${favorite.calories.roundedInt} kcal',
                                  style: TextStyle(fontSize: 12, color: WwColors.secondaryText(isDark)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 18, color: WwColors.secondaryText(isDark)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
