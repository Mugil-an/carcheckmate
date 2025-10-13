import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/exceptions/auth_exceptions.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        // Validate input
        if (event.email.isEmpty || !event.email.contains('@')) {
          throw const InvalidEmailException();
        }
        if (event.password.isEmpty) {
          throw const GenericAuthException('Password cannot be empty');
        }

        final user = await _repository.signIn(event.email, event.password);
        if (user != null) {
          if (user.emailVerified) {
            emit(Authenticated(user));
          } else {
            emit(Unauthenticated());
            add(AuthSendVerification());
          }
        } else {
          throw const GenericAuthException("Login failed");
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        emit(AuthError(const GenericAuthException().message));
      }
    });

    on<AuthRegister>((event, emit) async {
      emit(AuthLoading());
      try {
        // Validate input
        if (event.email.isEmpty || !event.email.contains('@')) {
          throw const InvalidEmailException();
        }
        if (event.password.isEmpty) {
          throw const WeakPasswordException();
        }
        if (event.password.length < 6) {
          throw const WeakPasswordException();
        }

        final user = await _repository.register(event.email, event.password);
        if (user != null) {
          add(AuthSendVerification());
          emit(Authenticated(user));
        } else {
          throw const GenericAuthException("Registration failed");
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        emit(AuthError(const GenericAuthException().message));
      }
    });

    on<AuthSendVerification>((event, emit) async {
      try {
        await _repository.sendEmailVerification();
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        emit(AuthError(const EmailVerificationFailedException().message));
      }
    });

    on<AuthCheckVerified>((event, emit) async {
      try {
        final user = await _repository.reloadUser();
        if (user != null && user.emailVerified) {
          emit(Authenticated(user));
        }
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        emit(AuthError(const GenericAuthException().message));
      }
    });

    on<AuthForgotPassword>((event, emit) async {
      emit(AuthLoading());
      try {
        // Validate email
        if (event.email.isEmpty || !event.email.contains('@')) {
          throw const InvalidEmailException();
        }

        await _repository.sendPasswordResetEmail(event.email);
        emit(AuthForgotPasswordSuccess());
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        emit(AuthError(const PasswordResetFailedException().message));
      }
    });

    on<AuthLogout>((event, emit) async {
      try {
        await _repository.signOut();
        emit(Unauthenticated());
      } on AuthException catch (e) {
        emit(AuthError(e.message));
      } on FirebaseAuthException catch (e) {
        final authException = _handleFirebaseAuthException(e);
        emit(AuthError(authException.message));
      } catch (e) {
        // Even if logout fails, consider user as unauthenticated
        emit(Unauthenticated());
      }
    });

    on<AuthCheckCurrent>((event, emit) async {
      try {
        final user = _repository.currentUser;
        if (user != null && user.emailVerified) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(Unauthenticated());
      }
    });
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
      default:
        return GenericAuthException(e.message, e.code);
    }
  }
}