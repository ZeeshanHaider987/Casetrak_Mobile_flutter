import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/models/paged.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/mock_matter_repo.dart';
import '../data/models/matter.dart';
import '../data/models/matter_detail.dart';
import '../data/remote_matter_repo.dart';
import '../domain/matter_repository.dart';

final matterRepositoryProvider = Provider<MatterRepository>((ref) {
  if (AppConfig.useMock) return MockMatterRepo();
  return RemoteMatterRepo(ref.watch(dioProvider));
});

final matterAccessProvider = Provider<MatterAccessContext>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull?.user;
  return MatterAccessContext(userId: user?.id ?? '', role: user?.role ?? '');
});

class MattersController extends AsyncNotifier<Paged<Matter>> {
  MatterQuery query = const MatterQuery();

  @override
  Future<Paged<Matter>> build() => _load();

  Future<Paged<Matter>> _load() {
    return ref.read(matterRepositoryProvider).list(query, ref.read(matterAccessProvider));
  }

  Future<void> setSearch(String value) async {
    query = query.copyWith(search: value, page: 1);
    state = await AsyncValue.guard(_load);
  }

  Future<void> setFilters({String? practicesArea, String? caseStatusType}) async {
    query = MatterQuery(
      search: query.search,
      practicesArea: practicesArea,
      caseStatusType: caseStatusType,
      page: 1,
      pageSize: query.pageSize,
    );
    state = await AsyncValue.guard(_load);
  }

  Future<void> setPage(int page) async {
    query = query.copyWith(page: page);
    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }
}

final mattersControllerProvider = AsyncNotifierProvider<MattersController, Paged<Matter>>(
  MattersController.new,
);

final matterDetailProvider = FutureProvider.family<MatterDetail, String>((ref, id) {
  return ref.watch(matterRepositoryProvider).getById(id, ref.watch(matterAccessProvider));
});
