import 'package:firebase_auth/firebase_auth.dart';
import '../../core/exceptions/auth_exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    try {
      final userCred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthNetworkException(errorCode: 'network-error');
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final userCred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user?.sendEmailVerification();
      return userCred.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthNetworkException(errorCode: 'network-error');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const UserNotLoggedInException();
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const EmailVerificationFailedException();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw const PasswordResetFailedException();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw const GenericAuthException('Failed to sign out');
    }
  }

  Future<User?> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw const GenericAuthException('Failed to reload user');
    }
  }

  /// Convert Firebase Auth exceptions to custom Auth exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserNotFoundException(errorCode: e.code);
      case 'wrong-password':
        return IncorrectPasswordException(errorCode: e.code);
      case 'invalid-email':
        return InvalidEmailException(errorCode: e.code);
      case 'user-disabled':
        return UserDisabledException(errorCode: e.code);
      case 'too-many-requests':
        return TooManyRequestsException(errorCode: e.code);
      case 'email-already-in-use':
        return EmailAlreadyInUseException(errorCode: e.code);
      case 'weak-password':
        return WeakPasswordException(errorCode: e.code);
      case 'invalid-credential':
        return InvalidCredentialsException(errorCode: e.code);
      case 'requires-recent-login':
        return RequiresRecentLoginException(errorCode: e.code);
      case 'network-request-failed':
        return AuthNetworkException(errorCode: e.code);
      case 'invalid-action-code':
        return InvalidPasswordResetCodeException(errorCode: e.code);
      case 'operation-not-allowed':
        return AuthServiceUnavailableException(errorCode: e.code);
      default:
        return GenericAuthException(e.message, e.code);
    }
  }
}