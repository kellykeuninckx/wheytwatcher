import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:whey_mate/data/database.dart';
import 'package:whey_mate/main.dart';
import 'package:whey_mate/screens/add_food_screen.dart';

void main() {
  testWidgets('Zonder profiel toont de app het onboardingscherm', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    expect(find.text('Profiel'), findsOneWidget);

    // De opslaan-knop staat onderaan de ListView, buiten het startviewport.
    await tester.dragUntilVisible(
      find.text('Start Whey, mate!'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Start Whey, mate!'), findsOneWidget);

    await db.close();
  });

  testWidgets('Onboarding invullen en opslaan toont daarna het Vandaag-scherm', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Kelly');
    await tester.pump();

    await tester.dragUntilVisible(
      find.text('Start Whey, mate!'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Start Whey, mate!'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kelly'), findsOneWidget);
    expect(find.text('Calorieën'), findsOneWidget);

    await db.close();
  });

  testWidgets('Vandaag-scherm rendert direct met een bestaand profiel', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    expect(find.textContaining('Jij'), findsOneWidget);
    expect(find.text('Calorieën'), findsOneWidget);

    // "Training" staat verderop in de ListView, buiten het startviewport.
    await tester.dragUntilVisible(
      find.text('Training'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    expect(find.text('Training'), findsOneWidget);

    await db.close();
  });

  testWidgets('Product zoeken en loggen werkt de Vandaag-cijfers bij', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    // Open het snel-toevoegen-menu (het bestekicoontje rechtsboven) en kies "Zoek product".
    await tester.tap(find.byIcon(Icons.restaurant).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zoek product'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'banaan');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Banaan'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Toevoegen'));
    await tester.pumpAndSettle();

    // Terug op Vandaag: 100 g banaan is 89 kcal, dat moet nu ergens op het scherm staan.
    expect(find.text('Zoek product'), findsNothing);
    expect(find.textContaining('89'), findsWidgets);

    await db.close();
  });

  testWidgets('Progressie-tabblad toont de periodekiezer en gewichtstrend', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    final now = DateTime.now();
    await db.into(db.weightLogs).insert(
          WeightLogsCompanion.insert(date: now.subtract(const Duration(days: 2)), weightKg: 75.5),
        );
    await db.into(db.weightLogs).insert(
          WeightLogsCompanion.insert(date: now, weightKg: 75.0),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progressie'));
    await tester.pumpAndSettle();

    expect(find.text('14 dagen'), findsOneWidget);
    expect(find.text('30 dagen'), findsOneWidget);
    expect(find.text('Alles'), findsOneWidget);
    expect(find.text('75 kg'), findsOneWidget);
    expect(find.text('Nog geen gewicht'), findsNothing);

    await db.close();
  });

  testWidgets('Logboek toont entries, favoriet-toggle en verwijderen werken', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: MealCategory.breakfast,
            name: 'Havermout',
            grams: 80,
            calories: 311,
            proteinGrams: 13.6,
            carbsGrams: 52.8,
            fatGrams: 5.6,
            fiberGrams: 8,
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logboek'));
    await tester.pumpAndSettle();

    expect(find.text('Havermout'), findsOneWidget);
    expect(find.text('ONTBIJT'), findsOneWidget);

    // Favoriet-toggle: leeg hartje -> vol hartje.
    final favoriteToggle = find.byKey(const ValueKey('favorite-toggle-1'));
    expect(find.descendant(of: favoriteToggle, matching: find.byIcon(Icons.favorite_border)), findsOneWidget);
    await tester.tap(favoriteToggle);
    await tester.pumpAndSettle();
    expect(find.descendant(of: favoriteToggle, matching: find.byIcon(Icons.favorite)), findsOneWidget);
    final favorites = await db.select(db.favoriteFoods).get();
    expect(favorites, hasLength(1));
    expect(favorites.first.name, 'Havermout');

    // Dagstatus zetten via het bed-icoon.
    await tester.tap(find.byIcon(Icons.bedtime));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rustdag'));
    await tester.pumpAndSettle();
    expect(find.text('Rustdag'), findsOneWidget);

    // Verwijderen via swipe.
    await tester.drag(find.text('Havermout'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Havermout'), findsNothing);
    expect(find.text('Nog niets gelogd'), findsOneWidget);

    await db.close();
  });

  testWidgets('Maaltijd opslaan vanuit logboek en weer toevoegen aan vandaag', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: MealCategory.breakfast,
            name: 'Havermout',
            grams: 80,
            calories: 311,
            proteinGrams: 13.6,
            carbsGrams: 52.8,
            fatGrams: 5.6,
            fiberGrams: 8,
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logboek'));
    await tester.pumpAndSettle();

    // Selecteer de enige entry en bewaar als maaltijd.
    await tester.tap(find.text('Selecteer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Havermout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bewaar als maaltijd'));
    await tester.pumpAndSettle();

    expect(find.text('Maaltijd opslaan'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Ontbijtje');
    await tester.pump();
    await tester.tap(find.text('Opslaan'));
    await tester.pumpAndSettle();

    // Terug op Logboek; nu naar Maaltijden.
    expect(find.text('Maaltijd opslaan'), findsNothing);
    await tester.tap(find.text('Maaltijden'));
    await tester.pumpAndSettle();

    expect(find.text('Ontbijtje'), findsOneWidget);
    expect(find.textContaining('311'), findsWidgets);

    await tester.tap(find.text('Ontbijtje'));
    await tester.pumpAndSettle();

    expect(find.text('Havermout'), findsOneWidget);
    await tester.tap(find.text('Voeg toe aan vandaag'));
    await tester.pumpAndSettle();

    final entries = await db.select(db.foodLogEntries).get();
    expect(entries, hasLength(2));
    expect(entries.where((e) => e.name == 'Havermout'), hasLength(2));

    await db.close();
  });

  testWidgets('Favoriet aanmaken in logboek, loggen vanuit Favorieten-tab', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.foodLogEntries).insert(
          FoodLogEntriesCompanion.insert(
            date: DateTime.now(),
            mealCategory: MealCategory.breakfast,
            name: 'Havermout',
            grams: 80,
            calories: 311,
            proteinGrams: 13.6,
            carbsGrams: 52.8,
            fatGrams: 5.6,
            fiberGrams: 8,
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    // Favoriet maken vanuit Logboek.
    await tester.tap(find.text('Logboek'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('favorite-toggle-1')));
    await tester.pumpAndSettle();

    // Leeg-staat mag hier niet meer voorkomen zodra er een favoriet is.
    await tester.tap(find.text('Favorieten'));
    await tester.pumpAndSettle();
    expect(find.text('Nog geen favorieten'), findsNothing);
    expect(find.text('Havermout'), findsOneWidget);

    await tester.tap(find.text('Havermout'));
    await tester.pumpAndSettle();
    expect(find.text('Toevoegen'), findsWidgets);

    await tester.tap(find.widgetWithText(TextButton, 'Toevoegen'));
    await tester.pumpAndSettle();

    // Terug op Favorieten (onAdded schakelt terug naar Vandaag als tab-root).
    expect(find.text('Calorieën'), findsOneWidget);

    final entries = await db.select(db.foodLogEntries).get();
    expect(entries.where((e) => e.name == 'Havermout'), hasLength(2));

    await db.close();
  });

  testWidgets('Handmatig toevoegen met prefilledBarcode koppelt de barcode aan het nieuwe product', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();

    await tester.pumpWidget(MaterialApp(
      home: AddFoodScreen(db: db, isDark: true, prefilledBarcode: '1234567890123'),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Wordt gekoppeld aan deze barcode'), findsOneWidget);

    // Volgorde van tekstvelden op dit scherm: Naam, Hoeveelheid, dan de vijf
    // "per 100 gram"-velden te beginnen met Calorieën.
    await tester.enterText(find.byType(TextField).at(0), 'Zelfgemaakte reep');
    await tester.enterText(find.byType(TextField).at(2), '450');
    await tester.pump();

    await tester.tap(find.text('Voeg toe'));
    await tester.pumpAndSettle();

    final entries = await db.select(db.foodLogEntries).get();
    expect(entries, hasLength(1));
    expect(entries.first.name, 'Zelfgemaakte reep');

    final products = await db.select(db.foodProducts).get();
    expect(products, hasLength(1));
    expect(products.first.barcode, '1234567890123');
    expect(products.first.caloriesPer100g, 450);

    await db.close();
  });

  // Geen widget-test voor het netwerkzoeken-scherm zelf: flutter test's
  // TestWidgetsFlutterBinding blokkeert alle echte HTTP-requests binnen
  // testWidgets() (retourneert altijd status 400), dus dat kan hier
  // structureel niet werken. De servicelaag zelf (OpenFoodFactsService.
  // searchProducts) is wél live getest in open_food_facts_service_test.dart
  // — de UI-koppeling is handmatig geverifieerd op de emulator.

  testWidgets('Voeg maaltijd toe vanuit Vandaag logt de opgeslagen maaltijd', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    final mealId = await db.into(db.savedMeals).insert(
          SavedMealsCompanion.insert(name: 'Ontbijtje', createdAt: DateTime.now()),
        );
    await db.into(db.mealItems).insert(
          MealItemsCompanion.insert(
            savedMealId: mealId,
            name: 'Banaan',
            grams: 100,
            calories: 89,
            proteinGrams: 1.1,
            carbsGrams: 23,
            fatGrams: 0.3,
            fiberGrams: 2.6,
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.restaurant).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voeg maaltijd toe'));
    await tester.pumpAndSettle();

    // "Maaltijden" staat zowel in de AppBar hier als (onzichtbaar, onder
    // deze pushed route) als label in de tabbalk — vandaar de check op de
    // unieke maaltijdnaam i.p.v. die dubbelzinnige tekst.
    expect(find.text('Ontbijtje'), findsOneWidget);

    await tester.tap(find.text('Ontbijtje'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voeg toe aan vandaag'));
    await tester.pumpAndSettle();

    // Popt helemaal terug tot Vandaag (niet blijven hangen op Maaltijden).
    expect(find.text('Ontbijtje'), findsNothing);
    expect(find.text('Calorieën'), findsOneWidget);

    final entries = await db.select(db.foodLogEntries).get();
    expect(entries, hasLength(1));
    expect(entries.first.name, 'Banaan');

    await db.close();
  });

  testWidgets('Voeg weegmoment toe logt gewicht en vult metingen voor met de laatste waarden', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
    await db.into(db.bodyMeasurementLogs).insert(
          BodyMeasurementLogsCompanion.insert(
            date: DateTime.now().subtract(const Duration(days: 7)),
            waistCm: const Value(80),
          ),
        );

    await tester.pumpWidget(WheyMateApp(db: db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.restaurant).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voeg weegmoment toe'));
    await tester.pumpAndSettle();

    expect(find.text('Gewicht loggen'), findsOneWidget);
    // Vooringevuld met het huidige profielgewicht.
    expect(find.text('75'), findsOneWidget);
    // Vooringevuld met de laatst gelogde tailleomvang.
    expect(find.text('80'), findsOneWidget);

    await tester.enterText(find.text('75'), '77');
    await tester.pump();

    await tester.tap(find.text('Bewaar'));
    await tester.pumpAndSettle();

    expect(find.text('Gewicht loggen'), findsNothing);

    final profile = await db.select(db.userProfiles).getSingle();
    expect(profile.currentWeightKg, 77);

    final weightLogs = await db.select(db.weightLogs).get();
    expect(weightLogs, hasLength(1));
    expect(weightLogs.first.weightKg, 77);

    await db.close();
  });
}
