import 'package:dio/dio.dart';

import '../../../core/models/paged.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import '../domain/matter_repository.dart';
import 'models/matter.dart';
import 'models/matter_detail.dart';

class RemoteMatterRepo implements MatterRepository {
  RemoteMatterRepo(this._dio);

  final Dio _dio;

  @override
  Future<Paged<Matter>> list(MatterQuery query, MatterAccessContext access) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/matters',
        queryParameters: {
          if (query.search.isNotEmpty) 'search': query.search,
          if (query.practicesArea != null) 'practicesArea': query.practicesArea,
          if (query.caseStatusType != null) 'caseStatusType': query.caseStatusType,
          'page': query.page,
          'pageSize': query.pageSize,
        },
      );
      final data = _dataMap(response.data);
      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems.whereType<Map>().map((item) => Matter.fromJson(_stringKey(item))).toList()
          : <Matter>[];
      return Paged(
        items: items,
        page: int.tryParse('${data['page']}') ?? query.page,
        pageSize: int.tryParse('${data['pageSize']}') ?? query.pageSize,
        totalCount: int.tryParse('${data['totalCount']}') ?? items.length,
      );
    });
  }

  @override
  Future<MatterDetail> getById(String id, MatterAccessContext access) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/matters/$id');
      final data = _dataMap(response.data);
      final matterJson = data['matter'] is Map ? _stringKey(data['matter'] as Map) : data;
      return MatterDetail(
        matter: Matter.fromJson(matterJson),
        time: const [],
        invoices: const [],
        expenses: const [],
        documents: const [],
        communications: const [],
        timeline: const [],
      );
    });
  }

  @override
  Future<List<Matter>> forClient(String clientId, MatterAccessContext access) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/matters',
        queryParameters: {'clientId': clientId, 'page': 1, 'pageSize': 50},
      );
      final data = _dataMap(response.data);
      final rawItems = data['items'];
      if (rawItems is! List) return const [];
      return rawItems.whereType<Map>().map((item) => Matter.fromJson(_stringKey(item))).toList();
    });
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic>? body) {
    final envelope = ApiResponse.fromJson(body ?? const {}, (json) => json);
    final data = envelope.data;
    if (data is Map) return _stringKey(data);
    return body ?? const {};
  }

  Map<String, dynamic> _stringKey(Map raw) => raw.map((k, v) => MapEntry(k.toString(), v));
}
