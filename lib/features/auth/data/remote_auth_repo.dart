import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/token_store.dart';
import '../domain/auth_repository.dart';
import 'models/login_user.dart';

class RemoteAuthRepo implements AuthRepository {
  RemoteAuthRepo(this._dio, this._store);

  final Dio _dio;
  final TokenStore _store;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return guardDio(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final session = _sessionFrom(response.data ?? const {});
      await _store.write(TokenStore.tokenKey, session.token);
      await _store.write(TokenStore.tenantKey, session.tenantId);
      return session;
    });
  }

  @override
  Future<void> forgotPassword({required String email}) {
    return guardDio(() async {
      await _dio.post<void>('/auth/forgot-password', data: {'email': email});
    });
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _store.read(TokenStore.tokenKey);
    final tenantId = await _store.read(TokenStore.tenantKey);
    if (token == null || tenantId == null) return null;
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final body = response.data ?? const {};
      final data = body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
      final userJson = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      return AuthSession(
        token: token,
        tenantId: data['tenantId']?.toString() ?? tenantId,
        user: LoginUser.fromJson(userJson),
      );
    });
  }

  @override
  Future<void> logout() => _store.clearSession();

  AuthSession _sessionFrom(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(body, (json) => json);
    final data = envelope.data is Map
        ? (envelope.data as Map).map((k, v) => MapEntry(k.toString(), v))
        : body;
    final userJson = data['user'];
    if (userJson is! Map || data['token'] == null || data['tenantId'] == null) {
      throw ApiException('Login response is missing token, tenantId, or user.');
    }
    return AuthSession(
      token: data['token'].toString(),
      tenantId: data['tenantId'].toString(),
      user: LoginUser.fromJson(userJson.map((k, v) => MapEntry(k.toString(), v))),
    );
  }
}
