import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/joincircle_screen.dart';

void main() {
  setUp(() {
    AppState.setCurrentUser(UserModel(
      id: 'uid1',
      username: 'alice',
      email: 'alice@test.com',
      createdAt: Timestamp.now(),
    ));
  });

  tearDown(() => AppState.clearUser());

  group('JoinCircleScreen', () {
    testWidgets('JCS1: renders UI', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: JoinGroupScreen()));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Join Group'), findsOneWidget);
    });

    testWidgets('JCS2: accepts input', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: JoinGroupScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'ABC123');

      expect(find.text('ABC123'), findsWidgets);
    });
  });
}
