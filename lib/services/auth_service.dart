import 'package:firebase_auth/firebase_auth.dart';


class AuthService{
  final FirebaseAuth _auth =  FirebaseAuth.instance;

  Future<User?> register(String email,String password) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    }
    on FirebaseAuthException catch(e){
      throw e.message ?? "Registration failed";
    }
  }
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get userChanges => _auth.authStateChanges();
}