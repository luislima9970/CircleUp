import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:projesof/services/auth_service.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    // Cria um novo mock limpo antes de cada teste
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  group('AuthService', () {

    test('AS1: signUp creates a new user and returns UserCredential', () async {
      final result = await authService.signUp(
        email: 'test@email.com',
        password: 'password123',
      );
      expect(result.user, isNotNull);
      expect(result.user!.email, 'test@email.com');
    });

    test('AS2: signIn returns UserCredential for existing user', () async {
      // MockFirebaseAuth aceita qualquer credencial por defeito
      final result = await authService.signIn(
        email: 'test@email.com',
        password: 'password123',
      );
      expect(result.user, isNotNull);
    });

    test('AS3: getCurrentUser returns null when not signed in', () {
      // Mock começa sem user autenticado
      expect(authService.getCurrentUser(), isNull);
    });

    test('AS4: getCurrentUser returns user after signUp', () async {
      await authService.signUp(
        email: 'test@email.com',
        password: 'password123',
      );
      expect(authService.getCurrentUser(), isNotNull);
    });

    test('AS5: getCurrentUid returns non-null uid after signUp', () async {
      await authService.signUp(
        email: 'test@email.com',
        password: 'password123',
      );
      expect(authService.getCurrentUid(), isNotNull);
    });

    test('AS6: signOut clears the current user', () async {
      await authService.signUp(
        email: 'test@email.com',
        password: 'password123',
      );
      expect(authService.getCurrentUser(), isNotNull);

      await authService.signOut();
      expect(authService.getCurrentUser(), isNull);
    });

  });
}