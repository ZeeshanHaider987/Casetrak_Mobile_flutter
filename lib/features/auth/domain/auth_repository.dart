import '../data/models/login_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<void> forgotPassword({required String email});

  Future<AuthSession?> restoreSession();

  Future<void> logout();
}
