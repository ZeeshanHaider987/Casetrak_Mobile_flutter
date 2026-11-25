import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/lookup_dropdown.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../domain/determine_client_type.dart';
import 'client_providers.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientDetailProvider(clientId));
    final matters = ref.watch(clientMattersProvider(clientId));
    final manager = ref.watch(lookupManagerProvider);

    return client.when(
      loading: () => const Scaffold(body: SkeletonList()),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Client')),
        body: ErrorRetry(
          message: error.toString(),
          onRetry: () => ref.invalidate(clientDetailProvider(clientId)),
        ),
      ),
      data: (data) {
        final rows = <(String, String)>[
          ('Type', determineClientTypeFromDto(data)),
          ('Email', data.email ?? '—'),
          ('Phone', data.phone ?? '—'),
          ('Title', lookupLabel(manager, LookupKeys.nameTitle, data.nameTitle)),
          ('Industry', lookupLabel(manager, LookupKeys.industryType, data.industryType)),
          ('Address type', lookupLabel(manager, LookupKeys.addressType, data.addressType)),
          ('Country', lookupLabel(manager, LookupKeys.country, data.country)),
          ('Group', lookupLabel(manager, LookupKeys.clientGroup, data.clientGroup)),
          ('Department', lookupLabel(manager, LookupKeys.department, data.department)),
          ('Point of contact', lookupLabel(manager, LookupKeys.pocList, data.pocList)),
          ('Company', lookupLabel(manager, LookupKeys.companyClients, data.companyClients)),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(data.displayName)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Contact', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final row in rows)
                if (row.$2 != '—')
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(row.$1),
                    subtitle: Text(row.$2),
                  ),
              const SizedBox(height: 12),
              Text('Custom fields', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.customFields.isEmpty)
                const Text('No custom fields')
              else
                for (final entry in data.customFields.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  ),
              const SizedBox(height: 12),
              Text('Linked matters', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              matters.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(title: 'No linked matters', icon: Icons.folder_off_outlined);
                  }
                  return Column(
                    children: [
                      for (final matter in items)
                        Card(
                          child: ListTile(
                            title: Text(matter.matterName),
                            subtitle: Text(matter.matterNumber),
                            onTap: () => context.push('/matters/${matter.id}'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
