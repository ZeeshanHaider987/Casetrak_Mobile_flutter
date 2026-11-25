import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../data/mock_auth_repo.dart';
import '../data/models/login_user.dart';
import '../data/remote_auth_repo.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useMock) {
    return MockAuthRepo(ref.watch(tokenStoreProvider));
  }
  return RemoteAuthRepo(ref.watch(dioProvider), ref.watch(tokenStoreProvider));
});

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final session = await ref.read(authRepositoryProvider).restoreSession();
    if (session != null) {
      await ref.read(lookupManagerProvider).batchFetchAll();
    }
    return session;
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
        );
    await ref.read(prefsStoreProvider).setLastEmail(email.trim());
    await ref.read(lookupManagerProvider).batchFetchAll();
    state = AsyncData(session);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(lookupManagerProvider).invalidateAll();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthSession?>(
  AuthController.new,
);
