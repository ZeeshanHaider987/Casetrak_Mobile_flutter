import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../network/session_events.dart';
import '../storage/prefs_store.dart';
import '../storage/token_store.dart';
import 'lookup_manager.dart';
import 'lookup_repository.dart';
import 'mock_lookup_repo.dart';
import 'remote_lookup_repo.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final prefsStoreProvider = Provider<PrefsStore>((ref) => MemoryPrefsStore());

final sessionEventsProvider = Provider<SessionEvents>((ref) => SessionEvents());

final dioProvider = Provider<Dio>((ref) {
  return createDio(
    tokenStore: ref.watch(tokenStoreProvider),
    sessionEvents: ref.watch(sessionEventsProvider),
  );
});

final lookupRepositoryProvider = Provider<LookupRepository>((ref) {
  if (AppConfig.useMock) return MockLookupRepo();
  return RemoteLookupRepo(ref.watch(dioProvider));
});

final lookupManagerProvider = ChangeNotifierProvider<LookupManager>((ref) {
  return LookupManager(ref.watch(lookupRepositoryProvider));
});
