import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import '../network/api_response.dart';
import 'lookup_item.dart';
import 'lookup_keys.dart';
import 'lookup_repository.dart';

class RemoteLookupRepo implements LookupRepository {
  RemoteLookupRepo(this._dio);

  final Dio _dio;

  @override
  Future<List<LookupItem>> fetchKey(String key) {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/lookups/$key');
      final body = response.data ?? const <String, dynamic>{};
      final envelope = ApiResponse.fromJson(body, (json) => json);
      final data = envelope.data;
      if (data is List) return _items(data);
      if (data is Map && data['items'] is List) return _items(data['items'] as List);
      if (body[key] is List) return _items(body[key] as List);
      throw ApiException('Lookup $key returned no items');
    });
  }

  @override
  Future<Map<String, List<LookupItem>>> fetchAll() {
    return guardDio(() async {
      final response = await _dio.get<Map<String, dynamic>>('/lookups');
      final body = response.data ?? const <String, dynamic>{};
      final payload = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final mapped = <String, List<LookupItem>>{};
      for (final key in LookupKeys.all) {
        final raw = payload[key];
        mapped[key] = raw is List ? _items(raw) : const [];
      }
      return mapped;
    });
  }

  List<LookupItem> _items(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((entry) => LookupItem.fromJson(entry.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }
}
