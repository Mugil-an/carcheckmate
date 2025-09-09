import '../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuthService _service;

  AuthRepository(this._service);

  User? get currentUser => _service.currentUser;

  Stream<User?> get authStateChanges => _service.authStateChanges;

  Future<User?> signIn(String email, String password) =>
      _service.signIn(email, password);

  Future<User?> register(String email, String password) =>
      _service.register(email, password);

  Future<void> sendEmailVerification() => _service.sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email) =>
      _service.sendPasswordResetEmail(email);

  Future<void> signOut() => _service.signOut();
}
