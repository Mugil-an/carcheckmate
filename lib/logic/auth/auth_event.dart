abstract class AuthEvent {}

class AuthSignIn extends AuthEvent {
  final String email;
  final String password;
  AuthSignIn(this.email, this.password);
}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  AuthRegister(this.email, this.password);
}

class AuthSendVerification extends AuthEvent {}

class AuthForgotPassword extends AuthEvent {
  final String email;
  AuthForgotPassword(this.email);
}

class AuthSignOut extends AuthEvent {}
