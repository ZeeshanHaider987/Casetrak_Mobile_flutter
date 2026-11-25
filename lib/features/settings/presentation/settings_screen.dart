import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text(session?.user.displayName ?? 'Signed out'),
            subtitle: Text('${session?.user.role ?? ''} · ${session?.user.email ?? ''}'),
          ),
          ListTile(
            title: const Text('Data source'),
            subtitle: Text(AppConfig.useMock ? 'Mock repositories' : 'Remote API'),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('Lookup debug'),
            subtitle: const Text('Cache, TTL, and force refresh'),
            onTap: () => context.push('/settings/lookups'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
