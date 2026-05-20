import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  AuthService._internal();

  static final AuthService instance =
      AuthService._internal();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User? get currentUser =>
      _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> signInAnonymously() async {
    if (_auth.currentUser != null) {
      return;
    }

    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}