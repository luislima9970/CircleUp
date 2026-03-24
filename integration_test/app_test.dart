import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app_name/main.dart' as app;  // substitui pelo nome da tua app

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Acceptance Tests - Task App', () {

    testWidgets('AC1: App abre e mostra o título CircleUP', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('CircleUP'), findsOneWidget);
    });

    testWidgets('AC2: App mostra a lista de tasks', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verifica que existe pelo menos uma task
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('AC3: Tasks mostram os pontos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verifica que os chips de pontos existem
      expect(find.byType(Chip), findsWidgets);
      expect(find.textContaining('pts'), findsWidgets);
    });

    testWidgets('AC4: Pontos iniciais são 0', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('0 pts'), findsOneWidget);
    });

    testWidgets('AC5: Completar uma task adiciona pontos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Lê os pontos antes
      final pointsBefore = _getPoints(tester);

      // Toca na primeira task
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Lê os pontos depois
      final pointsAfter = _getPoints(tester);

      expect(pointsAfter, greaterThan(pointsBefore));
    });

    testWidgets('AC6: Task fica marcada como completa ao ser tocada', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verifica ícone antes (unchecked)
      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);

      // Toca na primeira task
      await tester.tap(find.byType(Card).first);
      await tester.pump(); // pump sem settle para apanhar o estado intermédio

      // Verifica que apareceu pelo menos um check
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('AC7: Task volta ao estado inicial após 1.5 segundos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Toca na primeira task
      await tester.tap(find.byType(Card).first);
      await tester.pump();

      // Está marcada
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Avança o tempo 1.5 segundos
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Voltou ao estado inicial
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('AC8: Completar várias tasks acumula os pontos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Completa a primeira task e espera reset
      await tester.tap(find.byType(Card).first);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      final pointsAfterFirst = _getPoints(tester);

      // Completa a segunda task e espera reset
      await tester.tap(find.byType(Card).at(1));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      final pointsAfterSecond = _getPoints(tester);

      expect(pointsAfterSecond, greaterThan(pointsAfterFirst));
    });

  });
}

// Helper para extrair o valor de pontos do ecrã
int _getPoints(WidgetTester tester) {
  final finder = find.textContaining(' pts');
  // Filtra apenas o banner grande (exclui os Chips das tasks)
  final widgets = tester.widgetList<Text>(finder).where((t) =>
    t.style?.fontSize != null && t.style!.fontSize! > 20
  ).toList();

  if (widgets.isEmpty) return 0;
  return int.tryParse(widgets.first.data!.replaceAll(' pts', '')) ?? 0;
}