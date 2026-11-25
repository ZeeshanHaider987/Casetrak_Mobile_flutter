import 'package:dio/dio.dart';

import '../../../core/models/paged.dart';
import '../../../core/network/api_exception.dart';
import '../domain/client_repository.dart';
import 'models/client_dto.dart';

class RemoteClientRepo implements ClientRepository {
  RemoteClientRepo(this._dio);

  final Dio _dio;

  @override
  Future<Paged<ClientDto>> list({
    String search = '',
    String? clientType,
    int page = 1,
    int pageSize = 10,
  }) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/clients',
        queryParameters: {
          if (search.isNotEmpty) 'search': search,
          if (clientType != null) 'clientType': clientType,
          'page': page,
          'pageSize': pageSize,
        },
      );
      final data = _map(response.data);
      final raw = data['items'];
      final items = raw is List
          ? raw.whereType<Map>().map((item) => ClientDto.fromJson(_stringKey(item))).toList()
          : <ClientDto>[];
      return Paged(
        items: items,
        page: int.tryParse('${data['page']}') ?? page,
        pageSize: int.tryParse('${data['pageSize']}') ?? pageSize,
        totalCount: int.tryParse('${data['totalCount']}') ?? items.length,
      );
    });
  }

  @override
  Future<ClientDto> getById(String id) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/clients/$id');
      return ClientDto.fromJson(_map(response.data));
    });
  }

  @override
  Future<ClientDto> createIndividual(CreateIndividualClientRequest request, {bool force = false}) {
    return _create('/clients/individual', request.toJson(), force);
  }

  @override
  Future<ClientDto> createCompany(CreateCompanyClientRequest request, {bool force = false}) {
    return _create('/clients/company', request.toJson(), force);
  }

  @override
  Future<ClientDto> createTrustee(CreateTrusteeClientRequest request, {bool force = false}) {
    return _create('/clients/trustee', request.toJson(), force);
  }

  @override
  Future<ClientDto> update(String id, Map<String, dynamic> patch) {
    return guardDio(() async {
      final response = await _dio.patch<Map<String, dynamic>>('/clients/$id', data: patch);
      return ClientDto.fromJson(_map(response.data));
    });
  }

  Future<ClientDto> _create(String path, Map<String, dynamic> body, bool force) {
    return guardDio(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: {...body, 'force': force},
      );
      return ClientDto.fromJson(_map(response.data));
    });
  }

  Map<String, dynamic> _map(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is Map) return _stringKey(data);
    return body ?? const {};
  }

  Map<String, dynamic> _stringKey(Map raw) => raw.map((k, v) => MapEntry(k.toString(), v));
}
