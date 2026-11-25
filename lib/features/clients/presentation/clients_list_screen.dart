import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/case_trak_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pager.dart';
import '../../../core/widgets/skeleton_list.dart';
import 'client_providers.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientListProvider);
    final query = ref.read(clientListProvider.notifier).query;
    final types = ref.watch(lookupManagerProvider).get(LookupKeys.clientType);

    return Scaffold(
      appBar: const CaseTrakAppBar(title: 'Clients'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Create client'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search clients',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref.read(clientListProvider.notifier).setSearch(value);
                });
              },
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: query.clientType == null,
                    onSelected: (_) => ref.read(clientListProvider.notifier).setType(null),
                  ),
                ),
                for (final type in types)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: query.clientType == type.label,
                      onSelected: (_) => ref.read(clientListProvider.notifier).setType(
                            query.clientType == type.label ? null : type.label,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: clients.when(
              loading: () => const SkeletonList(),
              error: (error, _) => ErrorRetry(
                message: error.toString(),
                onRetry: () => ref.read(clientListProvider.notifier).refresh(),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return const EmptyState(title: 'No clients', icon: Icons.people_outline);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final client = page.items[index];
                    return Card(
                      child: ListTile(
                        title: Text(client.displayName),
                        subtitle: Text(client.email ?? ''),
                        trailing: _TypeBadge(label: client.clientType),
                        onTap: () => context.push('/clients/${client.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          clients.maybeWhen(
            data: (page) => Pager(
              page: page.page,
              pageCount: page.pageCount,
              totalCount: page.totalCount,
              onPage: (next) => ref.read(clientListProvider.notifier).setPage(next),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
