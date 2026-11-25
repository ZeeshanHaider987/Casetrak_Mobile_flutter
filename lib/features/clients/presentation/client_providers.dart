import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/models/paged.dart';
import '../../matters/data/models/matter.dart';
import '../../matters/presentation/matter_providers.dart';
import '../data/mock_client_repo.dart';
import '../data/models/client_dto.dart';
import '../data/remote_client_repo.dart';
import '../domain/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  if (AppConfig.useMock) return MockClientRepo();
  return RemoteClientRepo(ref.watch(dioProvider));
});

class ClientListQuery {
  const ClientListQuery({this.search = '', this.clientType, this.page = 1, this.pageSize = 10});

  final String search;
  final String? clientType;
  final int page;
  final int pageSize;

  ClientListQuery copyWith({
    String? search,
    String? clientType,
    int? page,
    bool clearType = false,
  }) {
    return ClientListQuery(
      search: search ?? this.search,
      clientType: clearType ? null : clientType ?? this.clientType,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }
}

class ClientListController extends AsyncNotifier<Paged<ClientDto>> {
  ClientListQuery query = const ClientListQuery();

  @override
  Future<Paged<ClientDto>> build() => _load();

  Future<Paged<ClientDto>> _load() {
    return ref.read(clientRepositoryProvider).list(
          search: query.search,
          clientType: query.clientType,
          page: query.page,
          pageSize: query.pageSize,
        );
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_load);
  }

  Future<void> setSearch(String value) async {
    query = query.copyWith(search: value, page: 1);
    await _reload();
  }

  Future<void> setType(String? clientType) async {
    query = query.copyWith(
      clientType: clientType,
      page: 1,
      clearType: clientType == null,
    );
    await _reload();
  }

  Future<void> setPage(int page) async {
    query = query.copyWith(page: page);
    await _reload();
  }

  Future<void> refresh() => _reload();
}

final clientListProvider = AsyncNotifierProvider<ClientListController, Paged<ClientDto>>(
  ClientListController.new,
);

final clientDetailProvider = FutureProvider.family<ClientDto, String>((ref, id) {
  return ref.watch(clientRepositoryProvider).getById(id);
});

final clientMattersProvider = FutureProvider.family<List<Matter>, String>((ref, clientId) {
  return ref.watch(matterRepositoryProvider).forClient(clientId, ref.watch(matterAccessProvider));
});
