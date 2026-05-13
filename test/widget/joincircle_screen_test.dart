import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:projesof/screens/joincircle_screen.dart';

void main() {
  group('JoinCircleScreen', () {
    testWidgets('JCS1: renders UI', (tester) async {
      await tester.pumpWidget(MaterialApp(home: JoinGroupScreen(auth: MockFirebaseAuth())));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Join Group'), findsOneWidget);
    });

    testWidgets('JCS2: accepts input', (tester) async {
      await tester.pumpWidget(MaterialApp(home: JoinGroupScreen(auth: MockFirebaseAuth())));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'ABC123');

      expect(find.text('ABC123'), findsWidgets);
    });
  });
}
