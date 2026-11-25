import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lookups/lookup_manager.dart';
import '../lookups/lookup_providers.dart';

/// Every dropdown in the app reads its options from [LookupManager].
class LookupDropdown extends ConsumerWidget {
  const LookupDropdown({
    super.key,
    required this.lookupKey,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
    this.errorText,
  });

  final String lookupKey;
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool allowClear;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(lookupManagerProvider);
    final items = manager.get(lookupKey).where((item) => item.isActive).toList();
    final loading = manager.loadingState(lookupKey);
    final error = manager.errorState(lookupKey);

    if (items.isEmpty && !loading && error == null && !manager.isFresh(lookupKey)) {
      Future.microtask(() => manager.getAsync(lookupKey));
    }

    final hasValue = value != null && items.any((item) => item.id == value);

    return DropdownButtonFormField<String>(
      key: ValueKey('$lookupKey-${value ?? ''}'),
      initialValue: hasValue ? value : null,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        helperText: loading ? 'Loading $label…' : (error != null ? 'Could not load $label' : null),
        suffixIcon: allowClear && hasValue
            ? IconButton(
                tooltip: 'Clear',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close),
              )
            : null,
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item.id, child: Text(item.label)),
      ],
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}

String lookupLabel(LookupManager manager, String key, String? id) {
  if (id == null || id.isEmpty) return '—';
  for (final item in manager.get(key)) {
    if (item.id == id) return item.label;
  }
  return id;
}

String? lookupCode(LookupManager manager, String key, String? id) {
  if (id == null) return null;
  for (final item in manager.get(key)) {
    if (item.id == id) return item.code ?? item.label;
  }
  return null;
}
