import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/lookups/lookup_providers.dart';
import 'core/storage/prefs_store.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('casetrak');
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(SecureTokenStore()),
        prefsStoreProvider.overrideWithValue(SharedPrefsStore(preferences)),
      ],
      child: const CaseTrakApp(),
    ),
  );
}
