import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  // =========================
  // EMAIL LOGIN
  // =========================

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // =========================
  // CREATE ACCOUNT
  // =========================

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // =========================
  // SIGN OUT
  // =========================

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // =========================
  // ADMIN CHECK
  // Update these emails to your actual admin email(s)
  // =========================

  bool get isAdmin {
    final email = _client.auth.currentUser?.email;

    // TODO: Replace with your actual admin email(s)
    const admins = [
      'construction@sunny.com',
    ];

    return admins.contains(email);
  }
}
