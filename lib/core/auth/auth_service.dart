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

  // =========================
  // EMAIL LOGIN
  // =========================

  Future<UserCredential>
      signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth
        .signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // =========================
  // CREATE ACCOUNT
  // =========================

  Future<UserCredential>
      createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth
        .createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // =========================
  // ANONYMOUS LOGIN
  // =========================

  Future<void> signInAnonymously() async {
    if (_auth.currentUser != null) {
      return;
    }

    await _auth.signInAnonymously();
  }

  // =========================
  // SIGN OUT
  // =========================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // =========================
  // ADMIN CHECK
  // =========================

  bool get isAdmin {
    final email =
        _auth.currentUser?.email;

    const admins = [
      'yourmainadmin@gmail.com',
      'secondadmin@gmail.com',
    ];

    return admins.contains(email);
  }
}