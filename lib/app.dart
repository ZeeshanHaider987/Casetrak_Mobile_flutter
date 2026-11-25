import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/lookups/lookup_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';

class CaseTrakApp extends ConsumerStatefulWidget {
  const CaseTrakApp({super.key});

  @override
  ConsumerState<CaseTrakApp> createState() => _CaseTrakAppState();
}

class _CaseTrakAppState extends ConsumerState<CaseTrakApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(sessionEventsProvider).onUnauthorized = () {
      ref.read(authControllerProvider.notifier).logout();
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(lookupManagerProvider).invalidateVolatile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CaseTrak',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
