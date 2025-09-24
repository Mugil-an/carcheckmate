import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<AuthLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _repository.signIn(event.email, event.password);
        if (user != null) {
          if (user.emailVerified) {
            emit(Authenticated(user));
          } else {
            emit(Unauthenticated());
            add(AuthSendVerification());
          }
        } else {
          emit(AuthError("Login failed"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthRegister>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _repository.register(event.email, event.password);
        if (user != null) {
          add(AuthSendVerification());
          emit(Authenticated(user));
        } else {
          emit(AuthError("Registration failed"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthSendVerification>((event, emit) async {
      try {
        await _repository.sendEmailVerification();
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthCheckVerified>((event, emit) async {
      try {
        final user = await _repository.reloadUser();
        if (user != null && user.emailVerified) {
          emit(Authenticated(user));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthForgotPassword>((event, emit) async {
      emit(AuthLoading());
      try {
        await _repository.sendPasswordResetEmail(event.email);
        emit(AuthForgotPasswordSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogout>((event, emit) async {
      await _repository.signOut();
      emit(Unauthenticated());
    });
  }
}