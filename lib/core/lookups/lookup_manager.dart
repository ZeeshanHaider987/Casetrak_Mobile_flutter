import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'lookup_item.dart';
import 'lookup_keys.dart';
import 'lookup_repository.dart';

class LookupManager extends ChangeNotifier {
  LookupManager(this._repository) {
    _restore();
  }

  static const shortCacheDuration = Duration(minutes: 15);
  static const mediumCacheDuration = Duration(hours: 12);
  static const longCacheDuration = Duration(days: 7);
  static const _hiveKey = 'lookup_cache_v1';

  final LookupRepository _repository;
  final Map<String, List<LookupItem>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, bool> _loading = {};
  final Map<String, Object?> _errors = {};

  Map<String, DateTime> get cacheTimestamps => Map.unmodifiable(_cacheTimestamps);

  Duration ttlFor(String key) {
    if (LookupKeys.shortTtl.contains(key)) return shortCacheDuration;
    if (LookupKeys.longTtl.contains(key)) return longCacheDuration;
    return mediumCacheDuration;
  }

  bool isFresh(String key) {
    final stamped = _cacheTimestamps[key];
    if (stamped == null || !_cache.containsKey(key)) return false;
    return DateTime.now().difference(stamped) < ttlFor(key);
  }

  Duration? ttlRemaining(String key) {
    final stamped = _cacheTimestamps[key];
    if (stamped == null) return null;
    final left = ttlFor(key) - DateTime.now().difference(stamped);
    return left.isNegative ? Duration.zero : left;
  }

  bool loadingState(String key) => _loading[key] ?? false;

  Object? errorState(String key) => _errors[key];

  bool isCached(String key) => _cache.containsKey(key) && _cacheTimestamps.containsKey(key);

  int countOf(String key) => _cache[key]?.length ?? 0;

  /// Synchronous read of whatever is currently cached.
  List<LookupItem> get(String key) => List.unmodifiable(_cache[key] ?? const []);

  Future<List<LookupItem>> getAsync(String key) {
    if (isFresh(key)) return Future.value(get(key));
    return _fetch(key);
  }

  Future<void> forceRefresh(String key) => _fetch(key);

  void invalidate(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _errors.remove(key);
    _loading.remove(key);
    _persist();
    notifyListeners();
  }

  void invalidateAll() {
    _cache.clear();
    _cacheTimestamps.clear();
    _errors.clear();
    _loading.clear();
    _persist();
    notifyListeners();
  }

  /// Short-TTL keys are volatile and drop when the app is resumed.
  void invalidateVolatile() {
    for (final key in LookupKeys.shortTtl) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      _errors.remove(key);
    }
    _persist();
    notifyListeners();
  }

  /// One [Future.wait] over every key, fired after login.
  Future<void> batchFetchAll() {
    return Future.wait(LookupKeys.all.map(getAsync));
  }

  Future<List<LookupItem>> _fetch(String key) async {
    _loading[key] = true;
    _errors[key] = null;
    notifyListeners();
    try {
      final items = await _repository.fetchKey(key);
      _cache[key] = items;
      _cacheTimestamps[key] = DateTime.now();
      _persist();
      return items;
    } catch (error) {
      _errors[key] = error;
      return get(key);
    } finally {
      _loading[key] = false;
      notifyListeners();
    }
  }

  void _persist() {
    if (!Hive.isBoxOpen('casetrak')) return;
    final box = Hive.box('casetrak');
    final payload = {
      for (final entry in _cache.entries)
        entry.key: {
          'at': _cacheTimestamps[entry.key]?.toIso8601String(),
          'items': entry.value.map((item) => item.toJson()).toList(),
        },
    };
    box.put(_hiveKey, jsonEncode(payload));
  }

  void _restore() {
    if (!Hive.isBoxOpen('casetrak')) return;
    final raw = Hive.box('casetrak').get(_hiveKey);
    if (raw is! String || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return;
    decoded.forEach((key, value) {
      if (key is! String || value is! Map) return;
      final at = DateTime.tryParse(value['at']?.toString() ?? '');
      final items = value['items'];
      if (at == null || items is! List) return;
      _cache[key] = items
          .whereType<Map>()
          .map((item) => LookupItem.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
          .toList();
      _cacheTimestamps[key] = at;
    });
  }
}
