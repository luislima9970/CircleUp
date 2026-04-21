import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/screens/createcircle_screen.dart';

void main() {
  group('CreateCirclePage', () {

    testWidgets('CC1: Renders Create Your Circle header', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Circle'), findsOneWidget);
    });

    testWidgets('CC2: Renders Circle Name field with default value', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Circle Name'), findsOneWidget);
      expect(find.text('Eco Battle'), findsWidgets);
    });

    testWidgets('CC3: Renders Theme dropdown with default Sustainability', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Sustainability'), findsOneWidget);
    });

    testWidgets('CC4: Renders Create Circle button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Circle'), findsOneWidget);
    });

    testWidgets('CC5: Theme dropdown shows all options', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sustainability'));
      await tester.tap(find.text('Sustainability'));
      await tester.pumpAndSettle();

      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Wellness'), findsOneWidget);
    });

    testWidgets('CC6: Selecting a theme updates the dropdown value', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sustainability'));
      await tester.tap(find.text('Sustainability'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fitness').first);
      await tester.pumpAndSettle();

      expect(find.text('Fitness'), findsOneWidget);
    });

    testWidgets('CC7: Tapping Home on bottom nav navigates to HomepageScreen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateCircleScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home_filled));
      await tester.pumpAndSettle();

      expect(find.text('Homepage'), findsOneWidget);
    });

  });
}