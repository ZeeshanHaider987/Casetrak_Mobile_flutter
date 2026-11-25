import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';

class LookupDebugScreen extends ConsumerWidget {
  const LookupDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(lookupManagerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lookup debug'),
        actions: [
          IconButton(
            tooltip: 'Refresh all',
            onPressed: () => manager.batchFetchAll(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: LookupKeys.all.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final key = LookupKeys.all[index];
          final cached = manager.isCached(key);
          final stamped = manager.cacheTimestamps[key];
          return ListTile(
            title: Text(key),
            subtitle: Text(
              'cached ${cached ? 'yes' : 'no'}'
              ' · ${stamped == null ? 'no timestamp' : stamped.toIso8601String()}'
              ' · count ${manager.countOf(key)}'
              ' · TTL ${_ttl(manager.ttlRemaining(key))}',
            ),
            trailing: TextButton(
              onPressed: () => manager.forceRefresh(key),
              child: const Text('Force refresh'),
            ),
          );
        },
      ),
    );
  }

  String _ttl(Duration? value) {
    if (value == null) return '—';
    if (value.inDays > 0) return '${value.inDays}d ${value.inHours.remainder(24)}h';
    if (value.inHours > 0) return '${value.inHours}h ${value.inMinutes.remainder(60)}m';
    return '${value.inMinutes}m';
  }
}
