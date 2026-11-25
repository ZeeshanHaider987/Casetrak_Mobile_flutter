import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../theme/app_theme.dart';

class CaseTrakAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CaseTrakAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showSettings = true,
  });

  final String title;
  final List<Widget> actions;
  final bool showSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull?.user;
    return AppBar(
      title: Text(title),
      actions: [
        ...actions,
        if (showSettings)
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.ink.withValues(alpha: 0.12),
              child: Text(
                user.displayName.isEmpty ? '?' : user.displayName[0],
                style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
