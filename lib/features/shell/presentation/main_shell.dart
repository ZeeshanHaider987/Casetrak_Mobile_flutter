import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/auth_controller.dart';
import 'nav_catalog.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).valueOrNull?.user.role ?? UserRoleFallback.none;
    final destinations = NavCatalog.forRole(role);
    var selected = destinations.indexWhere(
      (item) => item.branchIndex == navigationShell.currentIndex,
    );
    if (selected < 0) selected = 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        destinations: [
          for (final item in destinations)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            destinations[index].branchIndex,
            initialLocation: index == selected,
          );
        },
      ),
    );
  }
}

class UserRoleFallback {
  static const none = '';
}
