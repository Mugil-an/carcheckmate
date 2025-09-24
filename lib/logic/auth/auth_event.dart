abstract class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  AuthLogin(this.email, this.password);
}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  AuthRegister(this.email, this.password);
}

class AuthSendVerification extends AuthEvent {}

class AuthCheckVerified extends AuthEvent {}

class AuthForgotPassword extends AuthEvent {
  final String email;
  AuthForgotPassword(this.email);
}

class AuthLogout extends AuthEvent {}
