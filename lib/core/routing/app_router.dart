import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/clients/presentation/client_creation_success.dart';
import '../../features/clients/presentation/client_detail_screen.dart';
import '../../features/clients/presentation/clients_list_screen.dart';
import '../../features/clients/presentation/create_client_wizard.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/matters/presentation/matter_detail_screen.dart';
import '../../features/matters/presentation/matters_list_screen.dart';
import '../../features/settings/presentation/lookup_debug_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/shell/presentation/nav_catalog.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authControllerProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final signingIn = location == '/login' || location == '/forgot-password';
      if (auth.isLoading) return location == '/splash' ? null : '/splash';
      final session = auth.valueOrNull;
      if (session == null) {
        if (location == '/splash') return '/login';
        return signingIn ? null : '/login';
      }
      if (location == '/splash' || location == '/login') return '/dashboard';
      if (!NavCatalog.allows(session.user.role, location)) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ForgotPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matters',
                builder: (_, _) => const MattersListScreen(),
                routes: [
                  GoRoute(
                    path: ':matterId',
                    builder: (_, state) => MatterDetailScreen(
                      matterId: state.pathParameters['matterId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                builder: (_, _) => const ClientsListScreen(),
                routes: [
                  GoRoute(path: 'new', builder: (_, _) => const CreateClientWizard()),
                  GoRoute(
                    path: 'success/:clientId',
                    builder: (_, state) => ClientCreationSuccess(
                      clientId: state.pathParameters['clientId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':clientId',
                    builder: (_, state) => ClientDetailScreen(
                      clientId: state.pathParameters['clientId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'lookups', builder: (_, _) => const LookupDebugScreen()),
        ],
      ),
    ],
  );
});
