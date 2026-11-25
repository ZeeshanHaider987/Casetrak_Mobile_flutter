import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lookups/lookup_keys.dart';
import '../../../core/lookups/lookup_providers.dart';
import '../../../core/widgets/case_trak_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/lookup_dropdown.dart';
import '../../../core/widgets/pager.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../data/models/matter.dart';
import 'matter_providers.dart';

class MattersListScreen extends ConsumerStatefulWidget {
  const MattersListScreen({super.key});

  @override
  ConsumerState<MattersListScreen> createState() => _MattersListScreenState();
}

class _MattersListScreenState extends ConsumerState<MattersListScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final controller = ref.read(mattersControllerProvider.notifier);
    final current = controller.query;
    final selected = await showModalBottomSheet<_MatterFilters>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        practicesArea: current.practicesArea,
        caseStatusType: current.caseStatusType,
      ),
    );
    if (selected == null) return;
    await controller.setFilters(
      practicesArea: selected.practicesArea,
      caseStatusType: selected.caseStatusType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final matters = ref.watch(mattersControllerProvider);
    final query = ref.watch(mattersControllerProvider.notifier).query;
    final manager = ref.watch(lookupManagerProvider);
    final filtersOn = query.practicesArea != null || query.caseStatusType != null;

    return Scaffold(
      appBar: CaseTrakAppBar(
        title: 'Matters',
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: filtersOn,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search matters',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  ref.read(mattersControllerProvider.notifier).setSearch(value);
                });
              },
            ),
          ),
          Expanded(
            child: matters.when(
              loading: () => const SkeletonList(),
              error: (error, _) => ErrorRetry(
                message: error.toString(),
                onRetry: () => ref.read(mattersControllerProvider.notifier).refresh(),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return const EmptyState(
                    title: 'No matters',
                    message: 'Try a different search or filter.',
                    icon: Icons.folder_off_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(mattersControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: page.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final matter = page.items[index];
                      return _MatterTile(
                        matter: matter,
                        area: lookupLabel(manager, LookupKeys.practicesArea, matter.practicesArea),
                        status: lookupLabel(manager, LookupKeys.caseStatusType, matter.caseStatusType),
                        onTap: () => context.push('/matters/${matter.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          matters.maybeWhen(
            data: (page) => Pager(
              page: page.page,
              pageCount: page.pageCount,
              totalCount: page.totalCount,
              onPage: (page) => ref.read(mattersControllerProvider.notifier).setPage(page),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MatterTile extends StatelessWidget {
  const _MatterTile({
    required this.matter,
    required this.area,
    required this.status,
    required this.onTap,
  });

  final Matter matter;
  final String area;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(matter.matterName),
        subtitle: Text('${matter.matterNumber} · $area'),
        trailing: _StatusBadge(label: status),
        onTap: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _MatterFilters {
  const _MatterFilters({this.practicesArea, this.caseStatusType});

  final String? practicesArea;
  final String? caseStatusType;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({this.practicesArea, this.caseStatusType});

  final String? practicesArea;
  final String? caseStatusType;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _area;
  String? _status;

  @override
  void initState() {
    super.initState();
    _area = widget.practicesArea;
    _status = widget.caseStatusType;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter matters', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LookupDropdown(
            lookupKey: LookupKeys.practicesArea,
            label: 'Practice area',
            value: _area,
            onChanged: (value) => setState(() => _area = value),
          ),
          const SizedBox(height: 12),
          LookupDropdown(
            lookupKey: LookupKeys.caseStatusType,
            label: 'Status',
            value: _status,
            onChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _MatterFilters(practicesArea: _area, caseStatusType: _status),
            ),
            child: const Text('Apply'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, const _MatterFilters()),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
