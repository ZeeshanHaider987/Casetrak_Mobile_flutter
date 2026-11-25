import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../matters/presentation/matter_providers.dart';
import '../data/mock_dashboard_repo.dart';
import '../data/models/dashboard_data.dart';
import '../data/remote_dashboard_repo.dart';
import '../domain/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  if (AppConfig.useMock) return MockDashboardRepo();
  return RemoteDashboardRepo(ref.watch(dioProvider));
});

final dashboardProvider = FutureProvider<DashboardData>((ref) {
  return ref.watch(dashboardRepositoryProvider).load(ref.watch(matterAccessProvider));
});
