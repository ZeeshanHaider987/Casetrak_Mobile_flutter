import 'dart:convert';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_store.dart';
import '../domain/auth_repository.dart';
import 'models/login_user.dart';

class MockAuthRepo implements AuthRepository {
  MockAuthRepo(
    this._store, {
    this.delay = const Duration(milliseconds: 250),
    this.tenantId = 'tenant-casetrak',
  });

  final TokenStore _store;
  final Duration delay;
  final String tenantId;

  static final demoUsers = <String, LoginUser>{
    'admin@casetrak.test': const LoginUser(
      id: 'u-admin',
      email: 'admin@casetrak.test',
      displayName: 'Admin User',
      role: UserRole.admin,
    ),
    'partner@casetrak.test': const LoginUser(
      id: 'u-partner',
      email: 'partner@casetrak.test',
      displayName: 'Helen Croft',
      role: UserRole.partner,
    ),
    'feeearner@casetrak.test': const LoginUser(
      id: 'u-fee',
      email: 'feeearner@casetrak.test',
      displayName: 'Noah Bennett',
      role: UserRole.feeEarner,
    ),
    'rm@casetrak.test': const LoginUser(
      id: 'u-rm',
      email: 'rm@casetrak.test',
      displayName: 'David Chen',
      role: UserRole.relationshipManager,
    ),
    'assist@casetrak.test': const LoginUser(
      id: 'u-assist',
      email: 'assist@casetrak.test',
      displayName: 'Priya Nair',
      role: UserRole.personAssisting,
    ),
  };

  static const demoPassword = 'password';

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    await Future<void>.delayed(delay);
    final user = demoUsers[email.trim().toLowerCase()];
    if (user == null || password != demoPassword) {
      throw ApiException('Email or password is incorrect.');
    }
    final session = AuthSession(
      token: _fakeJwt(user),
      tenantId: tenantId,
      user: user,
    );
    await _persist(session);
    return session;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future<void>.delayed(delay);
    if (!email.contains('@')) {
      throw ApiException('Enter the email address on the account.');
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _store.read(TokenStore.tokenKey);
    final tenant = await _store.read(TokenStore.tenantKey);
    final rawUser = await _store.read(TokenStore.userKey);
    if (token == null || tenant == null || rawUser == null) return null;
    final decoded = jsonDecode(rawUser);
    if (decoded is! Map) return null;
    return AuthSession(
      token: token,
      tenantId: tenant,
      user: LoginUser.fromJson(decoded.map((k, v) => MapEntry(k.toString(), v))),
    );
  }

  @override
  Future<void> logout() => _store.clearSession();

  Future<void> _persist(AuthSession session) async {
    await _store.write(TokenStore.tokenKey, session.token);
    await _store.write(TokenStore.tenantKey, session.tenantId);
    await _store.write(TokenStore.userKey, jsonEncode(session.user.toJson()));
  }

  String _fakeJwt(LoginUser user) {
    final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'sub': user.id,
      'email': user.email,
      'role': user.role,
      'tenantId': tenantId,
    })));
    return '$header.$payload.mock';
  }
}
