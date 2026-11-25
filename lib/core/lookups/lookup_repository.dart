import 'lookup_item.dart';

abstract class LookupRepository {
  Future<List<LookupItem>> fetchKey(String key);

  /// Single-payload fallback used by the remote client (`GET /lookups`).
  Future<Map<String, List<LookupItem>>> fetchAll();
}
