import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:whey_mate/data/database.dart';
import 'package:whey_mate/main.dart';

void main() {
  testWidgets('Vandaag-scherm rendert met een geseed profiel', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    await tester.pumpWidget(WheyMateApp(db: db));

    // Profiel-seed + eerste DB-round trip zijn async.
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
}
