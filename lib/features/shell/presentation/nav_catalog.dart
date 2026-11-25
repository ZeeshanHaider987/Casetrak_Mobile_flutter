import 'package:flutter/material.dart';

import '../../auth/data/models/login_user.dart';

class NavDestinationSpec {
  const NavDestinationSpec({
    required this.label,
    required this.icon,
    required this.branchIndex,
  });

  final String label;
  final IconData icon;
  final int branchIndex;
}

/// Role visibility from the auth state doc.
/// Time Entry and Reporting are intentionally absent in Phase 1.
class NavCatalog {
  const NavCatalog._();

  static const dashboard = NavDestinationSpec(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    branchIndex: 0,
  );
  static const matters = NavDestinationSpec(
    label: 'Matters',
    icon: Icons.folder_outlined,
    branchIndex: 1,
  );
  static const clients = NavDestinationSpec(
    label: 'Clients',
    icon: Icons.people_outline,
    branchIndex: 2,
  );

  static List<NavDestinationSpec> forRole(String role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.partner:
      case UserRole.feeEarner:
      case UserRole.relationshipManager:
        return const [dashboard, matters, clients];
      case UserRole.personAssisting:
        return const [dashboard, matters];
      default:
        return const [dashboard, matters];
    }
  }

  static bool allows(String role, String location) {
    final clientsRoute = location.startsWith('/clients');
    if (!clientsRoute) return true;
    return role == UserRole.admin ||
        role == UserRole.partner ||
        role == UserRole.feeEarner ||
        role == UserRole.relationshipManager;
  }
}
