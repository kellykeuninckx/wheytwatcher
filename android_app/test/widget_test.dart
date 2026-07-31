import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:whey_mate/data/database.dart';
import 'package:whey_mate/main.dart';

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
}
